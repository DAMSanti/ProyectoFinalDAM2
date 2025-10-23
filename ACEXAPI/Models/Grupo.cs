using System.ComponentModel.DataAnnotations;

namespace ACEXAPI.Models;

public class Grupo
{
    [Key]
    public int Id { get; set; }

    [Required]
    [MaxLength(100)]
    public string Nombre { get; set; } = string.Empty;

    public int NumeroAlumnos { get; set; }

    // Relaciones
    public int CursoId { get; set; }
    public Curso Curso { get; set; } = null!;

    public ICollection<GrupoPartic> ActividadesParticipantes { get; set; } = new List<GrupoPartic>();
}
