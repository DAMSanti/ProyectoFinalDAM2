using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ACEXAPI.Models;

[Table("Alojamientos")]
public class Alojamiento
{
    [Key]
    public int Id { get; set; }

    [Required]
    [MaxLength(200)]
    public string Nombre { get; set; } = string.Empty;

    [MaxLength(300)]
    public string? Direccion { get; set; }

    [MaxLength(100)]
    public string? Ciudad { get; set; }

    [MaxLength(20)]
    public string? CodigoPostal { get; set; }

    [MaxLength(100)]
    public string? Provincia { get; set; }

    [MaxLength(20)]
    public string? Telefono { get; set; }

    [MaxLength(200)]
    [EmailAddress]
    public string? Email { get; set; }

    public string? Web { get; set; }

    public int? CapacidadTotal { get; set; }

    [MaxLength(1000)]
    public string? Observaciones { get; set; }

    public bool Activo { get; set; } = true;

    public DateTime FechaCreacion { get; set; } = DateTime.UtcNow;

    // Relación inversa
    public ICollection<Actividad> Actividades { get; set; } = new List<Actividad>();
}
