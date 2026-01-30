using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Motores.IO.server.API.Data;

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
    public async Task<ActionResult<IEnumerable<Models.Motor>>> GetMotores()
    {
        return await _context.Motores.ToListAsync();
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

    // PUT: api/motors/5
    [HttpPut("{id}")]
    public async Task<IActionResult> PutMotor(Guid id, Models.Motor motor)
    {
        if (id != motor.Id)
        {
            return BadRequest();
        }

        motor.DataAtualizacao = DateTime.UtcNow;
        _context.Entry(motor).State = EntityState.Modified;

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
