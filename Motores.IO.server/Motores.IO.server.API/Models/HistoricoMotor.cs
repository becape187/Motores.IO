namespace Motores.IO.server.API.Models;

public class HistoricoMotor
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid MotorId { get; set; }

    public DateTime Timestamp { get; set; } = DateTime.UtcNow;

    public decimal Corrente { get; set; }

    public decimal Tensao { get; set; }

    public decimal Temperatura { get; set; }

    public string Status { get; set; } = string.Empty;

    // Relacionamento
    public virtual Motor Motor { get; set; } = null!;
}
