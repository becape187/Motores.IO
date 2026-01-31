using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Motores.IO.server.API.Data;
using System.Security.Claims;

namespace Motores.IO.server.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class PlantasController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public PlantasController(ApplicationDbContext context)
    {
        _context = context;
    }

    // GET: api/plantas
    [HttpGet]
    public async Task<ActionResult<IEnumerable<object>>> GetPlantas(
        [FromQuery] Guid? clienteId = null,
        [FromQuery] bool? ativo = null)
    {
        var query = _context.Plantas.AsQueryable();

        if (clienteId.HasValue)
        {
            query = query.Where(p => p.ClienteId == clienteId.Value);
        }

        if (ativo.HasValue)
        {
            query = query.Where(p => p.Ativo == ativo.Value);
        }

        var plantas = await query
            .Include(p => p.Cliente)
            .Select(p => new
            {
                p.Id,
                p.Nome,
                p.Codigo,
                p.Endereco,
                p.Cidade,
                p.Estado,
                p.Ativo,
                p.ClienteId,
                Cliente = new
                {
                    p.Cliente.Id,
                    p.Cliente.Nome
                },
                p.DataCriacao,
                p.DataAtualizacao
            })
            .ToListAsync();

        return Ok(plantas);
    }

    // GET: api/plantas/por-usuario - Retorna plantas disponíveis para o usuário logado
    [HttpGet("por-usuario")]
    public async Task<ActionResult<IEnumerable<Models.Planta>>> GetPlantasPorUsuario()
    {
        var usuarioIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(usuarioIdClaim) || !Guid.TryParse(usuarioIdClaim, out var usuarioId))
        {
            return Unauthorized();
        }

        var plantas = await _context.UsuariosPlantas
            .Where(up => up.UsuarioId == usuarioId)
            .Include(up => up.Planta)
                .ThenInclude(p => p.Cliente)
            .Select(up => up.Planta)
            .Where(p => p.Ativo)
            .ToListAsync();

        return Ok(plantas);
    }

    // GET: api/plantas/5
    [HttpGet("{id}")]
    public async Task<ActionResult<Models.Planta>> GetPlanta(Guid id)
    {
        var planta = await _context.Plantas
            .Include(p => p.Cliente)
            .FirstOrDefaultAsync(p => p.Id == id);

        if (planta == null)
        {
            return NotFound();
        }

        return planta;
    }

    // POST: api/plantas
    [HttpPost]
    public async Task<ActionResult<Models.Planta>> PostPlanta(Models.Planta planta)
    {
        planta.Id = Guid.NewGuid();
        planta.DataCriacao = DateTime.UtcNow;
        _context.Plantas.Add(planta);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetPlanta), new { id = planta.Id }, planta);
    }

    // PUT: api/plantas/5
    [HttpPut("{id}")]
    public async Task<IActionResult> PutPlanta(Guid id, Models.Planta planta)
    {
        if (id != planta.Id)
        {
            return BadRequest();
        }

        planta.DataAtualizacao = DateTime.UtcNow;
        _context.Entry(planta).State = EntityState.Modified;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!PlantaExists(id))
            {
                return NotFound();
            }
            else
            {
                throw;
            }
        }

        return NoContent();
    }

    // DELETE: api/plantas/5
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeletePlanta(Guid id)
    {
        var planta = await _context.Plantas.FindAsync(id);
        if (planta == null)
        {
            return NotFound();
        }

        _context.Plantas.Remove(planta);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    // POST: api/plantas/{plantaId}/usuarios/{usuarioId} - Associar usuário a planta
    [HttpPost("{plantaId}/usuarios/{usuarioId}")]
    public async Task<IActionResult> AssociarUsuarioPlanta(Guid plantaId, Guid usuarioId)
    {
        if (await _context.UsuariosPlantas.AnyAsync(up => up.UsuarioId == usuarioId && up.PlantaId == plantaId))
        {
            return BadRequest("Usuário já está associado a esta planta");
        }

        var usuarioPlanta = new Models.UsuarioPlanta
        {
            Id = Guid.NewGuid(),
            UsuarioId = usuarioId,
            PlantaId = plantaId,
            DataCriacao = DateTime.UtcNow
        };

        _context.UsuariosPlantas.Add(usuarioPlanta);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetPlanta), new { id = plantaId }, usuarioPlanta);
    }

    // DELETE: api/plantas/{plantaId}/usuarios/{usuarioId} - Remover associação
    [HttpDelete("{plantaId}/usuarios/{usuarioId}")]
    public async Task<IActionResult> RemoverUsuarioPlanta(Guid plantaId, Guid usuarioId)
    {
        var usuarioPlanta = await _context.UsuariosPlantas
            .FirstOrDefaultAsync(up => up.UsuarioId == usuarioId && up.PlantaId == plantaId);

        if (usuarioPlanta == null)
        {
            return NotFound();
        }

        _context.UsuariosPlantas.Remove(usuarioPlanta);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    // POST: api/plantas/{id}/gerar-token - Gerar ou regenerar token da planta
    [HttpPost("{id}/gerar-token")]
    public async Task<ActionResult<object>> GerarTokenPlanta(Guid id)
    {
        var planta = await _context.Plantas.FindAsync(id);
        if (planta == null)
        {
            return NotFound();
        }

        // Gerar um token único e seguro
        var token = Convert.ToBase64String(Guid.NewGuid().ToByteArray())
            .Replace("+", "-")
            .Replace("/", "_")
            .Replace("=", "")
            + "-" + Convert.ToBase64String(Guid.NewGuid().ToByteArray())
            .Replace("+", "-")
            .Replace("/", "_")
            .Replace("=", "");

        // Hash do token antes de armazenar (usando BCrypt como nas senhas)
        var tokenHash = BCrypt.Net.BCrypt.HashPassword(token);

        planta.ApiToken = tokenHash;
        planta.ApiTokenGeradoEm = DateTime.UtcNow;
        planta.DataAtualizacao = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return Ok(new
        {
            token = token,
            geradoEm = planta.ApiTokenGeradoEm,
            mensagem = "Token gerado com sucesso. Guarde este token com segurança, pois ele não será exibido novamente e não pode ser recuperado do banco de dados."
        });
    }

    // GET: api/plantas/{id}/token - Verificar se existe token (sem mostrar completo)
    [HttpGet("{id}/token")]
    public async Task<ActionResult<object>> VerificarTokenPlanta(Guid id)
    {
        var planta = await _context.Plantas.FindAsync(id);
        if (planta == null)
        {
            return NotFound();
        }

        if (string.IsNullOrEmpty(planta.ApiToken))
        {
            return Ok(new
            {
                possuiToken = false,
                geradoEm = (DateTime?)null
            });
        }

        // Mostrar apenas os últimos 8 caracteres do token por segurança
        var tokenOculto = "****" + planta.ApiToken.Substring(Math.Max(0, planta.ApiToken.Length - 8));

        return Ok(new
        {
            possuiToken = true,
            tokenOculto = tokenOculto,
            geradoEm = planta.ApiTokenGeradoEm
        });
    }

    // GET: api/plantas/{id}/motores - Obter motores da planta (aceita JWT ou PlantaToken)
    [HttpGet("{id}/motores")]
    public async Task<ActionResult<IEnumerable<Models.Motor>>> GetMotoresPlanta(Guid id)
    {
        try
        {
            // Verificar se a planta existe e está ativa
            var planta = await _context.Plantas
                .FirstOrDefaultAsync(p => p.Id == id && p.Ativo);

            if (planta == null)
            {
                return NotFound("Planta não encontrada ou inativa");
            }

            // Se autenticado com token de planta, verificar se o token pertence a esta planta
            var authType = User.FindFirst("AuthType")?.Value;
            if (authType == "PlantaToken")
            {
                var plantaIdClaim = User.FindFirst("PlantaId")?.Value;
                if (plantaIdClaim != id.ToString())
                {
                    return Forbid("Token de planta não autorizado para esta planta");
                }
            }

            // Buscar motores da planta (sem incluir relacionamentos para evitar referências circulares)
            var motores = await _context.Motores
                .Where(m => m.PlantaId == id)
                .Select(m => new Models.Motor
                {
                    Id = m.Id,
                    Nome = m.Nome,
                    Potencia = m.Potencia,
                    Tensao = m.Tensao,
                    CorrenteNominal = m.CorrenteNominal,
                    PercentualCorrenteMaxima = m.PercentualCorrenteMaxima,
                    Histerese = m.Histerese,
                    RegistroModBus = m.RegistroModBus,
                    RegistroLocal = m.RegistroLocal,
                    Status = m.Status,
                    Horimetro = m.Horimetro,
                    Habilitado = m.Habilitado,
                    PosicaoX = m.PosicaoX,
                    PosicaoY = m.PosicaoY,
                    HorimetroProximaManutencao = m.HorimetroProximaManutencao,
                    DataEstimadaProximaManutencao = m.DataEstimadaProximaManutencao,
                    DataCriacao = m.DataCriacao,
                    DataAtualizacao = m.DataAtualizacao,
                    PlantaId = m.PlantaId
                })
                .ToListAsync();

            return Ok(motores);
        }
        catch (Exception ex)
        {
            // Log do erro para debug
            return StatusCode(500, new { 
                error = "Erro interno do servidor", 
                message = ex.Message,
                stackTrace = ex.StackTrace
            });
        }
    }

    // PUT: api/plantas/{plantaId}/motores/{motorId} - Atualizar motor da planta (aceita JWT ou PlantaToken)
    [HttpPut("{plantaId}/motores/{motorId}")]
    public async Task<IActionResult> AtualizarMotorPlanta(Guid plantaId, Guid motorId, Models.Motor motor)
    {
        // Verificar se a planta existe e está ativa
        var planta = await _context.Plantas
            .FirstOrDefaultAsync(p => p.Id == plantaId && p.Ativo);

        if (planta == null)
        {
            return NotFound("Planta não encontrada ou inativa");
        }

        // Se autenticado com token de planta, verificar se o token pertence a esta planta
        var authType = User.FindFirst("AuthType")?.Value;
        if (authType == "PlantaToken")
        {
            var plantaIdClaim = User.FindFirst("PlantaId")?.Value;
            if (plantaIdClaim != plantaId.ToString())
            {
                return Forbid("Token de planta não autorizado para esta planta");
            }
        }

        // Verificar se o motor existe e pertence à planta
        var existingMotor = await _context.Motores
            .FirstOrDefaultAsync(m => m.Id == motorId && m.PlantaId == plantaId);

        if (existingMotor == null)
        {
            return NotFound("Motor não encontrado ou não pertence a esta planta");
        }

        // Verificar se o ID do motor no body corresponde ao ID na rota
        if (motor.Id != motorId)
        {
            return BadRequest("ID do motor no body não corresponde ao ID na rota");
        }

        // Preservar campos protegidos (Status e Horimetro são atualizados apenas via endpoint /estado)
        motor.Status = existingMotor.Status;
        motor.Horimetro = existingMotor.Horimetro;
        motor.PosicaoX = existingMotor.PosicaoX;
        motor.PosicaoY = existingMotor.PosicaoY;
        motor.HorimetroProximaManutencao = existingMotor.HorimetroProximaManutencao;
        motor.DataEstimadaProximaManutencao = existingMotor.DataEstimadaProximaManutencao;
        motor.PlantaId = plantaId; // Garantir que o motor pertence à planta correta
        motor.DataCriacao = existingMotor.DataCriacao;
        motor.DataAtualizacao = DateTime.UtcNow;

        _context.Entry(existingMotor).CurrentValues.SetValues(motor);

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!await _context.Motores.AnyAsync(m => m.Id == motorId))
            {
                return NotFound();
            }
            else
            {
                throw;
            }
        }

        return NoContent();
    }

    private bool PlantaExists(Guid id)
    {
        return _context.Plantas.Any(e => e.Id == id);
    }
}
