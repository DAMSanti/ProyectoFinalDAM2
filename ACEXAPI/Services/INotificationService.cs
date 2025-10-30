using ACEXAPI.DTOs;

namespace ACEXAPI.Services;

/// <summary>
/// Interfaz para el servicio de notificaciones push usando Firebase Cloud Messaging
/// </summary>
public interface INotificationService
{
    /// <summary>
    /// Registra o actualiza el token FCM de un usuario
    /// </summary>
    Task<bool> RegisterTokenAsync(string usuarioId, FcmTokenDto dto);

    /// <summary>
    /// Elimina un token FCM específico
    /// </summary>
    Task<bool> RemoveTokenAsync(string usuarioId, string token);

    /// <summary>
    /// Elimina todos los tokens de un usuario (logout)
    /// </summary>
    Task<bool> RemoveAllUserTokensAsync(string usuarioId);

    /// <summary>
    /// Envía una notificación a un usuario específico
    /// </summary>
    Task<bool> SendNotificationToUserAsync(string usuarioId, SendNotificationDto notification);

    /// <summary>
    /// Envía una notificación a múltiples usuarios
    /// </summary>
    Task<bool> SendNotificationToUsersAsync(List<string> usuariosIds, SendNotificationDto notification);

    /// <summary>
    /// Envía una notificación a un tópico (grupo)
    /// </summary>
    Task<bool> SendNotificationToTopicAsync(string topic, SendNotificationDto notification);

    /// <summary>
    /// Notifica cuando se crea una nueva actividad
    /// </summary>
    Task NotifyNuevaActividadAsync(ActividadNotificationDto dto);

    /// <summary>
    /// Notifica cuando se actualiza una actividad
    /// </summary>
    Task NotifyActividadActualizadaAsync(int actividadId, List<string> profesoresUuids);

    /// <summary>
    /// Notifica cuando se añade un profesor a una actividad
    /// </summary>
    Task NotifyProfesorAnadidoAsync(string profesorUuid, int actividadId, string actividadNombre);

    /// <summary>
    /// Notifica cuando hay un nuevo mensaje de chat
    /// </summary>
    Task NotifyNuevoMensajeAsync(MensajeNotificationDto dto);

    /// <summary>
    /// Obtiene información de diagnóstico del sistema de notificaciones
    /// </summary>
    Task<object> GetDiagnosticsAsync(string? usuarioId);
}
