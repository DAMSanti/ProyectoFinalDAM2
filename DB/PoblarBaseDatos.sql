-- ========================================
-- Script para poblar la base de datos ACEXAPI con datos de ejemplo
-- CORREGIDO PARA COINCIDIR CON LA ESTRUCTURA REAL DE LA BD
-- ========================================
USE ACEXAPI;
GO

-- Limpiar datos existentes (opcional - comentar si no quieres borrar datos existentes)
-- DELETE FROM ProfResponsables;
-- DELETE FROM ProfParticipantes;
-- DELETE FROM GrupoPartics;
-- DELETE FROM Contratos;
-- DELETE FROM Fotos;
-- DELETE FROM Actividades;
-- DELETE FROM Profesores;
-- DELETE FROM Grupos;
-- DELETE FROM Cursos;
-- DELETE FROM Departamentos;
-- DELETE FROM Localizaciones;
-- DELETE FROM EmpTransportes;
-- GO

-- ========================================
-- 1. DEPARTAMENTOS
-- ========================================
IF NOT EXISTS (SELECT 1 FROM Departamentos WHERE Nombre = 'Informática')
BEGIN
    INSERT INTO Departamentos (Nombre, Descripcion)
    VALUES 
        ('Informática', 'Departamento de Informática y Comunicaciones'),
        ('Matemáticas', 'Departamento de Matemáticas'),
        ('Lengua y Literatura', 'Departamento de Lengua Castellana y Literatura'),
        ('Ciencias Naturales', 'Departamento de Biología y Geología'),
        ('Educación Física', 'Departamento de Educación Física y Deportes'),
        ('Idiomas', 'Departamento de Inglés y Francés');
END
GO

-- ========================================
-- 2. CURSOS
-- ========================================
IF NOT EXISTS (SELECT 1 FROM Cursos WHERE Nombre = '1º ESO')
BEGIN
    INSERT INTO Cursos (Nombre, Nivel, Activo)
    VALUES 
        ('1º ESO', 'ESO', 1),
        ('2º ESO', 'ESO', 1),
        ('3º ESO', 'ESO', 1),
        ('4º ESO', 'ESO', 1),
        ('1º ASIR', 'FP', 1),
        ('2º ASIR', 'FP', 1),
        ('1º DAW', 'FP', 1),
        ('2º DAW', 'FP', 1);
END
GO

-- ========================================
-- 3. GRUPOS
-- ========================================
DECLARE @Curso1ESO INT = (SELECT Id FROM Cursos WHERE Nombre = '1º ESO');
DECLARE @Curso2ESO INT = (SELECT Id FROM Cursos WHERE Nombre = '2º ESO');
DECLARE @Curso1ASIR INT = (SELECT Id FROM Cursos WHERE Nombre = '1º ASIR');
DECLARE @Curso2ASIR INT = (SELECT Id FROM Cursos WHERE Nombre = '2º ASIR');
DECLARE @Curso1DAW INT = (SELECT Id FROM Cursos WHERE Nombre = '1º DAW');
DECLARE @Curso2DAW INT = (SELECT Id FROM Cursos WHERE Nombre = '2º DAW');

IF NOT EXISTS (SELECT 1 FROM Grupos WHERE Nombre = '1º ESO A')
BEGIN
    INSERT INTO Grupos (CursoId, Nombre, NumeroAlumnos)
    VALUES 
        (@Curso1ESO, '1º ESO A', 25),
        (@Curso1ESO, '1º ESO B', 24),
        (@Curso2ESO, '2º ESO A', 28),
        (@Curso2ESO, '2º ESO B', 26),
        (@Curso1ASIR, '1º ASIR', 20),
        (@Curso2ASIR, '2º ASIR', 18),
        (@Curso1DAW, '1º DAW', 22),
        (@Curso2DAW, '2º DAW', 19);
END
GO

-- ========================================
-- 4. PROFESORES
-- ========================================
DECLARE @DeptInfo INT = (SELECT Id FROM Departamentos WHERE Nombre = 'Informática');
DECLARE @DeptMate INT = (SELECT Id FROM Departamentos WHERE Nombre = 'Matemáticas');
DECLARE @DeptLengua INT = (SELECT Id FROM Departamentos WHERE Nombre = 'Lengua y Literatura');
DECLARE @DeptCiencias INT = (SELECT Id FROM Departamentos WHERE Nombre = 'Ciencias Naturales');
DECLARE @DeptEF INT = (SELECT Id FROM Departamentos WHERE Nombre = 'Educación Física');

IF NOT EXISTS (SELECT 1 FROM Profesores WHERE Email = 'maria.garcia@ies.edu')
BEGIN
    INSERT INTO Profesores (Uuid, Nombre, Apellidos, Email, Telefono, DepartamentoId, Especialidad, Activo)
    VALUES 
        (NEWID(), 'María', 'García López', 'maria.garcia@ies.edu', '600111222', @DeptInfo, 'Sistemas Informáticos', 1),
        (NEWID(), 'Juan', 'Martínez Ruiz', 'juan.martinez@ies.edu', '600222333', @DeptInfo, 'Desarrollo de Aplicaciones', 1),
        (NEWID(), 'Ana', 'Fernández Sanz', 'ana.fernandez@ies.edu', '600333444', @DeptMate, 'Matemáticas', 1),
        (NEWID(), 'Carlos', 'López Pérez', 'carlos.lopez@ies.edu', '600444555', @DeptLengua, 'Lengua Castellana', 1),
        (NEWID(), 'Laura', 'Sánchez Gómez', 'laura.sanchez@ies.edu', '600555666', @DeptCiencias, 'Biología', 1),
        (NEWID(), 'Roberto', 'Díaz Martín', 'roberto.diaz@ies.edu', '600666777', @DeptEF, 'Educación Física', 1);
END
GO

-- ========================================
-- 5. LOCALIZACIONES
-- ========================================
IF NOT EXISTS (SELECT 1 FROM Localizaciones WHERE Nombre = 'Museo de Ciencias')
BEGIN
    INSERT INTO Localizaciones (Nombre, Direccion, Ciudad, Provincia, CodigoPostal, Pais, Latitud, Longitud, Descripcion)
    VALUES 
        ('Museo de Ciencias', 'Calle Museo 1', 'Santander', 'Cantabria', '39001', 'España', 43.4623, -3.8099, 'Museo interactivo de ciencias'),
        ('Parque de Cabárceno', 'Carretera Nacional 634', 'Cabárceno', 'Cantabria', '39693', 'España', 43.3536, -3.8356, 'Parque de naturaleza y fauna'),
        ('Playa del Sardinero', 'Paseo Pérez Galdós', 'Santander', 'Cantabria', '39005', 'España', 43.4732, -3.7872, 'Playa urbana de Santander'),
        ('Centro Cultural', 'Plaza Mayor 5', 'Torrelavega', 'Cantabria', '39300', 'España', 43.3497, -4.0503, 'Centro cultural municipal'),
        ('Polideportivo Municipal', 'Avenida Deporte 10', 'Santander', 'Cantabria', '39010', 'España', 43.4531, -3.8041, 'Instalaciones deportivas');
END
GO

-- ========================================
-- 6. EMPRESAS DE TRANSPORTE
-- ========================================
IF NOT EXISTS (SELECT 1 FROM EmpTransportes WHERE Nombre = 'Autocares del Norte')
BEGIN
    INSERT INTO EmpTransportes (Nombre, Direccion, Telefono, Email, Cif, ContactoPrincipal, Web, Activa)
    VALUES 
        ('Autocares del Norte', 'Polígono Industrial 1', '942123456', 'info@autocaresnorte.com', 'B12345678', 'Pedro Ruiz', 'www.autocaresnorte.com', 1),
        ('Transportes Cántabros', 'Calle Transporte 20', '942234567', 'contacto@transcantabros.com', 'B23456789', 'Ana Martín', 'www.transcantabros.com', 1),
        ('Viajes Escolares S.L.', 'Avenida Educación 15', '942345678', 'escolar@viajesescol.com', 'B34567890', 'Luis Fernández', 'www.viajesescol.com', 1);
END
GO

-- ========================================
-- 7. ACTIVIDADES
-- ========================================
DECLARE @ProfesorInfo1 UNIQUEIDENTIFIER = (SELECT TOP 1 Uuid FROM Profesores WHERE Email = 'maria.garcia@ies.edu');
DECLARE @ProfesorInfo2 UNIQUEIDENTIFIER = (SELECT TOP 1 Uuid FROM Profesores WHERE Email = 'juan.martinez@ies.edu');
DECLARE @ProfesorMate UNIQUEIDENTIFIER = (SELECT TOP 1 Uuid FROM Profesores WHERE Email = 'ana.fernandez@ies.edu');
DECLARE @ProfesorCiencias UNIQUEIDENTIFIER = (SELECT TOP 1 Uuid FROM Profesores WHERE Email = 'laura.sanchez@ies.edu');
DECLARE @ProfesorEF UNIQUEIDENTIFIER = (SELECT TOP 1 Uuid FROM Profesores WHERE Email = 'roberto.diaz@ies.edu');

DECLARE @LocMuseo INT = (SELECT Id FROM Localizaciones WHERE Nombre = 'Museo de Ciencias');
DECLARE @LocCabarceno INT = (SELECT Id FROM Localizaciones WHERE Nombre = 'Parque de Cabárceno');
DECLARE @LocPlaya INT = (SELECT Id FROM Localizaciones WHERE Nombre = 'Playa del Sardinero');
DECLARE @LocCultural INT = (SELECT Id FROM Localizaciones WHERE Nombre = 'Centro Cultural');
DECLARE @LocPolideportivo INT = (SELECT Id FROM Localizaciones WHERE Nombre = 'Polideportivo Municipal');

IF NOT EXISTS (SELECT 1 FROM Actividades WHERE Nombre = 'Excursión al Museo de Ciencias')
BEGIN
    INSERT INTO Actividades (
        Nombre, Descripcion, Tipo, FechaInicio, FechaFin, HoraInicio, HoraFin,
        LocalizacionId, PresupuestoEstimado, CostoReal, NumAlumnosEstimado,
        Aprobada, Realizada, FechaCreacion, SolicitanteId
    )
    VALUES 
        -- Actividades futuras aprobadas
        (
            'Excursión al Museo de Ciencias',
            'Visita educativa al Museo de Ciencias con actividades interactivas para estudiantes de ESO.',
            'Extraescolar',
            DATEADD(day, 7, GETDATE()),
            DATEADD(day, 7, GETDATE()),
            '09:00:00',
            '14:00:00',
            @LocMuseo,
            500.00,
            NULL,
            50,
            1,
            0,
            GETDATE(),
            @ProfesorCiencias
        ),
        (
            'Hackathon de Programación',
            'Competencia de desarrollo de software para estudiantes de FP. Los equipos tendrán 8 horas para crear una aplicación funcional.',
            'Complementaria',
            DATEADD(day, 14, GETDATE()),
            DATEADD(day, 14, GETDATE()),
            '09:00:00',
            '17:00:00',
            @LocCultural,
            800.00,
            NULL,
            40,
            1,
            0,
            GETDATE(),
            @ProfesorInfo1
        ),
        (
            'Visita al Parque de Cabárceno',
            'Excursión educativa para conocer la biodiversidad y los ecosistemas. Incluye transporte y entrada.',
            'Extraescolar',
            DATEADD(day, 21, GETDATE()),
            DATEADD(day, 21, GETDATE()),
            '08:30:00',
            '17:00:00',
            @LocCabarceno,
            1200.00,
            NULL,
            75,
            1,
            0,
            GETDATE(),
            @ProfesorCiencias
        ),
        (
            'Torneo Deportivo Interescolar',
            'Competencia deportiva con varias disciplinas: fútbol, baloncesto y voleibol.',
            'Complementaria',
            DATEADD(day, 30, GETDATE()),
            DATEADD(day, 30, GETDATE()),
            '10:00:00',
            '18:00:00',
            @LocPolideportivo,
            600.00,
            NULL,
            100,
            1,
            0,
            GETDATE(),
            @ProfesorEF
        ),
        (
            'Taller de Desarrollo Web',
            'Taller práctico sobre las últimas tecnologías en desarrollo web: React, Angular y Vue.',
            'Complementaria',
            DATEADD(day, 45, GETDATE()),
            DATEADD(day, 47, GETDATE()),
            '15:00:00',
            '18:00:00',
            @LocCultural,
            350.00,
            NULL,
            30,
            1,
            0,
            GETDATE(),
            @ProfesorInfo2
        ),
        
        -- Actividades pasadas realizadas
        (
            'Jornada de Reciclaje y Sostenibilidad',
            'Taller de sensibilización sobre el reciclaje y cuidado ambiental.',
            'Complementaria',
            DATEADD(day, -60, GETDATE()),
            DATEADD(day, -60, GETDATE()),
            '10:00:00',
            '12:00:00',
            NULL,
            150.00,
            140.00,
            60,
            1,
            1,
            DATEADD(day, -80, GETDATE()),
            @ProfesorCiencias
        ),
        (
            'Concurso de Matemáticas',
            'Competición interna para resolver retos matemáticos divertidos.',
            'Complementaria',
            DATEADD(day, -45, GETDATE()),
            DATEADD(day, -45, GETDATE()),
            '10:00:00',
            '13:00:00',
            NULL,
            100.00,
            95.00,
            40,
            1,
            1,
            DATEADD(day, -60, GETDATE()),
            @ProfesorMate
        ),
        (
            'Excursión a la Playa del Sardinero',
            'Día de convivencia en la playa con actividades deportivas y recreativas.',
            'Extraescolar',
            DATEADD(day, -30, GETDATE()),
            DATEADD(day, -30, GETDATE()),
            '10:00:00',
            '16:00:00',
            @LocPlaya,
            400.00,
            380.00,
            55,
            1,
            1,
            DATEADD(day, -50, GETDATE()),
            @ProfesorEF
        ),
        
        -- Actividades pendientes de aprobación
        (
            'Conferencia sobre Inteligencia Artificial',
            'Charla sobre las últimas tendencias en IA y machine learning impartida por expertos del sector.',
            'Complementaria',
            DATEADD(day, 60, GETDATE()),
            DATEADD(day, 60, GETDATE()),
            '11:00:00',
            '13:30:00',
            @LocCultural,
            450.00,
            NULL,
            50,
            0,
            0,
            GETDATE(),
            @ProfesorInfo1
        ),
        (
            'Campamento de Verano STEM',
            'Campamento educativo de 5 días con actividades de ciencia, tecnología, ingeniería y matemáticas.',
            'Extraescolar',
            DATEADD(day, 90, GETDATE()),
            DATEADD(day, 95, GETDATE()),
            '09:00:00',
            '18:00:00',
            NULL,
            3500.00,
            NULL,
            40,
            0,
            0,
            GETDATE(),
            @ProfesorInfo2
        );
END
GO

-- ========================================
-- 8. GRUPOS PARTICIPANTES
-- ========================================
DECLARE @Act1 INT = (SELECT Id FROM Actividades WHERE Nombre = 'Excursión al Museo de Ciencias');
DECLARE @Act2 INT = (SELECT Id FROM Actividades WHERE Nombre = 'Hackathon de Programación');
DECLARE @Act3 INT = (SELECT Id FROM Actividades WHERE Nombre = 'Visita al Parque de Cabárceno');

DECLARE @Grupo1ESO_A INT = (SELECT Id FROM Grupos WHERE Nombre = '1º ESO A');
DECLARE @Grupo2ESO_A INT = (SELECT Id FROM Grupos WHERE Nombre = '2º ESO A');
DECLARE @Grupo1ASIR INT = (SELECT Id FROM Grupos WHERE Nombre = '1º ASIR');
DECLARE @Grupo2ASIR INT = (SELECT Id FROM Grupos WHERE Nombre = '2º ASIR');
DECLARE @Grupo1DAW INT = (SELECT Id FROM Grupos WHERE Nombre = '1º DAW');
DECLARE @Grupo2DAW INT = (SELECT Id FROM Grupos WHERE Nombre = '2º DAW');

IF @Act1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM GrupoPartics WHERE ActividadId = @Act1)
BEGIN
    INSERT INTO GrupoPartics (ActividadId, GrupoId, NumAlumnos)
    VALUES 
        (@Act1, @Grupo1ESO_A, 25),
        (@Act1, @Grupo2ESO_A, 25);
END

IF @Act2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM GrupoPartics WHERE ActividadId = @Act2)
BEGIN
    INSERT INTO GrupoPartics (ActividadId, GrupoId, NumAlumnos)
    VALUES 
        (@Act2, @Grupo1ASIR, 20),
        (@Act2, @Grupo2DAW, 20);
END

IF @Act3 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM GrupoPartics WHERE ActividadId = @Act3)
BEGIN
    INSERT INTO GrupoPartics (ActividadId, GrupoId, NumAlumnos)
    VALUES 
        (@Act3, @Grupo1ESO_A, 25),
        (@Act3, @Grupo2ESO_A, 28),
        (@Act3, @Grupo2ASIR, 22);
END
GO

-- ========================================
-- 9. PROFESORES RESPONSABLES Y PARTICIPANTES
-- ========================================
DECLARE @Act1_R INT = (SELECT Id FROM Actividades WHERE Nombre = 'Excursión al Museo de Ciencias');
DECLARE @Act2_R INT = (SELECT Id FROM Actividades WHERE Nombre = 'Hackathon de Programación');
DECLARE @Act3_R INT = (SELECT Id FROM Actividades WHERE Nombre = 'Visita al Parque de Cabárceno');

DECLARE @Prof1 UNIQUEIDENTIFIER = (SELECT TOP 1 Uuid FROM Profesores WHERE Email = 'maria.garcia@ies.edu');
DECLARE @Prof2 UNIQUEIDENTIFIER = (SELECT TOP 1 Uuid FROM Profesores WHERE Email = 'juan.martinez@ies.edu');
DECLARE @Prof3 UNIQUEIDENTIFIER = (SELECT TOP 1 Uuid FROM Profesores WHERE Email = 'ana.fernandez@ies.edu');
DECLARE @Prof4 UNIQUEIDENTIFIER = (SELECT TOP 1 Uuid FROM Profesores WHERE Email = 'laura.sanchez@ies.edu');

IF @Act1_R IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ProfResponsables WHERE ActividadId = @Act1_R)
BEGIN
    INSERT INTO ProfResponsables (ActividadId, ProfesorId, EsResponsablePrincipal)
    VALUES (@Act1_R, @Prof4, 1);
    
    INSERT INTO ProfParticipantes (ActividadId, ProfesorId, Rol)
    VALUES 
        (@Act1_R, @Prof4, 'Coordinador'),
        (@Act1_R, @Prof3, 'Acompañante');
END

IF @Act2_R IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ProfResponsables WHERE ActividadId = @Act2_R)
BEGIN
    INSERT INTO ProfResponsables (ActividadId, ProfesorId, EsResponsablePrincipal)
    VALUES (@Act2_R, @Prof1, 1);
    
    INSERT INTO ProfParticipantes (ActividadId, ProfesorId, Rol)
    VALUES 
        (@Act2_R, @Prof1, 'Organizador'),
        (@Act2_R, @Prof2, 'Jurado');
END

IF @Act3_R IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ProfResponsables WHERE ActividadId = @Act3_R)
BEGIN
    INSERT INTO ProfResponsables (ActividadId, ProfesorId, EsResponsablePrincipal)
    VALUES (@Act3_R, @Prof4, 1);
    
    INSERT INTO ProfParticipantes (ActividadId, ProfesorId, Rol)
    VALUES 
        (@Act3_R, @Prof4, 'Guía'),
        (@Act3_R, @Prof1, 'Acompañante'),
        (@Act3_R, @Prof3, 'Acompañante');
END
GO

-- ========================================
-- 10. CONTRATOS DE TRANSPORTE
-- ========================================
DECLARE @ActTransp INT = (SELECT Id FROM Actividades WHERE Nombre = 'Visita al Parque de Cabárceno');
DECLARE @Empresa1 INT = (SELECT Id FROM EmpTransportes WHERE Nombre = 'Autocares del Norte');
DECLARE @Empresa2 INT = (SELECT Id FROM EmpTransportes WHERE Nombre = 'Transportes Cántabros');

IF @ActTransp IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Contratos WHERE ActividadId = @ActTransp)
BEGIN
    INSERT INTO Contratos (ActividadId, EmpTransporteId, Contratada, Importe, FechaContratacion)
    VALUES 
        (@ActTransp, @Empresa1, 1, 650.00, GETDATE()),
        (@ActTransp, @Empresa2, 0, 720.00, NULL);
END
GO

-- ========================================
-- VERIFICACIÓN FINAL
-- ========================================
PRINT '========================================';
PRINT 'RESUMEN DE DATOS INSERTADOS';
PRINT '========================================';

SELECT 'Departamentos' AS Tabla, COUNT(*) AS Total FROM Departamentos
UNION ALL
SELECT 'Cursos', COUNT(*) FROM Cursos
UNION ALL
SELECT 'Grupos', COUNT(*) FROM Grupos
UNION ALL
SELECT 'Profesores', COUNT(*) FROM Profesores
UNION ALL
SELECT 'Localizaciones', COUNT(*) FROM Localizaciones
UNION ALL
SELECT 'Empresas Transporte', COUNT(*) FROM EmpTransportes
UNION ALL
SELECT 'Actividades', COUNT(*) FROM Actividades
UNION ALL
SELECT 'Grupos Participantes', COUNT(*) FROM GrupoPartics
UNION ALL
SELECT 'Profesores Responsables', COUNT(*) FROM ProfResponsables
UNION ALL
SELECT 'Profesores Participantes', COUNT(*) FROM ProfParticipantes
UNION ALL
SELECT 'Contratos', COUNT(*) FROM Contratos;

PRINT '';
PRINT 'Base de datos poblada correctamente!';
PRINT '';

-- Ver actividades futuras (las que aparecerán en el home)
SELECT 
    Id,
    Nombre,
    Tipo,
    FechaInicio,
    FechaFin,
    PresupuestoEstimado,
    NumAlumnosEstimado,
    CASE WHEN Aprobada = 1 THEN 'Sí' ELSE 'No' END AS Aprobada,
    CASE WHEN Realizada = 1 THEN 'Sí' ELSE 'No' END AS Realizada
FROM Actividades
WHERE FechaInicio > GETDATE()
ORDER BY FechaInicio;
GO
