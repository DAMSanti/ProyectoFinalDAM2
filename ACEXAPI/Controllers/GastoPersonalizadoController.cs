using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ACEXAPI.Data;
using ACEXAPI.Models;
using ACEXAPI.DTOs;

namespace ACEXAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class GastoPersonalizadoController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public GastoPersonalizadoController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/GastoPersonalizado/actividad/{actividadId}
        [HttpGet("actividad/{actividadId}")]
        public async Task<ActionResult<IEnumerable<GastoPersonalizadoDto>>> GetGastosByActividad(int actividadId)
        {
            try
            {
                var gastos = await _context.Set<GastoPersonalizado>()
                    .Where(g => g.ActividadId == actividadId)
                    .OrderBy(g => g.FechaCreacion)
                    .Select(g => new GastoPersonalizadoDto
                    {
                        Id = g.Id,
                        ActividadId = g.ActividadId,
                        Concepto = g.Concepto,
                        Cantidad = g.Cantidad,
                        FechaCreacion = g.FechaCreacion
                    })
                    .ToListAsync();

                return Ok(gastos);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ERROR] GetGastosByActividad: {ex.Message}");
                Console.WriteLine($"[ERROR] Stack trace: {ex.StackTrace}");
                return StatusCode(500, new { message = "Error al cargar gastos", detail = ex.Message });
            }
        }

        // POST: api/GastoPersonalizado
        [HttpPost]
        public async Task<ActionResult<GastoPersonalizadoDto>> CreateGasto([FromBody] CreateGastoPersonalizadoDto dto)
        {
            var gasto = new GastoPersonalizado
            {
                ActividadId = dto.ActividadId,
                Concepto = dto.Concepto,
                Cantidad = dto.Cantidad,
                FechaCreacion = DateTime.Now
            };

            _context.Set<GastoPersonalizado>().Add(gasto);
            await _context.SaveChangesAsync();

            var gastoDto = new GastoPersonalizadoDto
            {
                Id = gasto.Id,
                ActividadId = gasto.ActividadId,
                Concepto = gasto.Concepto,
                Cantidad = gasto.Cantidad,
                FechaCreacion = gasto.FechaCreacion
            };

            return CreatedAtAction(nameof(GetGastosByActividad), new { actividadId = gasto.ActividadId }, gastoDto);
        }

        // PUT: api/GastoPersonalizado/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateGasto(int id, [FromBody] CreateGastoPersonalizadoDto dto)
        {
            var gasto = await _context.Set<GastoPersonalizado>().FindAsync(id);
            if (gasto == null)
            {
                return NotFound();
            }

            gasto.Concepto = dto.Concepto;
            gasto.Cantidad = dto.Cantidad;

            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE: api/GastoPersonalizado/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteGasto(int id)
        {
            var gasto = await _context.Set<GastoPersonalizado>().FindAsync(id);
            if (gasto == null)
            {
                return NotFound();
            }

            _context.Set<GastoPersonalizado>().Remove(gasto);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
