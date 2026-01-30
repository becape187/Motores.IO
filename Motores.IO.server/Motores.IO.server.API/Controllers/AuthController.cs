using Microsoft.AspNetCore.Mvc;
using Motores.IO.server.API.DTOs;
using Motores.IO.server.API.Services;

namespace Motores.IO.server.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("login")]
    public async Task<ActionResult<LoginResponse>> Login([FromBody] LoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Senha))
        {
            return BadRequest("Email e senha são obrigatórios");
        }

        var response = await _authService.AutenticarAsync(request.Email, request.Senha);

        if (response == null)
        {
            // Verificar se o problema é falta de plantas
            // (isso será verificado no AuthService e retornado como null com código especial)
            // Por enquanto, retornar erro genérico
            return Unauthorized(new { 
                message = "Email ou senha inválidos, ou você não tem acesso a nenhuma planta. Contate o seu gestor para solicitar acesso." 
            });
        }

        // Verificar se tem plantas (exceto se for global)
        if (response.Perfil != "global" && (!response.Plantas.Any()))
        {
            return Unauthorized(new { 
                message = "Você não tem acesso a nenhuma planta. Contate o seu gestor para solicitar acesso.",
                semPlantas = true
            });
        }

        return Ok(response);
    }
}
