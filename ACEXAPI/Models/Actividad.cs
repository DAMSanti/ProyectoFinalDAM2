using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ACEXAPI.Models;

[Table("Actividades")]
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

    // Campos que SÍ existen en la BD
    public decimal? PresupuestoEstimado { get; set; }

    public decimal? CostoReal { get; set; }

    public string? FolletoUrl { get; set; }

    public bool Aprobada { get; set; } = false;

    public DateTime FechaCreacion { get; set; } = DateTime.UtcNow;

    // Nuevos campos agregados recientemente
    [Column("precio_transporte")]
    public decimal? PrecioTransporte { get; set; }

    [Column("precio_alojamiento")]
    public decimal? PrecioAlojamiento { get; set; }

    [Column("transporte_req")]
    public int TransporteReq { get; set; } = 0;

    [Column("alojamiento_req")]
    public int AlojamientoReq { get; set; } = 0;

    // Relaciones - Estos campos SÍ existen en la BD con nombres PascalCase
    public int? AlojamientoId { get; set; }
    public Alojamiento? Alojamiento { get; set; }

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
    public ICollection<ActividadLocalizacion> ActividadLocalizaciones { get; set; } = new List<ActividadLocalizacion>();
}
