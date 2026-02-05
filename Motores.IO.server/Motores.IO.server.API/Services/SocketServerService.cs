using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;
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
    private readonly object _clientsLock = new();
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
            _logger.LogInformation("Socket Server iniciado na porta {Port}", _port);

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
            // Remover cliente da lista
            lock (_clientsLock)
            {
                _connectedClients.Remove(client);
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

        _logger.LogInformation("=== MENSAGEM RECEBIDA ===");
        _logger.LogInformation("Conteúdo: {Message}", message);
        _logger.LogInformation("Tamanho: {Length} bytes", message.Length);

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

        // Tentar processar como JSON
        try
        {
            _logger.LogInformation("Tentando deserializar JSON...");
            var socketMessage = JsonSerializer.Deserialize<SocketMessageDto>(message, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });

            if (socketMessage == null)
            {
                _logger.LogWarning("Mensagem JSON inválida ou nula: {Message}", message);
                await SendResponseAsync(client, "ERROR: JSON inválido\n");
                return;
            }

            _logger.LogInformation("JSON deserializado com sucesso:");
            _logger.LogInformation("  Tipo: {Tipo}", socketMessage.Tipo);
            _logger.LogInformation("  ID: {Id}", socketMessage.Id);
            _logger.LogInformation("  Nome: {Nome}", socketMessage.Nome);
            _logger.LogInformation("  Status: {Status}", socketMessage.Status);
            _logger.LogInformation("  Corrente Atual: {CorrenteAtual}", socketMessage.CorrenteAtual);
            _logger.LogInformation("  Horímetro: {Horimetro}", socketMessage.Horimetro);

            // Processar mensagem de motor
            if (socketMessage.Tipo == "motor" && !string.IsNullOrEmpty(socketMessage.Id))
            {
                _logger.LogInformation("Processando dados do motor ID: {Id}", socketMessage.Id);
                var success = await ProcessMotorDataAsync(socketMessage, cancellationToken);
                // Enviar confirmação de recebimento
                if (success)
                {
                    _logger.LogInformation("✓ Motor processado com sucesso, enviando OK");
                    await SendResponseAsync(client, "OK\n");
                }
                else
                {
                    _logger.LogWarning("✗ Erro ao processar motor, enviando ERROR");
                    await SendResponseAsync(client, "ERROR\n");
                }
            }
            // Processar mensagem de array de correntes
            else if (socketMessage.Tipo == "correntes")
            {
                _logger.LogInformation("Processando array de correntes");
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
                        _logger.LogWarning("Array de correntes vazio ou inválido");
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
        _logger.LogInformation("Processando array de {Count} correntes", correntesDto.Motores?.Count ?? 0);
        
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
        // Passar null como plantaId para enviar para TODAS as conexões (igual correntes)
        // Isso garante que o console receba mensagens independente do plantaId da conexão
        var webSocketHub = _serviceProvider.GetService<IWebSocketHub>();
        if (webSocketHub != null)
        {
            _logger.LogInformation("Retransmitindo mensagem de console para TODAS as conexões (sem filtro de plantaId)");
            await webSocketHub.BroadcastConsoleAsync(consoleMessage, null);
        }
    }

    private async Task<bool> ProcessMotorDataAsync(SocketMessageDto message, CancellationToken cancellationToken)
    {
        try
        {
            using var scope = _serviceProvider.CreateScope();
            var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

            // Tentar converter ID para Guid
            _logger.LogInformation("Tentando converter ID '{Id}' para GUID...", message.Id);
            if (!Guid.TryParse(message.Id, out var motorId))
            {
                _logger.LogWarning("✗ ID de motor inválido (não é um GUID válido): {Id}", message.Id);
                return false;
            }
            _logger.LogInformation("✓ ID convertido para GUID: {MotorId}", motorId);

            // Buscar motor no banco
            _logger.LogInformation("Buscando motor no banco de dados...");
            var motor = await dbContext.Motores.FindAsync(new object[] { motorId }, cancellationToken);

            if (motor == null)
            {
                _logger.LogWarning("✗ Motor não encontrado no banco de dados com ID: {Id} (GUID: {MotorId})", 
                    message.Id, motorId);
                _logger.LogWarning("Verifique se o motor foi cadastrado na API com este GUID");
                return false;
            }
            _logger.LogInformation("✓ Motor encontrado: {Nome} (ID: {Id})", motor.Nome, motorId);

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

                _logger.LogInformation("Motor {Id} atualizado via socket: Status={Status}, Horimetro={Horimetro}",
                    motorId, message.Status, message.Horimetro);
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

    public override void Dispose()
    {
        StopAsync(CancellationToken.None).Wait();
        _tcpListener?.Stop();
        base.Dispose();
    }
}