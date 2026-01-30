namespace Motores.IO.server.API.Models;

public class Motor
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public string Nome { get; set; } = string.Empty;

    public decimal Potencia { get; set; }

    public decimal Tensao { get; set; }

    public decimal CorrenteNominal { get; set; }

    public decimal PercentualCorrenteMaxima { get; set; }

    public decimal Histerese { get; set; }

    public string Status { get; set; } = "desligado"; // ligado, desligado, alerta, alarme, pendente (dinâmico, recebido via socket)

    public decimal Horimetro { get; set; }

    public bool Habilitado { get; set; } = true; // Para esconder do mapa, alarmes, etc

    public decimal? PosicaoX { get; set; }

    public decimal? PosicaoY { get; set; }

    // Dados de manutenção
    public decimal? HorimetroProximaManutencao { get; set; }

    public DateTime? DataEstimadaProximaManutencao { get; set; }

    public DateTime DataCriacao { get; set; } = DateTime.UtcNow;
    public DateTime? DataAtualizacao { get; set; }

    // Relacionamento com Planta
    public Guid? PlantaId { get; set; }

    // Relacionamentos
    public virtual Planta? Planta { get; set; }
    public virtual ICollection<HistoricoMotor> Historicos { get; set; } = new List<HistoricoMotor>();
    public virtual ICollection<Alarme> Alarmes { get; set; } = new List<Alarme>();
    public virtual ICollection<OrdemServico> OrdensServico { get; set; } = new List<OrdemServico>();
}
