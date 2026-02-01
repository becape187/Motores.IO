using Motores.IO.server.API.DTOs;

namespace Motores.IO.server.API.Services;

public interface IWebSocketHub
{
    Task BroadcastCorrentesAsync(CorrentesArrayDto correntes, string? plantaId = null);
    Task AddConnectionAsync(string connectionId, string plantaId);
    Task RemoveConnectionAsync(string connectionId);
}
