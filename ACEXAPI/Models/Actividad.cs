using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ACEXAPI.Models;

public class Actividad
{
    [Key]
    public int Id { get; set; }

    [Required]
    [MaxLength(200)]
    public string Nombre { get; set; } = string.Empty;

    [MaxLength(1000)]
    public string? Descripcion { get; set; }

    [Required]
    public DateTime FechaInicio { get; set; }

    public DateTime? FechaFin { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal? PresupuestoEstimado { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal? CostoReal { get; set; }

    public string? FolletoUrl { get; set; }

    public bool Aprobada { get; set; } = false;

    public DateTime FechaCreacion { get; set; } = DateTime.UtcNow;

    // Relaciones
    public int? DepartamentoId { get; set; }
    public Departamento? Departamento { get; set; }

    public int? LocalizacionId { get; set; }
    public Localizacion? Localizacion { get; set; }

    public int? EmpTransporteId { get; set; }
    public EmpTransporte? EmpTransporte { get; set; }

    public ICollection<GrupoPartic> GruposParticipantes { get; set; } = new List<GrupoPartic>();
    public ICollection<ProfParticipante> ProfesoresParticipantes { get; set; } = new List<ProfParticipante>();
    public ICollection<ProfResponsable> ProfesoresResponsables { get; set; } = new List<ProfResponsable>();
    public ICollection<Foto> Fotos { get; set; } = new List<Foto>();
    public ICollection<Contrato> Contratos { get; set; } = new List<Contrato>();
}
