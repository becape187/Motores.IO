namespace Motores.IO.server.API.DTOs;

public class LoginResponse
{
    public string Token { get; set; } = string.Empty;
    public Guid UsuarioId { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Perfil { get; set; } = string.Empty;
    public List<PlantaDto> Plantas { get; set; } = new List<PlantaDto>();
    public TemaConfiguracaoDto? TemaCliente { get; set; }
    public TemaConfiguracaoDto? TemaUsuario { get; set; }
}

public class PlantaDto
{
    public Guid Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string? Codigo { get; set; }
    public Guid ClienteId { get; set; }
    public string ClienteNome { get; set; } = string.Empty;
}

public class TemaConfiguracaoDto
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
