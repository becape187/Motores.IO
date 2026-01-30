namespace Motores.IO.server.API.DTOs;

public class UsuarioUpdateDto
{
    public Guid Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? Senha { get; set; } // Opcional - só atualiza se fornecido
    public string Perfil { get; set; } = "visualizador";
    public bool Ativo { get; set; } = true;
    public Guid ClienteId { get; set; }
    public List<Guid>? PlantaIds { get; set; } // Lista de IDs das plantas para associar
}
