using ACEXAPI.Data;
using ACEXAPI.DTOs;
using ACEXAPI.Models;
using ACEXAPI.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ACEXAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class FotoController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly IFileStorageService _fileStorage;
    private readonly ILogger<FotoController> _logger;

    public FotoController(
        ApplicationDbContext context,
        IFileStorageService fileStorage,
        ILogger<FotoController> logger)
    {
        _context = context;
        _fileStorage = fileStorage;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<List<FotoDto>>> GetAll()
    {
        var fotos = await _context.Fotos
            .Select(f => MapToDto(f))
            .ToListAsync();

        return Ok(fotos);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<FotoDto>> GetById(int id)
    {
        var foto = await _context.Fotos.FindAsync(id);
        if (foto == null)
            return NotFound(new { message = "Foto no encontrada" });

        return Ok(MapToDto(foto));
    }

    [HttpGet("actividad/{actividadId}")]
    public async Task<ActionResult<List<FotoDto>>> GetByActividad(int actividadId)
    {
        var fotos = await _context.Fotos
            .Where(f => f.ActividadId == actividadId)
            .Select(f => MapToDto(f))
            .ToListAsync();

        return Ok(fotos);
    }

    [HttpPost("upload")]
    [Authorize(Roles = "Administrador,Coordinador,Profesor")]
    public async Task<ActionResult<List<FotoDto>>> Upload([FromForm] int actividadId, [FromForm] string? descripcion, List<IFormFile> fotos)
    {
        if (fotos == null || !fotos.Any())
            return BadRequest(new { message = "No se proporcionaron fotos" });

        var actividad = await _context.Actividades.FindAsync(actividadId);
        if (actividad == null)
            return NotFound(new { message = "Actividad no encontrada" });

        var fotosCreadas = new List<Foto>();

        foreach (var archivo in fotos)
        {
            var (url, thumbnailUrl, size) = await _fileStorage.UploadImageAsync(archivo, "fotos");

            var foto = new Foto
            {
                ActividadId = actividadId,
                Url = url,
                UrlThumbnail = thumbnailUrl,
                Descripcion = descripcion,
                TamanoBytes = size
            };

            _context.Fotos.Add(foto);
            fotosCreadas.Add(foto);
        }

        await _context.SaveChangesAsync();

        return Ok(fotosCreadas.Select(f => MapToDto(f)).ToList());
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Administrador,Coordinador")]
    public async Task<IActionResult> Delete(int id)
    {
        var foto = await _context.Fotos.FindAsync(id);
        if (foto == null)
            return NotFound(new { message = "Foto no encontrada" });

        await _fileStorage.DeleteFileAsync(foto.Url);
        if (!string.IsNullOrEmpty(foto.UrlThumbnail))
        {
            await _fileStorage.DeleteFileAsync(foto.UrlThumbnail);
        }

        _context.Fotos.Remove(foto);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    private FotoDto MapToDto(Foto foto)
    {
        return new FotoDto
        {
            Id = foto.Id,
            ActividadId = foto.ActividadId,
            Url = foto.Url,
            UrlThumbnail = foto.UrlThumbnail,
            Descripcion = foto.Descripcion,
            FechaSubida = foto.FechaSubida,
            TamanoBytes = foto.TamanoBytes
        };
    }
}
