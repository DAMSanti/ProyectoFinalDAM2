using System.ComponentModel.DataAnnotations;

namespace ACEXAPI.Models;

public class Usuario
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [Required]
    [EmailAddress]
    [MaxLength(256)]
    public string Email { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(200)]
    public string NombreCompleto { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(256)]
    public string Password { get; set; } = string.Empty; // Hash de la contraseña
    
    [Required]
    [MaxLength(50)]
    public string Rol { get; set; } = "Usuario"; // Administrador, Coordinador, Profesor, Usuario
    
    public DateTime FechaCreacion { get; set; } = DateTime.UtcNow;
    
    public bool Activo { get; set; } = true;
}
