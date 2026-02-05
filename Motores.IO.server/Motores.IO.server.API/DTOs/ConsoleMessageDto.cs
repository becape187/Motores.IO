using System.Text.Json.Serialization;

namespace Motores.IO.server.API.DTOs;

public class ConsoleMessageDto
{
    [JsonPropertyName("tipo")]
    public string Tipo { get; set; } = "log"; // "log", "error", "warn", "info"

    [JsonPropertyName("mensagem")]
    public string Mensagem { get; set; } = string.Empty;

    [JsonPropertyName("timestamp")]
    public long Timestamp { get; set; }

    [JsonPropertyName("nivel")]
    public string Nivel { get; set; } = "log"; // "log", "error", "warn", "info"

    [JsonPropertyName("plantaId")]
    public string? PlantaId { get; set; } // ID da planta que enviou a mensagem
}
