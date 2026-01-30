using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Motores.IO.server.API.Data;
using Motores.IO.server.API.Models;
using System.Security.Claims;

namespace Motores.IO.server.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TemasController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public TemasController(ApplicationDbContext context)
    {
        _context = context;
    }

    // GET: api/temas/cliente/{clienteId}
    [HttpGet("cliente/{clienteId}")]
    public async Task<ActionResult<TemaCliente>> GetTemaCliente(Guid clienteId)
    {
        var tema = await _context.TemasCliente
            .FirstOrDefaultAsync(t => t.ClienteId == clienteId);

        if (tema == null)
        {
            return NotFound();
        }

        return tema;
    }

    // PUT: api/temas/cliente/{clienteId}
    [HttpPut("cliente/{clienteId}")]
    public async Task<IActionResult> PutTemaCliente(Guid clienteId, [FromBody] TemaConfiguracao configuracao)
    {
        var tema = await _context.TemasCliente
            .FirstOrDefaultAsync(t => t.ClienteId == clienteId);

        if (tema == null)
        {
            tema = new TemaCliente
            {
                Id = Guid.NewGuid(),
                ClienteId = clienteId,
                DataCriacao = DateTime.UtcNow
            };
            _context.TemasCliente.Add(tema);
        }

        tema.DefinirConfiguracao(configuracao);
        tema.DataAtualizacao = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return Ok(tema);
    }

    // GET: api/temas/usuario - Retorna tema do usuário logado
    [HttpGet("usuario")]
    public async Task<ActionResult<TemaUsuario>> GetTemaUsuario()
    {
        var usuarioIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(usuarioIdClaim) || !Guid.TryParse(usuarioIdClaim, out var usuarioId))
        {
            return Unauthorized();
        }

        var tema = await _context.TemasUsuario
            .FirstOrDefaultAsync(t => t.UsuarioId == usuarioId);

        if (tema == null)
        {
            return NotFound();
        }

        return tema;
    }

    // PUT: api/temas/usuario
    [HttpPut("usuario")]
    public async Task<IActionResult> PutTemaUsuario([FromBody] TemaConfiguracao configuracao)
    {
        var usuarioIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(usuarioIdClaim) || !Guid.TryParse(usuarioIdClaim, out var usuarioId))
        {
            return Unauthorized();
        }

        var tema = await _context.TemasUsuario
            .FirstOrDefaultAsync(t => t.UsuarioId == usuarioId);

        if (tema == null)
        {
            tema = new TemaUsuario
            {
                Id = Guid.NewGuid(),
                UsuarioId = usuarioId,
                DataCriacao = DateTime.UtcNow
            };
            _context.TemasUsuario.Add(tema);
        }

        tema.DefinirConfiguracao(configuracao);
        tema.DataAtualizacao = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return Ok(tema);
    }
}
