using System.ComponentModel.DataAnnotations;

namespace Motores.IO.server.API.Models;

public class Usuario
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    [MaxLength(200)]
    public string Nome { get; set; } = string.Empty;

    [Required]
    [MaxLength(200)]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required]
    [MaxLength(200)]
    public string SenhaHash { get; set; } = string.Empty;

    [Required]
    [MaxLength(50)]
    public string Perfil { get; set; } = "visualizador"; // admin, operador, visualizador

    [Required]
    public bool Ativo { get; set; } = true;

    public DateTime? UltimoAcesso { get; set; }

    public DateTime DataCriacao { get; set; } = DateTime.UtcNow;
    public DateTime? DataAtualizacao { get; set; }
}
