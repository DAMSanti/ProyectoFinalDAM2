namespace ACEXAPI.DTOs;

public class ProfesorDto
{
    public Guid Uuid { get; set; }
    public string Dni { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public string Apellidos { get; set; } = string.Empty;
    public string Correo { get; set; } = string.Empty;
    public string? Telefono { get; set; }
    public string? FotoUrl { get; set; }
    public bool Activo { get; set; }
    public int? DepartamentoId { get; set; }
    public string? DepartamentoNombre { get; set; }
}

public class ProfesorCreateDto
{
    public string Dni { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public string Apellidos { get; set; } = string.Empty;
    public string Correo { get; set; } = string.Empty;
    public string? Telefono { get; set; }
    public int? DepartamentoId { get; set; }
}

public class ProfesorUpdateDto
{
    public string? Nombre { get; set; }
    public string? Apellidos { get; set; }
    public string? Telefono { get; set; }
    public bool? Activo { get; set; }
    public int? DepartamentoId { get; set; }
}
