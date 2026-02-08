namespace Motores.IO.server.API.DTOs;

using System.Text.Json.Serialization;

public class FileCommandDto
{
    [JsonPropertyName("acao")]
    public string Acao { get; set; } = string.Empty; // listar, ler, salvar, apagar, info, listar_bancos
    
    [JsonPropertyName("caminho")]
    public string? Caminho { get; set; }
    
    [JsonPropertyName("conteudo")]
    public string? Conteudo { get; set; }
    
    [JsonPropertyName("path")]
    public string? Path { get; set; }
    
    [JsonPropertyName("requestId")]
    public string RequestId { get; set; } = Guid.NewGuid().ToString();
    
    [JsonPropertyName("plantaId")]
    public string? PlantaId { get; set; }
}

public class FileCommandResponseDto
{
    public bool Sucesso { get; set; }
    public string? Erro { get; set; }
    public object? Dados { get; set; }
    public string Acao { get; set; } = string.Empty;
    public string RequestId { get; set; } = string.Empty;
}
