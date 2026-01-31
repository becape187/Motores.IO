namespace Motores.IO.server.API.Services;

public interface ISocketServerService
{
    Task StartAsync(CancellationToken cancellationToken);
    Task StopAsync(CancellationToken cancellationToken);
    int GetConnectedClientsCount();
}