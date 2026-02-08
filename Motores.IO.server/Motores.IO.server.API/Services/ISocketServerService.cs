using Motores.IO.server.API.DTOs;

namespace Motores.IO.server.API.Services;

public interface ISocketServerService
{
    Task StartAsync(CancellationToken cancellationToken);
    Task StopAsync(CancellationToken cancellationToken);
    int GetConnectedClientsCount();
    Task<FileCommandResponseDto?> SendCommandToPlantaAsync(string plantaId, FileCommandDto command, CancellationToken cancellationToken = default);
}