using System.ComponentModel.DataAnnotations;

namespace ACEXAPI.Models;

public class Curso
{
    [Key]
    public int Id { get; set; }

    [Required]
    [MaxLength(100)]
    public string Nombre { get; set; } = string.Empty;

    [MaxLength(10)]
    public string? Nivel { get; set; }

    public bool Activo { get; set; } = true;

    // Relaciones
    public ICollection<Grupo> Grupos { get; set; } = new List<Grupo>();
}
