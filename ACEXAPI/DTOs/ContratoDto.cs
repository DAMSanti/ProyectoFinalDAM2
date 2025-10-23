namespace ACEXAPI.DTOs;

public class ContratoDto
{
    public int Id { get; set; }
    public int ActividadId { get; set; }
    public string NombreProveedor { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public decimal? Monto { get; set; }
    public DateTime? FechaContrato { get; set; }
    public string? PresupuestoUrl { get; set; }
    public string? FacturaUrl { get; set; }
}

public class ContratoCreateDto
{
    public int ActividadId { get; set; }
    public string NombreProveedor { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public decimal? Monto { get; set; }
    public DateTime? FechaContrato { get; set; }
}
