using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Motores.IO.server.API.Models;

public class Motor
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    [MaxLength(200)]
    public string Nome { get; set; } = string.Empty;

    [Required]
    [Column(TypeName = "decimal(10,2)")]
    public decimal Potencia { get; set; }

    [Required]
    [Column(TypeName = "decimal(10,2)")]
    public decimal Tensao { get; set; }

    [Required]
    [Column(TypeName = "decimal(10,2)")]
    public decimal CorrenteNominal { get; set; }

    [Required]
    [Column(TypeName = "decimal(5,2)")]
    public decimal PercentualCorrenteMaxima { get; set; }

    [Required]
    [Column(TypeName = "decimal(5,2)")]
    public decimal Histerese { get; set; }

    [Required]
    [Column(TypeName = "decimal(10,2)")]
    public decimal CorrenteInicial { get; set; }

    [Required]
    [MaxLength(50)]
    public string Status { get; set; } = "desligado"; // ligado, desligado, alerta, alarme, pendente

    [Required]
    [Column(TypeName = "decimal(10,2)")]
    public decimal Horimetro { get; set; }

    [Required]
    [Column(TypeName = "decimal(10,2)")]
    public decimal CorrenteAtual { get; set; }

    [Column(TypeName = "decimal(10,2)")]
    public decimal? PosicaoX { get; set; }

    [Column(TypeName = "decimal(10,2)")]
    public decimal? PosicaoY { get; set; }

    // Dados de manutenção
    [Column(TypeName = "decimal(10,2)")]
    public decimal? HorimetroProximaManutencao { get; set; }

    public DateTime? DataEstimadaProximaManutencao { get; set; }

    public int TotalOS { get; set; } = 0;

    [Column(TypeName = "decimal(10,2)")]
    public decimal? MediaHorasDia { get; set; }

    [Column(TypeName = "decimal(10,2)")]
    public decimal? MediaHorasSemana { get; set; }

    [Column(TypeName = "decimal(10,2)")]
    public decimal? MediaHorasMes { get; set; }

    public DateTime DataCriacao { get; set; } = DateTime.UtcNow;
    public DateTime? DataAtualizacao { get; set; }

    // Relacionamentos
    public virtual ICollection<HistoricoMotor> Historicos { get; set; } = new List<HistoricoMotor>();
    public virtual ICollection<Alarme> Alarmes { get; set; } = new List<Alarme>();
    public virtual ICollection<OrdemServico> OrdensServico { get; set; } = new List<OrdemServico>();
}
