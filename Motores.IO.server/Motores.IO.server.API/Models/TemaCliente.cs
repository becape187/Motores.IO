using System.Text.Json;

namespace Motores.IO.server.API.Models;

public class TemaCliente
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid ClienteId { get; set; }

    // Configurações de tema armazenadas como JSON
    public string ConfiguracaoJson { get; set; } = "{}";

    public DateTime DataCriacao { get; set; } = DateTime.UtcNow;

    public DateTime? DataAtualizacao { get; set; }

    // Relacionamento
    public virtual Cliente Cliente { get; set; } = null!;

    // Métodos auxiliares para trabalhar com o JSON
    public TemaConfiguracao? ObterConfiguracao()
    {
        try
        {
            return JsonSerializer.Deserialize<TemaConfiguracao>(ConfiguracaoJson);
        }
        catch
        {
            return null;
        }
    }

    public void DefinirConfiguracao(TemaConfiguracao configuracao)
    {
        ConfiguracaoJson = JsonSerializer.Serialize(configuracao);
    }
}

// Classe para representar a configuração do tema
public class TemaConfiguracao
{
    public string? LogoPath { get; set; }
    public string? CorPrimaria { get; set; }
    public string? CorSecundaria { get; set; }
    public string? CorTerciaria { get; set; }
    public string? CorFundo { get; set; }
    public string? CorTexto { get; set; }
    public Dictionary<string, string>? CoresCustomizadas { get; set; }
    public Dictionary<string, string>? EstilosCSS { get; set; }
}
