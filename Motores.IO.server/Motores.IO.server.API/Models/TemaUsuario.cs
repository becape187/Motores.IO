using System.Text.Json;

namespace Motores.IO.server.API.Models;

public class TemaUsuario
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid UsuarioId { get; set; }

    // Configurações de tema pessoal armazenadas como JSON
    public string ConfiguracaoJson { get; set; } = "{}";

    public DateTime DataCriacao { get; set; } = DateTime.UtcNow;

    public DateTime? DataAtualizacao { get; set; }

    // Relacionamento
    public virtual Usuario Usuario { get; set; } = null!;

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
