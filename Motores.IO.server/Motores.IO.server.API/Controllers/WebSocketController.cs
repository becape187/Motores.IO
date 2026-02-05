using System.Net.WebSockets;
using System.Text;
using Microsoft.AspNetCore.Mvc;
using Motores.IO.server.API.Services;

namespace Motores.IO.server.API.Controllers;

[ApiController]
[Route("api/[controller]")]
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
        
        // Adicionar conexão ao hub
        if (_webSocketHub is WebSocketHub hub)
        {
            hub.AddConnection(connectionId, webSocket, plantaId);
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
        if (!HttpContext.WebSockets.IsWebSocketRequest)
        {
            HttpContext.Response.StatusCode = StatusCodes.Status400BadRequest;
            return;
        }

        // Obter plantaId da query string (opcional para console - pode receber de todas as plantas)
        var plantaId = Request.Query["plantaId"].ToString();
        // Se não especificado, usar "all" para receber de todas as plantas
        if (string.IsNullOrEmpty(plantaId))
        {
            plantaId = "all";
        }

        var webSocket = await HttpContext.WebSockets.AcceptWebSocketAsync();
        var connectionId = Guid.NewGuid().ToString();
        
        // Adicionar conexão ao hub (marcada como console)
        if (_webSocketHub is WebSocketHub hub)
        {
            hub.AddConnection(connectionId, webSocket, plantaId);
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
