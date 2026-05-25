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

    public string? RegistroModBus { get; set; }

    public string? RegistroLocal { get; set; }

    // Campo legado: status agora é derivado na UI a partir de correnteAtual >= CorrenteLimite.
    // Mantido como histórico do último estado conhecido — sem regra de negócio em cima.
    public string Status { get; set; } = "desligado";

    // Horímetro de OPERAÇÃO — incrementa em tempo real (em todo `correntes`, 1/s).
    // É o usado para manutenção; o botão "Zerar Horímetro" zera ESTE campo.
    public decimal Horimetro { get; set; }

    public double HorimetroTs { get; set; }

    public DateTime? UltimoTimestampIntegrado { get; set; }

    // Horímetro CALCULADO — só atualizado quando o usuário clica em "Calcular do Histórico"
    // na tela do motor. Integra TODO o histórico do Influx para o motor. NUNCA é tocado
    // pela contagem em tempo real nem pelo botão de zerar.
    public decimal? HorimetroCalculado { get; set; }

    public DateTime? DataCalculoHorimetro { get; set; }

    public DateTime? DataZeramentoHorimetro { get; set; }

    public bool Habilitado { get; set; } = true; // Para esconder do mapa, alarmes, etc

    public decimal? PosicaoX { get; set; }

    public decimal? PosicaoY { get; set; }

    public int Ordem { get; set; } = 0;

    // Dados de manutenção
    public decimal? CicloManutencao { get; set; }

    public decimal? HorimetroProximaManutencao { get; set; }

    public DateTime? DataEstimadaProximaManutencao { get; set; }

    public DateTime? DataUltimaManutencao { get; set; }

    public DateTime DataCriacao { get; set; } = DateTime.UtcNow;
    public DateTime? DataAtualizacao { get; set; }

    // Relacionamento com Planta
    public Guid? PlantaId { get; set; }

    // Relacionamentos
    public virtual Planta? Planta { get; set; }
    public virtual ICollection<Alarme> Alarmes { get; set; } = new List<Alarme>();
    public virtual ICollection<OrdemServico> OrdensServico { get; set; } = new List<OrdemServico>();
}
