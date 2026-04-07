namespace Motores.IO.server.API.DTOs;

public class ReordenarMotoresDto
{
    public List<MotorOrdemItem> Itens { get; set; } = new();
}

public class MotorOrdemItem
{
    public Guid Id { get; set; }
    public int Ordem { get; set; }
}
