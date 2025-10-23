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
        _logger.LogInformation($"[LOGIN] Intento de login para: {request.Email}");
        
        // Validar que se proporcionen email y contraseña
        if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
        {
            _logger.LogWarning("[LOGIN] Email o contraseña vacíos");
            return BadRequest(new { message = "Email y contraseña son requeridos" });
        }

        // Buscar usuario por email
        var usuario = await _context.Usuarios
            .FirstOrDefaultAsync(u => u.Email == request.Email && u.Activo);

        if (usuario == null)
        {
            _logger.LogWarning($"[LOGIN] Usuario no encontrado: {request.Email}");
            return Unauthorized(new { message = "Credenciales inválidas" });
        }

        _logger.LogInformation($"[LOGIN] Usuario encontrado: {usuario.Email}, Password hash length: {usuario.Password?.Length ?? 0}");

        // Verificar contraseña
        try
        {
            var passwordValid = _passwordService.VerifyPassword(request.Password, usuario.Password);
            _logger.LogInformation($"[LOGIN] Verificación de contraseña: {passwordValid}");
            
            if (!passwordValid)
            {
                _logger.LogWarning($"[LOGIN] Contraseña incorrecta para: {request.Email}");
                return Unauthorized(new { message = "Credenciales inválidas" });
            }
        }
        catch (Exception ex)
        {
            _logger.LogError($"[LOGIN] Error verificando contraseña: {ex.Message}");
            return Unauthorized(new { message = "Error al verificar credenciales" });
        }

        // Generar token JWT
        var token = _jwtService.GenerateToken(usuario.Email, usuario.Rol, usuario.Id);
        
        _logger.LogInformation($"[LOGIN] Login exitoso para: {usuario.Email}");

        return Ok(new
        {
            token,
            usuario = new
            {
                usuario.Id,
                usuario.Email,
                usuario.NombreCompleto,
                usuario.Rol
            }
        });
    }

    [HttpPost("register")]
    public async Task<ActionResult<object>> Register([FromBody] RegisterRequest request)
    {
        // Validar que se proporcionen todos los campos requeridos
        if (string.IsNullOrWhiteSpace(request.Email) || 
            string.IsNullOrWhiteSpace(request.Password) || 
            string.IsNullOrWhiteSpace(request.NombreCompleto))
        {
            return BadRequest(new { message = "Email, contraseña y nombre completo son requeridos" });
        }

        // Verificar si el usuario ya existe
        if (await _context.Usuarios.AnyAsync(u => u.Email == request.Email))
        {
            return BadRequest(new { message = "Ya existe un usuario con ese email" });
        }

        // Crear nuevo usuario con contraseña hasheada
        var usuario = new Usuario
        {
            Email = request.Email,
            NombreCompleto = request.NombreCompleto,
            Password = _passwordService.HashPassword(request.Password),
            Rol = "Usuario"
        };

        _context.Usuarios.Add(usuario);
        await _context.SaveChangesAsync();

        // Generar token JWT
        var token = _jwtService.GenerateToken(usuario.Email, usuario.Rol, usuario.Id);

        return Ok(new
        {
            token,
            usuario = new
            {
                usuario.Id,
                usuario.Email,
                usuario.NombreCompleto,
                usuario.Rol
            }
        });
    }
}

public class LoginRequest
{
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

public class RegisterRequest
{
    public string Email { get; set; } = string.Empty;
    public string NombreCompleto { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}
