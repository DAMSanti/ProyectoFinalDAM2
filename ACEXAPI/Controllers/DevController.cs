using ACEXAPI.Data;
using ACEXAPI.Models;
using ACEXAPI.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ACEXAPI.Controllers;

/// <summary>
/// Controlador de utilidades para desarrollo
/// SOLO PARA DESARROLLO - ELIMINAR EN PRODUCCIÓN
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class DevController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly IPasswordService _passwordService;
    private readonly ILogger<DevController> _logger;

    public DevController(
        ApplicationDbContext context, 
        IPasswordService passwordService,
        ILogger<DevController> logger)
    {
        _context = context;
        _passwordService = passwordService;
        _logger = logger;
    }

    /// <summary>
    /// Crea usuarios de prueba para desarrollo
    /// </summary>
    [HttpPost("seed-users")]
    public async Task<ActionResult> SeedUsers()
    {
        // Eliminar usuarios existentes de prueba
        var existingUsers = await _context.Usuarios
            .Where(u => u.Email.EndsWith("@acexapi.com"))
            .ToListAsync();
        
        _context.Usuarios.RemoveRange(existingUsers);
        await _context.SaveChangesAsync();

        // Crear usuarios de prueba
        var usuarios = new List<Usuario>
        {
            new Usuario
            {
                Email = "admin@acexapi.com",
                NombreCompleto = "Administrador ACEX",
                Password = _passwordService.HashPassword("admin123"),
                Rol = "Administrador",
                Activo = true
            },
            new Usuario
            {
                Email = "profesor@acexapi.com",
                NombreCompleto = "Profesor Demo",
                Password = _passwordService.HashPassword("profesor123"),
                Rol = "Profesor",
                Activo = true
            },
            new Usuario
            {
                Email = "coordinador@acexapi.com",
                NombreCompleto = "Coordinador Demo",
                Password = _passwordService.HashPassword("coord123"),
                Rol = "Coordinador",
                Activo = true
            },
            new Usuario
            {
                Email = "usuario@acexapi.com",
                NombreCompleto = "Usuario Demo",
                Password = _passwordService.HashPassword("usuario123"),
                Rol = "Usuario",
                Activo = true
            }
        };

        _context.Usuarios.AddRange(usuarios);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Usuarios de prueba creados exitosamente");

        return Ok(new
        {
            message = "Usuarios de prueba creados exitosamente",
            usuarios = usuarios.Select(u => new
            {
                email = u.Email,
                nombreCompleto = u.NombreCompleto,
                rol = u.Rol,
                // NO devolver contraseñas en producción
                passwordHint = u.Email.Replace("@acexapi.com", "123")
            })
        });
    }

    /// <summary>
    /// Genera un hash BCrypt para una contraseña dada
    /// </summary>
    [HttpPost("hash-password")]
    public ActionResult<string> HashPassword([FromBody] HashPasswordRequest request)
    {
        var hash = _passwordService.HashPassword(request.Password);
        return Ok(new { hash, original = request.Password });
    }

    /// <summary>
    /// Lista todos los usuarios (solo para desarrollo)
    /// </summary>
    [HttpGet("list-users")]
    public async Task<ActionResult> ListUsers()
    {
        var usuarios = await _context.Usuarios
            .Select(u => new
            {
                u.Id,
                u.Email,
                u.NombreCompleto,
                u.Rol,
                u.Activo,
                u.FechaCreacion
            })
            .ToListAsync();

        return Ok(usuarios);
    }

    /// <summary>
    /// Crea actividades de prueba para desarrollo
    /// </summary>
    [HttpPost("seed-activities")]
    public async Task<ActionResult> SeedActivities()
    {
        // Eliminar actividades existentes de prueba (solo las que tienen "Demo" o "Prueba" en el nombre)
        var existingActivities = await _context.Actividades
            .Where(a => a.Nombre.Contains("Demo") || a.Nombre.Contains("Prueba") || a.Nombre.Contains("Excursión") || a.Nombre.Contains("Taller"))
            .ToListAsync();
        
        _context.Actividades.RemoveRange(existingActivities);
        await _context.SaveChangesAsync();

        var now = DateTime.Now;

        // Crear actividades de prueba
        var actividades = new List<Actividad>
        {
            new Actividad
            {
                Nombre = "Excursión al Museo de Ciencias",
                Descripcion = "Visita educativa al Museo de Ciencias con actividades interactivas para estudiantes.",
                FechaInicio = now.AddDays(7),
                FechaFin = now.AddDays(7),
                PresupuestoEstimado = 500.00m,
                Aprobada = true,
                FechaCreacion = DateTime.UtcNow
            },
            new Actividad
            {
                Nombre = "Taller de Robótica",
                Descripcion = "Taller práctico de programación y construcción de robots para estudiantes de secundaria.",
                FechaInicio = now.AddDays(14),
                FechaFin = now.AddDays(16),
                PresupuestoEstimado = 800.00m,
                Aprobada = true,
                FechaCreacion = DateTime.UtcNow
            },
            new Actividad
            {
                Nombre = "Campamento de Verano",
                Descripcion = "Campamento educativo con actividades al aire libre, deportes y talleres creativos.",
                FechaInicio = now.AddDays(30),
                FechaFin = now.AddDays(37),
                PresupuestoEstimado = 3500.00m,
                Aprobada = true,
                FechaCreacion = DateTime.UtcNow
            },
            new Actividad
            {
                Nombre = "Conferencia de Tecnología",
                Descripcion = "Conferencia sobre las últimas tendencias en inteligencia artificial y programación.",
                FechaInicio = now.AddDays(21),
                FechaFin = now.AddDays(21),
                PresupuestoEstimado = 1200.00m,
                Aprobada = true,
                FechaCreacion = DateTime.UtcNow
            },
            new Actividad
            {
                Nombre = "Excursión a la Playa",
                Descripcion = "Día de convivencia en la playa con actividades deportivas y recreativas.",
                FechaInicio = now.AddDays(10),
                FechaFin = now.AddDays(10),
                PresupuestoEstimado = 600.00m,
                Aprobada = true,
                FechaCreacion = DateTime.UtcNow
            },
            new Actividad
            {
                Nombre = "Torneo Deportivo Interescolar",
                Descripcion = "Competencia deportiva entre diferentes escuelas con varias disciplinas.",
                FechaInicio = now.AddDays(45),
                FechaFin = now.AddDays(47),
                PresupuestoEstimado = 2000.00m,
                Aprobada = true,
                FechaCreacion = DateTime.UtcNow
            }
        };

        _context.Actividades.AddRange(actividades);
        await _context.SaveChangesAsync();

        _logger.LogInformation($"Se crearon {actividades.Count} actividades de prueba");

        return Ok(new
        {
            message = $"Se crearon {actividades.Count} actividades de prueba exitosamente",
            actividades = actividades.Select(a => new
            {
                a.Id,
                a.Nombre,
                a.FechaInicio,
                a.FechaFin,
                a.PresupuestoEstimado
            })
        });
    }
}

public class HashPasswordRequest
{
    public string Password { get; set; } = string.Empty;
}
