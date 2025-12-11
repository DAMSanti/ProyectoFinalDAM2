using ACEXAPI.DTOs;
namespace ACEXAPI.Services;
public interface INotificationService
{
    Task<bool> RegisterTokenAsync(string usuarioId, FcmTokenDto dto);
    Task<bool> RemoveTokenAsync(string usuarioId, string token);
    Task<bool> RemoveAllUserTokensAsync(string usuarioId);
    Task<bool> SendNotificationToUserAsync(string usuarioId, SendNotificationDto notification);
    Task<bool> SendNotificationToUsersAsync(List<string> usuariosIds, SendNotificationDto notification);
    Task<bool> SendNotificationToTopicAsync(string topic, SendNotificationDto notification);
    Task NotifyNuevaActividadAsync(ActividadNotificationDto dto);
    Task NotifyActividadActualizadaAsync(int actividadId, List<string> profesoresUuids);
    Task NotifyProfesorAnadidoAsync(string profesorUuid, int actividadId, string actividadNombre);
    Task NotifyNuevoMensajeAsync(MensajeNotificationDto dto);
    Task<object> GetDiagnosticsAsync(string? usuarioId);
}