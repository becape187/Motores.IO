namespace Motores.IO.server.API.DTOs;

public class UsuarioCreateDto
{
    public string Nome { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Senha { get; set; } = string.Empty;
    public string Perfil { get; set; } = "visualizador";
    public bool Ativo { get; set; } = true;
}
