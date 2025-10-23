using System.ComponentModel.DataAnnotations;

namespace ACEXAPI.Models;

public class Foto
{
    [Key]
    public int Id { get; set; }

    public int ActividadId { get; set; }
    public Actividad Actividad { get; set; } = null!;

    [Required]
    public string Url { get; set; } = string.Empty;

    public string? UrlThumbnail { get; set; }

    [MaxLength(500)]
    public string? Descripcion { get; set; }

    public DateTime FechaSubida { get; set; } = DateTime.UtcNow;

    public long TamanoBytes { get; set; }
}
