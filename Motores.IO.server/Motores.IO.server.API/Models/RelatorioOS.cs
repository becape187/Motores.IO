namespace Motores.IO.server.API.Models;

public class RelatorioOS
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid OSId { get; set; }

    public DateTime Data { get; set; } = DateTime.UtcNow;

    public string Tecnico { get; set; } = string.Empty;

    public string Descricao { get; set; } = string.Empty;

    public string? Observacoes { get; set; }

    // Armazenar caminhos dos anexos (JSON ou array)
    public string? Anexos { get; set; }

    // Relacionamento
    public virtual OrdemServico OrdemServico { get; set; } = null!;
}
