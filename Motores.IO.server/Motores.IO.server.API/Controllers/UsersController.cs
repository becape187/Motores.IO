using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Motores.IO.server.API.Data;

namespace Motores.IO.server.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class UsersController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public UsersController(ApplicationDbContext context)
    {
        _context = context;
    }

    // GET: api/users
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Models.Usuario>>> GetUsuarios([FromQuery] bool? ativo = null)
    {
        var query = _context.Usuarios.AsQueryable();

        if (ativo.HasValue)
        {
            query = query.Where(u => u.Ativo == ativo.Value);
        }

        return await query.ToListAsync();
    }

    // GET: api/users/5
    [HttpGet("{id}")]
    public async Task<ActionResult<Models.Usuario>> GetUsuario(Guid id)
    {
        var usuario = await _context.Usuarios.FindAsync(id);

        if (usuario == null)
        {
            return NotFound();
        }

        // Não retornar a senha hash
        usuario.SenhaHash = string.Empty;

        return usuario;
    }

    // POST: api/users
    // Permitir criação sem autenticação (para criar primeiro usuário)
    [HttpPost]
    [AllowAnonymous]
    public async Task<ActionResult<Models.Usuario>> PostUsuario(DTOs.UsuarioCreateDto usuarioDto)
    {
        // Verificar se o email já existe
        if (await _context.Usuarios.AnyAsync(u => u.Email == usuarioDto.Email))
        {
            return BadRequest("Email já cadastrado");
        }

        var usuario = new Models.Usuario
        {
            Id = Guid.NewGuid(),
            Nome = usuarioDto.Nome,
            Email = usuarioDto.Email,
            SenhaHash = BCrypt.Net.BCrypt.HashPassword(usuarioDto.Senha),
            Perfil = usuarioDto.Perfil,
            Ativo = usuarioDto.Ativo,
            DataCriacao = DateTime.UtcNow
        };

        _context.Usuarios.Add(usuario);
        await _context.SaveChangesAsync();

        // Não retornar a senha hash
        usuario.SenhaHash = string.Empty;

        return CreatedAtAction(nameof(GetUsuario), new { id = usuario.Id }, usuario);
    }

    // PUT: api/users/5
    [HttpPut("{id}")]
    public async Task<IActionResult> PutUsuario(Guid id, DTOs.UsuarioUpdateDto usuarioDto)
    {
        if (id != usuarioDto.Id)
        {
            return BadRequest();
        }

        var usuario = await _context.Usuarios.FindAsync(id);
        if (usuario == null)
        {
            return NotFound();
        }

        // Verificar se o email já existe em outro usuário
        if (await _context.Usuarios.AnyAsync(u => u.Email == usuarioDto.Email && u.Id != id))
        {
            return BadRequest("Email já cadastrado");
        }

        usuario.Nome = usuarioDto.Nome;
        usuario.Email = usuarioDto.Email;
        usuario.Perfil = usuarioDto.Perfil;
        usuario.Ativo = usuarioDto.Ativo;
        usuario.DataAtualizacao = DateTime.UtcNow;

        // Atualizar senha apenas se fornecida
        if (!string.IsNullOrWhiteSpace(usuarioDto.Senha))
        {
            usuario.SenhaHash = BCrypt.Net.BCrypt.HashPassword(usuarioDto.Senha);
        }

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!UsuarioExists(id))
            {
                return NotFound();
            }
            else
            {
                throw;
            }
        }

        return NoContent();
    }

    // DELETE: api/users/5
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteUsuario(Guid id)
    {
        var usuario = await _context.Usuarios.FindAsync(id);
        if (usuario == null)
        {
            return NotFound();
        }

        _context.Usuarios.Remove(usuario);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    private bool UsuarioExists(Guid id)
    {
        return _context.Usuarios.Any(e => e.Id == id);
    }
}
