namespace ACEXAPI.DTOs;

public class DepartamentoDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
}

public class CursoDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Nivel { get; set; }
    public bool Activo { get; set; }
}

public class GrupoDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public int NumeroAlumnos { get; set; }
    public int CursoId { get; set; }
    public string? CursoNombre { get; set; }
}

public class EmpTransporteDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Cif { get; set; }
    public string? Telefono { get; set; }
    public string? Email { get; set; }
    public string? Direccion { get; set; }
}

public class GrupoParticDto
{
    public int Id { get; set; }
    public int ActividadId { get; set; }
    public int GrupoId { get; set; }
    public string? GrupoNombre { get; set; }
    public int NumeroParticipantes { get; set; }
}

public class ProfParticipanteDto
{
    public int Id { get; set; }
    public int ActividadId { get; set; }
    public Guid ProfesorUuid { get; set; }
    public string? ProfesorNombre { get; set; }
    public string? Observaciones { get; set; }
}

public class ProfResponsableDto
{
    public int Id { get; set; }
    public int ActividadId { get; set; }
    public Guid ProfesorUuid { get; set; }
    public string? ProfesorNombre { get; set; }
    public bool EsCoordinador { get; set; }
    public string? Observaciones { get; set; }
}

public class GrupoParticipanteDto
{
    public int GrupoId { get; set; }
    public string GrupoNombre { get; set; } = string.Empty;
    public int NumeroAlumnos { get; set; }
    public int NumeroParticipantes { get; set; }
}

public class GrupoParticipanteUpdateDto
{
    public int GrupoId { get; set; }
    public int NumeroParticipantes { get; set; }
}
