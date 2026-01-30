namespace Motores.IO.server.API.Models;

public class OrdemServico
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid MotorId { get; set; }

    public string NumeroOS { get; set; } = string.Empty;

    public DateTime DataAbertura { get; set; } = DateTime.UtcNow;

    public DateTime? DataEncerramento { get; set; }

    public DateTime? DataPrevista { get; set; }

    public string Status { get; set; } = "aberta"; // aberta, concluida, atrasada, pendente

    public string Descricao { get; set; } = string.Empty;

    public string Tipo { get; set; } = "preventiva"; // preventiva, corretiva, preditiva

    // Relacionamentos
    public virtual Motor Motor { get; set; } = null!;

    public virtual ICollection<RelatorioOS> Relatorios { get; set; } = new List<RelatorioOS>();
}
