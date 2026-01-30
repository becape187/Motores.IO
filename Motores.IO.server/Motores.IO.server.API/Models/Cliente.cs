namespace Motores.IO.server.API.Models;

public class Cliente
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public string Nome { get; set; } = string.Empty;

    public string? Cnpj { get; set; }

    public string? Email { get; set; }

    public string? Telefone { get; set; }

    public bool Ativo { get; set; } = true;

    public DateTime DataCriacao { get; set; } = DateTime.UtcNow;

    public DateTime? DataAtualizacao { get; set; }

    // Relacionamentos
    public virtual ICollection<Planta> Plantas { get; set; } = new List<Planta>();
    public virtual TemaCliente? Tema { get; set; }
}
