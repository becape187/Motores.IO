using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Motores.IO.server.API.Data;
using Motores.IO.server.API.DTOs;
using Motores.IO.server.API.Services;

namespace Motores.IO.server.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class MaintenanceController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly MaintenanceService _maintenanceService;

    public MaintenanceController(ApplicationDbContext context, MaintenanceService maintenanceService)
    {
        _context = context;
        _maintenanceService = maintenanceService;
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

    // POST: api/maintenance/orders/{id}/fechar
    [HttpPost("orders/{id}/fechar")]
    public async Task<IActionResult> FecharManutencao(Guid id, FecharManutencaoDto dto)
    {
        var (success, error) = await _maintenanceService.FecharManutencaoAsync(id, dto.Relatorio);

        if (!success)
        {
            return BadRequest(new { message = error });
        }

        await _context.SaveChangesAsync();

        return Ok(new { message = "Manutenção fechada com sucesso." });
    }

    // GET: api/maintenance/pendentes - Motores com manutenção pendente (horímetro >= limiar)
    [HttpGet("pendentes")]
    public async Task<ActionResult<IEnumerable<object>>> GetManutencoesPendentes([FromQuery] Guid? plantaId = null)
    {
        var query = _context.Motores
            .Where(m => m.CicloManutencao != null && m.HorimetroProximaManutencao != null)
            .AsQueryable();

        if (plantaId.HasValue)
        {
            query = query.Where(m => m.PlantaId == plantaId.Value);
        }

        var motores = await query.ToListAsync();

        var pendentes = motores
            .Where(m => m.Horimetro >= m.HorimetroProximaManutencao!.Value)
            .Select(m => new
            {
                m.Id,
                m.Nome,
                m.Horimetro,
                m.HorimetroProximaManutencao,
                m.CicloManutencao,
                m.DataEstimadaProximaManutencao,
                m.DataUltimaManutencao,
                HorasExcedidas = m.Horimetro - m.HorimetroProximaManutencao!.Value
            })
            .OrderByDescending(m => m.HorasExcedidas)
            .ToList();

        return Ok(pendentes);
    }

    // GET: api/maintenance/historico - Histórico de manutenções concluídas (com relatórios e nome do motor)
    [HttpGet("historico")]
    public async Task<ActionResult<IEnumerable<object>>> GetHistoricoManutencoes(
        [FromQuery] Guid? plantaId = null,
        [FromQuery] Guid? motorId = null)
    {
        var query = _context.OrdensServico
            .Include(os => os.Motor)
            .Include(os => os.Relatorios)
            .Where(os => os.Status == "concluida")
            .AsQueryable();

        if (plantaId.HasValue)
        {
            query = query.Where(os => os.Motor.PlantaId == plantaId.Value);
        }

        if (motorId.HasValue)
        {
            query = query.Where(os => os.MotorId == motorId.Value);
        }

        var historico = await query
            .OrderByDescending(os => os.DataEncerramento)
            .Select(os => new
            {
                os.Id,
                os.NumeroOS,
                os.MotorId,
                MotorNome = os.Motor.Nome,
                os.Tipo,
                os.Status,
                os.Descricao,
                os.DataAbertura,
                os.DataEncerramento,
                os.DataPrevista,
                Relatorios = os.Relatorios.OrderByDescending(r => r.Data).Select(r => new
                {
                    r.Id,
                    r.Data,
                    r.Tecnico,
                    r.Descricao,
                    r.Observacoes
                }).ToList()
            })
            .ToListAsync();

        return Ok(historico);
    }

    private bool OrdemServicoExists(Guid id)
    {
        return _context.OrdensServico.Any(e => e.Id == id);
    }
}
