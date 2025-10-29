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
    public decimal? PrecioTransporte { get; set; }
    public string? FolletoUrl { get; set; }
    public string Estado { get; set; } = "Pendiente";
    public string Tipo { get; set; } = "Complementaria";
    public int? LocalizacionId { get; set; }
    public string? LocalizacionNombre { get; set; }
    public int? EmpTransporteId { get; set; }
    public string? EmpTransporteNombre { get; set; }
    public int TransporteReq { get; set; }
    public decimal? PrecioAlojamiento { get; set; }
    public int? AlojamientoId { get; set; }
    public AlojamientoDto? Alojamiento { get; set; }
    public int AlojamientoReq { get; set; }
    
    // Lista de localizaciones de la actividad
    public List<LocalizacionDto>? Localizaciones { get; set; }
    
    // Información del profesor responsable
    public Guid? ResponsableId { get; set; }
    public ProfesorSimpleDto? Responsable { get; set; }
    
    // Información del profesor solicitante (mantener por compatibilidad)
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
    public Guid? ResponsableId { get; set; }
    public int? LocalizacionId { get; set; }
    public int? EmpTransporteId { get; set; }
    public string Tipo { get; set; } = "Complementaria";
}

public class ActividadUpdateDto
{
    public string? Nombre { get; set; }
    public string? Descripcion { get; set; }
    public DateTime? FechaInicio { get; set; }
    public DateTime? FechaFin { get; set; }
    public decimal? PresupuestoEstimado { get; set; }
    public decimal? CostoReal { get; set; }
    public decimal? PrecioTransporte { get; set; }
    public string? Estado { get; set; }
    public string? Tipo { get; set; }
    public Guid? ResponsableId { get; set; }
    public Guid? SolicitanteId { get; set; } // Mantener por compatibilidad
    public int? LocalizacionId { get; set; }
    public int? EmpTransporteId { get; set; }
    public int? EmpresaTransporteId { get; set; } // Alias para compatibilidad con Flutter
    public int? AlojamientoId { get; set; }
    public decimal? PrecioAlojamiento { get; set; }
    public int? TransporteReq { get; set; }
    public int? AlojamientoReq { get; set; }
}

public class ActividadListDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public DateTime FechaInicio { get; set; }
    public DateTime? FechaFin { get; set; }
    public string Estado { get; set; } = "Pendiente";
    public string Tipo { get; set; } = "Complementaria";
}

public class LocalizacionDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Direccion { get; set; }
    public string? Ciudad { get; set; }
    public string? Provincia { get; set; }
    public string? CodigoPostal { get; set; }
    public double? Latitud { get; set; }
    public double? Longitud { get; set; }
    public bool EsPrincipal { get; set; }
    public int Orden { get; set; }
    public string? Icono { get; set; }
}

public class AddLocalizacionDto
{
    public bool EsPrincipal { get; set; } = false;
    public int Orden { get; set; } = 0;
    public string? Icono { get; set; }
}

public class UpdateLocalizacionDto
{
    public bool EsPrincipal { get; set; }
    public int Orden { get; set; }
    public string? Icono { get; set; }
}
