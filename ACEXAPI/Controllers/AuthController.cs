using ACEXAPI.Data;
using ACEXAPI.Models;
using ACEXAPI.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ACEXAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly IJwtService _jwtService;
    private readonly IPasswordService _passwordService;
    private readonly ILogger<AuthController> _logger;

    public AuthController(
        ApplicationDbContext context, 
        IJwtService jwtService, 
        IPasswordService passwordService,
        ILogger<AuthController> logger)
    {
        _context = context;
        _jwtService = jwtService;
        _passwordService = passwordService;
        _logger = logger;
    }

    [HttpPost("login")]
    public async Task<ActionResult<object>> Login([FromBody] LoginRequest request)
    {
        _logger.LogInformation($"[LOGIN] Intento de login para: {request.NombreUsuario}");
        
        // Validar que se proporcionen nombre de usuario y contraseña
        if (string.IsNullOrWhiteSpace(request.NombreUsuario) || string.IsNullOrWhiteSpace(request.Password))
        {
            _logger.LogWarning("[LOGIN] Nombre de usuario o contraseña vacíos");
            return BadRequest(new { message = "Nombre de usuario y contraseña son requeridos" });
        }

        // Buscar usuario por nombre de usuario O por correo del profesor asociado
        var usuario = await _context.Usuarios
            .Include(u => u.Profesor)
            .Where(u => u.Activo && (
                u.NombreUsuario == request.NombreUsuario ||
                (u.Profesor != null && u.Profesor.Correo == request.NombreUsuario)
            ))
            .FirstOrDefaultAsync();

        if (usuario == null)
        {
            _logger.LogWarning($"[LOGIN] Usuario no encontrado: {request.NombreUsuario}");
            return Unauthorized(new { message = "Credenciales inválidas" });
        }

        _logger.LogInformation($"[LOGIN] Usuario encontrado: {usuario.NombreUsuario}, Password hash length: {usuario.Password?.Length ?? 0}");

        // Verificar que el password no sea null
        if (string.IsNullOrEmpty(usuario.Password))
        {
            _logger.LogError($"[LOGIN] Password hash es null para usuario: {usuario.NombreUsuario}");
            return Unauthorized(new { message = "Error en la configuración del usuario" });
        }

        // Verificar contraseña
        try
        {
            var passwordValid = _passwordService.VerifyPassword(request.Password, usuario.Password);
            _logger.LogInformation($"[LOGIN] Verificación de contraseña: {passwordValid}");
            
            if (!passwordValid)
            {
                _logger.LogWarning($"[LOGIN] Contraseña incorrecta para: {request.NombreUsuario}");
                return Unauthorized(new { message = "Credenciales inválidas" });
            }
        }
        catch (Exception ex)
        {
            _logger.LogError($"[LOGIN] Error verificando contraseña: {ex.Message}");
            return Unauthorized(new { message = "Error al verificar credenciales" });
        }

        // Generar token JWT
        var token = _jwtService.GenerateToken(usuario.NombreUsuario, usuario.Rol, usuario.Id);
        
        _logger.LogInformation($"[LOGIN] Login exitoso para: {usuario.NombreUsuario}");

        return Ok(new
        {
            token,
            usuario = new
            {
                usuario.Id,
                NombreUsuario = usuario.NombreUsuario,
                usuario.Rol
            }
        });
    }

    [HttpPost("register")]
    public async Task<ActionResult<object>> Register([FromBody] RegisterRequest request)
    {
        // Validar que se proporcionen todos los campos requeridos
        if (string.IsNullOrWhiteSpace(request.NombreUsuario) || 
            string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest(new { message = "Nombre de usuario y contraseña son requeridos" });
        }

        // Validar formato del nombre de usuario (solo letras, números, guiones y guiones bajos)
        if (!System.Text.RegularExpressions.Regex.IsMatch(request.NombreUsuario, @"^[a-zA-Z0-9_-]+$"))
        {
            return BadRequest(new { message = "El nombre de usuario solo puede contener letras, números, guiones (-) y guiones bajos (_)" });
        }

        // Verificar si el usuario ya existe
        if (await _context.Usuarios.AnyAsync(u => u.NombreUsuario == request.NombreUsuario))
        {
            return BadRequest(new { message = "Ya existe un usuario con ese nombre de usuario" });
        }

        // Crear nuevo usuario con contraseña hasheada
        var usuario = new Usuario
        {
            NombreUsuario = request.NombreUsuario,
            Password = _passwordService.HashPassword(request.Password),
            Rol = "Usuario"
        };

        _context.Usuarios.Add(usuario);
        await _context.SaveChangesAsync();

        // Generar token JWT
        var token = _jwtService.GenerateToken(usuario.NombreUsuario, usuario.Rol, usuario.Id);

        return Ok(new
        {
            token,
            usuario = new
            {
                usuario.Id,
                NombreUsuario = usuario.NombreUsuario,
                usuario.Rol
            }
        });
    }
}

public class LoginRequest
{
    public string NombreUsuario { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

public class RegisterRequest
{
    public string NombreUsuario { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}
