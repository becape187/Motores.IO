using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Motores.IO.server.API.Data;
using Motores.IO.server.API.DTOs;
using Motores.IO.server.API.Models;
using Motores.IO.server.API.Services;

namespace Motores.IO.server.API.Controllers;

[ApiController]
[Route("api/admin")]
[AllowAnonymous]
public class MigrationController : ControllerBase
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly InfluxDbService _influxDbService;
    private readonly ILogger<MigrationController> _logger;
    private static int _migrationEmExecucao;

    public MigrationController(
        IServiceScopeFactory scopeFactory,
        InfluxDbService influxDbService,
        ILogger<MigrationController> logger)
    {
        _scopeFactory = scopeFactory;
        _influxDbService = influxDbService;
        _logger = logger;
    }

    /// <summary>
    /// Diagnóstico sem abrir a UI do Influx: último timestamp ingerido e contagem (campo corrente).
    /// Use contarTodoPeriodo=true só se necessário (consulta pesada).
    /// </summary>
    [HttpGet("influx-resumo")]
    public async Task<ActionResult<InfluxIngestaoResumoDto>> InfluxResumo([FromQuery] bool contarTodoPeriodo = false)
    {
        return Ok(await _influxDbService.ObterResumoIngestaoAsync(contarTodoPeriodo));
    }

    /// <summary>
    /// Inicia migração PostgreSQL → InfluxDB em segundo plano (evita 504 do nginx em lotes grandes).
    /// </summary>
    [HttpPost("migrar-historico")]
    public IActionResult MigrarHistoricoParaInflux()
    {
        if (Interlocked.CompareExchange(ref _migrationEmExecucao, 1, 0) != 0)
        {
            return Conflict(new
            {
                mensagem = "Já existe uma migração em execução. Aguarde o término (veja os logs do servidor)."
            });
        }

        var logger = _logger;
        var scopeFactory = _scopeFactory;

        Console.WriteLine($"[MOTORES-API][MIGRACAO] UTC {DateTime.UtcNow:O} — POST migrar-historico aceito; fila em segundo plano.");
        logger.LogInformation("Migração: POST aceito, execução em segundo plano iniciada.");

        _ = Task.Run(async () =>
        {
            try
            {
                await ExecutarMigracaoAsync(scopeFactory, logger);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Falha na migração de histórico para InfluxDB");
                Console.WriteLine($"[MOTORES-API][MIGRACAO] ERRO: {ex.Message}");
            }
            finally
            {
                Interlocked.Exchange(ref _migrationEmExecucao, 0);
            }
        });

        return Accepted(new
        {
            mensagem =
                "Migração iniciada em segundo plano. Veja journalctl ou stdout por linhas [MOTORES-API][MIGRACAO]. GET /api/admin/influx-resumo para checar ingestão.",
            dicaNginx =
                "Se precisar de migração síncrona no futuro, aumente proxy_read_timeout no location da API."
        });
    }

    private static async Task ExecutarMigracaoAsync(
        IServiceScopeFactory scopeFactory,
        ILogger logger)
    {
        using var scope = scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var influxDbService = scope.ServiceProvider.GetRequiredService<InfluxDbService>();
        var config = scope.ServiceProvider.GetRequiredService<IConfiguration>();

        var batchSize = Math.Clamp(config.GetValue("InfluxDb:MigrationBatchSize", 400), 50, 10_000);
        var delayMs = Math.Clamp(config.GetValue("InfluxDb:MigrationDelayMsBetweenBatches", 150), 0, 120_000);

        var totalRegistros = await context.HistoricosMotores.CountAsync();
        logger.LogInformation(
            "Migração: iniciando {Total} registros PostgreSQL → InfluxDB (batch={Batch}, delayMs={Delay})",
            totalRegistros, batchSize, delayMs);
        Console.WriteLine(
            $"[MOTORES-API][MIGRACAO] UTC {DateTime.UtcNow:O} — início total={totalRegistros} batch={batchSize} delayMs={delayMs}");

        DateTime? lastTs = null;
        Guid? lastId = null;
        var processados = 0;

        while (true)
        {
            IQueryable<HistoricoMotor> query = context.HistoricosMotores.AsNoTracking();
            if (lastTs.HasValue && lastId.HasValue)
            {
                var ts = lastTs.Value;
                var id = lastId.Value;
                query = query.Where(h => h.Timestamp > ts || (h.Timestamp == ts && h.Id > id));
            }

            var lote = await query
                .OrderBy(h => h.Timestamp)
                .ThenBy(h => h.Id)
                .Take(batchSize)
                .ToListAsync();

            if (lote.Count == 0)
                break;

            await influxDbService.WriteBatchAsync(lote);
            var ult = lote[^1];
            lastTs = ult.Timestamp;
            lastId = ult.Id;
            processados += lote.Count;

            logger.LogInformation("Migração: {Processados}/{Total} registros enviados ao InfluxDB", processados,
                totalRegistros);
            Console.WriteLine(
                $"[MOTORES-API][MIGRACAO] UTC {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss} — {processados}/{totalRegistros}");

            if (delayMs > 0)
                await Task.Delay(delayMs);
        }

        logger.LogInformation("Migração concluída: {Total} registros migrados para InfluxDB", processados);
        Console.WriteLine($"[MOTORES-API][MIGRACAO] UTC {DateTime.UtcNow:O} — CONCLUÍDA {processados} registros.");
    }
}
