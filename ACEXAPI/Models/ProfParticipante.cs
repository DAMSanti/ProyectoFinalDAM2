using System.ComponentModel.DataAnnotations;

namespace ACEXAPI.Models;

public class ProfParticipante
{
    [Key]
    public int Id { get; set; }

    public int ActividadId { get; set; }
    public Actividad Actividad { get; set; } = null!;

    public Guid ProfesorUuid { get; set; }
    public Profesor Profesor { get; set; } = null!;

    public DateTime FechaRegistro { get; set; } = DateTime.UtcNow;

    [MaxLength(500)]
    public string? Observaciones { get; set; }
}
