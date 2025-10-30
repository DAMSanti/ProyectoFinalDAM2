using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ACEXAPI.Models;

/// <summary>
/// Modelo para almacenar tokens FCM de los dispositivos de los usuarios
/// </summary>
[Table("FcmTokens")]
public class FcmToken
{
    [Key]
    public int Id { get; set; }

    /// <summary>
    /// UUID del usuario (de la tabla Usuarios)
    /// </summary>
    [Required]
    public Guid UsuarioId { get; set; } = Guid.Empty;

    /// <summary>
    /// Token FCM del dispositivo
    /// </summary>
    [Required]
    [MaxLength(500)]
    public string Token { get; set; } = string.Empty;

    /// <summary>
    /// Tipo de dispositivo: android, ios, web
    /// </summary>
    [MaxLength(50)]
    public string? DeviceType { get; set; }

    /// <summary>
    /// Identificador único del dispositivo
    /// </summary>
    [MaxLength(200)]
    public string? DeviceId { get; set; }

    /// <summary>
    /// Fecha de creación del registro
    /// </summary>
    public DateTime FechaCreacion { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// Última vez que se actualizó el token
    /// </summary>
    public DateTime? UltimaActualizacion { get; set; }

    /// <summary>
    /// Indica si el token está activo
    /// </summary>
    public bool Activo { get; set; } = true;
}
