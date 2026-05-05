using Microsoft.EntityFrameworkCore;
using Motores.IO.server.API.Data;

namespace Motores.IO.server.API.Services;

public class HorimetroService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly InfluxDbService _influxDbService;
    private readonly ILogger<HorimetroService> _logger;
    private const double CorrenteLimite = 5.0;
    private const double MaxGapSegundos = 600.0;

    public HorimetroService(
        IServiceScopeFactory scopeFactory,
        InfluxDbService influxDbService,
        ILogger<HorimetroService> logger)
    {
        _scopeFactory = scopeFactory;
        _influxDbService = influxDbService;
        _logger = logger;
    }

    public async Task<(int motoresProcessados, double totalHorasAdicionadas)> IntegrarTodosMotoresAsync()
    {
        using var scope = _scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

        var motores = await context.Motores.ToListAsync();
        var totalHoras = 0.0;

        foreach (var motor in motores)
        {
            var horasAntes = motor.HorimetroTs;
            await IntegrarMotorInternoAsync(motor, context);
            totalHoras += motor.HorimetroTs - horasAntes;
        }

        return (motores.Count, totalHoras / 3600.0);
    }

    public async Task IntegrarHorimetroMotorAsync(Guid motorId)
    {
        using var scope = _scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

        var motor = await context.Motores.FindAsync(motorId);
        if (motor == null)
        {
            _logger.LogWarning("Motor {MotorId} não encontrado para integração de horímetro", motorId);
            return;
        }

        await IntegrarMotorInternoAsync(motor, context);
    }

    public async Task<(int motoresProcessados, double totalHorasCalculadas)> RecalcularTodosMotoresAsync()
    {
        using var scope = _scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

        var motores = await context.Motores.ToListAsync();
        var totalHoras = 0.0;

        foreach (var motor in motores)
        {
            motor.HorimetroTs = 0;
            motor.UltimoTimestampIntegrado = null;

            await IntegrarMotorInternoAsync(motor, context);
            totalHoras += motor.HorimetroTs / 3600.0;
        }

        return (motores.Count, totalHoras);
    }

    private async Task IntegrarMotorInternoAsync(Models.Motor motor, ApplicationDbContext context)
    {
        var pontos = await _influxDbService.QueryPontosCorrenteAsync(motor.Id, motor.UltimoTimestampIntegrado);

        if (pontos.Count == 0)
            return;

        var acumuladoSegundos = 0.0;
        var ligado = false;
        DateTime inicioLigado = default;

        for (var i = 0; i < pontos.Count; i++)
        {
            var (time, corrente) = pontos[i];
            var estaLigado = corrente >= CorrenteLimite;

            if (estaLigado && !ligado)
            {
                ligado = true;
                inicioLigado = time;
            }
            else if (!estaLigado && ligado)
            {
                var delta = (time - inicioLigado).TotalSeconds;
                if (delta > 0 && delta < MaxGapSegundos)
                    acumuladoSegundos += delta;
                else if (delta >= MaxGapSegundos)
                    acumuladoSegundos += CalcularComGaps(inicioLigado, time, pontos, i);
                ligado = false;
            }
            else if (estaLigado && ligado && i > 0)
            {
                var deltaPonto = (time - pontos[i - 1].Time).TotalSeconds;
                if (deltaPonto >= MaxGapSegundos)
                {
                    var deltaAteGap = (pontos[i - 1].Time - inicioLigado).TotalSeconds;
                    if (deltaAteGap > 0)
                        acumuladoSegundos += deltaAteGap;
                    inicioLigado = time;
                }
            }
        }

        if (ligado)
        {
            var ultimoPonto = pontos[^1];
            var delta = (ultimoPonto.Time - inicioLigado).TotalSeconds;
            if (delta > 0 && delta < MaxGapSegundos)
                acumuladoSegundos += delta;
        }

        motor.HorimetroTs += acumuladoSegundos;
        motor.Horimetro = (decimal)Math.Round(motor.HorimetroTs / 3600.0, 2);
        motor.UltimoTimestampIntegrado = pontos[^1].Time;
        motor.DataAtualizacao = DateTime.UtcNow;

        await context.SaveChangesAsync();

        if (acumuladoSegundos > 0)
        {
            _logger.LogInformation(
                "Horímetro motor {MotorId}: +{Segundos:F1}s (total={TotalHoras:F2}h)",
                motor.Id, acumuladoSegundos, (double)motor.Horimetro);
        }
    }

    private static double CalcularComGaps(
        DateTime inicioLigado,
        DateTime fimPeriodo,
        List<(DateTime Time, double Corrente)> pontos,
        int indiceFim)
    {
        var acumulado = 0.0;
        var ultimoTime = inicioLigado;

        for (var j = 0; j < indiceFim; j++)
        {
            if (pontos[j].Time <= inicioLigado)
                continue;
            if (pontos[j].Time >= fimPeriodo)
                break;

            var gap = (pontos[j].Time - ultimoTime).TotalSeconds;
            if (gap > 0 && gap < MaxGapSegundos)
                acumulado += gap;
            ultimoTime = pontos[j].Time;
        }

        return acumulado;
    }
}
