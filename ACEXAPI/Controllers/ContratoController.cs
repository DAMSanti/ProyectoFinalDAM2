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
public class ContratoController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly IFileStorageService _fileStorage;
    private readonly ILogger<ContratoController> _logger;

    public ContratoController(
        ApplicationDbContext context,
        IFileStorageService fileStorage,
        ILogger<ContratoController> logger)
    {
        _context = context;
        _fileStorage = fileStorage;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<List<ContratoDto>>> GetAll()
    {
        var contratos = await _context.Contratos
            .Select(c => MapToDto(c))
            .ToListAsync();

        return Ok(contratos);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ContratoDto>> GetById(int id)
    {
        var contrato = await _context.Contratos.FindAsync(id);
        if (contrato == null)
            return NotFound(new { message = "Contrato no encontrado" });

        return Ok(MapToDto(contrato));
    }

    [HttpGet("actividad/{actividadId}")]
    public async Task<ActionResult<List<ContratoDto>>> GetByActividad(int actividadId)
    {
        var contratos = await _context.Contratos
            .Where(c => c.ActividadId == actividadId)
            .Select(c => MapToDto(c))
            .ToListAsync();

        return Ok(contratos);
    }

    [HttpPost]
    [Authorize(Roles = "Administrador,Coordinador")]
    public async Task<ActionResult<ContratoDto>> Create(
        [FromForm] ContratoCreateDto dto,
        IFormFile? presupuesto,
        IFormFile? factura)
    {
        var actividad = await _context.Actividades.FindAsync(dto.ActividadId);
        if (actividad == null)
            return NotFound(new { message = "Actividad no encontrada" });

        var contrato = new Contrato
        {
            ActividadId = dto.ActividadId,
            NombreProveedor = dto.NombreProveedor,
            Descripcion = dto.Descripcion,
            Monto = dto.Monto,
            FechaContrato = dto.FechaContrato
        };

        if (presupuesto != null)
        {
            contrato.PresupuestoUrl = await _fileStorage.UploadFileAsync(presupuesto, "presupuestos");
        }

        if (factura != null)
        {
            contrato.FacturaUrl = await _fileStorage.UploadFileAsync(factura, "facturas");
        }

        _context.Contratos.Add(contrato);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetById), new { id = contrato.Id }, MapToDto(contrato));
    }

    [HttpPut("{id}")]
    [Authorize(Roles = "Administrador,Coordinador")]
    public async Task<ActionResult<ContratoDto>> Update(
        int id,
        [FromForm] ContratoCreateDto dto,
        IFormFile? presupuesto,
        IFormFile? factura)
    {
        var contrato = await _context.Contratos.FindAsync(id);
        if (contrato == null)
            return NotFound(new { message = "Contrato no encontrado" });

        contrato.NombreProveedor = dto.NombreProveedor;
        contrato.Descripcion = dto.Descripcion;
        contrato.Monto = dto.Monto;
        contrato.FechaContrato = dto.FechaContrato;

        if (presupuesto != null)
        {
            if (!string.IsNullOrEmpty(contrato.PresupuestoUrl))
            {
                await _fileStorage.DeleteFileAsync(contrato.PresupuestoUrl);
            }
            contrato.PresupuestoUrl = await _fileStorage.UploadFileAsync(presupuesto, "presupuestos");
        }

        if (factura != null)
        {
            if (!string.IsNullOrEmpty(contrato.FacturaUrl))
            {
                await _fileStorage.DeleteFileAsync(contrato.FacturaUrl);
            }
            contrato.FacturaUrl = await _fileStorage.UploadFileAsync(factura, "facturas");
        }

        await _context.SaveChangesAsync();

        return Ok(MapToDto(contrato));
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Administrador")]
    public async Task<IActionResult> Delete(int id)
    {
        var contrato = await _context.Contratos.FindAsync(id);
        if (contrato == null)
            return NotFound(new { message = "Contrato no encontrado" });

        if (!string.IsNullOrEmpty(contrato.PresupuestoUrl))
        {
            await _fileStorage.DeleteFileAsync(contrato.PresupuestoUrl);
        }

        if (!string.IsNullOrEmpty(contrato.FacturaUrl))
        {
            await _fileStorage.DeleteFileAsync(contrato.FacturaUrl);
        }

        _context.Contratos.Remove(contrato);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    private ContratoDto MapToDto(Contrato contrato)
    {
        return new ContratoDto
        {
            Id = contrato.Id,
            ActividadId = contrato.ActividadId,
            NombreProveedor = contrato.NombreProveedor,
            Descripcion = contrato.Descripcion,
            Monto = contrato.Monto,
            FechaContrato = contrato.FechaContrato,
            PresupuestoUrl = contrato.PresupuestoUrl,
            FacturaUrl = contrato.FacturaUrl
        };
    }
}
