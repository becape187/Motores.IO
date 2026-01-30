using Motores.IO.server.API.DTOs;

namespace Motores.IO.server.API.Services;

public interface IAuthService
{
    Task<LoginResponse?> AutenticarAsync(string email, string senha);
    string GerarToken(Guid usuarioId, string email, string perfil);
}
