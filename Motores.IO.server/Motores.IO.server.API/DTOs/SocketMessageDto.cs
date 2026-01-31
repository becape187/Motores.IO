using System.Text.Json.Serialization;

namespace Motores.IO.server.API.DTOs;

public class SocketMessageDto
{
    [JsonPropertyName("tipo")]
    public string? Tipo { get; set; }

    [JsonPropertyName("id")]
    public string? Id { get; set; }

    [JsonPropertyName("nome")]
    public string? Nome { get; set; }

    [JsonPropertyName("correnteAtual")]
    public decimal? CorrenteAtual { get; set; }

    [JsonPropertyName("status")]
    public string? Status { get; set; }

    [JsonPropertyName("horimetro")]
    public decimal? Horimetro { get; set; }

    [JsonPropertyName("timestamp")]
    public long? Timestamp { get; set; }
}