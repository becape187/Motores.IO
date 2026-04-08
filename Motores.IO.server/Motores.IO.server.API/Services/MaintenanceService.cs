using Microsoft.EntityFrameworkCore;
using Motores.IO.server.API.Data;
using Motores.IO.server.API.Models;

namespace Motores.IO.server.API.Services;

public class MaintenanceService
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<MaintenanceService> _logger;

    public MaintenanceService(ApplicationDbContext context, ILogger<MaintenanceService> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// Inicializa o ciclo de manutenção quando CicloManutencao é definido pela primeira vez.
    /// Define HorimetroProximaManutencao = Horimetro + CicloManutencao e marca DataUltimaManutencao.
    /// </summary>
    public void InicializarCicloManutencao(Motor motor)
    {
        if (motor.CicloManutencao == null || motor.CicloManutencao <= 0)
            return;

        motor.HorimetroProximaManutencao = motor.Horimetro + motor.CicloManutencao.Value;
        motor.DataUltimaManutencao = DateTime.UtcNow;

        _logger.LogInformation(
            "[Manutenção] Ciclo inicializado para motor {MotorId} ({Nome}): próxima em {Prox}h (atual: {Atual}h, ciclo: {Ciclo}h)",
            motor.Id, motor.Nome, motor.HorimetroProximaManutencao, motor.Horimetro, motor.CicloManutencao);
    }

    /// <summary>
    /// Verifica se o horímetro atingiu o limiar e gera uma OS preventiva automaticamente.
    /// Só gera se não existir OS aberta/pendente para o motor.
    /// </summary>
    public async Task VerificarEGerarOSAsync(Motor motor)
    {
        if (motor.CicloManutencao == null || motor.HorimetroProximaManutencao == null)
            return;

        if (motor.Horimetro < motor.HorimetroProximaManutencao.Value)
            return;

        var existeOSAberta = await _context.OrdensServico
            .AnyAsync(os => os.MotorId == motor.Id && (os.Status == "pendente" || os.Status == "aberta"));

        if (existeOSAberta)
            return;

        var numeroOS = $"MP-{DateTime.UtcNow:yyyyMMdd}-{motor.Nome.Replace(" ", "").ToUpperInvariant()[..Math.Min(motor.Nome.Length, 6)]}-{Guid.NewGuid().ToString()[..4].ToUpperInvariant()}";

        var ordemServico = new OrdemServico
        {
            Id = Guid.NewGuid(),
            MotorId = motor.Id,
            NumeroOS = numeroOS,
            DataAbertura = DateTime.UtcNow,
            DataPrevista = motor.DataEstimadaProximaManutencao,
            Status = "pendente",
            Tipo = "preventiva",
            Descricao = $"Manutenção preventiva automática - Horímetro atingiu {motor.Horimetro:F0}h (limiar: {motor.HorimetroProximaManutencao:F0}h)"
        };

        _context.OrdensServico.Add(ordemServico);

        _logger.LogInformation(
            "[Manutenção] OS gerada automaticamente: {NumeroOS} para motor {MotorId} ({Nome}). Horímetro: {Horimetro}h >= {Limiar}h",
            numeroOS, motor.Id, motor.Nome, motor.Horimetro, motor.HorimetroProximaManutencao);
    }

    /// <summary>
    /// Recalcula a data estimada da próxima manutenção com base na taxa de uso.
    /// Usa: taxa = horasUsadas / diasPassados; diasRestantes = horasRestantes / taxaPorDia.
    /// </summary>
    public void RecalcularDataEstimada(Motor motor)
    {
        if (motor.CicloManutencao == null || motor.HorimetroProximaManutencao == null || motor.DataUltimaManutencao == null)
            return;

        var horimetroBase = motor.HorimetroProximaManutencao.Value - motor.CicloManutencao.Value;
        var horasUsadas = motor.Horimetro - horimetroBase;
        var diasPassados = (DateTime.UtcNow - motor.DataUltimaManutencao.Value).TotalDays;

        if (diasPassados < 1 || horasUsadas <= 0)
            return;

        var taxaPorDia = (double)horasUsadas / diasPassados;
        var horasRestantes = (double)(motor.HorimetroProximaManutencao.Value - motor.Horimetro);

        if (horasRestantes <= 0)
        {
            motor.DataEstimadaProximaManutencao = DateTime.UtcNow;
            return;
        }

        var diasRestantes = horasRestantes / taxaPorDia;
        motor.DataEstimadaProximaManutencao = DateTime.UtcNow.AddDays(diasRestantes);
    }

    /// <summary>
    /// Fecha uma manutenção: marca OS como concluída, grava relatório simplificado na descrição,
    /// reinicia o contador do motor (HorimetroProximaManutencao = Horimetro + CicloManutencao).
    /// </summary>
    public async Task<(bool Success, string? Error)> FecharManutencaoAsync(Guid osId, string relatorio)
    {
        var ordemServico = await _context.OrdensServico
            .Include(os => os.Motor)
            .FirstOrDefaultAsync(os => os.Id == osId);

        if (ordemServico == null)
            return (false, "Ordem de serviço não encontrada.");

        if (ordemServico.Status == "concluida")
            return (false, "Esta ordem de serviço já está concluída.");

        var motor = ordemServico.Motor;
        if (motor == null)
            return (false, "Motor associado à OS não encontrado.");

        ordemServico.Status = "concluida";
        ordemServico.DataEncerramento = DateTime.UtcNow;

        var relatorioOS = new RelatorioOS
        {
            Id = Guid.NewGuid(),
            OSId = osId,
            Data = DateTime.UtcNow,
            Tecnico = "Sistema",
            Descricao = relatorio,
            Observacoes = $"Horímetro no fechamento: {motor.Horimetro:F0}h"
        };
        _context.RelatoriosOS.Add(relatorioOS);

        if (motor.CicloManutencao != null && motor.CicloManutencao > 0)
        {
            motor.HorimetroProximaManutencao = motor.Horimetro + motor.CicloManutencao.Value;
            motor.DataUltimaManutencao = DateTime.UtcNow;
            motor.DataEstimadaProximaManutencao = null;
        }

        _logger.LogInformation(
            "[Manutenção] OS {NumeroOS} fechada para motor {MotorId} ({Nome}). Próxima manutenção: {Prox}h",
            ordemServico.NumeroOS, motor.Id, motor.Nome, motor.HorimetroProximaManutencao);

        return (true, null);
    }
}
