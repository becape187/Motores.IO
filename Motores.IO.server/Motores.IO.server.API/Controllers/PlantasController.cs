using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Motores.IO.server.API.Data;
using System.Security.Claims;

namespace Motores.IO.server.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class PlantasController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public PlantasController(ApplicationDbContext context)
    {
        _context = context;
    }

    // GET: api/plantas
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Models.Planta>>> GetPlantas(
        [FromQuery] Guid? clienteId = null,
        [FromQuery] bool? ativo = null)
    {
        var query = _context.Plantas.AsQueryable();

        if (clienteId.HasValue)
        {
            query = query.Where(p => p.ClienteId == clienteId.Value);
        }

        if (ativo.HasValue)
        {
            query = query.Where(p => p.Ativo == ativo.Value);
        }

        return await query.Include(p => p.Cliente).ToListAsync();
    }

    // GET: api/plantas/por-usuario - Retorna plantas disponíveis para o usuário logado
    [HttpGet("por-usuario")]
    public async Task<ActionResult<IEnumerable<Models.Planta>>> GetPlantasPorUsuario()
    {
        var usuarioIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(usuarioIdClaim) || !Guid.TryParse(usuarioIdClaim, out var usuarioId))
        {
            return Unauthorized();
        }

        var plantas = await _context.UsuariosPlantas
            .Where(up => up.UsuarioId == usuarioId)
            .Include(up => up.Planta)
                .ThenInclude(p => p.Cliente)
            .Select(up => up.Planta)
            .Where(p => p.Ativo)
            .ToListAsync();

        return Ok(plantas);
    }

    // GET: api/plantas/5
    [HttpGet("{id}")]
    public async Task<ActionResult<Models.Planta>> GetPlanta(Guid id)
    {
        var planta = await _context.Plantas
            .Include(p => p.Cliente)
            .FirstOrDefaultAsync(p => p.Id == id);

        if (planta == null)
        {
            return NotFound();
        }

        return planta;
    }

    // POST: api/plantas
    [HttpPost]
    public async Task<ActionResult<Models.Planta>> PostPlanta(Models.Planta planta)
    {
        planta.Id = Guid.NewGuid();
        planta.DataCriacao = DateTime.UtcNow;
        _context.Plantas.Add(planta);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetPlanta), new { id = planta.Id }, planta);
    }

    // PUT: api/plantas/5
    [HttpPut("{id}")]
    public async Task<IActionResult> PutPlanta(Guid id, Models.Planta planta)
    {
        if (id != planta.Id)
        {
            return BadRequest();
        }

        planta.DataAtualizacao = DateTime.UtcNow;
        _context.Entry(planta).State = EntityState.Modified;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!PlantaExists(id))
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

    // DELETE: api/plantas/5
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeletePlanta(Guid id)
    {
        var planta = await _context.Plantas.FindAsync(id);
        if (planta == null)
        {
            return NotFound();
        }

        _context.Plantas.Remove(planta);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    // POST: api/plantas/{plantaId}/usuarios/{usuarioId} - Associar usuário a planta
    [HttpPost("{plantaId}/usuarios/{usuarioId}")]
    public async Task<IActionResult> AssociarUsuarioPlanta(Guid plantaId, Guid usuarioId)
    {
        if (await _context.UsuariosPlantas.AnyAsync(up => up.UsuarioId == usuarioId && up.PlantaId == plantaId))
        {
            return BadRequest("Usuário já está associado a esta planta");
        }

        var usuarioPlanta = new Models.UsuarioPlanta
        {
            Id = Guid.NewGuid(),
            UsuarioId = usuarioId,
            PlantaId = plantaId,
            DataCriacao = DateTime.UtcNow
        };

        _context.UsuariosPlantas.Add(usuarioPlanta);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetPlanta), new { id = plantaId }, usuarioPlanta);
    }

    // DELETE: api/plantas/{plantaId}/usuarios/{usuarioId} - Remover associação
    [HttpDelete("{plantaId}/usuarios/{usuarioId}")]
    public async Task<IActionResult> RemoverUsuarioPlanta(Guid plantaId, Guid usuarioId)
    {
        var usuarioPlanta = await _context.UsuariosPlantas
            .FirstOrDefaultAsync(up => up.UsuarioId == usuarioId && up.PlantaId == plantaId);

        if (usuarioPlanta == null)
        {
            return NotFound();
        }

        _context.UsuariosPlantas.Remove(usuarioPlanta);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    private bool PlantaExists(Guid id)
    {
        return _context.Plantas.Any(e => e.Id == id);
    }
}
