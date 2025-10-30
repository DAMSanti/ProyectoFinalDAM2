using ACEXAPI.Data;
using ACEXAPI.DTOs;
using ACEXAPI.Models;
using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using Microsoft.EntityFrameworkCore;

namespace ACEXAPI.Services;

/// <summary>
/// Servicio para enviar notificaciones push usando Firebase Cloud Messaging
/// </summary>
public class NotificationService : INotificationService
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<NotificationService> _logger;
    private static bool _firebaseInitialized = false;

    public NotificationService(ApplicationDbContext context, ILogger<NotificationService> logger)
    {
        _context = context;
        _logger = logger;
        InitializeFirebase();
    }

    /// <summary>
    /// Inicializa Firebase Admin SDK
    /// </summary>
    private void InitializeFirebase()
    {
        if (_firebaseInitialized) return;

        try
        {
            // Buscar el archivo de credenciales de Firebase
            var credentialPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "firebase-credentials.json");
            
            if (File.Exists(credentialPath))
            {
                FirebaseApp.Create(new AppOptions()
                {
                    Credential = GoogleCredential.FromFile(credentialPath)
                });
                _firebaseInitialized = true;
                _logger.LogInformation("Firebase Admin SDK initialized successfully");
            }
            else
            {
                _logger.LogWarning("Firebase credentials file not found at: {Path}", credentialPath);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error initializing Firebase Admin SDK");
        }
    }

    public async Task<bool> RegisterTokenAsync(string usuarioId, FcmTokenDto dto)
    {
        try
        {
            // Convertir string a Guid
            if (!Guid.TryParse(usuarioId, out var usuarioGuid))
            {
                _logger.LogWarning("Invalid usuario ID format: {UsuarioId}", usuarioId);
                return false;
            }

            // Buscar si ya existe el token
            var existingToken = await _context.Set<FcmToken>()
                .FirstOrDefaultAsync(t => t.UsuarioId == usuarioGuid && t.Token == dto.Token);

            if (existingToken != null)
            {
                // Actualizar token existente
                existingToken.UltimaActualizacion = DateTime.UtcNow;
                existingToken.Activo = true;
                existingToken.DeviceType = dto.DeviceType;
                existingToken.DeviceId = dto.DeviceId;
            }
            else
            {
                // Crear nuevo token
                var newToken = new FcmToken
                {
                    UsuarioId = usuarioGuid,
                    Token = dto.Token,
                    DeviceType = dto.DeviceType,
                    DeviceId = dto.DeviceId,
                    FechaCreacion = DateTime.UtcNow,
                    Activo = true
                };
                _context.Set<FcmToken>().Add(newToken);
            }

            await _context.SaveChangesAsync();
            _logger.LogInformation("FCM token registered for user {UsuarioId}", usuarioId);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error registering FCM token for user {UsuarioId}", usuarioId);
            return false;
        }
    }

    public async Task<bool> RemoveTokenAsync(string usuarioId, string token)
    {
        try
        {
            if (!Guid.TryParse(usuarioId, out var usuarioGuid))
            {
                return false;
            }

            var fcmToken = await _context.Set<FcmToken>()
                .FirstOrDefaultAsync(t => t.UsuarioId == usuarioGuid && t.Token == token);

            if (fcmToken != null)
            {
                _context.Set<FcmToken>().Remove(fcmToken);
                await _context.SaveChangesAsync();
                _logger.LogInformation("FCM token removed for user {UsuarioId}", usuarioId);
                return true;
            }

            return false;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error removing FCM token for user {UsuarioId}", usuarioId);
            return false;
        }
    }

    public async Task<bool> RemoveAllUserTokensAsync(string usuarioId)
    {
        try
        {
            if (!Guid.TryParse(usuarioId, out var usuarioGuid))
            {
                return false;
            }

            var tokens = await _context.Set<FcmToken>()
                .Where(t => t.UsuarioId == usuarioGuid)
                .ToListAsync();

            _context.Set<FcmToken>().RemoveRange(tokens);
            await _context.SaveChangesAsync();
            _logger.LogInformation("All FCM tokens removed for user {UsuarioId}", usuarioId);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error removing all tokens for user {UsuarioId}", usuarioId);
            return false;
        }
    }

    public async Task<bool> SendNotificationToUserAsync(string usuarioId, SendNotificationDto notification)
    {
        try
        {
            if (!Guid.TryParse(usuarioId, out var usuarioGuid))
            {
                _logger.LogWarning("Invalid usuario ID format: {UsuarioId}", usuarioId);
                return false;
            }

            var tokens = await _context.Set<FcmToken>()
                .Where(t => t.UsuarioId == usuarioGuid && t.Activo)
                .Select(t => t.Token)
                .ToListAsync();

            if (!tokens.Any())
            {
                _logger.LogWarning("No active tokens found for user {UsuarioId}", usuarioId);
                return false;
            }

            return await SendMulticastNotificationAsync(tokens, notification);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending notification to user {UsuarioId}", usuarioId);
            return false;
        }
    }

    public async Task<bool> SendNotificationToUsersAsync(List<string> usuariosIds, SendNotificationDto notification)
    {
        try
        {
            // Convertir strings a Guids
            var usuariosGuids = usuariosIds
                .Select(id => Guid.TryParse(id, out var guid) ? guid : (Guid?)null)
                .Where(g => g.HasValue)
                .Select(g => g.Value)
                .ToList();

            if (!usuariosGuids.Any())
            {
                _logger.LogWarning("No valid usuario IDs provided");
                return false;
            }

            var tokens = await _context.Set<FcmToken>()
                .Where(t => usuariosGuids.Contains(t.UsuarioId) && t.Activo)
                .Select(t => t.Token)
                .ToListAsync();

            if (!tokens.Any())
            {
                _logger.LogWarning("No active tokens found for users");
                return false;
            }

            return await SendMulticastNotificationAsync(tokens, notification);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending notification to multiple users");
            return false;
        }
    }

    public async Task<bool> SendNotificationToTopicAsync(string topic, SendNotificationDto notification)
    {
        try
        {
            if (!_firebaseInitialized)
            {
                _logger.LogWarning("Firebase not initialized, cannot send notification");
                return false;
            }

            var message = new Message
            {
                Topic = topic,
                Notification = new Notification
                {
                    Title = notification.Title,
                    Body = notification.Body
                },
                Data = notification.Data ?? new Dictionary<string, string>
                {
                    { "type", notification.Type }
                }
            };

            var response = await FirebaseMessaging.DefaultInstance.SendAsync(message);
            _logger.LogInformation("Notification sent to topic {Topic}: {Response}", topic, response);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending notification to topic {Topic}", topic);
            return false;
        }
    }

    private async Task<bool> SendMulticastNotificationAsync(List<string> tokens, SendNotificationDto notification)
    {
        try
        {
            if (!_firebaseInitialized || !tokens.Any())
            {
                return false;
            }

            var message = new MulticastMessage
            {
                Tokens = tokens,
                Notification = new Notification
                {
                    Title = notification.Title,
                    Body = notification.Body
                },
                Data = notification.Data ?? new Dictionary<string, string>
                {
                    { "type", notification.Type }
                }
            };

            var response = await FirebaseMessaging.DefaultInstance.SendEachForMulticastAsync(message);
            _logger.LogInformation("Multicast notification sent. Success: {Success}, Failure: {Failure}", 
                response.SuccessCount, response.FailureCount);

            // Eliminar tokens inválidos
            if (response.FailureCount > 0)
            {
                await RemoveInvalidTokensAsync(tokens, response);
            }

            return response.SuccessCount > 0;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending multicast notification");
            return false;
        }
    }

    private async Task RemoveInvalidTokensAsync(List<string> tokens, BatchResponse response)
    {
        try
        {
            var invalidTokens = new List<string>();
            for (int i = 0; i < response.Responses.Count; i++)
            {
                if (!response.Responses[i].IsSuccess)
                {
                    var error = response.Responses[i].Exception;
                    if (error?.MessagingErrorCode == MessagingErrorCode.InvalidArgument ||
                        error?.MessagingErrorCode == MessagingErrorCode.Unregistered)
                    {
                        invalidTokens.Add(tokens[i]);
                    }
                }
            }

            if (invalidTokens.Any())
            {
                var tokensToRemove = await _context.Set<FcmToken>()
                    .Where(t => invalidTokens.Contains(t.Token))
                    .ToListAsync();

                _context.Set<FcmToken>().RemoveRange(tokensToRemove);
                await _context.SaveChangesAsync();
                _logger.LogInformation("Removed {Count} invalid FCM tokens", tokensToRemove.Count);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error removing invalid tokens");
        }
    }

    public async Task NotifyNuevaActividadAsync(ActividadNotificationDto dto)
    {
        var notification = new SendNotificationDto
        {
            Title = "Nueva Actividad Creada",
            Body = $"Se ha creado la actividad '{dto.ActividadNombre}' para el {dto.FechaInicio:dd/MM/yyyy}",
            Type = "nueva_actividad",
            Data = new Dictionary<string, string>
            {
                { "type", "nueva_actividad" },
                { "actividadId", dto.ActividadId.ToString() },
                { "actividadNombre", dto.ActividadNombre },
                { "fechaInicio", dto.FechaInicio.ToString("O") }
            }
        };

        await SendNotificationToUsersAsync(dto.ProfesoresUuids, notification);
    }

    public async Task NotifyActividadActualizadaAsync(int actividadId, List<string> profesoresUuids)
    {
        var notification = new SendNotificationDto
        {
            Title = "Actividad Actualizada",
            Body = "Una actividad en la que participas ha sido actualizada",
            Type = "actividad_actualizada",
            Data = new Dictionary<string, string>
            {
                { "type", "actividad_actualizada" },
                { "actividadId", actividadId.ToString() }
            }
        };

        await SendNotificationToUsersAsync(profesoresUuids, notification);
    }

    public async Task NotifyProfesorAnadidoAsync(string profesorUuid, int actividadId, string actividadNombre)
    {
        var notification = new SendNotificationDto
        {
            Title = "Te han añadido a una actividad",
            Body = $"Has sido añadido a la actividad '{actividadNombre}'",
            Type = "profesor_anadido",
            Data = new Dictionary<string, string>
            {
                { "type", "profesor_anadido" },
                { "actividadId", actividadId.ToString() },
                { "actividadNombre", actividadNombre }
            }
        };

        await SendNotificationToUserAsync(profesorUuid, notification);
    }

    public async Task NotifyNuevoMensajeAsync(MensajeNotificationDto dto)
    {
        _logger.LogInformation("📨 [NotificationService] Preparando notificación de mensaje para usuario {RecipientUuid}", dto.RecipientUuid);
        
        var notification = new SendNotificationDto
        {
            Title = $"Mensaje de {dto.SenderName}",
            Body = dto.MessagePreview,
            Type = "nuevo_mensaje",
            Data = new Dictionary<string, string>
            {
                { "type", "nuevo_mensaje" },
                { "chatId", dto.ChatId },
                { "senderName", dto.SenderName }
            }
        };

        await SendNotificationToUserAsync(dto.RecipientUuid, notification);
        _logger.LogInformation("✅ [NotificationService] Notificación de mensaje procesada");
    }

    public async Task<object> GetDiagnosticsAsync(string? usuarioId)
    {
        try
        {
            // Información general del sistema
            var totalTokens = await _context.Set<FcmToken>().CountAsync(t => t.Activo);
            var totalUsers = await _context.Set<FcmToken>()
                .Where(t => t.Activo)
                .Select(t => t.UsuarioId)
                .Distinct()
                .CountAsync();

            // Información del usuario actual (si está autenticado)
            object? userInfo = null;
            if (!string.IsNullOrEmpty(usuarioId) && Guid.TryParse(usuarioId, out var usuarioGuid))
            {
                var userTokens = await _context.Set<FcmToken>()
                    .Where(t => t.UsuarioId == usuarioGuid && t.Activo)
                    .Select(t => new
                    {
                        t.DeviceType,
                        t.DeviceId,
                        t.FechaCreacion,
                        TokenPreview = t.Token.Substring(0, Math.Min(20, t.Token.Length)) + "..."
                    })
                    .ToListAsync();

                userInfo = new
                {
                    usuarioId,
                    tokensRegistrados = userTokens.Count,
                    dispositivos = userTokens
                };
            }

            // Estado de Firebase
            var firebaseStatus = _firebaseInitialized ? "Inicializado" : "No inicializado";

            return new
            {
                firebase = new
                {
                    status = firebaseStatus,
                    initialized = _firebaseInitialized
                },
                tokens = new
                {
                    total = totalTokens,
                    usuarios = totalUsers
                },
                usuario = userInfo,
                timestamp = DateTime.UtcNow
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error obteniendo diagnósticos");
            return new
            {
                error = "Error al obtener diagnósticos",
                message = ex.Message
            };
        }
    }
}

