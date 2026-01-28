using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Motores.IO.server.API.Models;

public class HistoricoMotor
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    public Guid MotorId { get; set; }

    [Required]
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;

    [Required]
    [Column(TypeName = "decimal(10,2)")]
    public decimal Corrente { get; set; }

    [Required]
    [Column(TypeName = "decimal(10,2)")]
    public decimal Tensao { get; set; }

    [Required]
    [Column(TypeName = "decimal(10,2)")]
    public decimal Temperatura { get; set; }

    [Required]
    [MaxLength(50)]
    public string Status { get; set; } = string.Empty;

    // Relacionamento
    [ForeignKey("MotorId")]
    public virtual Motor Motor { get; set; } = null!;
}
