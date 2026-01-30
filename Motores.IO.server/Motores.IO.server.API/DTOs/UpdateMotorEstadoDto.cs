namespace Motores.IO.server.API.DTOs;

/// <summary>
/// DTO para atualizar apenas o estado dinâmico do motor (vindo do PLC/socket)
/// Este endpoint deve ser usado apenas pelo sistema de integração com PLC
/// </summary>
public class UpdateMotorEstadoDto
{
    public string Status { get; set; } = "desligado";
    public decimal Horimetro { get; set; }
    // Nota: CorrenteAtual será armazenado no HistoricoMotor quando implementado
}
