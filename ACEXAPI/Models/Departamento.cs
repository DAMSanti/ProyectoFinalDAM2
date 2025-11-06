using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ACEXAPI.Models;

[Table("departamentos")]
public class Departamento
{
    [Key]
    [Column("id_depar")]
    public int Id { get; set; }

    [MaxLength(3)]
    [Column("codigo")]
    public string? Codigo { get; set; }

    [Required]
    [MaxLength(200)]
    [Column("nombre")]
    public string Nombre { get; set; } = string.Empty;

    [MaxLength(500)]
    public string? Descripcion { get; set; }

    // Relaciones
    public ICollection<Profesor> Profesores { get; set; } = new List<Profesor>();
    // Actividades ya NO tienen relación directa con Departamento
    // La relación es: Actividad -> Responsable (Profesor) -> Departamento
}
