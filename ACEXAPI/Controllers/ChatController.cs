using ACEXAPI.DTOs;
using ACEXAPI.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
namespace ACEXAPI.Controllers;
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ChatController : ControllerBase
{
    private readonly INotificationService _notificationService;
    private readonly IActividadService _actividadService;
    private readonly ILogger<ChatController> _logger;
    public ChatController(
        INotificationService notificationService, 
        IActividadService actividadService,
        ILogger<ChatController> logger)
    {
        _notificationService = notificationService;
        _actividadService = actividadService;
        _logger = logger;
    }
    [HttpPost("notify-new-message")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> NotifyNewMessage([FromBody] ChatMessageNotificationDto dto)
    {
        try
        {
            _logger.LogInformation("🔔 [ChatController] Recibida solicitud de notificación para actividad {ActividadId}", dto.ActividadId);
            var senderId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(senderId))
            {
                _logger.LogWarning("❌ [ChatController] Usuario no autenticado");
                return Unauthorized(new { message = "Usuario no autenticado" });
            }
            _logger.LogInformation("👤 [ChatController] Sender: {SenderId}, SenderName: {SenderName}", senderId, dto.SenderName);
            var profesoresIds = await _actividadService.GetProfesoresParticipantesAsync(dto.ActividadId);
            _logger.LogInformation("👥 [ChatController] Participantes encontrados: {Count}", profesoresIds.Count);
            var recipients = profesoresIds.Where(id => id != senderId).ToList();
            if (!recipients.Any())
            {
                _logger.LogInformation("⚠️ [ChatController] No hay destinatarios (todos son el remitente)");
                return Ok(new { message = "No hay destinatarios para notificar" });
            }
            _logger.LogInformation("📤 [ChatController] Enviando notificaciones a {Count} usuarios", recipients.Count);
            foreach (var recipientId in recipients)
            {
                _logger.LogInformation("  → Enviando a usuario: {RecipientId}", recipientId);
                await _notificationService.NotifyNuevoMensajeAsync(new MensajeNotificationDto
                {
                    ChatId = dto.ActividadId.ToString(),
                    SenderName = dto.SenderName,
                    MessagePreview = dto.MessagePreview,
                    RecipientUuid = recipientId
                });
            }
            _logger.LogInformation(
                "✅ [ChatController] Notificaciones de chat enviadas para actividad {ActividadId} desde {SenderId} a {Count} usuarios",
                dto.ActividadId, senderId, recipients.Count);
            return Ok(new { 
                message = "Notificaciones enviadas",
                recipientCount = recipients.Count 
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error enviando notificaciones de chat");
            return StatusCode(500, new { message = "Error al enviar notificaciones" });
        }
    }
}
public class ChatMessageNotificationDto
{
    public int ActividadId { get; set; }
    public string SenderName { get; set; } = string.Empty;
    public string MessagePreview { get; set; } = string.Empty;
}