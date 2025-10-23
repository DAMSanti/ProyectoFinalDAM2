using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ACEXAPI.Models;

public class Contrato
{
    [Key]
    public int Id { get; set; }

    public int ActividadId { get; set; }
    public Actividad Actividad { get; set; } = null!;

    [Required]
    [MaxLength(200)]
    public string NombreProveedor { get; set; } = string.Empty;

    [MaxLength(1000)]
    public string? Descripcion { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal? Monto { get; set; }

    public DateTime? FechaContrato { get; set; }

    public string? PresupuestoUrl { get; set; }

    public string? FacturaUrl { get; set; }

    public DateTime FechaCreacion { get; set; } = DateTime.UtcNow;
}
