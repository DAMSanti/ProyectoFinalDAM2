using System.ComponentModel.DataAnnotations;

namespace ACEXAPI.Models;

public class GrupoPartic
{
    [Key]
    public int Id { get; set; }

    public int ActividadId { get; set; }
    public Actividad Actividad { get; set; } = null!;

    public int GrupoId { get; set; }
    public Grupo Grupo { get; set; } = null!;

    public int NumeroParticipantes { get; set; }

    public DateTime FechaRegistro { get; set; } = DateTime.UtcNow;
}
