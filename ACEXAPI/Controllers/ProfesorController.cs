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
public class ProfesorController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly IFileStorageService _fileStorage;
    private readonly ILogger<ProfesorController> _logger;

    public ProfesorController(
        ApplicationDbContext context,
        IFileStorageService fileStorage,
        ILogger<ProfesorController> logger)
    {
        _context = context;
        _fileStorage = fileStorage;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<List<ProfesorDto>>> GetAll()
    {
        var profesores = await _context.Profesores
            .Include(p => p.Departamento)
            .Select(p => new ProfesorDto
            {
                Uuid = p.Uuid,
                Dni = p.Dni,
                Nombre = p.Nombre,
                Apellidos = p.Apellidos,
                Correo = p.Correo,
                Telefono = p.Telefono,
                FotoUrl = p.FotoUrl,
                Activo = p.Activo,
                DepartamentoId = p.DepartamentoId,
                DepartamentoNombre = p.Departamento != null ? p.Departamento.Nombre : null
            })
            .ToListAsync();

        return Ok(profesores);
    }

    [HttpGet("{uuid}")]
    public async Task<ActionResult<ProfesorDto>> GetByUuid(Guid uuid)
    {
        var profesor = await _context.Profesores
            .Include(p => p.Departamento)
            .FirstOrDefaultAsync(p => p.Uuid == uuid);

        if (profesor == null)
            return NotFound(new { message = "Profesor no encontrado" });

        return Ok(MapToDto(profesor));
    }

    [HttpGet("dni/{dni}")]
    public async Task<ActionResult<ProfesorDto>> GetByDni(string dni)
    {
        var profesor = await _context.Profesores
            .Include(p => p.Departamento)
            .FirstOrDefaultAsync(p => p.Dni == dni);

        if (profesor == null)
            return NotFound(new { message = "Profesor no encontrado" });

        return Ok(MapToDto(profesor));
    }

    [HttpPost]
    [Authorize(Roles = "Administrador")]
    public async Task<ActionResult<ProfesorDto>> Create([FromForm] ProfesorCreateDto dto, IFormFile? foto)
    {
        if (await _context.Profesores.AnyAsync(p => p.Dni == dto.Dni))
            return BadRequest(new { message = "Ya existe un profesor con ese DNI" });

        if (await _context.Profesores.AnyAsync(p => p.Correo == dto.Correo))
            return BadRequest(new { message = "Ya existe un profesor con ese correo" });

        var profesor = new Profesor
        {
            Dni = dto.Dni,
            Nombre = dto.Nombre,
            Apellidos = dto.Apellidos,
            Correo = dto.Correo,
            Telefono = dto.Telefono,
            DepartamentoId = dto.DepartamentoId
        };

        if (foto != null)
        {
            var (url, _, _) = await _fileStorage.UploadImageAsync(foto, "profesores");
            profesor.FotoUrl = url;
        }

        _context.Profesores.Add(profesor);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetByUuid), new { uuid = profesor.Uuid }, MapToDto(profesor));
    }

    [HttpPut("{uuid}")]
    [Authorize(Roles = "Administrador")]
    public async Task<ActionResult<ProfesorDto>> Update(Guid uuid, [FromForm] ProfesorUpdateDto dto, IFormFile? foto)
    {
        var profesor = await _context.Profesores.FindAsync(uuid);
        if (profesor == null)
            return NotFound(new { message = "Profesor no encontrado" });

        if (dto.Nombre != null) profesor.Nombre = dto.Nombre;
        if (dto.Apellidos != null) profesor.Apellidos = dto.Apellidos;
        if (dto.Telefono != null) profesor.Telefono = dto.Telefono;
        if (dto.Activo.HasValue) profesor.Activo = dto.Activo.Value;
        if (dto.DepartamentoId.HasValue) profesor.DepartamentoId = dto.DepartamentoId;

        if (foto != null)
        {
            if (!string.IsNullOrEmpty(profesor.FotoUrl))
            {
                await _fileStorage.DeleteFileAsync(profesor.FotoUrl);
            }
            var (url, _, _) = await _fileStorage.UploadImageAsync(foto, "profesores");
            profesor.FotoUrl = url;
        }

        await _context.SaveChangesAsync();

        return Ok(MapToDto(profesor));
    }

    [HttpDelete("{uuid}")]
    [Authorize(Roles = "Administrador")]
    public async Task<IActionResult> Delete(Guid uuid)
    {
        var profesor = await _context.Profesores.FindAsync(uuid);
        if (profesor == null)
            return NotFound(new { message = "Profesor no encontrado" });

        if (!string.IsNullOrEmpty(profesor.FotoUrl))
        {
            await _fileStorage.DeleteFileAsync(profesor.FotoUrl);
        }

        _context.Profesores.Remove(profesor);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    private ProfesorDto MapToDto(Profesor profesor)
    {
        return new ProfesorDto
        {
            Uuid = profesor.Uuid,
            Dni = profesor.Dni,
            Nombre = profesor.Nombre,
            Apellidos = profesor.Apellidos,
            Correo = profesor.Correo,
            Telefono = profesor.Telefono,
            FotoUrl = profesor.FotoUrl,
            Activo = profesor.Activo,
            DepartamentoId = profesor.DepartamentoId,
            DepartamentoNombre = profesor.Departamento?.Nombre
        };
    }
}
