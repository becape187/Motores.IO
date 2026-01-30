using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Motores.IO.server.API.Data;
using System.Security.Claims;

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
    public async Task<ActionResult<IEnumerable<object>>> GetUsuarios([FromQuery] bool? ativo = null)
    {
        // Obter cliente do usuário logado
        var usuarioIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(usuarioIdClaim) || !Guid.TryParse(usuarioIdClaim, out var usuarioId))
        {
            return Unauthorized();
        }

        var usuarioLogado = await _context.Usuarios.FindAsync(usuarioId);
        if (usuarioLogado == null)
        {
            return Unauthorized();
        }

        // Se for perfil global, retornar todos os usuários
        // Caso contrário, filtrar por cliente
        var query = _context.Usuarios.AsQueryable();
        
        if (usuarioLogado.Perfil != "global")
        {
            query = query.Where(u => u.ClienteId == usuarioLogado.ClienteId);
        }

        if (ativo.HasValue)
        {
            query = query.Where(u => u.Ativo == ativo.Value);
        }

        // Retornar usuários com suas plantas associadas
        var usuarios = await query
            .Include(u => u.UsuariosPlantas)
                .ThenInclude(up => up.Planta)
            .Select(u => new
            {
                u.Id,
                u.Nome,
                u.Email,
                u.Perfil,
                u.Ativo,
                u.UltimoAcesso,
                u.DataCriacao,
                u.DataAtualizacao,
                u.ClienteId,
                Plantas = u.UsuariosPlantas.Select(up => new
                {
                    up.Planta.Id,
                    up.Planta.Nome,
                    up.Planta.Codigo
                }).ToList()
            })
            .ToListAsync();

        return Ok(usuarios);
    }

    // GET: api/users/5
    [HttpGet("{id}")]
    public async Task<ActionResult<object>> GetUsuario(Guid id)
    {
        var usuario = await _context.Usuarios
            .Include(u => u.UsuariosPlantas)
                .ThenInclude(up => up.Planta)
            .FirstOrDefaultAsync(u => u.Id == id);

        if (usuario == null)
        {
            return NotFound();
        }

        // Retornar usuário com plantas associadas
        return Ok(new
        {
            usuario.Id,
            usuario.Nome,
            usuario.Email,
            usuario.Perfil,
            usuario.Ativo,
            usuario.UltimoAcesso,
            usuario.DataCriacao,
            usuario.DataAtualizacao,
            usuario.ClienteId,
            Plantas = usuario.UsuariosPlantas.Select(up => new
            {
                up.Planta.Id,
                up.Planta.Nome,
                up.Planta.Codigo
            }).ToList()
        });
    }

    // POST: api/users
    [HttpPost]
    public async Task<ActionResult<object>> PostUsuario(DTOs.UsuarioCreateDto usuarioDto)
    {
        // Obter cliente do usuário logado
        var usuarioIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(usuarioIdClaim) || !Guid.TryParse(usuarioIdClaim, out var usuarioIdLogado))
        {
            return Unauthorized();
        }

        var usuarioLogado = await _context.Usuarios.FindAsync(usuarioIdLogado);
        if (usuarioLogado == null)
        {
            return Unauthorized();
        }

        // Verificar se o email já existe
        if (await _context.Usuarios.AnyAsync(u => u.Email == usuarioDto.Email))
        {
            return BadRequest("Email já cadastrado");
        }

        // Se não for global, usar o cliente do usuário logado
        var clienteId = usuarioLogado.Perfil == "global" ? usuarioDto.ClienteId : usuarioLogado.ClienteId;

        // Verificar se o cliente existe
        if (!await _context.Clientes.AnyAsync(c => c.Id == clienteId))
        {
            return BadRequest("Cliente não encontrado");
        }

        var usuario = new Models.Usuario
        {
            Id = Guid.NewGuid(),
            Nome = usuarioDto.Nome,
            Email = usuarioDto.Email,
            SenhaHash = BCrypt.Net.BCrypt.HashPassword(usuarioDto.Senha),
            Perfil = usuarioDto.Perfil,
            Ativo = usuarioDto.Ativo,
            ClienteId = clienteId,
            DataCriacao = DateTime.UtcNow
        };

        _context.Usuarios.Add(usuario);
        await _context.SaveChangesAsync();

        // Associar plantas se fornecido e se não for perfil global
        if (usuarioDto.PlantaIds != null && usuarioDto.PlantaIds.Any() && usuarioDto.Perfil != "global")
        {
            // Verificar se o admin tem acesso a essas plantas
            var plantasDisponiveis = await ObterPlantasDisponiveisParaAdmin(usuarioIdLogado);
            var plantasIdsDisponiveis = plantasDisponiveis.Select(p => p.Id).ToList();

            foreach (var plantaId in usuarioDto.PlantaIds)
            {
                // Só associar se o admin tiver acesso à planta
                if (plantasIdsDisponiveis.Contains(plantaId))
                {
                    // Verificar se já existe associação
                    if (!await _context.UsuariosPlantas.AnyAsync(up => up.UsuarioId == usuario.Id && up.PlantaId == plantaId))
                    {
                        _context.UsuariosPlantas.Add(new Models.UsuarioPlanta
                        {
                            UsuarioId = usuario.Id,
                            PlantaId = plantaId
                        });
                    }
                }
            }
            await _context.SaveChangesAsync();
        }

        // Retornar usuário criado com plantas
        var usuarioCriado = await _context.Usuarios
            .Include(u => u.UsuariosPlantas)
                .ThenInclude(up => up.Planta)
            .FirstOrDefaultAsync(u => u.Id == usuario.Id);

        return CreatedAtAction(nameof(GetUsuario), new { id = usuario.Id }, new
        {
            usuarioCriado.Id,
            usuarioCriado.Nome,
            usuarioCriado.Email,
            usuarioCriado.Perfil,
            usuarioCriado.Ativo,
            usuarioCriado.ClienteId,
            Plantas = usuarioCriado.UsuariosPlantas.Select(up => new
            {
                up.Planta.Id,
                up.Planta.Nome,
                up.Planta.Codigo
            }).ToList()
        });
    }

    // PUT: api/users/5
    [HttpPut("{id}")]
    public async Task<IActionResult> PutUsuario(Guid id, DTOs.UsuarioUpdateDto usuarioDto)
    {
        if (id != usuarioDto.Id)
        {
            return BadRequest();
        }

        // Obter cliente do usuário logado
        var usuarioIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(usuarioIdClaim) || !Guid.TryParse(usuarioIdClaim, out var usuarioIdLogado))
        {
            return Unauthorized();
        }

        var usuarioLogado = await _context.Usuarios.FindAsync(usuarioIdLogado);
        if (usuarioLogado == null)
        {
            return Unauthorized();
        }

        var usuario = await _context.Usuarios
            .Include(u => u.UsuariosPlantas)
            .FirstOrDefaultAsync(u => u.Id == id);

        if (usuario == null)
        {
            return NotFound();
        }

        // Verificar se o usuário logado tem permissão (mesmo cliente ou global)
        if (usuarioLogado.Perfil != "global" && usuario.ClienteId != usuarioLogado.ClienteId)
        {
            return Forbid();
        }

        // Verificar se o email já existe em outro usuário
        if (await _context.Usuarios.AnyAsync(u => u.Email == usuarioDto.Email && u.Id != id))
        {
            return BadRequest("Email já cadastrado");
        }

        // Se não for global, usar o cliente do usuário logado
        var clienteId = usuarioLogado.Perfil == "global" ? usuarioDto.ClienteId : usuarioLogado.ClienteId;

        usuario.Nome = usuarioDto.Nome;
        usuario.Email = usuarioDto.Email;
        usuario.Perfil = usuarioDto.Perfil;
        usuario.Ativo = usuarioDto.Ativo;
        usuario.ClienteId = clienteId;
        usuario.DataAtualizacao = DateTime.UtcNow;

        // Atualizar senha apenas se fornecida
        if (!string.IsNullOrWhiteSpace(usuarioDto.Senha))
        {
            usuario.SenhaHash = BCrypt.Net.BCrypt.HashPassword(usuarioDto.Senha);
        }

        // Atualizar associações de plantas se fornecido e se não for perfil global
        if (usuarioDto.PlantaIds != null && usuarioDto.Perfil != "global")
        {
            // Remover associações existentes
            var associacoesExistentes = usuario.UsuariosPlantas.ToList();
            _context.UsuariosPlantas.RemoveRange(associacoesExistentes);

            // Verificar se o admin tem acesso a essas plantas
            var plantasDisponiveis = await ObterPlantasDisponiveisParaAdmin(usuarioIdLogado);
            var plantasIdsDisponiveis = plantasDisponiveis.Select(p => p.Id).ToList();

            // Adicionar novas associações
            foreach (var plantaId in usuarioDto.PlantaIds)
            {
                // Só associar se o admin tiver acesso à planta
                if (plantasIdsDisponiveis.Contains(plantaId))
                {
                    _context.UsuariosPlantas.Add(new Models.UsuarioPlanta
                    {
                        UsuarioId = usuario.Id,
                        PlantaId = plantaId
                    });
                }
            }
        }
        else if (usuarioDto.Perfil == "global")
        {
            // Se mudou para global, remover todas as associações de plantas
            var associacoesExistentes = usuario.UsuariosPlantas.ToList();
            _context.UsuariosPlantas.RemoveRange(associacoesExistentes);
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

    // GET: api/users/plantas-disponiveis - Retorna plantas disponíveis para o admin logado associar a usuários
    [HttpGet("plantas-disponiveis")]
    public async Task<ActionResult<IEnumerable<object>>> GetPlantasDisponiveis()
    {
        var usuarioIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(usuarioIdClaim) || !Guid.TryParse(usuarioIdClaim, out var usuarioId))
        {
            return Unauthorized();
        }

        var plantas = await ObterPlantasDisponiveisParaAdmin(usuarioId);
        
        return Ok(plantas.Select(p => new
        {
            p.Id,
            p.Nome,
            p.Codigo,
            p.ClienteId
        }));
    }

    // Método auxiliar para obter plantas disponíveis para o admin
    private async Task<List<Models.Planta>> ObterPlantasDisponiveisParaAdmin(Guid adminId)
    {
        var admin = await _context.Usuarios.FindAsync(adminId);
        if (admin == null)
        {
            return new List<Models.Planta>();
        }

        // Se for perfil global, retornar todas as plantas
        if (admin.Perfil == "global")
        {
            return await _context.Plantas
                .Where(p => p.Ativo)
                .Include(p => p.Cliente)
                .ToListAsync();
        }

        // Caso contrário, retornar apenas plantas do cliente do admin
        return await _context.Plantas
            .Where(p => p.ClienteId == admin.ClienteId && p.Ativo)
            .Include(p => p.Cliente)
            .ToListAsync();
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
