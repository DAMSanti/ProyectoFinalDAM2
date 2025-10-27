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
            .Include(a => a.Departamento)
            .AsQueryable();

        // B�squeda
        if (!string.IsNullOrWhiteSpace(queryParams.Search))
        {
            query = query.Where(a =>
                a.Nombre.Contains(queryParams.Search) ||
                (a.Descripcion != null && a.Descripcion.Contains(queryParams.Search)));
        }

        // Ordenamiento
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
                FechaInicio = a.FechaInicio,
                Aprobada = a.Aprobada,
                DepartamentoNombre = a.Departamento != null ? a.Departamento.Nombre : null
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
            .Include(a => a.Departamento)
            .Include(a => a.Localizacion)
            .Include(a => a.EmpTransporte)
            .Include(a => a.ProfesoresResponsables)
                .ThenInclude(pr => pr.Profesor)
            .FirstOrDefaultAsync(a => a.Id == id);

        if (actividad == null)
            return null;

        return MapToDto(actividad);
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
            DepartamentoId = dto.DepartamentoId,
            LocalizacionId = dto.LocalizacionId,
            EmpTransporteId = dto.EmpTransporteId
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
        if (dto.Aprobada.HasValue) actividad.Aprobada = dto.Aprobada.Value;
        if (dto.DepartamentoId.HasValue) actividad.DepartamentoId = dto.DepartamentoId;
        if (dto.LocalizacionId.HasValue) actividad.LocalizacionId = dto.LocalizacionId;
        if (dto.EmpTransporteId.HasValue) actividad.EmpTransporteId = dto.EmpTransporteId;
        
        // Actualizar solicitante (profesor responsable)
        if (dto.SolicitanteId.HasValue)
        {
            // Eliminar responsable actual
            var responsableActual = actividad.ProfesoresResponsables.FirstOrDefault();
            if (responsableActual != null)
            {
                _context.ProfResponsables.Remove(responsableActual);
            }
            
            // Añadir nuevo responsable
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

        // Recargar la actividad con todas las relaciones para MapToDto
        var actividadActualizada = await _context.Actividades
            .Include(a => a.Departamento)
            .Include(a => a.Localizacion)
            .Include(a => a.EmpTransporte)
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
        // Obtener el primer profesor responsable como solicitante
        var primerResponsable = actividad.ProfesoresResponsables.FirstOrDefault();
        ProfesorSimpleDto? solicitante = null;
        
        if (primerResponsable?.Profesor != null)
        {
            solicitante = new ProfesorSimpleDto
            {
                Id = primerResponsable.Profesor.Uuid.GetHashCode(), // Convertir Guid a int para el frontend
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
            FolletoUrl = actividad.FolletoUrl,
            Aprobada = actividad.Aprobada,
            DepartamentoId = actividad.DepartamentoId,
            DepartamentoNombre = actividad.Departamento?.Nombre,
            LocalizacionId = actividad.LocalizacionId,
            LocalizacionNombre = actividad.Localizacion?.Nombre,
            EmpTransporteId = actividad.EmpTransporteId,
            EmpTransporteNombre = actividad.EmpTransporte?.Nombre,
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
        // Verificar que la actividad existe
        var actividad = await _context.Actividades.FindAsync(actividadId);
        if (actividad == null)
            return false;

        // Eliminar los participantes actuales
        var participantesActuales = await _context.Set<ProfParticipante>()
            .Where(pp => pp.ActividadId == actividadId)
            .ToListAsync();
        
        _context.Set<ProfParticipante>().RemoveRange(participantesActuales);

        // Agregar los nuevos participantes
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
            .Where(gp => gp.ActividadId == actividadId)
            .Select(gp => new GrupoParticipanteDto
            {
                GrupoId = gp.GrupoId,
                GrupoNombre = gp.Grupo.Nombre,
                NumeroAlumnos = gp.Grupo.NumeroAlumnos,
                NumeroParticipantes = gp.NumeroParticipantes
            })
            .ToListAsync();

        return grupos;
    }

    public async Task<bool> UpdateGruposParticipantesAsync(int actividadId, List<GrupoParticipanteUpdateDto> grupos)
    {
        // Verificar que la actividad existe
        var actividad = await _context.Actividades.FindAsync(actividadId);
        if (actividad == null)
            return false;

        // Eliminar los grupos participantes actuales
        var gruposActuales = await _context.Set<GrupoPartic>()
            .Where(gp => gp.ActividadId == actividadId)
            .ToListAsync();
        
        _context.Set<GrupoPartic>().RemoveRange(gruposActuales);

        // Agregar los nuevos grupos participantes
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
}
