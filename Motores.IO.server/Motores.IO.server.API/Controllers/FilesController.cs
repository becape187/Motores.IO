using Microsoft.AspNetCore.Mvc;
using Motores.IO.server.API.DTOs;
using Motores.IO.server.API.Services;

namespace Motores.IO.server.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class FilesController : ControllerBase
{
    private readonly ISocketServerService _socketServerService;
    private readonly ILogger<FilesController> _logger;

    public FilesController(
        ISocketServerService socketServerService,
        ILogger<FilesController> logger)
    {
        _socketServerService = socketServerService;
        _logger = logger;
    }

    [HttpPost("{plantaId}/listar")]
    public async Task<ActionResult<FileCommandResponseDto>> ListarArquivos(
        string plantaId,
        [FromBody] FileCommandDto? command = null)
    {
        var cmd = command ?? new FileCommandDto();
        
        // Se não tem Acao mas tem Path, assumir "listar"
        if (string.IsNullOrEmpty(cmd.Acao) && !string.IsNullOrEmpty(cmd.Path))
        {
            cmd.Acao = "listar";
        }
        
        // Garantir que Acao sempre está definida
        if (string.IsNullOrEmpty(cmd.Acao))
        {
            cmd.Acao = "listar";
        }
        
        // Garantir que Path está definido se não foi fornecido
        if (string.IsNullOrEmpty(cmd.Path))
        {
            cmd.Path = "/flash";
        }
        
        // Normalizar: se path (minúsculo) foi enviado mas Path não, usar Caminho ou path do body
        // O JSON deserializer pode não mapear path minúsculo para Path maiúsculo
        // Vamos verificar se há um campo "path" no body original
        if (string.IsNullOrEmpty(cmd.Path))
        {
            if (!string.IsNullOrEmpty(cmd.Caminho))
            {
                cmd.Path = cmd.Caminho;
            }
        }
        
        cmd.PlantaId = plantaId;
        if (string.IsNullOrEmpty(cmd.RequestId))
            cmd.RequestId = Guid.NewGuid().ToString();

        var response = await _socketServerService.SendCommandToPlantaAsync(plantaId, cmd);
        
        if (response == null)
        {
            return BadRequest(new FileCommandResponseDto
            {
                Sucesso = false,
                Erro = "Não foi possível comunicar com a IHM"
            });
        }

        return Ok(response);
    }

    [HttpPost("{plantaId}/listar-bancos")]
    public async Task<ActionResult<FileCommandResponseDto>> ListarBancosDados(string plantaId)
    {
        var cmd = new FileCommandDto
        {
            Acao = "listar_bancos",
            RequestId = Guid.NewGuid().ToString(),
            PlantaId = plantaId
        };

        var response = await _socketServerService.SendCommandToPlantaAsync(plantaId, cmd);
        
        if (response == null)
        {
            return BadRequest(new FileCommandResponseDto
            {
                Sucesso = false,
                Erro = "Não foi possível comunicar com a IHM"
            });
        }

        return Ok(response);
    }

    [HttpPost("{plantaId}/ler")]
    public async Task<ActionResult<FileCommandResponseDto>> LerArquivo(
        string plantaId,
        [FromBody] FileCommandDto command)
    {
        if (string.IsNullOrEmpty(command.Caminho))
        {
            return BadRequest(new FileCommandResponseDto
            {
                Sucesso = false,
                Erro = "Caminho não especificado"
            });
        }

        command.Acao = "ler";
        command.PlantaId = plantaId;
        if (string.IsNullOrEmpty(command.RequestId))
            command.RequestId = Guid.NewGuid().ToString();

        var response = await _socketServerService.SendCommandToPlantaAsync(plantaId, command);
        
        if (response == null)
        {
            return BadRequest(new FileCommandResponseDto
            {
                Sucesso = false,
                Erro = "Não foi possível comunicar com a IHM"
            });
        }

        return Ok(response);
    }

    [HttpPost("{plantaId}/salvar")]
    public async Task<ActionResult<FileCommandResponseDto>> SalvarArquivo(
        string plantaId,
        [FromBody] FileCommandDto command)
    {
        if (string.IsNullOrEmpty(command.Caminho))
        {
            return BadRequest(new FileCommandResponseDto
            {
                Sucesso = false,
                Erro = "Caminho não especificado"
            });
        }

        if (command.Conteudo == null)
        {
            return BadRequest(new FileCommandResponseDto
            {
                Sucesso = false,
                Erro = "Conteúdo não especificado"
            });
        }

        command.Acao = "salvar";
        command.PlantaId = plantaId;
        if (string.IsNullOrEmpty(command.RequestId))
            command.RequestId = Guid.NewGuid().ToString();

        var response = await _socketServerService.SendCommandToPlantaAsync(plantaId, command);
        
        if (response == null)
        {
            return BadRequest(new FileCommandResponseDto
            {
                Sucesso = false,
                Erro = "Não foi possível comunicar com a IHM"
            });
        }

        return Ok(response);
    }

    [HttpPost("{plantaId}/apagar")]
    public async Task<ActionResult<FileCommandResponseDto>> ApagarArquivo(
        string plantaId,
        [FromBody] FileCommandDto command)
    {
        if (string.IsNullOrEmpty(command.Caminho))
        {
            return BadRequest(new FileCommandResponseDto
            {
                Sucesso = false,
                Erro = "Caminho não especificado"
            });
        }

        command.Acao = "apagar";
        command.PlantaId = plantaId;
        if (string.IsNullOrEmpty(command.RequestId))
            command.RequestId = Guid.NewGuid().ToString();

        var response = await _socketServerService.SendCommandToPlantaAsync(plantaId, command);
        
        if (response == null)
        {
            return BadRequest(new FileCommandResponseDto
            {
                Sucesso = false,
                Erro = "Não foi possível comunicar com a IHM"
            });
        }

        return Ok(response);
    }

    [HttpPost("{plantaId}/info")]
    public async Task<ActionResult<FileCommandResponseDto>> ObterInfoArquivo(
        string plantaId,
        [FromBody] FileCommandDto command)
    {
        if (string.IsNullOrEmpty(command.Caminho))
        {
            return BadRequest(new FileCommandResponseDto
            {
                Sucesso = false,
                Erro = "Caminho não especificado"
            });
        }

        command.Acao = "info";
        command.PlantaId = plantaId;
        if (string.IsNullOrEmpty(command.RequestId))
            command.RequestId = Guid.NewGuid().ToString();

        var response = await _socketServerService.SendCommandToPlantaAsync(plantaId, command);
        
        if (response == null)
        {
            return BadRequest(new FileCommandResponseDto
            {
                Sucesso = false,
                Erro = "Não foi possível comunicar com a IHM"
            });
        }

        return Ok(response);
    }
}
