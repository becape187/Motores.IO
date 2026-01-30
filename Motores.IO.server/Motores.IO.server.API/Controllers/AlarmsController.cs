using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Motores.IO.server.API.Data;

namespace Motores.IO.server.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class AlarmsController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public AlarmsController(ApplicationDbContext context)
    {
        _context = context;
    }

    // GET: api/alarms
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Models.Alarme>>> GetAlarmes([FromQuery] bool? reconhecido = null)
    {
        var query = _context.Alarmes.AsQueryable();

        if (reconhecido.HasValue)
        {
            query = query.Where(a => a.Reconhecido == reconhecido.Value);
        }

        return await query.OrderByDescending(a => a.Timestamp).ToListAsync();
    }

    // GET: api/alarms/5
    [HttpGet("{id}")]
    public async Task<ActionResult<Models.Alarme>> GetAlarme(Guid id)
    {
        var alarme = await _context.Alarmes.FindAsync(id);

        if (alarme == null)
        {
            return NotFound();
        }

        return alarme;
    }

    // GET: api/alarms/motor/5
    [HttpGet("motor/{motorId}")]
    public async Task<ActionResult<IEnumerable<Models.Alarme>>> GetAlarmesPorMotor(Guid motorId)
    {
        return await _context.Alarmes
            .Where(a => a.MotorId == motorId)
            .OrderByDescending(a => a.Timestamp)
            .ToListAsync();
    }

    // POST: api/alarms
    [HttpPost]
    public async Task<ActionResult<Models.Alarme>> PostAlarme(Models.Alarme alarme)
    {
        alarme.Id = Guid.NewGuid();
        alarme.Timestamp = DateTime.UtcNow;
        _context.Alarmes.Add(alarme);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetAlarme), new { id = alarme.Id }, alarme);
    }

    // PUT: api/alarms/5/reconhecer
    [HttpPut("{id}/reconhecer")]
    public async Task<IActionResult> ReconhecerAlarme(Guid id, [FromBody] Guid? usuarioId = null)
    {
        var alarme = await _context.Alarmes.FindAsync(id);
        if (alarme == null)
        {
            return NotFound();
        }

        alarme.Reconhecido = true;
        alarme.DataReconhecimento = DateTime.UtcNow;
        alarme.UsuarioReconhecimentoId = usuarioId;

        await _context.SaveChangesAsync();

        return NoContent();
    }

    // DELETE: api/alarms/5
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteAlarme(Guid id)
    {
        var alarme = await _context.Alarmes.FindAsync(id);
        if (alarme == null)
        {
            return NotFound();
        }

        _context.Alarmes.Remove(alarme);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
