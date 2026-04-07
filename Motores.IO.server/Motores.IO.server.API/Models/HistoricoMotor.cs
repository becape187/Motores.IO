namespace Motores.IO.server.API.Models;

/// <summary>
/// DTO em memória para leitura/escrita no InfluxDB e API de histórico. Não há tabela PostgreSQL.
/// </summary>
public class HistoricoMotor
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid MotorId { get; set; }

    public DateTime Timestamp { get; set; } = DateTime.UtcNow;

    public decimal Corrente { get; set; }

    public decimal Tensao { get; set; }

    public decimal Temperatura { get; set; }

    public string Status { get; set; } = string.Empty;

    public decimal? CorrenteMedia { get; set; }

    public decimal? CorrenteMaxima { get; set; }

    public decimal? CorrenteMinima { get; set; }
}
