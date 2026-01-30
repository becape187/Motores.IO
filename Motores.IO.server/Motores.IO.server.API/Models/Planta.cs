namespace Motores.IO.server.API.Models;

public class Planta
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid ClienteId { get; set; }

    public string Nome { get; set; } = string.Empty;

    public string? Codigo { get; set; }

    public string? Endereco { get; set; }

    public string? Cidade { get; set; }

    public string? Estado { get; set; }

    public bool Ativo { get; set; } = true;

    public DateTime DataCriacao { get; set; } = DateTime.UtcNow;

    public DateTime? DataAtualizacao { get; set; }

    // Relacionamentos
    public virtual Cliente Cliente { get; set; } = null!;
    public virtual ICollection<UsuarioPlanta> UsuariosPlantas { get; set; } = new List<UsuarioPlanta>();
    public virtual ICollection<Motor> Motores { get; set; } = new List<Motor>();
}
