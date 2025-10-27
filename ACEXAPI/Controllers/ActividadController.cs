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
    /// Obtiene todas las actividades con paginaci�n, filtrado y ordenamiento
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

    /// <summary>
    /// Obtiene los profesores participantes de una actividad
    /// </summary>
    [HttpGet("{id}/profesores-participantes")]
    [ProducesResponseType(typeof(List<string>), StatusCodes.Status200OK)]
    public async Task<ActionResult<List<string>>> GetProfesoresParticipantes(int id)
    {
        var profesoresIds = await _actividadService.GetProfesoresParticipantesAsync(id);
        return Ok(profesoresIds);
    }

    /// <summary>
    /// Actualiza los profesores participantes de una actividad
    /// </summary>
    [HttpPut("{id}/profesores-participantes")]
    [Authorize(Roles = "Administrador,Coordinador")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateProfesoresParticipantes(int id, [FromBody] List<string> profesoresIds)
    {
        var result = await _actividadService.UpdateProfesoresParticipantesAsync(id, profesoresIds);
        if (!result)
            return NotFound(new { message = "Actividad no encontrada" });

        return Ok(new { message = "Profesores participantes actualizados correctamente" });
    }

    /// <summary>
    /// Obtiene los grupos participantes de una actividad
    /// </summary>
    [HttpGet("{id}/grupos-participantes")]
    [ProducesResponseType(typeof(List<GrupoParticipanteDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<List<GrupoParticipanteDto>>> GetGruposParticipantes(int id)
    {
        var grupos = await _actividadService.GetGruposParticipantesAsync(id);
        return Ok(grupos);
    }

    /// <summary>
    /// Actualiza los grupos participantes de una actividad
    /// </summary>
    [HttpPut("{id}/grupos-participantes")]
    [Authorize(Roles = "Administrador,Coordinador")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateGruposParticipantes(int id, [FromBody] List<GrupoParticipanteUpdateDto> grupos)
    {
        var result = await _actividadService.UpdateGruposParticipantesAsync(id, grupos);
        if (!result)
            return NotFound(new { message = "Actividad no encontrada" });

        return Ok(new { message = "Grupos participantes actualizados correctamente" });
    }

    /// <summary>
    /// Sube o actualiza el folleto PDF de una actividad
    /// </summary>
    [HttpPost("{id}/folleto")]
    [Authorize(Roles = "Administrador,Coordinador")]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> UploadFolleto(int id, IFormFile folleto)
    {
        if (folleto == null || folleto.Length == 0)
            return BadRequest(new { message = "No se proporcionó ningún archivo" });

        // Validar que sea un PDF
        if (!folleto.ContentType.Equals("application/pdf", StringComparison.OrdinalIgnoreCase) &&
            !folleto.FileName.EndsWith(".pdf", StringComparison.OrdinalIgnoreCase))
            return BadRequest(new { message = "El archivo debe ser un PDF" });

        var result = await _actividadService.UpdateFolletoAsync(id, folleto);
        if (result == null)
            return NotFound(new { message = "Actividad no encontrada" });

        return Ok(new { message = "Folleto subido correctamente", folletoUrl = result });
    }

    [HttpDelete("{id}/folleto")]
    public async Task<IActionResult> DeleteFolleto(int id)
    {
        var result = await _actividadService.DeleteFolletoAsync(id);
        if (!result)
            return NotFound(new { message = "Actividad no encontrada o no tiene folleto" });

        return Ok(new { message = "Folleto eliminado correctamente" });
    }

    /// <summary>
    /// Obtiene todas las localizaciones de una actividad
    /// </summary>
    [HttpGet("{id}/localizaciones")]
    [ProducesResponseType(typeof(List<LocalizacionDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<List<LocalizacionDto>>> GetLocalizaciones(int id)
    {
        var localizaciones = await _actividadService.GetLocalizacionesAsync(id);
        return Ok(localizaciones);
    }

    /// <summary>
    /// Añade una localización a una actividad
    /// </summary>
    [HttpPost("{id}/localizaciones/{localizacionId}")]
    [Authorize(Roles = "Administrador,Coordinador")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> AddLocalizacion(int id, int localizacionId, [FromBody] AddLocalizacionDto? dto = null)
    {
        var result = await _actividadService.AddLocalizacionAsync(
            id, 
            localizacionId, 
            dto?.EsPrincipal ?? false, 
            dto?.Orden ?? 0,
            dto?.Icono
        );
        if (!result)
            return NotFound(new { message = "Actividad o localización no encontrada" });

        return Ok(new { message = "Localización añadida correctamente" });
    }

    /// <summary>
    /// Elimina una localización de una actividad
    /// </summary>
    [HttpDelete("{id}/localizaciones/{localizacionId}")]
    [Authorize(Roles = "Administrador,Coordinador")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> RemoveLocalizacion(int id, int localizacionId)
    {
        var result = await _actividadService.RemoveLocalizacionAsync(id, localizacionId);
        if (!result)
            return NotFound(new { message = "Relación no encontrada" });

        return Ok(new { message = "Localización eliminada correctamente" });
    }

    /// <summary>
    /// Actualiza el orden y si es principal de una localización en una actividad
    /// </summary>
    [HttpPut("{id}/localizaciones/{localizacionId}")]
    [Authorize(Roles = "Administrador,Coordinador")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateLocalizacion(int id, int localizacionId, [FromBody] UpdateLocalizacionDto dto)
    {
        var result = await _actividadService.UpdateLocalizacionAsync(
            id, 
            localizacionId, 
            dto.EsPrincipal, 
            dto.Orden,
            dto.Icono
        );
        if (!result)
            return NotFound(new { message = "Relación no encontrada" });

        return Ok(new { message = "Localización actualizada correctamente" });
    }
}

