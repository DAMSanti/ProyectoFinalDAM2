namespace ACEXAPI.DTOs;

/// <summary>
/// DTO para registrar el token FCM de un usuario
/// </summary>
public class FcmTokenDto
{
    public string Token { get; set; } = string.Empty;
    public string? DeviceType { get; set; } // "android", "ios", "web"
    public string? DeviceId { get; set; }
}

/// <summary>
/// DTO para enviar una notificación push
/// </summary>
public class SendNotificationDto
{
    public string Title { get; set; } = string.Empty;
    public string Body { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty; // "nueva_actividad", "nuevo_mensaje", etc.
    public Dictionary<string, string>? Data { get; set; }
}

/// <summary>
/// DTO para notificación de nueva actividad
/// </summary>
public class ActividadNotificationDto
{
    public int ActividadId { get; set; }
    public string ActividadNombre { get; set; } = string.Empty;
    public DateTime FechaInicio { get; set; }
    public List<string> ProfesoresUuids { get; set; } = new();
}

/// <summary>
/// DTO para notificación de nuevo mensaje
/// </summary>
public class MensajeNotificationDto
{
    public string ChatId { get; set; } = string.Empty;
    public string SenderName { get; set; } = string.Empty;
    public string MessagePreview { get; set; } = string.Empty;
    public string RecipientUuid { get; set; } = string.Empty;
}
