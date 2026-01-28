using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Motores.IO.server.API.Data;

namespace Motores.IO.server.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MaintenanceController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public MaintenanceController(ApplicationDbContext context)
    {
        _context = context;
    }

    // GET: api/maintenance/orders
    [HttpGet("orders")]
    public async Task<ActionResult<IEnumerable<Models.OrdemServico>>> GetOrdensServico(
        [FromQuery] Guid? motorId = null,
        [FromQuery] string? status = null)
    {
        var query = _context.OrdensServico.AsQueryable();

        if (motorId.HasValue)
        {
            query = query.Where(os => os.MotorId == motorId.Value);
        }

        if (!string.IsNullOrEmpty(status))
        {
            query = query.Where(os => os.Status == status);
        }

        return await query.OrderByDescending(os => os.DataAbertura).ToListAsync();
    }

    // GET: api/maintenance/orders/5
    [HttpGet("orders/{id}")]
    public async Task<ActionResult<Models.OrdemServico>> GetOrdemServico(Guid id)
    {
        var ordemServico = await _context.OrdensServico
            .Include(os => os.Relatorios)
            .FirstOrDefaultAsync(os => os.Id == id);

        if (ordemServico == null)
        {
            return NotFound();
        }

        return ordemServico;
    }

    // POST: api/maintenance/orders
    [HttpPost("orders")]
    public async Task<ActionResult<Models.OrdemServico>> PostOrdemServico(Models.OrdemServico ordemServico)
    {
        ordemServico.Id = Guid.NewGuid();
        ordemServico.DataAbertura = DateTime.UtcNow;
        _context.OrdensServico.Add(ordemServico);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetOrdemServico), new { id = ordemServico.Id }, ordemServico);
    }

    // PUT: api/maintenance/orders/5
    [HttpPut("orders/{id}")]
    public async Task<IActionResult> PutOrdemServico(Guid id, Models.OrdemServico ordemServico)
    {
        if (id != ordemServico.Id)
        {
            return BadRequest();
        }

        _context.Entry(ordemServico).State = EntityState.Modified;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!OrdemServicoExists(id))
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

    // DELETE: api/maintenance/orders/5
    [HttpDelete("orders/{id}")]
    public async Task<IActionResult> DeleteOrdemServico(Guid id)
    {
        var ordemServico = await _context.OrdensServico.FindAsync(id);
        if (ordemServico == null)
        {
            return NotFound();
        }

        _context.OrdensServico.Remove(ordemServico);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    // GET: api/maintenance/reports
    [HttpGet("reports")]
    public async Task<ActionResult<IEnumerable<Models.RelatorioOS>>> GetRelatorios([FromQuery] Guid? osId = null)
    {
        var query = _context.RelatoriosOS.AsQueryable();

        if (osId.HasValue)
        {
            query = query.Where(r => r.OSId == osId.Value);
        }

        return await query.OrderByDescending(r => r.Data).ToListAsync();
    }

    // POST: api/maintenance/reports
    [HttpPost("reports")]
    public async Task<ActionResult<Models.RelatorioOS>> PostRelatorio(Models.RelatorioOS relatorio)
    {
        relatorio.Id = Guid.NewGuid();
        relatorio.Data = DateTime.UtcNow;
        _context.RelatoriosOS.Add(relatorio);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetRelatorios), new { id = relatorio.Id }, relatorio);
    }

    private bool OrdemServicoExists(Guid id)
    {
        return _context.OrdensServico.Any(e => e.Id == id);
    }
}
