using System.Collections.Concurrent;
using System.Net.WebSockets;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using Motores.IO.server.API.DTOs;

namespace Motores.IO.server.API.Services;

public class WebSocketHub : IWebSocketHub
{
    private readonly ILogger<WebSocketHub> _logger;
    private readonly ConcurrentDictionary<string, WebSocketConnection> _connections = new();
    private readonly object _lock = new();

    public WebSocketHub(ILogger<WebSocketHub> logger)
    {
        _logger = logger;
    }

    public async Task BroadcastCorrentesAsync(CorrentesArrayDto correntes, string? plantaId = null)
    {
        if (correntes?.Motores == null || correntes.Motores.Count == 0)
            return;
        
        var json = JsonSerializer.Serialize(correntes);
        var bytes = Encoding.UTF8.GetBytes(json);

        var connectionsToRemove = new List<string>();
        var sentCount = 0;

        foreach (var kvp in _connections)
        {
            var connection = kvp.Value;
            
            // Filtrar por plantaId se especificado
            if (!string.IsNullOrEmpty(plantaId) && connection.PlantaId != plantaId)
            {
                continue; // Pular conexões de outras plantas
            }
            
            if (connection.WebSocket.State == WebSocketState.Open)
            {
                try
                {
                    await connection.WebSocket.SendAsync(
                        new ArraySegment<byte>(bytes),
                        WebSocketMessageType.Text,
                        true,
                        CancellationToken.None);
                    
                    sentCount++;
                    _logger.LogDebug("Correntes enviadas para conexão {ConnectionId} (planta: {PlantaId})", 
                        kvp.Key, connection.PlantaId);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Erro ao enviar para conexão {ConnectionId}", kvp.Key);
                    connectionsToRemove.Add(kvp.Key);
                }
            }
            else
            {
                connectionsToRemove.Add(kvp.Key);
            }
        }

        // Remover conexões fechadas
        foreach (var connectionId in connectionsToRemove)
        {
            _connections.TryRemove(connectionId, out _);
        }

        _logger.LogInformation("Correntes retransmitidas para {Count} conexões WebSocket (planta: {PlantaId})", 
            sentCount, plantaId ?? "todas");
    }

    public async Task BroadcastConsoleAsync(ConsoleMessageDto consoleMessage, string? plantaId = null)
    {
        if (consoleMessage == null || string.IsNullOrEmpty(consoleMessage.Mensagem))
            return;
        
        var json = JsonSerializer.Serialize(consoleMessage);
        var bytes = Encoding.UTF8.GetBytes(json);

        var connectionsToRemove = new List<string>();
        var sentCount = 0;

        // Usar plantaId da mensagem se disponível, senão usar o parâmetro
        var messagePlantaId = consoleMessage.PlantaId ?? plantaId;

        foreach (var kvp in _connections)
        {
            var connection = kvp.Value;
            
            // Filtrar por plantaId se especificado
            // Se connection.PlantaId for "all", sempre enviar (recebe de todas as plantas)
            // Se messagePlantaId for especificado, enviar apenas para conexões com mesmo plantaId ou "all"
            if (!string.IsNullOrEmpty(messagePlantaId))
            {
                // Se a conexão não é "all" e não é a planta da mensagem, pular
                if (connection.PlantaId != "all" && connection.PlantaId != messagePlantaId)
                {
                    continue; // Pular conexões de outras plantas
                }
            }
            
            // Verificar se é conexão de console (tipo "console") ou conexão geral
            // Por enquanto, enviar para todas as conexões WebSocket
            // No futuro, podemos adicionar um campo ConnectionType para diferenciar
            
            if (connection.WebSocket.State == WebSocketState.Open)
            {
                try
                {
                    await connection.WebSocket.SendAsync(
                        new ArraySegment<byte>(bytes),
                        WebSocketMessageType.Text,
                        true,
                        CancellationToken.None);
                    
                    sentCount++;
                    _logger.LogDebug("Mensagem de console enviada para conexão {ConnectionId} (planta: {PlantaId})", 
                        kvp.Key, connection.PlantaId);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Erro ao enviar mensagem de console para conexão {ConnectionId}", kvp.Key);
                    connectionsToRemove.Add(kvp.Key);
                }
            }
            else
            {
                connectionsToRemove.Add(kvp.Key);
            }
        }

        // Remover conexões fechadas
        foreach (var connectionId in connectionsToRemove)
        {
            _connections.TryRemove(connectionId, out _);
        }

        _logger.LogInformation("Mensagem de console retransmitida para {Count} conexões WebSocket (planta: {PlantaId})", 
            sentCount, plantaId ?? "todas");
    }

    public Task AddConnectionAsync(string connectionId, string plantaId)
    {
        // Esta função será chamada quando uma nova conexão WebSocket for estabelecida
        // O WebSocketConnection será criado no endpoint
        return Task.CompletedTask;
    }

    public void AddConnection(string connectionId, WebSocket webSocket, string plantaId)
    {
        _connections.TryAdd(connectionId, new WebSocketConnection
        {
            WebSocket = webSocket,
            PlantaId = plantaId,
            ConnectedAt = DateTime.UtcNow
        });
        _logger.LogInformation("Conexão WebSocket adicionada: {ConnectionId} para planta {PlantaId}", 
            connectionId, plantaId);
    }

    public Task RemoveConnectionAsync(string connectionId)
    {
        if (_connections.TryRemove(connectionId, out var connection))
        {
            _logger.LogInformation("Conexão WebSocket removida: {ConnectionId}", connectionId);
        }
        return Task.CompletedTask;
    }

    public int GetConnectionCount()
    {
        return _connections.Count;
    }
}

public class WebSocketConnection
{
    public WebSocket WebSocket { get; set; } = null!;
    public string PlantaId { get; set; } = string.Empty;
    public DateTime ConnectedAt { get; set; }
}
