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

            // Aceitar conexões em loop
            while (!cancellationToken.IsCancellationRequested)
            {
                try
                {
                    var tcpClient = await _tcpListener.AcceptTcpClientAsync();
                    _logger.LogInformation("Nova conexão estabelecida de {RemoteEndPoint}", 
                        tcpClient.Client.RemoteEndPoint);

                    // Adicionar cliente à lista
                    lock (_clientsLock)
                    {
                        _connectedClients.Add(tcpClient);
                    }
                    
                    // Aguardar mensagem de identificação da planta (timeout de 5 segundos)
                    _ = Task.Run(async () =>
                    {
                        try
                        {
                            await Task.Delay(5000, cancellationToken); // Aguardar 5 segundos
                            // Se não recebeu identificação, remover da lista após timeout
                            // (será tratado no HandleClientAsync quando desconectar)
                        }
                        catch { }
                    }, cancellationToken);

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
            // Configurar timeout
            client.ReceiveTimeout = 30000; // 30 segundos
            client.SendTimeout = 5000; // 5 segundos

            while (!cancellationToken.IsCancellationRequested && client.Connected)
            {
                try
                {
                    var bytesRead = await stream.ReadAsync(buffer, 0, buffer.Length, cancellationToken);
                    
                    if (bytesRead == 0)
                    {
                        // Cliente desconectou
                        break;
                    }

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
                        lock (_clientsLock)
                        {
                            _plantaClients[plantaId] = client;
                            _logger.LogInformation("Cliente identificado como planta: {PlantaId}", plantaId);
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
                try
                {
                    var correntesDto = JsonSerializer.Deserialize<CorrentesArrayDto>(message, new JsonSerializerOptions
                    {
                        PropertyNameCaseInsensitive = true
                    });

                    if (correntesDto?.Motores != null && correntesDto.Motores.Count > 0)
                    {
                        await ProcessCorrentesArrayAsync(correntesDto, cancellationToken);
                        await SendResponseAsync(client, "OK\n");
                    }
                    else
                    {
                        await SendResponseAsync(client, "ERROR: Array vazio\n");
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Erro ao processar array de correntes");
                    await SendResponseAsync(client, "ERROR: Erro ao processar\n");
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

            // Atualizar dados do motor
            var hasChanges = false;

            if (message.CorrenteAtual.HasValue)
            {
                // Aqui você pode processar a corrente atual se necessário
                // Por exemplo, verificar se está acima do limite e atualizar status
            }

            if (!string.IsNullOrEmpty(message.Status))
            {
                motor.Status = message.Status;
                hasChanges = true;
            }

            if (message.Horimetro.HasValue)
            {
                motor.Horimetro = message.Horimetro.Value;
                hasChanges = true;
            }

            if (hasChanges)
            {
                motor.DataAtualizacao = DateTime.UtcNow;
                await dbContext.SaveChangesAsync(cancellationToken);
                // Removido log para evitar poluição (mais de 20 por segundo)
            }

            // Criar registro de histórico
            // IMPORTANTE: PostgreSQL requer DateTime com Kind=UTC
            DateTime timestampUtc;
            if (message.Timestamp.HasValue)
            {
                // Converter timestamp Unix para DateTime UTC
                timestampUtc = DateTimeOffset.FromUnixTimeSeconds(message.Timestamp.Value).UtcDateTime;
            }
            else
            {
                // Usar DateTime.UtcNow que já retorna UTC
                timestampUtc = DateTime.UtcNow;
            }

            var historico = new HistoricoMotor
            {
                MotorId = motorId,
                Corrente = message.CorrenteAtual ?? motor.CorrenteNominal,
                Tensao = motor.Tensao, // Usar tensão do motor
                Temperatura = 0, // Valor padrão, pode ser ajustado se necessário
                Status = message.Status ?? motor.Status,
                Timestamp = timestampUtc // Garantir que seja UTC
            };

            dbContext.HistoricosMotores.Add(historico);
            await dbContext.SaveChangesAsync(cancellationToken);

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

            // Converter timestamp Unix para DateTime UTC
            DateTime timestampUtc;
            if (message.Timestamp.HasValue)
            {
                timestampUtc = DateTimeOffset.FromUnixTimeSeconds(message.Timestamp.Value).UtcDateTime;
            }
            else
            {
                timestampUtc = DateTime.UtcNow;
            }

            // Criar registro de histórico com todos os campos
            var historico = new HistoricoMotor
            {
                MotorId = motorId,
                Corrente = message.CorrenteAtual ?? motor.CorrenteNominal, // Corrente instantânea
                CorrenteMedia = message.CorrenteMedia,
                CorrenteMaxima = message.CorrenteMaxima,
                CorrenteMinima = message.CorrenteMinima,
                Tensao = motor.Tensao, // Usar tensão do motor
                Temperatura = 0, // Valor padrão
                Status = message.Status ?? motor.Status,
                Timestamp = timestampUtc
            };

            dbContext.HistoricosMotores.Add(historico);
            await dbContext.SaveChangesAsync(cancellationToken);

            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao processar histórico do motor {Id}", message.Id);
            return false;
        }
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
}