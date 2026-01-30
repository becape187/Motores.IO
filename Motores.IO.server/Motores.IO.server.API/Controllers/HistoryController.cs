using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Motores.IO.server.API.Data;

namespace Motores.IO.server.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class HistoryController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public HistoryController(ApplicationDbContext context)
    {
        _context = context;
    }

    // GET: api/history
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Models.HistoricoMotor>>> GetHistorico(
        [FromQuery] Guid? motorId = null,
        [FromQuery] DateTime? dataInicio = null,
        [FromQuery] DateTime? dataFim = null)
    {
        var query = _context.HistoricosMotores.AsQueryable();

        if (motorId.HasValue)
        {
            query = query.Where(h => h.MotorId == motorId.Value);
        }

        if (dataInicio.HasValue)
        {
            query = query.Where(h => h.Timestamp >= dataInicio.Value);
        }

        if (dataFim.HasValue)
        {
            query = query.Where(h => h.Timestamp <= dataFim.Value);
        }

        return await query.OrderByDescending(h => h.Timestamp).ToListAsync();
    }

    // GET: api/history/5
    [HttpGet("{id}")]
    public async Task<ActionResult<Models.HistoricoMotor>> GetHistoricoRegistro(Guid id)
    {
        var historico = await _context.HistoricosMotores.FindAsync(id);

        if (historico == null)
        {
            return NotFound();
        }

        return historico;
    }

    // POST: api/history
    [HttpPost]
    public async Task<ActionResult<Models.HistoricoMotor>> PostHistorico(Models.HistoricoMotor historico)
    {
        historico.Id = Guid.NewGuid();
        historico.Timestamp = DateTime.UtcNow;
        _context.HistoricosMotores.Add(historico);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetHistoricoRegistro), new { id = historico.Id }, historico);
    }

    // DELETE: api/history/5
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteHistorico(Guid id)
    {
        var historico = await _context.HistoricosMotores.FindAsync(id);
        if (historico == null)
        {
            return NotFound();
        }

        _context.HistoricosMotores.Remove(historico);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
