using System.ComponentModel.DataAnnotations;

namespace ACEXAPI.Models;

public class EmpTransporte
{
    [Key]
    public int Id { get; set; }

    [Required]
    [MaxLength(200)]
    public string Nombre { get; set; } = string.Empty;

    [MaxLength(50)]
    public string? Cif { get; set; }

    [MaxLength(20)]
    public string? Telefono { get; set; }

    [EmailAddress]
    [MaxLength(200)]
    public string? Email { get; set; }

    [MaxLength(500)]
    public string? Direccion { get; set; }

    // Relaciones
    public ICollection<Actividad> Actividades { get; set; } = new List<Actividad>();
}
