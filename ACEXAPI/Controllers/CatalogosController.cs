using ACEXAPI.Data;
using ACEXAPI.DTOs;
using ACEXAPI.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ACEXAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class DepartamentoController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public DepartamentoController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<List<DepartamentoDto>>> GetAll()
    {
        var departamentos = await _context.Departamentos
            .Select(d => new DepartamentoDto
            {
                Id = d.Id,
                Codigo = d.Codigo,
                Nombre = d.Nombre,
                Descripcion = d.Descripcion
            })
            .ToListAsync();

        return Ok(departamentos);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<DepartamentoDto>> GetById(int id)
    {
        var departamento = await _context.Departamentos.FindAsync(id);
        if (departamento == null)
            return NotFound();

        return Ok(new DepartamentoDto
        {
            Id = departamento.Id,
            Codigo = departamento.Codigo,
            Nombre = departamento.Nombre,
            Descripcion = departamento.Descripcion
        });
    }

    [HttpPost]
    [Authorize(Roles = "Administrador")]
    public async Task<ActionResult<DepartamentoDto>> Create(DepartamentoDto dto)
    {
        var departamento = new Departamento
        {
            Codigo = dto.Codigo,
            Nombre = dto.Nombre,
            Descripcion = dto.Descripcion
        };

        _context.Departamentos.Add(departamento);
        await _context.SaveChangesAsync();

        dto.Id = departamento.Id;
        return CreatedAtAction(nameof(GetById), new { id = departamento.Id }, dto);
    }

    [HttpPut("{id}")]
    [Authorize(Roles = "Administrador")]
    public async Task<ActionResult<DepartamentoDto>> Update(int id, DepartamentoDto dto)
    {
        var departamento = await _context.Departamentos.FindAsync(id);
        if (departamento == null)
            return NotFound();

        departamento.Codigo = dto.Codigo;
        departamento.Nombre = dto.Nombre;
        departamento.Descripcion = dto.Descripcion;

        await _context.SaveChangesAsync();

        return Ok(dto);
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Administrador")]
    public async Task<IActionResult> Delete(int id)
    {
        var departamento = await _context.Departamentos.FindAsync(id);
        if (departamento == null)
            return NotFound();

        _context.Departamentos.Remove(departamento);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class CursoController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public CursoController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<List<CursoDto>>> GetAll()
    {
        var cursos = await _context.Cursos
            .Select(c => new CursoDto
            {
                Id = c.Id,
                Nombre = c.Nombre,
                Nivel = c.Nivel,
                Activo = c.Activo
            })
            .ToListAsync();

        return Ok(cursos);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<CursoDto>> GetById(int id)
    {
        var curso = await _context.Cursos.FindAsync(id);
        if (curso == null)
            return NotFound();

        return Ok(new CursoDto
        {
            Id = curso.Id,
            Nombre = curso.Nombre,
            Nivel = curso.Nivel,
            Activo = curso.Activo
        });
    }

    [HttpPost]
    [Authorize(Roles = "Administrador")]
    public async Task<ActionResult<CursoDto>> Create(CursoDto dto)
    {
        var curso = new Curso
        {
            Nombre = dto.Nombre,
            Nivel = dto.Nivel,
            Activo = dto.Activo
        };

        _context.Cursos.Add(curso);
        await _context.SaveChangesAsync();

        dto.Id = curso.Id;
        return CreatedAtAction(nameof(GetById), new { id = curso.Id }, dto);
    }

    [HttpPut("{id}")]
    [Authorize(Roles = "Administrador")]
    public async Task<ActionResult<CursoDto>> Update(int id, CursoDto dto)
    {
        var curso = await _context.Cursos.FindAsync(id);
        if (curso == null)
            return NotFound();

        curso.Nombre = dto.Nombre;
        curso.Nivel = dto.Nivel;
        curso.Activo = dto.Activo;

        await _context.SaveChangesAsync();

        return Ok(dto);
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Administrador")]
    public async Task<IActionResult> Delete(int id)
    {
        var curso = await _context.Cursos.FindAsync(id);
        if (curso == null)
            return NotFound();

        _context.Cursos.Remove(curso);
        await _context.SaveChangesAsync();

        return NoContent();
    }
    
    // Obtener grupos de un curso específico
    [HttpGet("{id}/grupos")]
    public async Task<ActionResult<List<GrupoDto>>> GetGruposByCurso(int id)
    {
        var grupos = await _context.Grupos
            .Include(g => g.Curso)
            .Where(g => g.CursoId == id)
            .Select(g => new GrupoDto
            {
                Id = g.Id,
                Nombre = g.Nombre,
                NumeroAlumnos = g.NumeroAlumnos,
                CursoId = g.CursoId,
                CursoNombre = g.Curso.Nombre
            })
            .ToListAsync();

        return Ok(grupos);
    }
}

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class GrupoController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public GrupoController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<List<GrupoDto>>> GetAll()
    {
        var grupos = await _context.Grupos
            .Include(g => g.Curso)
            .Select(g => new GrupoDto
            {
                Id = g.Id,
                Nombre = g.Nombre,
                NumeroAlumnos = g.NumeroAlumnos,
                CursoId = g.CursoId,
                CursoNombre = g.Curso.Nombre
            })
            .ToListAsync();

        return Ok(grupos);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<GrupoDto>> GetById(int id)
    {
        var grupo = await _context.Grupos
            .Include(g => g.Curso)
            .FirstOrDefaultAsync(g => g.Id == id);
            
        if (grupo == null)
            return NotFound();

        return Ok(new GrupoDto
        {
            Id = grupo.Id,
            Nombre = grupo.Nombre,
            NumeroAlumnos = grupo.NumeroAlumnos,
            CursoId = grupo.CursoId,
            CursoNombre = grupo.Curso.Nombre
        });
    }

    [HttpPost]
    [Authorize(Roles = "Administrador")]
    public async Task<ActionResult<GrupoDto>> Create(GrupoDto dto)
    {
        var grupo = new Grupo
        {
            Nombre = dto.Nombre,
            NumeroAlumnos = dto.NumeroAlumnos,
            CursoId = dto.CursoId
        };

        _context.Grupos.Add(grupo);
        await _context.SaveChangesAsync();

        dto.Id = grupo.Id;
        return CreatedAtAction(nameof(GetById), new { id = grupo.Id }, dto);
    }

    [HttpPut("{id}")]
    [Authorize(Roles = "Administrador")]
    public async Task<ActionResult<GrupoDto>> Update(int id, GrupoDto dto)
    {
        var grupo = await _context.Grupos.FindAsync(id);
        if (grupo == null)
            return NotFound();

        grupo.Nombre = dto.Nombre;
        grupo.NumeroAlumnos = dto.NumeroAlumnos;
        grupo.CursoId = dto.CursoId;

        await _context.SaveChangesAsync();

        return Ok(dto);
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Administrador")]
    public async Task<IActionResult> Delete(int id)
    {
        var grupo = await _context.Grupos.FindAsync(id);
        if (grupo == null)
            return NotFound();

        _context.Grupos.Remove(grupo);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class LocalizacionController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public LocalizacionController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<List<LocalizacionDto>>> GetAll()
    {
        var localizaciones = await _context.Localizaciones
            .Select(l => new LocalizacionDto
            {
                Id = l.Id,
                Nombre = l.Nombre,
                Direccion = l.Direccion,
                Ciudad = l.Ciudad,
                Provincia = l.Provincia,
                CodigoPostal = l.CodigoPostal,
                Latitud = l.Latitud,
                Longitud = l.Longitud,
                EsPrincipal = l.EsPrincipal,
                Icono = l.Icono
            })
            .ToListAsync();

        return Ok(localizaciones);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<LocalizacionDto>> GetById(int id)
    {
        var localizacion = await _context.Localizaciones.FindAsync(id);
        if (localizacion == null)
            return NotFound();

        return Ok(new LocalizacionDto
        {
            Id = localizacion.Id,
            Nombre = localizacion.Nombre,
            Direccion = localizacion.Direccion,
            Ciudad = localizacion.Ciudad,
            Provincia = localizacion.Provincia,
            CodigoPostal = localizacion.CodigoPostal,
            Latitud = localizacion.Latitud,
            Longitud = localizacion.Longitud,
            EsPrincipal = localizacion.EsPrincipal,
            Icono = localizacion.Icono
        });
    }

    [HttpPost]
    [Authorize(Roles = "Administrador,Coordinador")]
    public async Task<ActionResult<LocalizacionDto>> Create(LocalizacionDto dto)
    {
        var localizacion = new Localizacion
        {
            Nombre = dto.Nombre,
            Direccion = dto.Direccion,
            Ciudad = dto.Ciudad,
            Provincia = dto.Provincia,
            CodigoPostal = dto.CodigoPostal,
            Latitud = dto.Latitud,
            Longitud = dto.Longitud,
            EsPrincipal = dto.EsPrincipal,
            Icono = dto.Icono
        };

        _context.Localizaciones.Add(localizacion);
        await _context.SaveChangesAsync();

        dto.Id = localizacion.Id;
        return CreatedAtAction(nameof(GetById), new { id = localizacion.Id }, dto);
    }

    [HttpPut("{id}")]
    [Authorize(Roles = "Administrador,Coordinador")]
    public async Task<ActionResult<LocalizacionDto>> Update(int id, LocalizacionDto dto)
    {
        var localizacion = await _context.Localizaciones.FindAsync(id);
        if (localizacion == null)
            return NotFound();

        localizacion.Nombre = dto.Nombre;
        localizacion.Direccion = dto.Direccion;
        localizacion.Ciudad = dto.Ciudad;
        localizacion.Provincia = dto.Provincia;
        localizacion.CodigoPostal = dto.CodigoPostal;
        localizacion.Latitud = dto.Latitud;
        localizacion.Longitud = dto.Longitud;
        localizacion.EsPrincipal = dto.EsPrincipal;
        localizacion.Icono = dto.Icono;

        await _context.SaveChangesAsync();

        return Ok(dto);
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Administrador")]
    public async Task<IActionResult> Delete(int id)
    {
        var localizacion = await _context.Localizaciones.FindAsync(id);
        if (localizacion == null)
            return NotFound();

        _context.Localizaciones.Remove(localizacion);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class EmpTransporteController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public EmpTransporteController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<List<EmpTransporteDto>>> GetAll()
    {
        var empresas = await _context.EmpTransportes
            .Select(e => new EmpTransporteDto
            {
                Id = e.Id,
                Nombre = e.Nombre,
                Cif = e.Cif,
                Telefono = e.Telefono,
                Email = e.Email,
                Direccion = e.Direccion
            })
            .ToListAsync();

        return Ok(empresas);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<EmpTransporteDto>> GetById(int id)
    {
        var empresa = await _context.EmpTransportes.FindAsync(id);
        if (empresa == null)
            return NotFound();

        return Ok(new EmpTransporteDto
        {
            Id = empresa.Id,
            Nombre = empresa.Nombre,
            Cif = empresa.Cif,
            Telefono = empresa.Telefono,
            Email = empresa.Email,
            Direccion = empresa.Direccion
        });
    }

    [HttpPost]
    [Authorize(Roles = "Administrador")]
    public async Task<ActionResult<EmpTransporteDto>> Create(EmpTransporteDto dto)
    {
        var empresa = new EmpTransporte
        {
            Nombre = dto.Nombre,
            Cif = dto.Cif,
            Telefono = dto.Telefono,
            Email = dto.Email,
            Direccion = dto.Direccion
        };

        _context.EmpTransportes.Add(empresa);
        await _context.SaveChangesAsync();

        dto.Id = empresa.Id;
        return CreatedAtAction(nameof(GetById), new { id = empresa.Id }, dto);
    }

    [HttpPut("{id}")]
    [Authorize(Roles = "Administrador")]
    public async Task<ActionResult<EmpTransporteDto>> Update(int id, EmpTransporteDto dto)
    {
        var empresa = await _context.EmpTransportes.FindAsync(id);
        if (empresa == null)
            return NotFound();

        empresa.Nombre = dto.Nombre;
        empresa.Cif = dto.Cif;
        empresa.Telefono = dto.Telefono;
        empresa.Email = dto.Email;
        empresa.Direccion = dto.Direccion;

        await _context.SaveChangesAsync();

        return Ok(dto);
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Administrador")]
    public async Task<IActionResult> Delete(int id)
    {
        var empresa = await _context.EmpTransportes.FindAsync(id);
        if (empresa == null)
            return NotFound();

        _context.EmpTransportes.Remove(empresa);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
