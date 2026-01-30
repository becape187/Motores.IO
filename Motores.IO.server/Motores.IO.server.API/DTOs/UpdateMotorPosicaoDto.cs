namespace Motores.IO.server.API.DTOs;

/// <summary>
/// DTO para atualizar apenas a posição do motor no mapa
/// </summary>
public class UpdateMotorPosicaoDto
{
    public decimal? PosicaoX { get; set; }
    public decimal? PosicaoY { get; set; }
}
