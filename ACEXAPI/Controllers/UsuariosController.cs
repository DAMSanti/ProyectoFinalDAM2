using ACEXAPI.Data;
using ACEXAPI.Models;
using ACEXAPI.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
namespace ACEXAPI.Controllers;
[ApiController]
[Route("api/[controller]")]
[Authorize] 
public class UsuariosController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly IPasswordService _passwordService;
    private readonly ILogger<UsuariosController> _logger;
    public UsuariosController(
        ApplicationDbContext context,
        IPasswordService passwordService,
        ILogger<UsuariosController> logger)
    {
        _context = context;
        _passwordService = passwordService;
        _logger = logger;
    }
    [HttpGet]
    public async Task<ActionResult<IEnumerable<object>>> GetUsuarios()
    {
        try
        {
            var usuarios = await _context.Usuarios
                .Include(u => u.Profesor)
                .Select(u => new
                {
                    u.Id,
                    u.NombreUsuario,
                    Email = u.Profesor != null ? u.Profesor.Correo : "",
                    u.Rol,
                    u.Activo,
                    u.FechaCreacion,
                    u.ProfesorUuid,
                    UltimoAcceso = (DateTime?)null, 
                    ProfesorNombre = u.Profesor != null ? u.Profesor.Nombre : null,
                    ProfesorApellidos = u.Profesor != null ? u.Profesor.Apellidos : null,
                    ProfesorNombreCompleto = u.Profesor != null ? u.Profesor.Nombre + " " + u.Profesor.Apellidos : null
                })
                .ToListAsync();
            return Ok(usuarios);
        }
        catch (Exception ex)
        {
            _logger.LogError($"[UsuariosController] Error obteniendo usuarios: {ex.Message}");
            return StatusCode(500, new { message = "Error al obtener usuarios", error = ex.Message });
        }
    }
    [HttpGet("{id}")]
    public async Task<ActionResult<object>> GetUsuario(Guid id)
    {
        try
        {
            var usuario = await _context.Usuarios
                .Include(u => u.Profesor)
                .Where(u => u.Id == id)
                .Select(u => new
                {
                    u.Id,
                    u.NombreUsuario,
                    Email = u.Profesor != null ? u.Profesor.Correo : "",
                    u.Rol,
                    u.Activo,
                    u.FechaCreacion,
                    u.ProfesorUuid,
                    ProfesorNombre = u.Profesor != null ? u.Profesor.Nombre : null,
                    ProfesorApellidos = u.Profesor != null ? u.Profesor.Apellidos : null,
                    ProfesorNombreCompleto = u.Profesor != null ? u.Profesor.Nombre + " " + u.Profesor.Apellidos : null
                })
                .FirstOrDefaultAsync();
            if (usuario == null)
            {
                return NotFound(new { message = "Usuario no encontrado" });
            }
            return Ok(usuario);
        }
        catch (Exception ex)
        {
            _logger.LogError($"[UsuariosController] Error obteniendo usuario {id}: {ex.Message}");
            return StatusCode(500, new { message = "Error al obtener usuario", error = ex.Message });
        }
    }
    [HttpPost]
    [Authorize(Roles = "Administrador,Admin")] 
    public async Task<ActionResult<object>> CreateUsuario([FromBody] CreateUsuarioRequest request)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(request.NombreUsuario))
            {
                return BadRequest(new { message = "El nombre de usuario es requerido" });
            }
            if (string.IsNullOrWhiteSpace(request.Password))
            {
                return BadRequest(new { message = "La contraseña es requerida" });
            }
            if (await _context.Usuarios.AnyAsync(u => u.NombreUsuario == request.NombreUsuario))
            {
                return BadRequest(new { message = "Ya existe un usuario con ese nombre de usuario" });
            }
            if (request.ProfesorUuid.HasValue)
            {
                var profesorYaAsignado = await _context.Usuarios
                    .AnyAsync(u => u.ProfesorUuid == request.ProfesorUuid.Value);
                if (profesorYaAsignado)
                {
                    return BadRequest(new { message = "Este profesor ya está asociado a otro usuario" });
                }
            }
            var usuario = new Usuario
            {
                NombreUsuario = request.NombreUsuario,
                Password = _passwordService.HashPassword(request.Password),
                Rol = request.Rol ?? "Usuario",
                Activo = request.Activo ?? true,
                ProfesorUuid = request.ProfesorUuid,
                FechaCreacion = DateTime.UtcNow
            };
            _context.Usuarios.Add(usuario);
            await _context.SaveChangesAsync();
            _logger.LogInformation($"[UsuariosController] Usuario creado: {usuario.NombreUsuario}");
            return CreatedAtAction(
                nameof(GetUsuario),
                new { id = usuario.Id },
                new
                {
                    usuario.Id,
                    usuario.NombreUsuario,
                    usuario.Rol,
                    usuario.Activo,
                    usuario.FechaCreacion
                });
        }
        catch (Exception ex)
        {
            _logger.LogError($"[UsuariosController] Error creando usuario: {ex.Message}");
            return StatusCode(500, new { message = "Error al crear usuario", error = ex.Message });
        }
    }
    [HttpPut("{id}")]
    [Authorize(Roles = "Administrador,Admin")] 
    public async Task<IActionResult> UpdateUsuario(Guid id, [FromBody] UpdateUsuarioRequest request)
    {
        try
        {
            var usuario = await _context.Usuarios.FindAsync(id);
            if (usuario == null)
            {
                return NotFound(new { message = "Usuario no encontrado" });
            }
            if (!string.IsNullOrWhiteSpace(request.NombreUsuario) && request.NombreUsuario != usuario.NombreUsuario)
            {
                if (await _context.Usuarios.AnyAsync(u => u.NombreUsuario == request.NombreUsuario && u.Id != id))
                {
                    return BadRequest(new { message = "Ya existe un usuario con ese nombre de usuario" });
                }
                usuario.NombreUsuario = request.NombreUsuario;
            }
            if (!string.IsNullOrWhiteSpace(request.Rol))
            {
                usuario.Rol = request.Rol;
            }
            if (request.Activo.HasValue)
            {
                usuario.Activo = request.Activo.Value;
            }
            if (request.ProfesorUuid.HasValue)
            {
                var profesorYaAsignado = await _context.Usuarios
                    .AnyAsync(u => u.ProfesorUuid == request.ProfesorUuid.Value && u.Id != id);
                if (profesorYaAsignado)
                {
                    return BadRequest(new { message = "Este profesor ya está asociado a otro usuario" });
                }
                usuario.ProfesorUuid = request.ProfesorUuid.Value;
            }
            await _context.SaveChangesAsync();
            _logger.LogInformation($"[UsuariosController] Usuario actualizado: {usuario.NombreUsuario}");
            return Ok(new
            {
                usuario.Id,
                usuario.NombreUsuario,
                usuario.Rol,
                usuario.Activo,
                usuario.FechaCreacion
            });
        }
        catch (Exception ex)
        {
            _logger.LogError($"[UsuariosController] Error actualizando usuario {id}: {ex.Message}");
            return StatusCode(500, new { message = "Error al actualizar usuario", error = ex.Message });
        }
    }
    [HttpDelete("{id}")]
    [Authorize(Roles = "Administrador,Admin")] 
    public async Task<IActionResult> DeleteUsuario(Guid id)
    {
        try
        {
            var usuario = await _context.Usuarios.FindAsync(id);
            if (usuario == null)
            {
                return NotFound(new { message = "Usuario no encontrado" });
            }
            _context.Usuarios.Remove(usuario);
            await _context.SaveChangesAsync();
            _logger.LogInformation($"[UsuariosController] Usuario eliminado: {usuario.NombreUsuario}");
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError($"[UsuariosController] Error eliminando usuario {id}: {ex.Message}");
            return StatusCode(500, new { message = "Error al eliminar usuario", error = ex.Message });
        }
    }
    [HttpPatch("{id}/toggle-activo")]
    [Authorize(Roles = "Administrador,Admin")]
    public async Task<IActionResult> ToggleActivo(Guid id)
    {
        try
        {
            var usuario = await _context.Usuarios.FindAsync(id);
            if (usuario == null)
            {
                return NotFound(new { message = "Usuario no encontrado" });
            }
            usuario.Activo = !usuario.Activo;
            await _context.SaveChangesAsync();
            _logger.LogInformation($"[UsuariosController] Estado activo cambiado para {usuario.NombreUsuario}: {usuario.Activo}");
            return Ok(new
            {
                usuario.Id,
                usuario.Activo
            });
        }
        catch (Exception ex)
        {
            _logger.LogError($"[UsuariosController] Error cambiando estado activo {id}: {ex.Message}");
            return StatusCode(500, new { message = "Error al cambiar estado", error = ex.Message });
        }
    }
    [HttpPost("{id}/cambiar-password")]
    [Authorize(Roles = "Administrador,Admin")]
    public async Task<IActionResult> CambiarPassword(Guid id, [FromBody] CambiarPasswordRequest request)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(request.NuevaPassword))
            {
                return BadRequest(new { message = "La nueva contraseña es requerida" });
            }
            var usuario = await _context.Usuarios.FindAsync(id);
            if (usuario == null)
            {
                return NotFound(new { message = "Usuario no encontrado" });
            }
            usuario.Password = _passwordService.HashPassword(request.NuevaPassword);
            await _context.SaveChangesAsync();
            _logger.LogInformation($"[UsuariosController] Contraseña cambiada para {usuario.NombreUsuario}");
            return Ok(new { message = "Contraseña actualizada correctamente" });
        }
        catch (Exception ex)
        {
            _logger.LogError($"[UsuariosController] Error cambiando contraseña {id}: {ex.Message}");
            return StatusCode(500, new { message = "Error al cambiar contraseña", error = ex.Message });
        }
    }
}
public class CreateUsuarioRequest
{
    public string NombreUsuario { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string? Rol { get; set; }
    public bool? Activo { get; set; }
    public Guid? ProfesorUuid { get; set; }
}
public class UpdateUsuarioRequest
{
    public string? NombreUsuario { get; set; }
    public string? Rol { get; set; }
    public bool? Activo { get; set; }
    public Guid? ProfesorUuid { get; set; }
}
public class CambiarPasswordRequest
{
    public string NuevaPassword { get; set; } = string.Empty;
}