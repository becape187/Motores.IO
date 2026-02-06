using System.Net.WebSockets;
using System.Text;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Motores.IO.server.API.Services;

namespace Motores.IO.server.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[AllowAnonymous] // WebSockets não precisam de autenticação
public class WebSocketController : ControllerBase
{
    private readonly IWebSocketHub _webSocketHub;
    private readonly ILogger<WebSocketController> _logger;

    public WebSocketController(IWebSocketHub webSocketHub, ILogger<WebSocketController> logger)
    {
        _webSocketHub = webSocketHub;
        _logger = logger;
    }

    [HttpGet("correntes")]
    public async Task GetCorrentes()
    {
        if (!HttpContext.WebSockets.IsWebSocketRequest)
        {
            HttpContext.Response.StatusCode = StatusCodes.Status400BadRequest;
            return;
        }

        // Obter plantaId da query string ou header
        var plantaId = Request.Query["plantaId"].ToString();
        if (string.IsNullOrEmpty(plantaId))
        {
            HttpContext.Response.StatusCode = StatusCodes.Status400BadRequest;
            await HttpContext.Response.WriteAsync("plantaId é obrigatório");
            return;
        }

        var webSocket = await HttpContext.WebSockets.AcceptWebSocketAsync();
        var connectionId = Guid.NewGuid().ToString();
        
        // Adicionar conexão ao hub (tipo: correntes)
        if (_webSocketHub is WebSocketHub hub)
        {
            hub.AddConnection(connectionId, webSocket, plantaId, "correntes");
        }

        _logger.LogInformation("Nova conexão WebSocket estabelecida: {ConnectionId} para planta {PlantaId}", 
            connectionId, plantaId);

        try
        {
            // Manter conexão aberta e escutar mensagens
            var buffer = new byte[1024 * 4];
            while (webSocket.State == WebSocketState.Open)
            {
                var result = await webSocket.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);
                
                if (result.MessageType == WebSocketMessageType.Close)
                {
                    await webSocket.CloseAsync(WebSocketCloseStatus.NormalClosure, "Fechamento normal", CancellationToken.None);
                    break;
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro na conexão WebSocket {ConnectionId}", connectionId);
        }
        finally
        {
            await _webSocketHub.RemoveConnectionAsync(connectionId);
            _logger.LogInformation("Conexão WebSocket fechada: {ConnectionId}", connectionId);
        }
    }

    [HttpGet("console")]
    public async Task GetConsole()
    {
        _logger.LogInformation("=== REQUISIÇÃO WEBSOCKET CONSOLE RECEBIDA ===");
        _logger.LogInformation("Path: {Path}", HttpContext.Request.Path);
        _logger.LogInformation("QueryString: {QueryString}", HttpContext.Request.QueryString);
        _logger.LogInformation("IsWebSocketRequest: {IsWebSocket}", HttpContext.WebSockets.IsWebSocketRequest);
        
        if (!HttpContext.WebSockets.IsWebSocketRequest)
        {
            _logger.LogWarning("✗ Requisição não é WebSocket, retornando 400");
            HttpContext.Response.StatusCode = StatusCodes.Status400BadRequest;
            await HttpContext.Response.WriteAsync("WebSocket request required");
            return;
        }

        // Obter plantaId da query string (opcional para console - pode receber de todas as plantas)
        var plantaId = Request.Query["plantaId"].ToString();
        _logger.LogInformation("PlantaId recebido: {PlantaId}", plantaId ?? "null");
        
        // Se não especificado, usar "all" para receber de todas as plantas
        if (string.IsNullOrEmpty(plantaId))
        {
            plantaId = "all";
            _logger.LogInformation("PlantaId não especificado, usando 'all'");
        }

        _logger.LogInformation("Aceitando conexão WebSocket...");
        WebSocket webSocket;
        try
        {
            webSocket = await HttpContext.WebSockets.AcceptWebSocketAsync();
            _logger.LogInformation("✓ WebSocket aceito com sucesso");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "✗ Erro ao aceitar WebSocket");
            return;
        }
        
        var connectionId = Guid.NewGuid().ToString();
        _logger.LogInformation("ConnectionId gerado: {ConnectionId}", connectionId);
        
        // Adicionar conexão ao hub (tipo: console)
        if (_webSocketHub is WebSocketHub hub)
        {
            hub.AddConnection(connectionId, webSocket, plantaId, "console");
            _logger.LogInformation("✓ Conexão adicionada ao hub (tipo: console)");
        }
        else
        {
            _logger.LogError("✗ WebSocketHub não é do tipo WebSocketHub!");
        }

        _logger.LogInformation("Nova conexão WebSocket Console estabelecida: {ConnectionId} para planta {PlantaId}", 
            connectionId, plantaId);

        try
        {
            // Manter conexão aberta e escutar mensagens
            var buffer = new byte[1024 * 4];
            while (webSocket.State == WebSocketState.Open)
            {
                var result = await webSocket.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);
                
                if (result.MessageType == WebSocketMessageType.Close)
                {
                    await webSocket.CloseAsync(WebSocketCloseStatus.NormalClosure, "Fechamento normal", CancellationToken.None);
                    break;
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro na conexão WebSocket Console {ConnectionId}", connectionId);
        }
        finally
        {
            await _webSocketHub.RemoveConnectionAsync(connectionId);
            _logger.LogInformation("Conexão WebSocket Console fechada: {ConnectionId}", connectionId);
        }
    }
}
