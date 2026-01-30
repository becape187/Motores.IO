namespace Motores.IO.server.API.Models;

public class Alarme
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid MotorId { get; set; }

    public string MotorNome { get; set; } = string.Empty;

    public string Tipo { get; set; } = "info"; // erro, alerta, info

    public string Mensagem { get; set; } = string.Empty;

    public DateTime Timestamp { get; set; } = DateTime.UtcNow;

    public bool Reconhecido { get; set; } = false;

    public DateTime? DataReconhecimento { get; set; }

    public Guid? UsuarioReconhecimentoId { get; set; }

    // Relacionamento
    public virtual Motor Motor { get; set; } = null!;
}
