using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Motores.IO.server.API.Models;

public class Alarme
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    public Guid MotorId { get; set; }

    [Required]
    [MaxLength(200)]
    public string MotorNome { get; set; } = string.Empty;

    [Required]
    [MaxLength(50)]
    public string Tipo { get; set; } = "info"; // erro, alerta, info

    [Required]
    [MaxLength(500)]
    public string Mensagem { get; set; } = string.Empty;

    [Required]
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;

    [Required]
    public bool Reconhecido { get; set; } = false;

    public DateTime? DataReconhecimento { get; set; }

    public Guid? UsuarioReconhecimentoId { get; set; }

    // Relacionamento
    [ForeignKey("MotorId")]
    public virtual Motor Motor { get; set; } = null!;
}
