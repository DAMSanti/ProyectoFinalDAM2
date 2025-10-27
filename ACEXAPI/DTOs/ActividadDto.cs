namespace ACEXAPI.DTOs;

public class ActividadDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public DateTime FechaInicio { get; set; }
    public DateTime? FechaFin { get; set; }
    public decimal? PresupuestoEstimado { get; set; }
    public decimal? CostoReal { get; set; }
    public string? FolletoUrl { get; set; }
    public bool Aprobada { get; set; }
    public int? DepartamentoId { get; set; }
    public string? DepartamentoNombre { get; set; }
    public int? LocalizacionId { get; set; }
    public string? LocalizacionNombre { get; set; }
    public int? EmpTransporteId { get; set; }
    public string? EmpTransporteNombre { get; set; }
    
    // Información del profesor responsable/solicitante
    public ProfesorSimpleDto? Solicitante { get; set; }
}

public class ProfesorSimpleDto
{
    public int Id { get; set; }
    public Guid Uuid { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Apellidos { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? FotoUrl { get; set; }
}

public class ActividadCreateDto
{
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public DateTime FechaInicio { get; set; }
    public DateTime? FechaFin { get; set; }
    public decimal? PresupuestoEstimado { get; set; }
    public int? DepartamentoId { get; set; }
    public int? LocalizacionId { get; set; }
    public int? EmpTransporteId { get; set; }
}

public class ActividadUpdateDto
{
    public string? Nombre { get; set; }
    public string? Descripcion { get; set; }
    public DateTime? FechaInicio { get; set; }
    public DateTime? FechaFin { get; set; }
    public decimal? PresupuestoEstimado { get; set; }
    public decimal? CostoReal { get; set; }
    public bool? Aprobada { get; set; }
    public Guid? SolicitanteId { get; set; }
    public int? DepartamentoId { get; set; }
    public int? LocalizacionId { get; set; }
    public int? EmpTransporteId { get; set; }
}

public class ActividadListDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public DateTime FechaInicio { get; set; }
    public bool Aprobada { get; set; }
    public string? DepartamentoNombre { get; set; }
}
