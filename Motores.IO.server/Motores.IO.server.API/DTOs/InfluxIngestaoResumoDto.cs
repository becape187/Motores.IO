namespace Motores.IO.server.API.DTOs;

public class InfluxIngestaoResumoDto
{
    public bool InfluxRespondendo { get; set; }

    public string? ErroConexao { get; set; }

    public string Bucket { get; set; } = "";

    public string Org { get; set; } = "";

    public DateTime? UltimoPontoUtc { get; set; }

    public long? PontosUltimos30Dias { get; set; }

    /// <summary>Contagem em todo o bucket; consulta pesada em VM fraca — use com cuidado.</summary>
    public long? PontosTodoPeriodo { get; set; }

    public string? Aviso { get; set; }
}
