using Microsoft.EntityFrameworkCore;
using ACEXAPI.Models;

namespace ACEXAPI.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<Actividad> Actividades { get; set; }
    public DbSet<Alojamiento> Alojamientos { get; set; }
    public DbSet<Departamento> Departamentos { get; set; }
    public DbSet<Profesor> Profesores { get; set; }
    public DbSet<Curso> Cursos { get; set; }
    public DbSet<Grupo> Grupos { get; set; }
    public DbSet<Localizacion> Localizaciones { get; set; }
    public DbSet<EmpTransporte> EmpTransportes { get; set; }
    public DbSet<GrupoPartic> GrupoPartics { get; set; }
    public DbSet<ProfParticipante> ProfParticipantes { get; set; }
    public DbSet<ProfResponsable> ProfResponsables { get; set; }
    public DbSet<Foto> Fotos { get; set; }
    public DbSet<Contrato> Contratos { get; set; }
    public DbSet<Usuario> Usuarios { get; set; }
    public DbSet<ActividadLocalizacion> ActividadLocalizaciones { get; set; }
    public DbSet<GastoPersonalizado> GastosPersonalizados { get; set; }
    public DbSet<FcmToken> FcmTokens { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configurar precisión de decimales para Actividad
        modelBuilder.Entity<Actividad>()
            .Property(a => a.PresupuestoEstimado)
            .HasPrecision(18, 2);

        modelBuilder.Entity<Actividad>()
            .Property(a => a.CostoReal)
            .HasPrecision(18, 2);

        modelBuilder.Entity<Actividad>()
            .Property(a => a.PrecioTransporte)
            .HasPrecision(18, 2);

        modelBuilder.Entity<Actividad>()
            .Property(a => a.PrecioAlojamiento)
            .HasPrecision(18, 2);

        // Configurar precisión de decimales para GastoPersonalizado
        modelBuilder.Entity<GastoPersonalizado>()
            .Property(g => g.Cantidad)
            .HasPrecision(18, 2);

        // Configurar relación de GastoPersonalizado con Actividad
        modelBuilder.Entity<GastoPersonalizado>()
            .HasOne(g => g.Actividad)
            .WithMany()
            .HasForeignKey(g => g.ActividadId)
            .OnDelete(DeleteBehavior.Cascade);

        // Configurar índices únicos
        modelBuilder.Entity<Profesor>()
            .HasIndex(p => p.Dni)
            .IsUnique();

        modelBuilder.Entity<Profesor>()
            .HasIndex(p => p.Correo)
            .IsUnique();

        modelBuilder.Entity<Usuario>()
            .HasIndex(u => u.NombreUsuario)
            .IsUnique();

        // Configurar relaciones
        modelBuilder.Entity<Actividad>()
            .Ignore("DepartamentoId"); // Ignorar esta columna que existe en BD pero no en el modelo

        modelBuilder.Entity<Actividad>()
            .HasOne(a => a.Alojamiento)
            .WithMany(al => al.Actividades)
            .HasForeignKey(a => a.AlojamientoId)
            .OnDelete(DeleteBehavior.SetNull);

        // Relación Actividad -> Responsable (Profesor) eliminada de aquí
        // ya que se maneja en el modelo Actividad

        modelBuilder.Entity<Actividad>()
            .HasOne(a => a.Localizacion)
            .WithMany(l => l.Actividades)
            .HasForeignKey(a => a.LocalizacionId)
            .OnDelete(DeleteBehavior.SetNull);

        modelBuilder.Entity<Actividad>()
            .HasOne(a => a.EmpTransporte)
            .WithMany(e => e.Actividades)
            .HasForeignKey(a => a.EmpTransporteId)
            .OnDelete(DeleteBehavior.SetNull);

        modelBuilder.Entity<Profesor>()
            .HasOne(p => p.Departamento)
            .WithMany(d => d.Profesores)
            .HasForeignKey(p => p.DepartamentoId)
            .OnDelete(DeleteBehavior.SetNull);

        modelBuilder.Entity<Grupo>()
            .HasOne(g => g.Curso)
            .WithMany(c => c.Grupos)
            .HasForeignKey(g => g.CursoId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<GrupoPartic>()
            .HasOne(gp => gp.Actividad)
            .WithMany(a => a.GruposParticipantes)
            .HasForeignKey(gp => gp.ActividadId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<GrupoPartic>()
            .HasOne(gp => gp.Grupo)
            .WithMany(g => g.ActividadesParticipantes)
            .HasForeignKey(gp => gp.GrupoId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<ProfParticipante>()
            .HasOne(pp => pp.Actividad)
            .WithMany(a => a.ProfesoresParticipantes)
            .HasForeignKey(pp => pp.ActividadId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<ProfParticipante>()
            .HasOne(pp => pp.Profesor)
            .WithMany(p => p.ActividadesParticipante)
            .HasForeignKey(pp => pp.ProfesorUuid)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<ProfResponsable>()
            .HasOne(pr => pr.Actividad)
            .WithMany(a => a.ProfesoresResponsables)
            .HasForeignKey(pr => pr.ActividadId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<ProfResponsable>()
            .HasOne(pr => pr.Profesor)
            .WithMany(p => p.ActividadesResponsable)
            .HasForeignKey(pr => pr.ProfesorUuid)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Foto>()
            .HasOne(f => f.Actividad)
            .WithMany(a => a.Fotos)
            .HasForeignKey(f => f.ActividadId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Contrato>()
            .HasOne(c => c.Actividad)
            .WithMany(a => a.Contratos)
            .HasForeignKey(c => c.ActividadId)
            .OnDelete(DeleteBehavior.Cascade);

        // Configurar relación muchos-a-muchos entre Actividades y Localizaciones
        modelBuilder.Entity<ActividadLocalizacion>()
            .HasOne(al => al.Actividad)
            .WithMany(a => a.ActividadLocalizaciones)
            .HasForeignKey(al => al.ActividadId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<ActividadLocalizacion>()
            .HasOne(al => al.Localizacion)
            .WithMany(l => l.ActividadLocalizaciones)
            .HasForeignKey(al => al.LocalizacionId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<ActividadLocalizacion>()
            .HasIndex(al => new { al.ActividadId, al.LocalizacionId })
            .IsUnique();

        // Seed data inicial
        SeedData(modelBuilder);
    }

    private void SeedData(ModelBuilder modelBuilder)
    {
        // Datos iniciales de ejemplo
        modelBuilder.Entity<Departamento>().HasData(
            new Departamento { Id = 1, Nombre = "Inform�tica", Descripcion = "Departamento de Inform�tica" },
            new Departamento { Id = 2, Nombre = "Matem�ticas", Descripcion = "Departamento de Matem�ticas" },
            new Departamento { Id = 3, Nombre = "Lengua", Descripcion = "Departamento de Lengua y Literatura" }
        );

        modelBuilder.Entity<Curso>().HasData(
            new Curso { Id = 1, Nombre = "1� ESO", Nivel = "ESO", Activo = true },
            new Curso { Id = 2, Nombre = "2� ESO", Nivel = "ESO", Activo = true },
            new Curso { Id = 3, Nombre = "1� Bach", Nivel = "BACH", Activo = true }
        );
    }
}
