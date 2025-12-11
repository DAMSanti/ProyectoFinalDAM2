using ACEXAPI.Data;
using ACEXAPI.DTOs;
using ACEXAPI.Models;
using Microsoft.EntityFrameworkCore;
namespace ACEXAPI.Services;
public interface IActividadService
{
    Task<PaginatedResult<ActividadListDto>> GetAllAsync(QueryParameters queryParams);
    Task<ActividadDto?> GetByIdAsync(int id);
    Task<ActividadDto> CreateAsync(ActividadCreateDto dto, IFormFile? folleto);
    Task<ActividadDto?> UpdateAsync(int id, ActividadUpdateDto dto, IFormFile? folleto);
    Task<bool> DeleteAsync(int id);
    Task<List<string>> GetProfesoresParticipantesAsync(int actividadId);
    Task<bool> UpdateProfesoresParticipantesAsync(int actividadId, List<string> profesoresIds);
    Task<List<GrupoParticipanteDto>> GetGruposParticipantesAsync(int actividadId);
    Task<bool> UpdateGruposParticipantesAsync(int actividadId, List<GrupoParticipanteUpdateDto> grupos);
    Task<string?> UpdateFolletoAsync(int actividadId, IFormFile folleto);
    Task<bool> DeleteFolletoAsync(int actividadId);
    Task<List<LocalizacionDto>> GetLocalizacionesAsync(int actividadId);
    Task<bool> AddLocalizacionAsync(int actividadId, int localizacionId, bool esPrincipal, int orden, string? icono, string? descripcion = null, string? tipoLocalizacion = null);
    Task<bool> RemoveLocalizacionAsync(int actividadId, int localizacionId);
    Task<bool> UpdateLocalizacionAsync(int actividadId, int localizacionId, bool esPrincipal, int orden, string? icono, string? descripcion = null, string? tipoLocalizacion = null);
}
public class ActividadService : IActividadService
{
    private readonly ApplicationDbContext _context;
    private readonly IFileStorageService _fileStorage;
    private readonly ILogger<ActividadService> _logger;
    public ActividadService(
        ApplicationDbContext context,
        IFileStorageService fileStorage,
        ILogger<ActividadService> logger)
    {
        _context = context;
        _fileStorage = fileStorage;
        _logger = logger;
    }
    public async Task<PaginatedResult<ActividadListDto>> GetAllAsync(QueryParameters queryParams)
    {
        var query = _context.Actividades
            .Include(a => a.Responsable!)
                .ThenInclude(r => r.Departamento)
            .Include(a => a.ProfesoresParticipantes)
            .AsQueryable();
        if (!string.IsNullOrWhiteSpace(queryParams.Search))
        {
            query = query.Where(a =>
                a.Nombre.Contains(queryParams.Search) ||
                (a.Descripcion != null && a.Descripcion.Contains(queryParams.Search)));
        }
        query = queryParams.OrderBy?.ToLower() switch
        {
            "nombre" => queryParams.Descending ? query.OrderByDescending(a => a.Nombre) : query.OrderBy(a => a.Nombre),
            "fecha" => queryParams.Descending ? query.OrderByDescending(a => a.FechaInicio) : query.OrderBy(a => a.FechaInicio),
            _ => query.OrderByDescending(a => a.FechaCreacion)
        };
        var totalCount = await query.CountAsync();
        var items = await query
            .Skip((queryParams.Page - 1) * queryParams.PageSize)
            .Take(queryParams.PageSize)
            .Select(a => new ActividadListDto
            {
                Id = a.Id,
                Nombre = a.Nombre,
                Descripcion = a.Descripcion,
                FechaInicio = a.FechaInicio,
                FechaFin = a.FechaFin,
                Estado = a.Estado,
                Tipo = a.Tipo,
                ResponsableId = a.ResponsableId,
                Responsable = a.Responsable != null ? new ProfesorSimpleDto
                {
                    Id = 0, 
                    Uuid = a.Responsable.Uuid,
                    Nombre = a.Responsable.Nombre,
                    Apellidos = a.Responsable.Apellidos,
                    Email = a.Responsable.Correo,
                    FotoUrl = a.Responsable.FotoUrl,
                    DepartamentoId = a.Responsable.DepartamentoId,
                    DepartamentoNombre = a.Responsable.Departamento != null ? a.Responsable.Departamento.Nombre : null
                } : null,
                Solicitante = a.Responsable != null ? new ProfesorSimpleDto
                {
                    Id = 0, 
                    Uuid = a.Responsable.Uuid,
                    Nombre = a.Responsable.Nombre,
                    Apellidos = a.Responsable.Apellidos,
                    Email = a.Responsable.Correo,
                    FotoUrl = a.Responsable.FotoUrl,
                    DepartamentoId = a.Responsable.DepartamentoId,
                    DepartamentoNombre = a.Responsable.Departamento != null ? a.Responsable.Departamento.Nombre : null
                } : null,
                ProfesoresParticipantesIds = a.ProfesoresParticipantes.Select(pp => pp.ProfesorUuid).ToList()
            })
            .ToListAsync();
        return new PaginatedResult<ActividadListDto>
        {
            Items = items,
            Page = queryParams.Page,
            PageSize = queryParams.PageSize,
            TotalCount = totalCount
        };
    }
    public async Task<ActividadDto?> GetByIdAsync(int id)
    {
        var actividad = await _context.Actividades
            .Include(a => a.Responsable)
                .ThenInclude(r => r.Departamento)
            .Include(a => a.Localizacion)
            .Include(a => a.EmpTransporte)
            .Include(a => a.Alojamiento)
            .Include(a => a.ProfesoresResponsables)
                .ThenInclude(pr => pr.Profesor)
            .Include(a => a.ActividadLocalizaciones)
                .ThenInclude(al => al.Localizacion)
            .FirstOrDefaultAsync(a => a.Id == id);
        if (actividad == null)
            return null;
        var dto = MapToDto(actividad);
        dto.Localizaciones = actividad.ActividadLocalizaciones
            .OrderBy(al => al.Orden)
            .Select(al => new LocalizacionDto
            {
                Id = al.Localizacion!.Id,
                Nombre = al.Localizacion.Nombre,
                Direccion = al.Localizacion.Direccion,
                Ciudad = al.Localizacion.Ciudad,
                Provincia = al.Localizacion.Provincia,
                CodigoPostal = al.Localizacion.CodigoPostal,
                Latitud = al.Localizacion.Latitud,
                Longitud = al.Localizacion.Longitud,
                EsPrincipal = al.EsPrincipal,
                Orden = al.Orden,
                Icono = al.Localizacion.Icono
            })
            .ToList();
        return dto;
    }
    public async Task<ActividadDto> CreateAsync(ActividadCreateDto dto, IFormFile? folleto)
    {
        var actividad = new Actividad
        {
            Nombre = dto.Nombre,
            Descripcion = dto.Descripcion,
            FechaInicio = dto.FechaInicio,
            FechaFin = dto.FechaFin,
            PresupuestoEstimado = dto.PresupuestoEstimado,
            ResponsableId = dto.ResponsableId,
            LocalizacionId = dto.LocalizacionId,
            EmpTransporteId = dto.EmpTransporteId,
            Tipo = dto.Tipo
        };
        if (folleto != null)
        {
            actividad.FolletoUrl = await _fileStorage.UploadFileAsync(folleto, "folletos");
        }
        _context.Actividades.Add(actividad);
        await _context.SaveChangesAsync();
        return MapToDto(actividad);
    }
    public async Task<ActividadDto?> UpdateAsync(int id, ActividadUpdateDto dto, IFormFile? folleto)
    {
        _logger.LogInformation("=== ACTUALIZAR ACTIVIDAD {Id} ===", id);
        _logger.LogInformation("PresupuestoEstimado recibido: {Presupuesto}", dto.PresupuestoEstimado);
        _logger.LogInformation("PrecioTransporte recibido: {PrecioTransporte}", dto.PrecioTransporte);
        _logger.LogInformation("PrecioAlojamiento recibido: {PrecioAlojamiento}", dto.PrecioAlojamiento);
        _logger.LogInformation("CostoReal recibido: {CostoReal}", dto.CostoReal);
        var actividad = await _context.Actividades
            .Include(a => a.ProfesoresResponsables)
            .FirstOrDefaultAsync(a => a.Id == id);
        if (actividad == null)
            return null;
        if (dto.Nombre != null) actividad.Nombre = dto.Nombre;
        if (dto.Descripcion != null) actividad.Descripcion = dto.Descripcion;
        if (dto.FechaInicio.HasValue) actividad.FechaInicio = dto.FechaInicio.Value;
        if (dto.FechaFin.HasValue) actividad.FechaFin = dto.FechaFin;
        if (dto.PresupuestoEstimado.HasValue) actividad.PresupuestoEstimado = dto.PresupuestoEstimado;
        if (dto.CostoReal.HasValue) actividad.CostoReal = dto.CostoReal;
        if (dto.PrecioTransporte.HasValue) actividad.PrecioTransporte = dto.PrecioTransporte;
        if (dto.Estado != null) actividad.Estado = dto.Estado;
        if (dto.Tipo != null) actividad.Tipo = dto.Tipo;
        if (dto.ResponsableId != null) actividad.ResponsableId = dto.ResponsableId;
        if (dto.LocalizacionId.HasValue) actividad.LocalizacionId = dto.LocalizacionId;
        if (dto.EmpresaTransporteId.HasValue) actividad.EmpTransporteId = dto.EmpresaTransporteId;
        else if (dto.EmpTransporteId.HasValue) actividad.EmpTransporteId = dto.EmpTransporteId;
        if (dto.AlojamientoId.HasValue) actividad.AlojamientoId = dto.AlojamientoId;
        if (dto.PrecioAlojamiento.HasValue) actividad.PrecioAlojamiento = dto.PrecioAlojamiento.Value;
        if (dto.TransporteReq.HasValue) actividad.TransporteReq = dto.TransporteReq.Value;
        if (dto.AlojamientoReq.HasValue) actividad.AlojamientoReq = dto.AlojamientoReq.Value;
        if (dto.SolicitanteId.HasValue)
        {
            var responsableActual = actividad.ProfesoresResponsables.FirstOrDefault();
            if (responsableActual != null)
            {
                _context.ProfResponsables.Remove(responsableActual);
            }
            actividad.ProfesoresResponsables.Add(new ProfResponsable
            {
                ActividadId = actividad.Id,
                ProfesorUuid = dto.SolicitanteId.Value,
                EsCoordinador = true
            });
        }
        if (folleto != null)
        {
            if (!string.IsNullOrEmpty(actividad.FolletoUrl))
            {
                await _fileStorage.DeleteFileAsync(actividad.FolletoUrl);
            }
            actividad.FolletoUrl = await _fileStorage.UploadFileAsync(folleto, "folletos");
        }
        await _context.SaveChangesAsync();
        var actividadActualizada = await _context.Actividades
            .Include(a => a.Responsable)
            .Include(a => a.Localizacion)
            .Include(a => a.EmpTransporte)
            .Include(a => a.Alojamiento)
            .Include(a => a.ProfesoresResponsables)
                .ThenInclude(pr => pr.Profesor)
            .FirstOrDefaultAsync(a => a.Id == id);
        return MapToDto(actividadActualizada!);
    }
    public async Task<bool> DeleteAsync(int id)
    {
        var actividad = await _context.Actividades.FindAsync(id);
        if (actividad == null)
            return false;
        if (!string.IsNullOrEmpty(actividad.FolletoUrl))
        {
            await _fileStorage.DeleteFileAsync(actividad.FolletoUrl);
        }
        _context.Actividades.Remove(actividad);
        await _context.SaveChangesAsync();
        return true;
    }
    private ActividadDto MapToDto(Actividad actividad)
    {
        var primerResponsable = actividad.ProfesoresResponsables.FirstOrDefault();
        ProfesorSimpleDto? solicitante = null;
        if (primerResponsable?.Profesor != null)
        {
            solicitante = new ProfesorSimpleDto
            {
                Id = primerResponsable.Profesor.Uuid.GetHashCode(), 
                Uuid = primerResponsable.Profesor.Uuid,
                Nombre = primerResponsable.Profesor.Nombre,
                Apellidos = primerResponsable.Profesor.Apellidos,
                Email = primerResponsable.Profesor.Correo,
                FotoUrl = primerResponsable.Profesor.FotoUrl
            };
        }
        return new ActividadDto
        {
            Id = actividad.Id,
            Nombre = actividad.Nombre,
            Descripcion = actividad.Descripcion,
            FechaInicio = actividad.FechaInicio,
            FechaFin = actividad.FechaFin,
            PresupuestoEstimado = actividad.PresupuestoEstimado,
            CostoReal = actividad.CostoReal,
            PrecioTransporte = actividad.PrecioTransporte,
            FolletoUrl = actividad.FolletoUrl,
            Estado = actividad.Estado,
            Tipo = actividad.Tipo,
            ResponsableId = actividad.ResponsableId,
            Responsable = actividad.Responsable != null ? new ProfesorSimpleDto
            {
                Id = actividad.Responsable.Uuid.GetHashCode(), 
                Uuid = actividad.Responsable.Uuid,
                Nombre = actividad.Responsable.Nombre,
                Apellidos = actividad.Responsable.Apellidos,
                Email = actividad.Responsable.Correo,
                FotoUrl = actividad.Responsable.FotoUrl,
                DepartamentoId = actividad.Responsable.DepartamentoId,
                DepartamentoNombre = actividad.Responsable.Departamento?.Nombre
            } : null,
            LocalizacionId = actividad.LocalizacionId,
            LocalizacionNombre = actividad.Localizacion?.Nombre,
            EmpTransporteId = actividad.EmpTransporteId,
            EmpTransporteNombre = actividad.EmpTransporte?.Nombre,
            TransporteReq = actividad.TransporteReq,
            PrecioAlojamiento = actividad.PrecioAlojamiento,
            AlojamientoId = actividad.AlojamientoId,
            Alojamiento = actividad.Alojamiento != null ? new AlojamientoDto
            {
                Id = actividad.Alojamiento.Id,
                Nombre = actividad.Alojamiento.Nombre,
                Direccion = actividad.Alojamiento.Direccion,
                Ciudad = actividad.Alojamiento.Ciudad,
                CodigoPostal = actividad.Alojamiento.CodigoPostal,
                Provincia = actividad.Alojamiento.Provincia,
                Telefono = actividad.Alojamiento.Telefono,
                Email = actividad.Alojamiento.Email,
                Web = actividad.Alojamiento.Web,
                CapacidadTotal = actividad.Alojamiento.CapacidadTotal,
                Observaciones = actividad.Alojamiento.Observaciones,
                Activo = actividad.Alojamiento.Activo,
                FechaCreacion = actividad.Alojamiento.FechaCreacion
            } : null,
            AlojamientoReq = actividad.AlojamientoReq,
            Solicitante = solicitante
        };
    }
    public async Task<List<string>> GetProfesoresParticipantesAsync(int actividadId)
    {
        var profesoresIds = await _context.Set<ProfParticipante>()
            .Where(pp => pp.ActividadId == actividadId)
            .Select(pp => pp.ProfesorUuid.ToString())
            .ToListAsync();
        return profesoresIds;
    }
    public async Task<bool> UpdateProfesoresParticipantesAsync(int actividadId, List<string> profesoresIds)
    {
        var actividad = await _context.Actividades.FindAsync(actividadId);
        if (actividad == null)
            return false;
        var participantesActuales = await _context.Set<ProfParticipante>()
            .Where(pp => pp.ActividadId == actividadId)
            .ToListAsync();
        _context.Set<ProfParticipante>().RemoveRange(participantesActuales);
        foreach (var profesorId in profesoresIds)
        {
            if (Guid.TryParse(profesorId, out var uuid))
            {
                _context.Set<ProfParticipante>().Add(new ProfParticipante
                {
                    ActividadId = actividadId,
                    ProfesorUuid = uuid
                });
            }
        }
        await _context.SaveChangesAsync();
        return true;
    }
    public async Task<List<GrupoParticipanteDto>> GetGruposParticipantesAsync(int actividadId)
    {
        var grupos = await _context.Set<GrupoPartic>()
            .Include(gp => gp.Grupo)
                .ThenInclude(g => g.Curso)
            .Where(gp => gp.ActividadId == actividadId)
            .Select(gp => new GrupoParticipanteDto
            {
                GrupoId = gp.GrupoId,
                GrupoNombre = gp.Grupo.Nombre,
                NumeroAlumnos = gp.Grupo.NumeroAlumnos,
                NumeroParticipantes = gp.NumeroParticipantes,
                CursoId = gp.Grupo.CursoId,
                CursoNombre = gp.Grupo.Curso != null ? gp.Grupo.Curso.Nombre : null
            })
            .ToListAsync();
        return grupos;
    }
    public async Task<bool> UpdateGruposParticipantesAsync(int actividadId, List<GrupoParticipanteUpdateDto> grupos)
    {
        var actividad = await _context.Actividades.FindAsync(actividadId);
        if (actividad == null)
            return false;
        var gruposActuales = await _context.Set<GrupoPartic>()
            .Where(gp => gp.ActividadId == actividadId)
            .ToListAsync();
        _context.Set<GrupoPartic>().RemoveRange(gruposActuales);
        foreach (var grupo in grupos)
        {
            _context.Set<GrupoPartic>().Add(new GrupoPartic
            {
                ActividadId = actividadId,
                GrupoId = grupo.GrupoId,
                NumeroParticipantes = grupo.NumeroParticipantes
            });
        }
        await _context.SaveChangesAsync();
        return true;
    }
    public async Task<string?> UpdateFolletoAsync(int actividadId, IFormFile folleto)
    {
        var actividad = await _context.Actividades.FindAsync(actividadId);
        if (actividad == null)
            return null;
        if (!string.IsNullOrEmpty(actividad.FolletoUrl))
        {
            await _fileStorage.DeleteFileAsync(actividad.FolletoUrl);
        }
        var folletoUrl = await _fileStorage.UploadFileAsync(folleto, "folletos");
        actividad.FolletoUrl = folletoUrl;
        await _context.SaveChangesAsync();
        return folletoUrl;
    }
    public async Task<bool> DeleteFolletoAsync(int actividadId)
    {
        var actividad = await _context.Actividades.FindAsync(actividadId);
        if (actividad == null || string.IsNullOrEmpty(actividad.FolletoUrl))
            return false;
        await _fileStorage.DeleteFileAsync(actividad.FolletoUrl);
        actividad.FolletoUrl = null;
        await _context.SaveChangesAsync();
        return true;
    }
    public async Task<List<LocalizacionDto>> GetLocalizacionesAsync(int actividadId)
    {
        var localizaciones = await _context.ActividadLocalizaciones
            .Include(al => al.Localizacion)
            .Where(al => al.ActividadId == actividadId)
            .OrderBy(al => al.Orden)
            .Select(al => new LocalizacionDto
            {
                Id = al.Localizacion!.Id,
                Nombre = al.Localizacion.Nombre,
                Direccion = al.Localizacion.Direccion,
                Ciudad = al.Localizacion.Ciudad,
                Provincia = al.Localizacion.Provincia,
                CodigoPostal = al.Localizacion.CodigoPostal,
                Latitud = al.Localizacion.Latitud,
                Longitud = al.Localizacion.Longitud,
                EsPrincipal = al.EsPrincipal,
                Orden = al.Orden,
                Icono = al.Localizacion.Icono,
                Descripcion = al.Descripcion,
                TipoLocalizacion = al.TipoLocalizacion
            })
            .ToListAsync();
        return localizaciones;
    }
    public async Task<bool> AddLocalizacionAsync(int actividadId, int localizacionId, bool esPrincipal, int orden, string? icono = null, string? descripcion = null, string? tipoLocalizacion = null)
    {
        var actividadExists = await _context.Actividades.AnyAsync(a => a.Id == actividadId);
        var localizacion = await _context.Localizaciones.FindAsync(localizacionId);
        if (!actividadExists || localizacion == null)
            return false;
        if (!string.IsNullOrEmpty(icono))
        {
            localizacion.Icono = icono;
        }
        var exists = await _context.ActividadLocalizaciones
            .AnyAsync(al => al.ActividadId == actividadId && al.LocalizacionId == localizacionId);
        if (exists)
            return false;
        if (esPrincipal)
        {
            var otrasLocalizaciones = await _context.ActividadLocalizaciones
                .Where(al => al.ActividadId == actividadId && al.EsPrincipal)
                .ToListAsync();
            foreach (var loc in otrasLocalizaciones)
            {
                loc.EsPrincipal = false;
            }
        }
        var actividadLocalizacion = new ActividadLocalizacion
        {
            ActividadId = actividadId,
            LocalizacionId = localizacionId,
            EsPrincipal = esPrincipal,
            Orden = orden,
            Descripcion = descripcion,
            TipoLocalizacion = tipoLocalizacion,
            FechaAsignacion = DateTime.UtcNow
        };
        _context.ActividadLocalizaciones.Add(actividadLocalizacion);
        await _context.SaveChangesAsync();
        return true;
    }
    public async Task<bool> RemoveLocalizacionAsync(int actividadId, int localizacionId)
    {
        var actividadLocalizacion = await _context.ActividadLocalizaciones
            .FirstOrDefaultAsync(al => al.ActividadId == actividadId && al.LocalizacionId == localizacionId);
        if (actividadLocalizacion == null)
            return false;
        _context.ActividadLocalizaciones.Remove(actividadLocalizacion);
        await _context.SaveChangesAsync();
        return true;
    }
    public async Task<bool> UpdateLocalizacionAsync(int actividadId, int localizacionId, bool esPrincipal, int orden, string? icono = null, string? descripcion = null, string? tipoLocalizacion = null)
    {
        var actividadLocalizacion = await _context.ActividadLocalizaciones
            .Include(al => al.Localizacion)
            .FirstOrDefaultAsync(al => al.ActividadId == actividadId && al.LocalizacionId == localizacionId);
        if (actividadLocalizacion == null)
            return false;
        if (!string.IsNullOrEmpty(icono) && actividadLocalizacion.Localizacion != null)
        {
            actividadLocalizacion.Localizacion.Icono = icono;
        }
        if (esPrincipal && !actividadLocalizacion.EsPrincipal)
        {
            var otrasLocalizaciones = await _context.ActividadLocalizaciones
                .Where(al => al.ActividadId == actividadId && al.EsPrincipal && al.Id != actividadLocalizacion.Id)
                .ToListAsync();
            foreach (var loc in otrasLocalizaciones)
            {
                loc.EsPrincipal = false;
            }
        }
        actividadLocalizacion.EsPrincipal = esPrincipal;
        actividadLocalizacion.Orden = orden;
        actividadLocalizacion.Descripcion = descripcion;
        actividadLocalizacion.TipoLocalizacion = tipoLocalizacion;
        await _context.SaveChangesAsync();
        return true;
    }
}