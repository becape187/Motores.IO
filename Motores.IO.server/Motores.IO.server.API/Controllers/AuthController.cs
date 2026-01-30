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
            return Unauthorized("Email ou senha inválidos");
        }

        return Ok(response);
    }
}
