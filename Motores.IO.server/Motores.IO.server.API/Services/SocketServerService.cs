using System.Collections.Concurrent;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Motores.IO.server.API.Data;
using Motores.IO.server.API.DTOs;
using Motores.IO.server.API.Models;

namespace Motores.IO.server.API.Services;

public class SocketServerService : BackgroundService, ISocketServerService
{
    private readonly ILogger<SocketServerService> _logger;
    private readonly IConfiguration _configuration;
    private readonly IServiceProvider _serviceProvider;
    private TcpListener? _tcpListener;
    private readonly List<TcpClient> _connectedClients = new();
    private readonly Dictionary<string, TcpClient> _plantaClients = new(); // Mapeia plantaId -> TcpClient
    private readonly Dictionary<string, TaskCompletionSource<FileCommandResponseDto>> _pendingCommands = new(); // Mapeia requestId -> TaskCompletionSource
    private readonly object _clientsLock = new();
    private readonly object _commandsLock = new();
    // Última atividade útil por cliente. O idle scanner usa isso para fechar zumbis
    // que escapam do TCP keepalive e do timeout do ReadAsync.
    private readonly ConcurrentDictionary<TcpClient, DateTime> _lastActivityUtc = new();
    private static readonly TimeSpan IdleLimit = TimeSpan.FromSeconds(120);
    private static readonly TimeSpan IdleScanInterval = TimeSpan.FromSeconds(30);
    // Timeout por leitura individual no ReadAsync. ReceiveTimeout do TcpClient é
    // ignorado pelo ReadAsync no .NET 8 — precisa ser via CancellationToken.
    private static readonly TimeSpan ReadTimeout = TimeSpan.FromSeconds(60);
    private int _port;

    public SocketServerService(
        ILogger<SocketServerService> logger,
        IConfiguration configuration,
        IServiceProvider serviceProvider)
    {
        _logger = logger;
        _configuration = configuration;
        _serviceProvider = serviceProvider;
        _port = _configuration.GetValue<int>("SocketServer:Port", 5055);
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        await StartAsync(stoppingToken);
    }

    public async Task StartAsync(CancellationToken cancellationToken)
    {
        try
        {
            _tcpListener = new TcpListener(IPAddress.Any, _port);
            _tcpListener.Start();
            _logger.LogInformation("=== SOCKET SERVER INICIADO ===");
            _logger.LogInformation("Porta: {Port}", _port);
            _logger.LogInformation("Endereço: {Address} (aceita conexões de qualquer interface)", IPAddress.Any);
            _logger.LogInformation("Aguardando conexões TCP na porta {Port}...", _port);

            // Idle scanner (E): roda em paralelo varrendo _lastActivityUtc e fechando zumbis.
            _ = Task.Run(() => IdleScannerAsync(cancellationToken), cancellationToken);

            // Aceitar conexões em loop
            while (!cancellationToken.IsCancellationRequested)
            {
                try
                {
                    var tcpClient = await _tcpListener.AcceptTcpClientAsync();
                    _logger.LogInformation("Nova conexão estabelecida de {RemoteEndPoint}",
                        tcpClient.Client.RemoteEndPoint);

                    // (A) Habilita TCP keepalive nativo no socket recém-aceito.
                    // Garante detecção de IHM desaparecida (sem RST) em ~90s, mesmo com
                    // os defaults péssimos do kernel (tcp_keepalive_time=7200s).
                    TryEnableTcpKeepAlive(tcpClient);

                    // Adicionar cliente à lista e marcar atividade inicial.
                    lock (_clientsLock)
                    {
                        _connectedClients.Add(tcpClient);
                    }
                    _lastActivityUtc[tcpClient] = DateTime.UtcNow;

                    // Processar cliente em thread separada
                    _ = Task.Run(() => HandleClientAsync(tcpClient, cancellationToken), cancellationToken);
                }
                catch (ObjectDisposedException)
                {
                    // Listener foi fechado, sair do loop
                    break;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Erro ao aceitar conexão");
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao iniciar Socket Server");
        }
    }

    private async Task HandleClientAsync(TcpClient client, CancellationToken cancellationToken)
    {
        var remoteEndPoint = client.Client.RemoteEndPoint?.ToString() ?? "Desconhecido";
        var stream = client.GetStream();
        var buffer = new byte[4096];
        var messageBuilder = new StringBuilder();

        try
        {
            // SendTimeout do TcpClient ainda vale para o WriteAsync síncrono interno.
            client.SendTimeout = 5000; // 5 segundos

            while (!cancellationToken.IsCancellationRequested && client.Connected)
            {
                try
                {
                    // (D) ReceiveTimeout não funciona com ReadAsync no .NET 8.
                    // Usar CancellationTokenSource linkado e CancelAfter por leitura.
                    int bytesRead;
                    using (var readCts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken))
                    {
                        readCts.CancelAfter(ReadTimeout);
                        try
                        {
                            bytesRead = await stream.ReadAsync(buffer.AsMemory(0, buffer.Length), readCts.Token);
                        }
                        catch (OperationCanceledException) when (!cancellationToken.IsCancellationRequested)
                        {
                            _logger.LogWarning("Cliente {RemoteEndPoint} sem dados há {Timeout}s — fechando",
                                remoteEndPoint, (int)ReadTimeout.TotalSeconds);
                            break;
                        }
                    }

                    if (bytesRead == 0)
                    {
                        // Cliente desconectou
                        break;
                    }

                    _lastActivityUtc[client] = DateTime.UtcNow;

                    // Adicionar dados recebidos ao builder
                    messageBuilder.Append(Encoding.UTF8.GetString(buffer, 0, bytesRead));

                    // Processar mensagens completas (terminadas com \n)
                    var message = messageBuilder.ToString();
                    var lines = message.Split('\n');

                    // Processar todas as linhas completas (exceto a última que pode estar incompleta)
                    messageBuilder.Clear();
                    for (int i = 0; i < lines.Length; i++)
                    {
                        if (i == lines.Length - 1)
                        {
                            // Última linha: se a mensagem não termina com \n, está incompleta
                            if (!message.EndsWith('\n'))
                            {
                                // Manter no builder para próxima leitura
                                messageBuilder.Append(lines[i]);
                            }
                            else if (!string.IsNullOrWhiteSpace(lines[i]))
                            {
                                // Linha completa, processar
                                await ProcessMessageAsync(lines[i], client, cancellationToken);
                            }
                        }
                        else
                        {
                            // Linha completa, processar
                            if (!string.IsNullOrWhiteSpace(lines[i]))
                            {
                                await ProcessMessageAsync(lines[i], client, cancellationToken);
                            }
                        }
                    }
                }
                catch (IOException ex)
                {
                    _logger.LogWarning("Cliente {RemoteEndPoint} desconectou: {Error}", 
                        remoteEndPoint, ex.Message);
                    break;
                }
                catch (SocketException ex)
                {
                    _logger.LogWarning("Erro de socket com cliente {RemoteEndPoint}: {Error}", 
                        remoteEndPoint, ex.Message);
                    break;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Erro ao processar mensagem do cliente {RemoteEndPoint}", 
                        remoteEndPoint);
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao processar cliente {RemoteEndPoint}", remoteEndPoint);
        }
        finally
        {
            // Remover cliente da lista e limpar comandos pendentes
            lock (_clientsLock)
            {
                _connectedClients.Remove(client);

                // Remover cliente do mapeamento de plantas
                var plantasParaRemover = _plantaClients
                    .Where(kvp => kvp.Value == client)
                    .Select(kvp => kvp.Key)
                    .ToList();

                foreach (var plantaId in plantasParaRemover)
                {
                    _plantaClients.Remove(plantaId);
                }
            }

            _lastActivityUtc.TryRemove(client, out _);
            
            // Cancelar comandos pendentes deste cliente
            lock (_commandsLock)
            {
                var commandsToCancel = _pendingCommands
                    .Where(kvp => !kvp.Value.Task.IsCompleted)
                    .ToList();
                
                foreach (var kvp in commandsToCancel)
                {
                    kvp.Value.SetResult(new FileCommandResponseDto
                    {
                        Sucesso = false,
                        Erro = "Cliente desconectado",
                        Acao = "",
                        RequestId = kvp.Key
                    });
                    _pendingCommands.Remove(kvp.Key);
                }
            }

            // Fechar conexão
            try
            {
                client.Close();
                _logger.LogInformation("Conexão com {RemoteEndPoint} fechada", remoteEndPoint);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Erro ao fechar conexão com {RemoteEndPoint}", remoteEndPoint);
            }
        }
    }

    private async Task ProcessMessageAsync(string message, TcpClient client, CancellationToken cancellationToken)
    {
        message = message.Trim();
        
        if (string.IsNullOrEmpty(message))
            return;

        // Log apenas para mensagens importantes (evitar poluição com atualizações de motores)
        var isImportantMessage = message == "PING" || message == "KEEPALIVE" || 
                                 message.Contains("\"acao\"") || message.Contains("\"tipo\":\"identificacao\"");
        
        if (isImportantMessage)
        {
            _logger.LogDebug("Mensagem recebida: {Message}", message);
        }

        // Processar comandos especiais
        if (message == "PING")
        {
            _logger.LogInformation("Comando PING recebido, enviando PONG");
            await SendResponseAsync(client, "PONG\n");
            return;
        }

        if (message == "KEEPALIVE")
        {
            _logger.LogInformation("Comando KEEPALIVE recebido, enviando OK");
            await SendResponseAsync(client, "OK\n");
            return;
        }

            // Verificar se é mensagem de identificação de planta
            try
            {
                var identMessage = JsonSerializer.Deserialize<Dictionary<string, JsonElement>>(message, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });
                
                if (identMessage != null && identMessage.ContainsKey("tipo") &&
                    identMessage["tipo"].GetString() == "identificacao" &&
                    identMessage.ContainsKey("plantaId"))
                {
                    var plantaId = identMessage["plantaId"].GetString();
                    if (!string.IsNullOrEmpty(plantaId))
                    {
                        // (B) Quando a IHM reabre a conexão sem fechar a anterior, o
                        // _plantaClients era sobrescrito mas o TcpClient antigo continuava
                        // vivo (zumbi) consumindo uma task de HandleClientAsync. Agora
                        // fechamos o anterior antes de substituir.
                        TcpClient? clienteAnterior = null;
                        lock (_clientsLock)
                        {
                            if (_plantaClients.TryGetValue(plantaId, out var existente) && !ReferenceEquals(existente, client))
                            {
                                clienteAnterior = existente;
                            }
                            _plantaClients[plantaId] = client;
                            _logger.LogInformation("Cliente identificado como planta: {PlantaId}", plantaId);
                        }

                        if (clienteAnterior != null)
                        {
                            try
                            {
                                _logger.LogInformation(
                                    "Fechando conexão anterior da planta {PlantaId}: {EP}",
                                    plantaId, clienteAnterior.Client.RemoteEndPoint);
                                clienteAnterior.Close();
                            }
                            catch (Exception ex)
                            {
                                _logger.LogDebug(ex, "Falha ao fechar conexão anterior da planta {PlantaId}", plantaId);
                            }
                        }

                        await SendResponseAsync(client, "OK\n");
                        return;
                    }
                }
            }
            catch
            {
                // Não é mensagem de identificação, continuar processamento normal
            }

            // Verificar se é resposta de comando de arquivo
            try
            {
                var fileResponse = JsonSerializer.Deserialize<FileCommandResponseDto>(message, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });

                if (fileResponse != null && !string.IsNullOrEmpty(fileResponse.RequestId))
                {
                    // É uma resposta de comando de arquivo
                    lock (_commandsLock)
                    {
                        if (_pendingCommands.TryGetValue(fileResponse.RequestId, out var tcs))
                        {
                            tcs.SetResult(fileResponse);
                            _pendingCommands.Remove(fileResponse.RequestId);
                            _logger.LogDebug("Resposta de comando de arquivo recebida: {RequestId}, Sucesso: {Sucesso}", 
                                fileResponse.RequestId, fileResponse.Sucesso);
                            return;
                        }
                    }
                }
            }
            catch
            {
                // Não é resposta de comando de arquivo, continuar
            }

            // Tentar processar como JSON (mensagens da IHM)
        try
        {
            var socketMessage = JsonSerializer.Deserialize<SocketMessageDto>(message, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });

            if (socketMessage == null)
            {
                // Tentar processar como comando de arquivo enviado pelo servidor (não deve acontecer aqui)
                _logger.LogWarning("Mensagem JSON inválida ou nula: {Message}", message);
                await SendResponseAsync(client, "ERROR: JSON inválido\n");
                return;
            }

            // Processar mensagem de histórico (sem logs excessivos)
            if (socketMessage.Tipo == "historico" && !string.IsNullOrEmpty(socketMessage.Id))
            {
                // Removido log para evitar poluição (mais de 20 por segundo)
                var success = await ProcessHistoricoMotorAsync(socketMessage, cancellationToken);
                // Enviar confirmação de recebimento
                if (success)
                {
                    await SendResponseAsync(client, "OK\n");
                }
                else
                {
                    await SendResponseAsync(client, "ERROR\n");
                }
            }
            // Processar mensagem de motor (sem logs excessivos)
            else if (socketMessage.Tipo == "motor" && !string.IsNullOrEmpty(socketMessage.Id))
            {
                // Removido log para evitar poluição (mais de 20 por segundo)
                var success = await ProcessMotorDataAsync(socketMessage, cancellationToken);
                // Enviar confirmação de recebimento
                if (success)
                {
                    await SendResponseAsync(client, "OK\n");
                }
                else
                {
                    await SendResponseAsync(client, "ERROR\n");
                }
            }
            // Processar mensagem de array de correntes (sem logs excessivos)
            else if (socketMessage.Tipo == "correntes")
            {
                // (C) 'correntes' é fire-and-forget. A IHM não lê resposta neste caminho
                // (EnviarCorrentesArray → EnviarMensagem, sem ReceberMensagem). Responder
                // OK só enche o buffer TCP da IHM (que nunca lê), gasta RTT e adia o
                // próximo ReadAsync no server enquanto o WriteAsync ainda não terminou.
                try
                {
                    var correntesDto = JsonSerializer.Deserialize<CorrentesArrayDto>(message, new JsonSerializerOptions
                    {
                        PropertyNameCaseInsensitive = true
                    });

                    if (correntesDto?.Motores != null && correntesDto.Motores.Count > 0)
                    {
                        await ProcessCorrentesArrayAsync(correntesDto, cancellationToken);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Erro ao processar array de correntes");
                }
            }
            // Processar mensagens de console (log, error, warn, info)
            else if (socketMessage.Tipo == "log" || socketMessage.Tipo == "error" || 
                     socketMessage.Tipo == "warn" || socketMessage.Tipo == "info")
            {
                _logger.LogInformation("Processando mensagem de console: {Tipo}", socketMessage.Tipo);
                try
                {
                    var consoleMessage = JsonSerializer.Deserialize<ConsoleMessageDto>(message, new JsonSerializerOptions
                    {
                        PropertyNameCaseInsensitive = true
                    });

                    if (consoleMessage != null && !string.IsNullOrEmpty(consoleMessage.Mensagem))
                    {
                        await ProcessConsoleMessageAsync(consoleMessage, cancellationToken);
                        await SendResponseAsync(client, "OK\n");
                    }
                    else
                    {
                        _logger.LogWarning("Mensagem de console vazia ou inválida");
                        await SendResponseAsync(client, "ERROR: Mensagem vazia\n");
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Erro ao processar mensagem de console");
                    await SendResponseAsync(client, "ERROR: Erro ao processar\n");
                }
            }
            else
            {
                _logger.LogWarning("Tipo de mensagem desconhecido ou ID vazio. Tipo: {Tipo}, ID: {Id}", 
                    socketMessage.Tipo, socketMessage.Id);
                await SendResponseAsync(client, "ERROR: Tipo desconhecido ou ID vazio\n");
            }
        }
        catch (JsonException ex)
        {
            _logger.LogError(ex, "Erro ao deserializar JSON: {Message}", message);
            await SendResponseAsync(client, "ERROR: JSON inválido\n");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao processar mensagem: {Message}", message);
        }
    }

    private async Task ProcessCorrentesArrayAsync(CorrentesArrayDto correntesDto, CancellationToken cancellationToken)
    {
        // Removido log para evitar poluição (mais de 20 por segundo)
        
        if (correntesDto.Motores == null || correntesDto.Motores.Count == 0)
            return;
        
        // Retransmitir via WebSocket hub diretamente usando plantaId da mensagem
        // Sem buscar no banco - apenas retransmitir para clientes conectados
        var webSocketHub = _serviceProvider.GetService<IWebSocketHub>();
        if (webSocketHub != null && !string.IsNullOrEmpty(correntesDto.PlantaId))
        {
            _logger.LogDebug("Retransmitindo correntes para planta {PlantaId}", correntesDto.PlantaId);
            await webSocketHub.BroadcastCorrentesAsync(correntesDto, correntesDto.PlantaId);
        }
        else if (webSocketHub != null)
        {
            _logger.LogWarning("PlantaId não fornecido, retransmitindo para todas as conexões");
            await webSocketHub.BroadcastCorrentesAsync(correntesDto, null);
        }
    }

    private async Task ProcessConsoleMessageAsync(ConsoleMessageDto consoleMessage, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Processando mensagem de console: {Tipo} - {Mensagem}", 
            consoleMessage.Tipo, consoleMessage.Mensagem);
        
        if (string.IsNullOrEmpty(consoleMessage.Mensagem))
            return;
        
        // Retransmitir via WebSocket hub
        // Usar plantaId da mensagem para filtrar conexões de console
        // Conexões com plantaId="all" recebem de todas as plantas
        var webSocketHub = _serviceProvider.GetService<IWebSocketHub>();
        if (webSocketHub != null)
        {
            var messagePlantaId = consoleMessage.PlantaId;
            _logger.LogInformation("Retransmitindo mensagem de console para planta: {PlantaId}", messagePlantaId ?? "todas");
            await webSocketHub.BroadcastConsoleAsync(consoleMessage, messagePlantaId);
        }
    }

    private async Task<bool> ProcessMotorDataAsync(SocketMessageDto message, CancellationToken cancellationToken)
    {
        try
        {
            using var scope = _serviceProvider.CreateScope();
            var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

            // Tentar converter ID para Guid (sem logs excessivos)
            if (!Guid.TryParse(message.Id, out var motorId))
            {
                _logger.LogWarning("ID de motor inválido: {Id}", message.Id);
                return false;
            }

            // Buscar motor no banco (sem logs excessivos)
            var motor = await dbContext.Motores.FindAsync(new object[] { motorId }, cancellationToken);

            if (motor == null)
            {
                _logger.LogWarning("Motor não encontrado: {Id}", motorId);
                return false;
            }

            // Mensagem `tipo:"motor"` é o caminho legado (1 motor por msg). Apenas
            // grava ponto histórico no Influx; status e horímetro NÃO vêm da IHM.
            // (Horímetro inline vive em ProcessHistoricoMotorAsync, que usa correnteMedia.)
            DateTime timestampUtc;
            if (message.Timestamp.HasValue)
            {
                timestampUtc = DateTimeOffset.FromUnixTimeSeconds(message.Timestamp.Value).UtcDateTime;
            }
            else
            {
                timestampUtc = DateTime.UtcNow;
            }

            var historico = new HistoricoMotor
            {
                MotorId = motorId,
                Corrente = message.CorrenteAtual ?? motor.CorrenteNominal,
                Tensao = motor.Tensao,
                Temperatura = 0,
                Status = string.Empty,
                Timestamp = timestampUtc,
                Horimetro = motor.Horimetro
            };

            var influxService = _serviceProvider.GetRequiredService<InfluxDbService>();
            await influxService.WriteHistoricoAsync(historico);

            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao processar dados do motor {Id}", message.Id);
            return false;
        }
    }

    private async Task<bool> ProcessHistoricoMotorAsync(SocketMessageDto message, CancellationToken cancellationToken)
    {
        try
        {
            using var scope = _serviceProvider.CreateScope();
            var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

            // Tentar converter ID para Guid
            if (!Guid.TryParse(message.Id, out var motorId))
            {
                _logger.LogWarning("ID de motor inválido para histórico: {Id}", message.Id);
                return false;
            }

            // Buscar motor no banco
            var motor = await dbContext.Motores.FindAsync(new object[] { motorId }, cancellationToken);

            if (motor == null)
            {
                _logger.LogWarning("Motor não encontrado para histórico: {Id}", motorId);
                return false;
            }

            // CRÍTICO: histórico DEVE vir com timestamp da medição (não do envio).
            // A IHM acumula consolidados numa fila local quando a internet cai e os
            // reenvia depois — se gravarmos com DateTime.UtcNow, o ponto fica no
            // tempo errado no Influx. Rejeitar pra forçar a IHM a corrigir e log
            // warning para diagnóstico.
            if (!message.Timestamp.HasValue)
            {
                _logger.LogWarning("Histórico sem timestamp — REJEITADO. Motor={Id}", motorId);
                return false;
            }

            var timestampUtc = DateTimeOffset.FromUnixTimeSeconds(message.Timestamp.Value).UtcDateTime;

            // CORRENTE EM AMPERES — a IHM (ScriptNovo/MotorCurrentReader) já aplica a
            // aferição local (raw/100) antes de enviar. Threshold de 5.0 abaixo é 5 A.
            // Para o horímetro inline, usar a MÉDIA da janela (correnteMedia) é mais
            // representativo do que `correnteAtual` instantânea: cobre o minuto inteiro.
            var correnteParaHorimetro = (double)(message.CorrenteMedia ?? message.CorrenteAtual ?? 0);
            AtualizarHorimetroInline(motor, correnteParaHorimetro, timestampUtc);
            await dbContext.SaveChangesAsync(cancellationToken);

            var historico = new HistoricoMotor
            {
                MotorId = motorId,
                Corrente = message.CorrenteAtual ?? motor.CorrenteNominal,
                CorrenteMedia = message.CorrenteMedia,
                CorrenteMaxima = message.CorrenteMaxima,
                CorrenteMinima = message.CorrenteMinima,
                Tensao = motor.Tensao,
                Temperatura = 0,
                // Status é derivado na UI; campo segue no DTO por compatibilidade, mas
                // o Influx não tagga mais por status (ver InfluxDbService.WriteHistoricoAsync).
                Status = string.Empty,
                Timestamp = timestampUtc,
                Horimetro = motor.Horimetro
            };

            var influxService = _serviceProvider.GetRequiredService<InfluxDbService>();
            await influxService.WriteHistoricoAsync(historico);

            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao processar histórico do motor {Id}", message.Id);
            return false;
        }
    }

    // Acumula horímetro com a corrente JÁ EM AMPERES. 5.0 abaixo é 5 A — não confundir
    // com 0,05 A. O `maxGapSegundos = 600` evita somar um buraco de >10 min como se o
    // motor tivesse rodado nele.
    private static void AtualizarHorimetroInline(Models.Motor motor, double correnteAmperes, DateTime timestampUtc)
    {
        const double correnteLimiteAmperes = 5.0;
        const double maxGapSegundos = 600.0;

        if (motor.UltimoTimestampIntegrado.HasValue && correnteAmperes >= correnteLimiteAmperes)
        {
            var deltaSegundos = (timestampUtc - motor.UltimoTimestampIntegrado.Value).TotalSeconds;
            if (deltaSegundos > 0 && deltaSegundos < maxGapSegundos)
            {
                motor.HorimetroTs += deltaSegundos;
                motor.Horimetro = (decimal)Math.Round(motor.HorimetroTs / 3600.0, 2);
            }
        }

        motor.UltimoTimestampIntegrado = timestampUtc;
        motor.DataAtualizacao = DateTime.UtcNow;
    }

    private async Task SendResponseAsync(TcpClient client, string response)
    {
        try
        {
            if (!client.Connected)
                return;

            var stream = client.GetStream();
            var data = Encoding.UTF8.GetBytes(response);
            await stream.WriteAsync(data, 0, data.Length);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Erro ao enviar resposta ao cliente");
        }
    }

    public async Task StopAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Parando Socket Server...");

        // Fechar todas as conexões
        lock (_clientsLock)
        {
            foreach (var client in _connectedClients.ToList())
            {
                try
                {
                    client.Close();
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Erro ao fechar cliente");
                }
            }
            _connectedClients.Clear();
        }

        // Parar listener
        try
        {
            _tcpListener?.Stop();
            _logger.LogInformation("Socket Server parado");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao parar Socket Server");
        }

        await Task.CompletedTask;
    }

    public int GetConnectedClientsCount()
    {
        lock (_clientsLock)
        {
            return _connectedClients.Count(c => c.Connected);
        }
    }

    public async Task<FileCommandResponseDto?> SendCommandToPlantaAsync(string plantaId, FileCommandDto command, CancellationToken cancellationToken = default)
    {
        TcpClient? client = null;
        
        lock (_clientsLock)
        {
            if (_plantaClients.TryGetValue(plantaId, out var plantaClient) && plantaClient.Connected)
            {
                client = plantaClient;
            }
        }

        if (client == null)
        {
            _logger.LogWarning("Nenhum cliente conectado para planta {PlantaId}", plantaId);
            return new FileCommandResponseDto
            {
                Sucesso = false,
                Erro = "IHM não conectada",
                Acao = command.Acao,
                RequestId = command.RequestId
            };
        }

        try
        {
            // Criar TaskCompletionSource para aguardar resposta
            var tcs = new TaskCompletionSource<FileCommandResponseDto>();
            
            lock (_commandsLock)
            {
                _pendingCommands[command.RequestId] = tcs;
            }

            _logger.LogInformation("Enviando comando de arquivo para planta {PlantaId}: {Acao} (RequestId: {RequestId})", 
                plantaId, command.Acao, command.RequestId);

            // Enviar comando
            var commandJson = JsonSerializer.Serialize(command);
            _logger.LogDebug("Comando JSON: {CommandJson}", commandJson);
            await SendResponseAsync(client, commandJson + "\n");
            _logger.LogDebug("Comando enviado via socket para planta {PlantaId}", plantaId);

            // Aguardar resposta com timeout de 10 segundos
            using var timeoutCts = new CancellationTokenSource(TimeSpan.FromSeconds(10));
            using var linkedCts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken, timeoutCts.Token);

            try
            {
                var response = await tcs.Task.WaitAsync(linkedCts.Token);
                _logger.LogInformation("Resposta recebida para comando {RequestId}: Sucesso={Sucesso}", 
                    command.RequestId, response.Sucesso);
                return response;
            }
            catch (OperationCanceledException) when (timeoutCts.Token.IsCancellationRequested)
            {
                lock (_commandsLock)
                {
                    _pendingCommands.Remove(command.RequestId);
                }
                _logger.LogWarning("Timeout ao aguardar resposta do comando {RequestId}", command.RequestId);
                return new FileCommandResponseDto
                {
                    Sucesso = false,
                    Erro = "Timeout ao aguardar resposta",
                    Acao = command.Acao,
                    RequestId = command.RequestId
                };
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao enviar comando para planta {PlantaId}", plantaId);
            return new FileCommandResponseDto
            {
                Sucesso = false,
                Erro = ex.Message,
                Acao = command.Acao,
                RequestId = command.RequestId
            };
        }
    }

    public override void Dispose()
    {
        StopAsync(CancellationToken.None).Wait();
        _tcpListener?.Stop();
        base.Dispose();
    }

    // (A) Habilita TCP keepalive nativo do socket. Detecta IHM desaparecida (sem RST,
    // sem FIN — ex.: NAT expirado, link cortado bruscamente) em ~90s sem precisar de
    // tráfego da aplicação. As 3 opções TcpKeepAlive* são cross-platform a partir
    // do .NET 8 (no Linux mapeiam para TCP_KEEPIDLE/TCP_KEEPINTVL/TCP_KEEPCNT).
    private void TryEnableTcpKeepAlive(TcpClient tcpClient)
    {
        try
        {
            var socket = tcpClient.Client;
            socket.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.KeepAlive, true);
            socket.SetSocketOption(SocketOptionLevel.Tcp, SocketOptionName.TcpKeepAliveTime, 60);
            socket.SetSocketOption(SocketOptionLevel.Tcp, SocketOptionName.TcpKeepAliveInterval, 10);
            socket.SetSocketOption(SocketOptionLevel.Tcp, SocketOptionName.TcpKeepAliveRetryCount, 3);
        }
        catch (Exception ex)
        {
            _logger.LogDebug(ex, "Não foi possível habilitar TCP keepalive em {EP}",
                tcpClient.Client.RemoteEndPoint);
        }
    }

    // (E) Defesa em profundidade. TCP keepalive (A) e o timeout do ReadAsync (D) já
    // deveriam fechar zumbis, mas se algum deles falhar por qualquer motivo (ex.: o
    // socket está com Read pendurado num estado raro do TCP), o scanner pega.
    private async Task IdleScannerAsync(CancellationToken cancellationToken)
    {
        while (!cancellationToken.IsCancellationRequested)
        {
            try
            {
                await Task.Delay(IdleScanInterval, cancellationToken);

                var agora = DateTime.UtcNow;
                var zumbis = _lastActivityUtc
                    .Where(kvp => (agora - kvp.Value) > IdleLimit)
                    .Select(kvp => kvp.Key)
                    .ToList();

                foreach (var cliente in zumbis)
                {
                    try
                    {
                        var ep = cliente.Client?.RemoteEndPoint?.ToString() ?? "?";
                        _logger.LogWarning("[IdleScanner] Fechando conexão zumbi {EP} (idle > {Limit}s)",
                            ep, (int)IdleLimit.TotalSeconds);
                        cliente.Close();
                    }
                    catch (Exception ex)
                    {
                        _logger.LogDebug(ex, "[IdleScanner] Erro ao fechar zumbi");
                    }
                }
            }
            catch (OperationCanceledException)
            {
                break;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[IdleScanner] Erro no loop");
            }
        }
    }
}