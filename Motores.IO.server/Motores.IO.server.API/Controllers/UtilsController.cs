using Microsoft.AspNetCore.Mvc;

namespace Motores.IO.server.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UtilsController : ControllerBase
{
    // Endpoint temporário para gerar hash de senha
    // Remova este endpoint após criar o primeiro usuário
    [HttpGet("gerar-hash/{senha}")]
    public ActionResult<string> GerarHash(string senha)
    {
        string hash = BCrypt.Net.BCrypt.HashPassword(senha);
        return Ok(new { senha, hash });
    }
}
