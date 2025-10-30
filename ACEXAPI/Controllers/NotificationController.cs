using ACEXAPI.DTOs;
using ACEXAPI.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace ACEXAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class NotificationController : ControllerBase
{
    private readonly INotificationService _notificationService;
    private readonly ILogger<NotificationController> _logger;

    public NotificationController(INotificationService notificationService, ILogger<NotificationController> logger)
    {
        _notificationService = notificationService;
        _logger = logger;
    }

    /// <summary>
    /// Registra el token FCM del dispositivo del usuario
    /// </summary>
    [HttpPost("register-token")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> RegisterToken([FromBody] FcmTokenDto dto)
    {
        var usuarioId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        
        if (string.IsNullOrEmpty(usuarioId))
        {
            return Unauthorized(new { message = "Usuario no autenticado" });
        }

        if (string.IsNullOrEmpty(dto.Token))
        {
            return BadRequest(new { message = "Token FCM requerido" });
        }

        var result = await _notificationService.RegisterTokenAsync(usuarioId, dto);
        
        if (result)
        {
            return Ok(new { message = "Token registrado exitosamente" });
        }

        return BadRequest(new { message = "Error al registrar token" });
    }

    /// <summary>
    /// Elimina el token FCM del dispositivo
    /// </summary>
    [HttpDelete("remove-token")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> RemoveToken([FromBody] FcmTokenDto dto)
    {
        var usuarioId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        
        if (string.IsNullOrEmpty(usuarioId))
        {
            return Unauthorized(new { message = "Usuario no autenticado" });
        }

        await _notificationService.RemoveTokenAsync(usuarioId, dto.Token);
        return Ok(new { message = "Token eliminado" });
    }

    /// <summary>
    /// Elimina todos los tokens del usuario (logout)
    /// </summary>
    [HttpDelete("remove-all-tokens")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> RemoveAllTokens()
    {
        var usuarioId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        
        if (string.IsNullOrEmpty(usuarioId))
        {
            return Unauthorized(new { message = "Usuario no autenticado" });
        }

        await _notificationService.RemoveAllUserTokensAsync(usuarioId);
        return Ok(new { message = "Todos los tokens eliminados" });
    }

    /// <summary>
    /// Envía una notificación de prueba al usuario actual
    /// </summary>
    [HttpPost("test")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> SendTestNotification()
    {
        var usuarioId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        
        if (string.IsNullOrEmpty(usuarioId))
        {
            return Unauthorized(new { message = "Usuario no autenticado" });
        }

        var notification = new SendNotificationDto
        {
            Title = "Notificación de Prueba",
            Body = "Esta es una notificación de prueba de ACEX",
            Type = "test",
            Data = new Dictionary<string, string>
            {
                { "type", "test" },
                { "timestamp", DateTime.UtcNow.ToString("O") }
            }
        };

        var result = await _notificationService.SendNotificationToUserAsync(usuarioId, notification);
        
        if (result)
        {
            return Ok(new { message = "Notificación de prueba enviada" });
        }

        return BadRequest(new { message = "Error al enviar notificación. Verifica que tengas tokens registrados." });
    }

    /// <summary>
    /// Envía una notificación personalizada (solo administradores)
    /// </summary>
    [HttpPost("send")]
    [Authorize(Roles = "Administrador")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> SendNotification([FromBody] SendNotificationDto dto, [FromQuery] string? usuarioId, [FromQuery] string? topic)
    {
        if (!string.IsNullOrEmpty(usuarioId))
        {
            var result = await _notificationService.SendNotificationToUserAsync(usuarioId, dto);
            return result ? Ok(new { message = "Notificación enviada" }) : BadRequest(new { message = "Error al enviar notificación" });
        }
        else if (!string.IsNullOrEmpty(topic))
        {
            var result = await _notificationService.SendNotificationToTopicAsync(topic, dto);
            return result ? Ok(new { message = "Notificación enviada al tópico" }) : BadRequest(new { message = "Error al enviar notificación" });
        }

        return BadRequest(new { message = "Debe especificar usuarioId o topic" });
    }

    /// <summary>
    /// Obtiene información de diagnóstico del sistema de notificaciones
    /// </summary>
    [HttpGet("diagnostics")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetDiagnostics()
    {
        var usuarioId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var diagnostics = await _notificationService.GetDiagnosticsAsync(usuarioId);
        return Ok(diagnostics);
    }
}
