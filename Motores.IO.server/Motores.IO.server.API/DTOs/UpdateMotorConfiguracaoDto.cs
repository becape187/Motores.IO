namespace Motores.IO.server.API.DTOs;

/// <summary>
/// DTO para atualizar apenas a configuração do motor (campos editáveis pelo usuário)
/// </summary>
public class UpdateMotorConfiguracaoDto
{
    public string Nome { get; set; } = string.Empty;
    public decimal Potencia { get; set; }
    public decimal Tensao { get; set; }
    public decimal CorrenteNominal { get; set; }
    public decimal PercentualCorrenteMaxima { get; set; }
    public decimal Histerese { get; set; }
    public string? RegistroModBus { get; set; }
    public string? RegistroLocal { get; set; }
    public bool Habilitado { get; set; } = true;
    public Guid? PlantaId { get; set; }
}
