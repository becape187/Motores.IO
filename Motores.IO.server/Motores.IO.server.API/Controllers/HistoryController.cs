using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Motores.IO.server.API.Services;

namespace Motores.IO.server.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class HistoryController : ControllerBase
{
    private readonly InfluxDbService _influxDbService;

    public HistoryController(InfluxDbService influxDbService)
    {
        _influxDbService = influxDbService;
    }

    // GET: api/history
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Models.HistoricoMotor>>> GetHistorico(
        [FromQuery] Guid? motorId = null,
        [FromQuery] DateTime? dataInicio = null,
        [FromQuery] DateTime? dataFim = null)
    {
        var historicos = await _influxDbService.QueryHistoricoAsync(motorId, dataInicio, dataFim);
        return Ok(historicos);
    }

    // POST: api/history
    [HttpPost]
    public async Task<ActionResult> PostHistorico(Models.HistoricoMotor historico)
    {
        historico.Timestamp = DateTime.UtcNow;
        await _influxDbService.WriteHistoricoAsync(historico);
        return Ok(historico);
    }

    // DELETE: api/history/motor/{motorId}
    [HttpDelete("motor/{motorId}")]
    public async Task<IActionResult> DeleteHistoricoByMotor(Guid motorId)
    {
        await _influxDbService.DeleteByMotorIdAsync(motorId);
        return NoContent();
    }
}
