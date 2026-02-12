using System.Text.Json.Serialization;

namespace Motores.IO.server.API.DTOs;

public class CorrentesArrayDto
{
    [JsonPropertyName("tipo")]
    public string? Tipo { get; set; }

    [JsonPropertyName("plantaId")]
    public string? PlantaId { get; set; }

    [JsonPropertyName("motores")]
    public List<MotorCorrenteDto>? Motores { get; set; }

    [JsonPropertyName("timestamp")]
    public long? Timestamp { get; set; }
}

public class MotorCorrenteDto
{
    [JsonPropertyName("id")]
    public string? Id { get; set; }

    [JsonPropertyName("correnteAtual")]
    public decimal CorrenteAtual { get; set; }

    [JsonPropertyName("correnteMedia")]
    public decimal? CorrenteMedia { get; set; }

    [JsonPropertyName("correnteMaxima")]
    public decimal? CorrenteMaxima { get; set; }

    [JsonPropertyName("correnteMinima")]
    public decimal? CorrenteMinima { get; set; }

    [JsonPropertyName("status")]
    public string? Status { get; set; }
}
