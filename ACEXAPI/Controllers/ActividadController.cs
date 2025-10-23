using ACEXAPI.DTOs;
using ACEXAPI.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ACEXAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ActividadController : ControllerBase
{
    private readonly IActividadService _actividadService;
    private readonly ILogger<ActividadController> _logger;

    public ActividadController(IActividadService actividadService, ILogger<ActividadController> logger)
    {
        _actividadService = actividadService;
        _logger = logger;
    }

    /// <summary>
    /// Obtiene todas las actividades con paginación, filtrado y ordenamiento
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(PaginatedResult<ActividadListDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<PaginatedResult<ActividadListDto>>> GetAll([FromQuery] QueryParameters queryParams)
    {
        var result = await _actividadService.GetAllAsync(queryParams);
        return Ok(result);
    }

    /// <summary>
    /// Obtiene una actividad por su ID
    /// </summary>
    [HttpGet("{id}")]
    [ProducesResponseType(typeof(ActividadDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ActividadDto>> GetById(int id)
    {
        var actividad = await _actividadService.GetByIdAsync(id);
        if (actividad == null)
            return NotFound(new { message = "Actividad no encontrada" });

        return Ok(actividad);
    }

    /// <summary>
    /// Crea una nueva actividad
    /// </summary>
    [HttpPost]
    [Authorize(Roles = "Administrador,Coordinador")]
    [ProducesResponseType(typeof(ActividadDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<ActividadDto>> Create([FromForm] ActividadCreateDto dto, IFormFile? folleto)
    {
        var actividad = await _actividadService.CreateAsync(dto, folleto);
        return CreatedAtAction(nameof(GetById), new { id = actividad.Id }, actividad);
    }

    /// <summary>
    /// Actualiza una actividad existente
    /// </summary>
    [HttpPut("{id}")]
    [Authorize(Roles = "Administrador,Coordinador")]
    [ProducesResponseType(typeof(ActividadDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ActividadDto>> Update(int id, [FromForm] ActividadUpdateDto dto, IFormFile? folleto)
    {
        var actividad = await _actividadService.UpdateAsync(id, dto, folleto);
        if (actividad == null)
            return NotFound(new { message = "Actividad no encontrada" });

        return Ok(actividad);
    }

    /// <summary>
    /// Elimina una actividad
    /// </summary>
    [HttpDelete("{id}")]
    [Authorize(Roles = "Administrador")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _actividadService.DeleteAsync(id);
        if (!result)
            return NotFound(new { message = "Actividad no encontrada" });

        return NoContent();
    }
}
