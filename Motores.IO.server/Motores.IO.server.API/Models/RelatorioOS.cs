using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Motores.IO.server.API.Models;

public class RelatorioOS
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    public Guid OSId { get; set; }

    [Required]
    public DateTime Data { get; set; } = DateTime.UtcNow;

    [Required]
    [MaxLength(200)]
    public string Tecnico { get; set; } = string.Empty;

    [Required]
    [MaxLength(2000)]
    public string Descricao { get; set; } = string.Empty;

    [MaxLength(2000)]
    public string? Observacoes { get; set; }

    // Armazenar caminhos dos anexos (JSON ou array)
    [Column(TypeName = "text")]
    public string? Anexos { get; set; }

    // Relacionamento
    [ForeignKey("OSId")]
    public virtual OrdemServico OrdemServico { get; set; } = null!;
}
