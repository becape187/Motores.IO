using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Motores.IO.server.API.DTOs;
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
    private static int _horimetroEmExecucao;

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
    /// Integra horímetro incrementalmente (a partir do último ponto já processado de cada motor).
    /// </summary>
    [HttpPost("integrar-horimetro")]
    public IActionResult IntegrarHorimetro()
    {
        if (Interlocked.CompareExchange(ref _horimetroEmExecucao, 1, 0) != 0)
        {
            return Conflict(new { mensagem = "Já existe um cálculo de horímetro em execução." });
        }

        var logger = _logger;
        var scopeFactory = _scopeFactory;

        _ = Task.Run(async () =>
        {
            try
            {
                using var scope = scopeFactory.CreateScope();
                var service = scope.ServiceProvider.GetRequiredService<HorimetroService>();
                var (motores, horas) = await service.IntegrarTodosMotoresAsync();
                logger.LogInformation("Integração horímetro concluída: {Motores} motores, +{Horas:F2}h", motores, horas);
                Console.WriteLine($"[MOTORES-API][HORIMETRO] Integração concluída: {motores} motores, +{horas:F2}h adicionadas.");
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Falha na integração de horímetro");
                Console.WriteLine($"[MOTORES-API][HORIMETRO] ERRO: {ex.Message}");
            }
            finally
            {
                Interlocked.Exchange(ref _horimetroEmExecucao, 0);
            }
        });

        return Accepted(new { mensagem = "Integração de horímetro iniciada em segundo plano. Acompanhe os logs." });
    }

    /// <summary>
    /// Zera HorimetroTs e UltimoTimestampIntegrado de todos os motores e recalcula do zero a partir do InfluxDB.
    /// </summary>
    [HttpPost("recalcular-horimetro")]
    public IActionResult RecalcularHorimetro()
    {
        if (Interlocked.CompareExchange(ref _horimetroEmExecucao, 1, 0) != 0)
        {
            return Conflict(new { mensagem = "Já existe um cálculo de horímetro em execução." });
        }

        var logger = _logger;
        var scopeFactory = _scopeFactory;

        _ = Task.Run(async () =>
        {
            try
            {
                using var scope = scopeFactory.CreateScope();
                var service = scope.ServiceProvider.GetRequiredService<HorimetroService>();
                var (motores, horas) = await service.RecalcularTodosMotoresAsync();
                logger.LogInformation("Recálculo horímetro concluído: {Motores} motores, total={Horas:F2}h", motores, horas);
                Console.WriteLine($"[MOTORES-API][HORIMETRO] Recálculo concluído: {motores} motores, total={horas:F2}h.");
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Falha no recálculo de horímetro");
                Console.WriteLine($"[MOTORES-API][HORIMETRO] ERRO: {ex.Message}");
            }
            finally
            {
                Interlocked.Exchange(ref _horimetroEmExecucao, 0);
            }
        });

        return Accepted(new { mensagem = "Recálculo de horímetro iniciado em segundo plano (zera e recalcula tudo). Acompanhe os logs." });
    }
}
