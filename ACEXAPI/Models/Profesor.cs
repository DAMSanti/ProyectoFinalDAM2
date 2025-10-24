using System.ComponentModel.DataAnnotations;

namespace ACEXAPI.Models;

public class Profesor
{
    [Key]
    public Guid Uuid { get; set; } = Guid.NewGuid();

    [Required]
    [MaxLength(20)]
    public string Dni { get; set; } = string.Empty;

    [Required]
    [MaxLength(100)]
    public string Nombre { get; set; } = string.Empty;

    [Required]
    [MaxLength(100)]
    public string Apellidos { get; set; } = string.Empty;

    [Required]
    [EmailAddress]
    [MaxLength(200)]
    public string Correo { get; set; } = string.Empty;

    [MaxLength(20)]
    public string? Telefono { get; set; }

    public string? FotoUrl { get; set; }

    public bool Activo { get; set; } = true;

    // Relaciones
    public int? DepartamentoId { get; set; }
    public Departamento? Departamento { get; set; }

    public ICollection<ProfParticipante> ActividadesParticipante { get; set; } = new List<ProfParticipante>();
    public ICollection<ProfResponsable> ActividadesResponsable { get; set; } = new List<ProfResponsable>();
    
    // Relación con Usuario (un profesor puede tener un usuario para login)
    public ICollection<Usuario> Usuarios { get; set; } = new List<Usuario>();
}
