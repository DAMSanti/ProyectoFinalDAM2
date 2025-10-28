using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ACEXAPI.Data;
using ACEXAPI.DTOs;
using ACEXAPI.Models;

namespace ACEXAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AlojamientoController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<AlojamientoController> _logger;

    public AlojamientoController(ApplicationDbContext context, ILogger<AlojamientoController> logger)
    {
        _context = context;
        _logger = logger;
    }

    // GET: api/alojamiento
    [HttpGet]
    public async Task<ActionResult<IEnumerable<AlojamientoDto>>> GetAlojamientos(
        [FromQuery] bool? soloActivos = true,
        [FromQuery] string? ciudad = null)
    {
        try
        {
            var query = _context.Alojamientos.AsQueryable();

            if (soloActivos == true)
            {
                query = query.Where(a => a.Activo);
            }

            if (!string.IsNullOrEmpty(ciudad))
            {
                query = query.Where(a => a.Ciudad != null && a.Ciudad.Contains(ciudad));
            }

            var alojamientos = await query
                .OrderBy(a => a.Nombre)
                .Select(a => new AlojamientoDto
                {
                    Id = a.Id,
                    Nombre = a.Nombre,
                    Direccion = a.Direccion,
                    Ciudad = a.Ciudad,
                    CodigoPostal = a.CodigoPostal,
                    Provincia = a.Provincia,
                    Telefono = a.Telefono,
                    Email = a.Email,
                    Web = a.Web,
                    CapacidadTotal = a.CapacidadTotal,
                    Observaciones = a.Observaciones,
                    Activo = a.Activo,
                    FechaCreacion = a.FechaCreacion
                })
                .ToListAsync();

            return Ok(alojamientos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener alojamientos");
            return StatusCode(500, "Error al obtener alojamientos");
        }
    }

    // GET: api/alojamiento/5
    [HttpGet("{id}")]
    public async Task<ActionResult<AlojamientoDto>> GetAlojamiento(int id)
    {
        try
        {
            var alojamiento = await _context.Alojamientos
                .Where(a => a.Id == id)
                .Select(a => new AlojamientoDto
                {
                    Id = a.Id,
                    Nombre = a.Nombre,
                    Direccion = a.Direccion,
                    Ciudad = a.Ciudad,
                    CodigoPostal = a.CodigoPostal,
                    Provincia = a.Provincia,
                    Telefono = a.Telefono,
                    Email = a.Email,
                    Web = a.Web,
                    CapacidadTotal = a.CapacidadTotal,
                    Observaciones = a.Observaciones,
                    Activo = a.Activo,
                    FechaCreacion = a.FechaCreacion
                })
                .FirstOrDefaultAsync();

            if (alojamiento == null)
            {
                return NotFound($"Alojamiento con ID {id} no encontrado");
            }

            return Ok(alojamiento);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener alojamiento {Id}", id);
            return StatusCode(500, "Error al obtener alojamiento");
        }
    }

    // POST: api/alojamiento
    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<AlojamientoDto>> CreateAlojamiento(CreateAlojamientoDto dto)
    {
        try
        {
            var alojamiento = new Alojamiento
            {
                Nombre = dto.Nombre,
                Direccion = dto.Direccion,
                Ciudad = dto.Ciudad,
                CodigoPostal = dto.CodigoPostal,
                Provincia = dto.Provincia,
                Telefono = dto.Telefono,
                Email = dto.Email,
                Web = dto.Web,
                CapacidadTotal = dto.CapacidadTotal,
                Observaciones = dto.Observaciones,
                Activo = true,
                FechaCreacion = DateTime.UtcNow
            };

            _context.Alojamientos.Add(alojamiento);
            await _context.SaveChangesAsync();

            var alojamientoDto = new AlojamientoDto
            {
                Id = alojamiento.Id,
                Nombre = alojamiento.Nombre,
                Direccion = alojamiento.Direccion,
                Ciudad = alojamiento.Ciudad,
                CodigoPostal = alojamiento.CodigoPostal,
                Provincia = alojamiento.Provincia,
                Telefono = alojamiento.Telefono,
                Email = alojamiento.Email,
                Web = alojamiento.Web,
                CapacidadTotal = alojamiento.CapacidadTotal,
                Observaciones = alojamiento.Observaciones,
                Activo = alojamiento.Activo,
                FechaCreacion = alojamiento.FechaCreacion
            };

            return CreatedAtAction(nameof(GetAlojamiento), new { id = alojamiento.Id }, alojamientoDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al crear alojamiento");
            return StatusCode(500, "Error al crear alojamiento");
        }
    }

    // PUT: api/alojamiento/5
    [HttpPut("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> UpdateAlojamiento(int id, UpdateAlojamientoDto dto)
    {
        try
        {
            var alojamiento = await _context.Alojamientos.FindAsync(id);
            if (alojamiento == null)
            {
                return NotFound($"Alojamiento con ID {id} no encontrado");
            }

            // Actualizar solo los campos proporcionados
            if (dto.Nombre != null) alojamiento.Nombre = dto.Nombre;
            if (dto.Direccion != null) alojamiento.Direccion = dto.Direccion;
            if (dto.Ciudad != null) alojamiento.Ciudad = dto.Ciudad;
            if (dto.CodigoPostal != null) alojamiento.CodigoPostal = dto.CodigoPostal;
            if (dto.Provincia != null) alojamiento.Provincia = dto.Provincia;
            if (dto.Telefono != null) alojamiento.Telefono = dto.Telefono;
            if (dto.Email != null) alojamiento.Email = dto.Email;
            if (dto.Web != null) alojamiento.Web = dto.Web;
            if (dto.CapacidadTotal.HasValue) alojamiento.CapacidadTotal = dto.CapacidadTotal;
            if (dto.Observaciones != null) alojamiento.Observaciones = dto.Observaciones;
            if (dto.Activo.HasValue) alojamiento.Activo = dto.Activo.Value;

            await _context.SaveChangesAsync();

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al actualizar alojamiento {Id}", id);
            return StatusCode(500, "Error al actualizar alojamiento");
        }
    }

    // DELETE: api/alojamiento/5
    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteAlojamiento(int id)
    {
        try
        {
            var alojamiento = await _context.Alojamientos.FindAsync(id);
            if (alojamiento == null)
            {
                return NotFound($"Alojamiento con ID {id} no encontrado");
            }

            // Verificar si hay actividades usando este alojamiento
            var actividadesConAlojamiento = await _context.Actividades
                .Where(a => a.AlojamientoId == id)
                .CountAsync();

            if (actividadesConAlojamiento > 0)
            {
                // Soft delete: marcar como inactivo en lugar de eliminar
                alojamiento.Activo = false;
                await _context.SaveChangesAsync();
                return Ok(new { message = $"Alojamiento marcado como inactivo. Hay {actividadesConAlojamiento} actividades asociadas." });
            }

            // Si no hay actividades asociadas, eliminar físicamente
            _context.Alojamientos.Remove(alojamiento);
            await _context.SaveChangesAsync();

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al eliminar alojamiento {Id}", id);
            return StatusCode(500, "Error al eliminar alojamiento");
        }
    }

    // GET: api/alojamiento/ciudades
    [HttpGet("ciudades")]
    public async Task<ActionResult<IEnumerable<string>>> GetCiudades()
    {
        try
        {
            var ciudades = await _context.Alojamientos
                .Where(a => a.Ciudad != null)
                .Select(a => a.Ciudad!)
                .Distinct()
                .OrderBy(c => c)
                .ToListAsync();

            return Ok(ciudades);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener ciudades");
            return StatusCode(500, "Error al obtener ciudades");
        }
    }
}
