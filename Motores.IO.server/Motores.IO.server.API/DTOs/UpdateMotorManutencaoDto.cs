namespace Motores.IO.server.API.DTOs;

/// <summary>
/// DTO para atualizar apenas os dados de manutenção do motor
/// </summary>
public class UpdateMotorManutencaoDto
{
    public decimal? HorimetroProximaManutencao { get; set; }
    public DateTime? DataEstimadaProximaManutencao { get; set; }
}
