using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Motores.IO.server.API.Data;
using Motores.IO.server.API.Services;


namespace Motores.IO.server.API.Controllers;

[ApiController]
[Route("api/admin")]
[AllowAnonymous]
public class MigrationController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly InfluxDbService _influxDbService;
    private readonly ILogger<MigrationController> _logger;

    public MigrationController(
        ApplicationDbContext context,
        InfluxDbService influxDbService,
        ILogger<MigrationController> logger)
    {
        _context = context;
        _influxDbService = influxDbService;
        _logger = logger;
    }

    /// <summary>
    /// Migra todos os registros de HistoricosMotores do PostgreSQL para o InfluxDB.
    /// Processa em lotes de 5000 registros para não sobrecarregar a memória.
    /// </summary>
    [HttpPost("migrar-historico")]
    public async Task<ActionResult> MigrarHistoricoParaInflux()
    {
        const int batchSize = 5000;
        var totalMigrado = 0;
        var totalRegistros = await _context.HistoricosMotores.CountAsync();

        _logger.LogInformation("Iniciando migração de {Total} registros do PostgreSQL para InfluxDB", totalRegistros);

        var processados = 0;
        while (processados < totalRegistros)
        {
            var lote = await _context.HistoricosMotores
                .AsNoTracking()
                .OrderBy(h => h.Timestamp)
                .Skip(processados)
                .Take(batchSize)
                .ToListAsync();

            if (lote.Count == 0)
                break;

            await _influxDbService.WriteBatchAsync(lote);
            processados += lote.Count;
            totalMigrado += lote.Count;

            _logger.LogInformation("Migração: {Processados}/{Total} registros", processados, totalRegistros);
        }

        _logger.LogInformation("Migração concluída: {Total} registros migrados para InfluxDB", totalMigrado);

        return Ok(new
        {
            mensagem = "Migração concluída com sucesso",
            totalRegistros,
            totalMigrado
        });
    }
}
