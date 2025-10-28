namespace ACEXAPI.DTOs;

public class AlojamientoDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Direccion { get; set; }
    public string? Ciudad { get; set; }
    public string? CodigoPostal { get; set; }
    public string? Provincia { get; set; }
    public string? Telefono { get; set; }
    public string? Email { get; set; }
    public string? Web { get; set; }
    public int? CapacidadTotal { get; set; }
    public string? Observaciones { get; set; }
    public bool Activo { get; set; }
    public DateTime FechaCreacion { get; set; }
}

public class CreateAlojamientoDto
{
    public string Nombre { get; set; } = string.Empty;
    public string? Direccion { get; set; }
    public string? Ciudad { get; set; }
    public string? CodigoPostal { get; set; }
    public string? Provincia { get; set; }
    public string? Telefono { get; set; }
    public string? Email { get; set; }
    public string? Web { get; set; }
    public int? CapacidadTotal { get; set; }
    public string? Observaciones { get; set; }
}

public class UpdateAlojamientoDto
{
    public string? Nombre { get; set; }
    public string? Direccion { get; set; }
    public string? Ciudad { get; set; }
    public string? CodigoPostal { get; set; }
    public string? Provincia { get; set; }
    public string? Telefono { get; set; }
    public string? Email { get; set; }
    public string? Web { get; set; }
    public int? CapacidadTotal { get; set; }
    public string? Observaciones { get; set; }
    public bool? Activo { get; set; }
}
