using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
namespace ACEXAPI.Models;
public class Usuario
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();
    [Required]
    [MaxLength(200)]
    [RegularExpression(@"^[a-zA-Z0-9_-]+$", ErrorMessage = "El nombre de usuario solo puede contener letras, números, guiones y guiones bajos")]
    public string NombreUsuario { get; set; } = string.Empty;
    [Required]
    [MaxLength(256)]
    public string Password { get; set; } = string.Empty; 
    [Required]
    [MaxLength(50)]
    public string Rol { get; set; } = "Usuario"; 
    public DateTime FechaCreacion { get; set; } = DateTime.UtcNow;
    public bool Activo { get; set; } = true;
    public Guid? ProfesorUuid { get; set; }
    [ForeignKey("ProfesorUuid")]
    public Profesor? Profesor { get; set; }
}