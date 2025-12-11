namespace ACEXAPI.DTOs;
public class FcmTokenDto
{
    public string Token { get; set; } = string.Empty;
    public string? DeviceType { get; set; } 
    public string? DeviceId { get; set; }
}
public class SendNotificationDto
{
    public string Title { get; set; } = string.Empty;
    public string Body { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty; 
    public Dictionary<string, string>? Data { get; set; }
}
public class ActividadNotificationDto
{
    public int ActividadId { get; set; }
    public string ActividadNombre { get; set; } = string.Empty;
    public DateTime FechaInicio { get; set; }
    public List<string> ProfesoresUuids { get; set; } = new();
}
public class MensajeNotificationDto
{
    public string ChatId { get; set; } = string.Empty;
    public string SenderName { get; set; } = string.Empty;
    public string MessagePreview { get; set; } = string.Empty;
    public string RecipientUuid { get; set; } = string.Empty;
}