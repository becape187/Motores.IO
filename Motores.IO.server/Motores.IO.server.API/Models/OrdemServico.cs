using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Motores.IO.server.API.Models;

public class OrdemServico
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    public Guid MotorId { get; set; }

    [Required]
    [MaxLength(50)]
    public string NumeroOS { get; set; } = string.Empty;

    [Required]
    public DateTime DataAbertura { get; set; } = DateTime.UtcNow;

    public DateTime? DataEncerramento { get; set; }

    public DateTime? DataPrevista { get; set; }

    [Required]
    [MaxLength(50)]
    public string Status { get; set; } = "aberta"; // aberta, concluida, atrasada, pendente

    [Required]
    [MaxLength(1000)]
    public string Descricao { get; set; } = string.Empty;

    [Required]
    [MaxLength(50)]
    public string Tipo { get; set; } = "preventiva"; // preventiva, corretiva, preditiva

    // Relacionamentos
    [ForeignKey("MotorId")]
    public virtual Motor Motor { get; set; } = null!;

    public virtual ICollection<RelatorioOS> Relatorios { get; set; } = new List<RelatorioOS>();
}
