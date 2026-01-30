using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Motores.IO.server.API.Data;
using Motores.IO.server.API.DTOs;

namespace Motores.IO.server.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class MotorsController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public MotorsController(ApplicationDbContext context)
    {
        _context = context;
    }

    // GET: api/motors
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Models.Motor>>> GetMotores([FromQuery] Guid? plantaId = null)
    {
        var query = _context.Motores.AsQueryable();
        
        if (plantaId.HasValue)
        {
            query = query.Where(m => m.PlantaId == plantaId.Value);
        }
        
        return await query.ToListAsync();
    }

    // GET: api/motors/5
    [HttpGet("{id}")]
    public async Task<ActionResult<Models.Motor>> GetMotor(Guid id)
    {
        var motor = await _context.Motores.FindAsync(id);

        if (motor == null)
        {
            return NotFound();
        }

        return motor;
    }

    // POST: api/motors
    [HttpPost]
    public async Task<ActionResult<Models.Motor>> PostMotor(Models.Motor motor)
    {
        motor.Id = Guid.NewGuid();
        motor.DataCriacao = DateTime.UtcNow;
        _context.Motores.Add(motor);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetMotor), new { id = motor.Id }, motor);
    }

    // PUT: api/motors/5 - Atualizar configuração do motor (DEPRECATED - usar endpoints específicos)
    [HttpPut("{id}")]
    public async Task<IActionResult> PutMotor(Guid id, Models.Motor motor)
    {
        if (id != motor.Id)
        {
            return BadRequest();
        }

        // Buscar o motor existente para preservar campos protegidos
        var existingMotor = await _context.Motores.FindAsync(id);
        if (existingMotor == null)
        {
            return NotFound();
        }

        // PROTEGER CAMPOS DINÂMICOS - NÃO PODEM SER SOBRESCRITOS
        // Preservar campos que vêm do PLC/socket (Status e Horimetro são atualizados apenas via endpoint /estado)
        motor.Status = existingMotor.Status;
        motor.Horimetro = existingMotor.Horimetro;
        
        // Preservar posição (deve ser atualizada via endpoint específico)
        motor.PosicaoX = existingMotor.PosicaoX;
        motor.PosicaoY = existingMotor.PosicaoY;
        
        // Preservar dados de manutenção (devem ser atualizados via endpoint específico)
        motor.HorimetroProximaManutencao = existingMotor.HorimetroProximaManutencao;
        motor.DataEstimadaProximaManutencao = existingMotor.DataEstimadaProximaManutencao;

        // Preservar PlantaId se não foi enviado no request
        if (motor.PlantaId == null && existingMotor.PlantaId != null)
        {
            motor.PlantaId = existingMotor.PlantaId;
        }

        // Preservar DataCriacao
        motor.DataCriacao = existingMotor.DataCriacao;
        motor.DataAtualizacao = DateTime.UtcNow;

        _context.Entry(existingMotor).CurrentValues.SetValues(motor);

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!MotorExists(id))
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

    // PATCH: api/motors/{id}/configuracao - Atualizar apenas configuração do motor
    [HttpPatch("{id}/configuracao")]
    public async Task<IActionResult> UpdateConfiguracao(Guid id, UpdateMotorConfiguracaoDto dto)
    {
        var motor = await _context.Motores.FindAsync(id);
        if (motor == null)
        {
            return NotFound();
        }

        // Atualizar apenas campos de configuração
        motor.Nome = dto.Nome;
        motor.Potencia = dto.Potencia;
        motor.Tensao = dto.Tensao;
        motor.CorrenteNominal = dto.CorrenteNominal;
        motor.PercentualCorrenteMaxima = dto.PercentualCorrenteMaxima;
        motor.Histerese = dto.Histerese;
        motor.Habilitado = dto.Habilitado;
        
        // Preservar PlantaId se não foi enviado
        if (dto.PlantaId.HasValue)
        {
            motor.PlantaId = dto.PlantaId;
        }

        motor.DataAtualizacao = DateTime.UtcNow;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!MotorExists(id))
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

    // PATCH: api/motors/{id}/posicao - Atualizar apenas posição do motor no mapa
    [HttpPatch("{id}/posicao")]
    public async Task<IActionResult> UpdatePosicao(Guid id, UpdateMotorPosicaoDto dto)
    {
        var motor = await _context.Motores.FindAsync(id);
        if (motor == null)
        {
            return NotFound();
        }

        // Atualizar apenas posição
        motor.PosicaoX = dto.PosicaoX;
        motor.PosicaoY = dto.PosicaoY;
        motor.DataAtualizacao = DateTime.UtcNow;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!MotorExists(id))
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

    // PATCH: api/motors/{id}/manutencao - Atualizar apenas dados de manutenção
    [HttpPatch("{id}/manutencao")]
    public async Task<IActionResult> UpdateManutencao(Guid id, UpdateMotorManutencaoDto dto)
    {
        var motor = await _context.Motores.FindAsync(id);
        if (motor == null)
        {
            return NotFound();
        }

        // Atualizar apenas dados de manutenção
        motor.HorimetroProximaManutencao = dto.HorimetroProximaManutencao;
        motor.DataEstimadaProximaManutencao = dto.DataEstimadaProximaManutencao;
        motor.DataAtualizacao = DateTime.UtcNow;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!MotorExists(id))
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

    // PATCH: api/motors/{id}/estado - Atualizar estado dinâmico (apenas para integração PLC/socket)
    [HttpPatch("{id}/estado")]
    public async Task<IActionResult> UpdateEstado(Guid id, UpdateMotorEstadoDto dto)
    {
        var motor = await _context.Motores.FindAsync(id);
        if (motor == null)
        {
            return NotFound();
        }

        // Atualizar apenas estado dinâmico (vindo do PLC)
        motor.Status = dto.Status;
        motor.Horimetro = dto.Horimetro;
        // Nota: CorrenteAtual será armazenado no HistoricoMotor quando implementado
        // Não atualizar DataAtualizacao para estado dinâmico (muito frequente)

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!MotorExists(id))
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

    // DELETE: api/motors/5
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteMotor(Guid id)
    {
        var motor = await _context.Motores.FindAsync(id);
        if (motor == null)
        {
            return NotFound();
        }

        _context.Motores.Remove(motor);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    private bool MotorExists(Guid id)
    {
        return _context.Motores.Any(e => e.Id == id);
    }
}
