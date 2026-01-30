namespace Motores.IO.server.API.Models;

public class UsuarioPlanta
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid UsuarioId { get; set; }

    public Guid PlantaId { get; set; }

    public DateTime DataCriacao { get; set; } = DateTime.UtcNow;

    // Relacionamentos
    public virtual Usuario Usuario { get; set; } = null!;
    public virtual Planta Planta { get; set; } = null!;
}
