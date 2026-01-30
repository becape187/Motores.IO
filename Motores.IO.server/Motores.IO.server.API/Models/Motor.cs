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

    public decimal CorrenteInicial { get; set; }

    public string Status { get; set; } = "desligado"; // ligado, desligado, alerta, alarme, pendente

    public decimal Horimetro { get; set; }

    public decimal CorrenteAtual { get; set; }

    public decimal? PosicaoX { get; set; }

    public decimal? PosicaoY { get; set; }

    // Dados de manutenção
    public decimal? HorimetroProximaManutencao { get; set; }

    public DateTime? DataEstimadaProximaManutencao { get; set; }

    public int TotalOS { get; set; } = 0;

    public decimal? MediaHorasDia { get; set; }

    public decimal? MediaHorasSemana { get; set; }

    public decimal? MediaHorasMes { get; set; }

    public DateTime DataCriacao { get; set; } = DateTime.UtcNow;
    public DateTime? DataAtualizacao { get; set; }

    // Relacionamentos
    public virtual ICollection<HistoricoMotor> Historicos { get; set; } = new List<HistoricoMotor>();
    public virtual ICollection<Alarme> Alarmes { get; set; } = new List<Alarme>();
    public virtual ICollection<OrdemServico> OrdensServico { get; set; } = new List<OrdemServico>();
}
