namespace Motores.IO.server.API.Models;

public class Usuario
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public string Nome { get; set; } = string.Empty;

    public string Email { get; set; } = string.Empty;

    public string SenhaHash { get; set; } = string.Empty;

    public string Perfil { get; set; } = "visualizador"; // admin, operador, visualizador

    public bool Ativo { get; set; } = true;

    public DateTime? UltimoAcesso { get; set; }

    public DateTime DataCriacao { get; set; } = DateTime.UtcNow;
    public DateTime? DataAtualizacao { get; set; }
}
