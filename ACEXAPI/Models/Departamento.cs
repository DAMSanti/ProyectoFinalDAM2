using System.ComponentModel.DataAnnotations;

namespace ACEXAPI.Models;

public class Departamento
{
    [Key]
    public int Id { get; set; }

    [Required]
    [MaxLength(200)]
    public string Nombre { get; set; } = string.Empty;

    [MaxLength(10)]
    public string? Codigo { get; set; }

    [MaxLength(500)]
    public string? Descripcion { get; set; }

    // Relaciones
    public ICollection<Profesor> Profesores { get; set; } = new List<Profesor>();
    // Actividades ya NO tienen relación directa con Departamento
    // La relación es: Actividad -> Responsable (Profesor) -> Departamento
}
