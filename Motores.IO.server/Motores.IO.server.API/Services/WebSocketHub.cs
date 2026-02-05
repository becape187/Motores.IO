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
        _logger.LogInformation("=== BROADCAST CONSOLE INICIADO ===");
        _logger.LogInformation("Mensagem: {Mensagem}", consoleMessage?.Mensagem ?? "null");
        _logger.LogInformation("Tipo: {Tipo}", consoleMessage?.Tipo ?? "null");
        _logger.LogInformation("PlantaId (parâmetro): {PlantaId}", plantaId ?? "null");
        _logger.LogInformation("PlantaId (mensagem): {PlantaId}", consoleMessage?.PlantaId ?? "null");
        _logger.LogInformation("Total de conexões WebSocket: {Count}", _connections.Count);
        
        if (consoleMessage == null || string.IsNullOrEmpty(consoleMessage.Mensagem))
        {
            _logger.LogWarning("Mensagem de console nula ou vazia, abortando broadcast");
            return;
        }
        
        var json = JsonSerializer.Serialize(consoleMessage);
        var bytes = Encoding.UTF8.GetBytes(json);
        _logger.LogDebug("JSON serializado: {Json}", json);
        _logger.LogDebug("Tamanho: {Size} bytes", bytes.Length);

        var connectionsToRemove = new List<string>();
        var sentCount = 0;
        var skippedCount = 0;

        // Usar plantaId do parâmetro (se fornecido), senão usar da mensagem
        // Se nenhum for fornecido, enviar para TODAS as conexões (igual BroadcastCorrentesAsync)
        var filterPlantaId = plantaId ?? consoleMessage.PlantaId;
        _logger.LogInformation("PlantaId usado para filtro: {PlantaId}", filterPlantaId ?? "TODAS (sem filtro)");

        foreach (var kvp in _connections)
        {
            var connection = kvp.Value;
            _logger.LogDebug("Verificando conexão {ConnectionId} (planta: {PlantaId}, estado: {State})", 
                kvp.Key, connection.PlantaId, connection.WebSocket.State);
            
            // Filtrar por plantaId se especificado (igual BroadcastCorrentesAsync)
            // Se filterPlantaId for null/empty, enviar para TODAS as conexões
            // Se filterPlantaId for especificado, enviar para conexões "all" OU com mesmo plantaId
            if (!string.IsNullOrEmpty(filterPlantaId))
            {
                // Se a conexão não é "all" e não corresponde ao filterPlantaId, pular
                if (connection.PlantaId != "all" && connection.PlantaId != filterPlantaId)
                {
                    skippedCount++;
                    _logger.LogDebug("Pulando conexão {ConnectionId} (planta {ConnectionPlanta} != {FilterPlanta} e != 'all')", 
                        kvp.Key, connection.PlantaId, filterPlantaId);
                    continue;
                }
            }
            // Se filterPlantaId for null/empty, enviar para TODAS (não pular nenhuma)
            
            if (connection.WebSocket.State == WebSocketState.Open)
            {
                try
                {
                    _logger.LogDebug("Enviando para conexão {ConnectionId}...", kvp.Key);
                    await connection.WebSocket.SendAsync(
                        new ArraySegment<byte>(bytes),
                        WebSocketMessageType.Text,
                        true,
                        CancellationToken.None);
                    
                    sentCount++;
                    _logger.LogInformation("✓ Mensagem enviada para conexão {ConnectionId} (planta: {PlantaId})", 
                        kvp.Key, connection.PlantaId);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "✗ Erro ao enviar mensagem de console para conexão {ConnectionId}", kvp.Key);
                    connectionsToRemove.Add(kvp.Key);
                }
            }
            else
            {
                _logger.LogDebug("Conexão {ConnectionId} não está aberta (estado: {State})", 
                    kvp.Key, connection.WebSocket.State);
                connectionsToRemove.Add(kvp.Key);
            }
        }

        // Remover conexões fechadas
        foreach (var connectionId in connectionsToRemove)
        {
            _connections.TryRemove(connectionId, out _);
            _logger.LogDebug("Conexão {ConnectionId} removida", connectionId);
        }

        _logger.LogInformation("=== BROADCAST CONSOLE CONCLUÍDO ===");
        _logger.LogInformation("Enviadas: {SentCount}, Puladas: {SkippedCount}, Removidas: {RemovedCount}", 
            sentCount, skippedCount, connectionsToRemove.Count);
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
