using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
namespace ACEXAPI.Models;
[Table("FcmTokens")]
public class FcmToken
{
    [Key]
    public int Id { get; set; }
    [Required]
    public Guid UsuarioId { get; set; } = Guid.Empty;
    [Required]
    [MaxLength(500)]
    public string Token { get; set; } = string.Empty;
    [MaxLength(50)]
    public string? DeviceType { get; set; }
    [MaxLength(200)]
    public string? DeviceId { get; set; }
    public DateTime FechaCreacion { get; set; } = DateTime.UtcNow;
    public DateTime? UltimaActualizacion { get; set; }
    public bool Activo { get; set; } = true;
}