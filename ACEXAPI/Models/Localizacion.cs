using System.ComponentModel.DataAnnotations;

namespace ACEXAPI.Models;

public class Localizacion
{
    [Key]
    public int Id { get; set; }

    [Required]
    [MaxLength(200)]
    public string Nombre { get; set; } = string.Empty;

    [MaxLength(500)]
    public string? Direccion { get; set; }

    [MaxLength(100)]
    public string? Ciudad { get; set; }

    [MaxLength(100)]
    public string? Provincia { get; set; }

    [MaxLength(20)]
    public string? CodigoPostal { get; set; }

    // Relaciones
    public ICollection<Actividad> Actividades { get; set; } = new List<Actividad>();
}
