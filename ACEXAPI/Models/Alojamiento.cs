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

    [MaxLength(50)]
    public string? TipoAlojamiento { get; set; } // Hotel, Hostal, Albergue, Casa Rural, etc.

    public int? NumeroHabitaciones { get; set; }

    public int? CapacidadTotal { get; set; }

    [Column(TypeName = "decimal(10,2)")]
    public decimal? PrecioPorNoche { get; set; }

    [MaxLength(1000)]
    public string? Servicios { get; set; } // WiFi, Desayuno, Parking, etc.

    [MaxLength(1000)]
    public string? Observaciones { get; set; }

    public bool Activo { get; set; } = true;

    public DateTime FechaCreacion { get; set; } = DateTime.UtcNow;

    // Coordenadas para mapa
    [Column(TypeName = "decimal(10,7)")]
    public decimal? Latitud { get; set; }

    [Column(TypeName = "decimal(10,7)")]
    public decimal? Longitud { get; set; }

    // Relación inversa
    public ICollection<Actividad> Actividades { get; set; } = new List<Actividad>();
}
