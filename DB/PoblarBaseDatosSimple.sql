-- ========================================
-- Script SIMPLIFICADO para poblar ACEXAPI
-- Basado en la estructura REAL de la base de datos
-- ========================================
USE ACEXAPI;
GO

PRINT 'Iniciando población de base de datos...';

-- ====== 1. DEPARTAMENTOS ======
PRINT 'Insertando Departamentos...';
IF NOT EXISTS (SELECT 1 FROM Departamentos WHERE Nombre = 'Informática')
BEGIN
    INSERT INTO Departamentos (Nombre, Descripcion)
    VALUES 
        ('Informática', 'Departamento de Informática y Comunicaciones'),
        ('Matemáticas', 'Departamento de Matemáticas'),
        ('Ciencias Naturales', 'Departamento de Biología y Geología'),
        ('Educación Física', 'Departamento de Educación Física y Deportes');
    PRINT 'Departamentos insertados: 4';
END
ELSE
    PRINT 'Departamentos ya existen';
GO

-- ====== 2. CURSOS ======
PRINT 'Insertando Cursos...';
IF NOT EXISTS (SELECT 1 FROM Cursos WHERE Nombre = '1º ESO')
BEGIN
    INSERT INTO Cursos (Nombre, Nivel, Activo)
    VALUES 
        ('1º ESO', 'ESO', 1),
        ('2º ESO', 'ESO', 1),
        ('1º ASIR', 'FP', 1),
        ('2º ASIR', 'FP', 1),
        ('1º DAW', 'FP', 1),
        ('2º DAW', 'FP', 1);
    PRINT 'Cursos insertados: 6';
END
ELSE
    PRINT 'Cursos ya existen';
GO

-- ====== 3. GRUPOS ======
PRINT 'Insertando Grupos...';
DECLARE @Curso1ESO INT = (SELECT Id FROM Cursos WHERE Nombre = '1º ESO');
DECLARE @Curso2ESO INT = (SELECT Id FROM Cursos WHERE Nombre = '2º ESO');
DECLARE @Curso1ASIR INT = (SELECT Id FROM Cursos WHERE Nombre = '1º ASIR');
DECLARE @Curso2DAW INT = (SELECT Id FROM Cursos WHERE Nombre = '2º DAW');

IF @Curso1ESO IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Grupos WHERE Nombre = '1º ESO A')
BEGIN
    INSERT INTO Grupos (CursoId, Nombre, NumeroAlumnos)
    VALUES 
        (@Curso1ESO, '1º ESO A', 25),
        (@Curso2ESO, '2º ESO A', 28),
        (@Curso1ASIR, '1º ASIR', 20),
        (@Curso2DAW, '2º DAW', 19);
    PRINT 'Grupos insertados: 4';
END
ELSE
    PRINT 'Grupos ya existen o cursos no encontrados';
GO

-- ====== 4. PROFESORES ======
PRINT 'Insertando Profesores...';
DECLARE @DeptInfo INT = (SELECT Id FROM Departamentos WHERE Nombre = 'Informática');
DECLARE @DeptMate INT = (SELECT Id FROM Departamentos WHERE Nombre = 'Matemáticas');
DECLARE @DeptCiencias INT = (SELECT Id FROM Departamentos WHERE Nombre = 'Ciencias Naturales');
DECLARE @DeptEF INT = (SELECT Id FROM Departamentos WHERE Nombre = 'Educación Física');

IF NOT EXISTS (SELECT 1 FROM Profesores WHERE Dni = '12345678A')
BEGIN
    INSERT INTO Profesores (Uuid, Dni, Nombre, Apellidos, Correo, Telefono, DepartamentoId, Activo)
    VALUES 
        (NEWID(), '12345678A', 'María', 'García López', 'maria.garcia@ies.edu', '600111222', @DeptInfo, 1),
        (NEWID(), '23456789B', 'Juan', 'Martínez Ruiz', 'juan.martinez@ies.edu', '600222333', @DeptInfo, 1),
        (NEWID(), '34567890C', 'Ana', 'Fernández Sanz', 'ana.fernandez@ies.edu', '600333444', @DeptMate, 1),
        (NEWID(), '45678901D', 'Laura', 'Sánchez Gómez', 'laura.sanchez@ies.edu', '600555666', @DeptCiencias, 1),
        (NEWID(), '56789012E', 'Roberto', 'Díaz Martín', 'roberto.diaz@ies.edu', '600666777', @DeptEF, 1);
    PRINT 'Profesores insertados: 5';
END
ELSE
    PRINT 'Profesores ya existen';
GO

-- ====== 5. LOCALIZACIONES ======
PRINT 'Insertando Localizaciones...';
IF NOT EXISTS (SELECT 1 FROM Localizaciones WHERE Nombre = 'Museo de Ciencias')
BEGIN
    INSERT INTO Localizaciones (Nombre, Direccion, Ciudad, Provincia, CodigoPostal)
    VALUES 
        ('Museo de Ciencias', 'Calle Museo 1', 'Santander', 'Cantabria', '39001'),
        ('Parque de Cabárceno', 'Carretera Nacional 634', 'Cabárceno', 'Cantabria', '39693'),
        ('Playa del Sardinero', 'Paseo Pérez Galdós', 'Santander', 'Cantabria', '39005'),
        ('Polideportivo Municipal', 'Avenida Deporte 10', 'Santander', 'Cantabria', '39010');
    PRINT 'Localizaciones insertadas: 4';
END
ELSE
    PRINT 'Localizaciones ya existen';
GO

-- ====== 6. EMPRESAS DE TRANSPORTE ======
PRINT 'Insertando Empresas de Transporte...';
IF NOT EXISTS (SELECT 1 FROM EmpTransportes WHERE Cif = 'B12345678')
BEGIN
    INSERT INTO EmpTransportes (Nombre, Cif, Telefono, Email, Direccion)
    VALUES 
        ('Autocares del Norte', 'B12345678', '942123456', 'info@autocaresnorte.com', 'Polígono Industrial 1'),
        ('Transportes Cántabros', 'B23456789', '942234567', 'contacto@transcantabros.com', 'Calle Transporte 20');
    PRINT 'Empresas de Transporte insertadas: 2';
END
ELSE
    PRINT 'Empresas de Transporte ya existen';
GO

-- ====== 6B. USUARIOS ======
PRINT 'Insertando Usuarios...';
PRINT '';
PRINT '=================================================================';
PRINT 'NOTA IMPORTANTE: Los usuarios se crearán con contraseñas BCrypt';
PRINT 'Use el endpoint /api/dev/seed-users para crear usuarios de prueba';
PRINT 'O use el endpoint /api/auth/register para registrar nuevos usuarios';
PRINT '=================================================================';
PRINT '';
PRINT 'Usuarios NO insertados desde SQL (usar API para crearlos)';
PRINT '';
PRINT 'Para crear usuarios de prueba, ejecuta:';
PRINT '  POST https://localhost:7139/api/dev/seed-users';
PRINT '';
PRINT 'O registra usuarios manualmente:';
PRINT '  POST https://localhost:7139/api/auth/register';
PRINT '  Body: { "email": "tu@email.com", "nombreCompleto": "Tu Nombre", "password": "tupassword" }';
PRINT '';
GO

-- ====== 7. ACTIVIDADES ======
PRINT 'Insertando Actividades...';
DECLARE @DeptInfo2 INT = (SELECT Id FROM Departamentos WHERE Nombre = 'Informática');
DECLARE @DeptCiencias2 INT = (SELECT Id FROM Departamentos WHERE Nombre = 'Ciencias Naturales');
DECLARE @DeptEF2 INT = (SELECT Id FROM Departamentos WHERE Nombre = 'Educación Física');

DECLARE @LocMuseo INT = (SELECT Id FROM Localizaciones WHERE Nombre = 'Museo de Ciencias');
DECLARE @LocCabarceno INT = (SELECT Id FROM Localizaciones WHERE Nombre = 'Parque de Cabárceno');
DECLARE @LocPlaya INT = (SELECT Id FROM Localizaciones WHERE Nombre = 'Playa del Sardinero');

IF NOT EXISTS (SELECT 1 FROM Actividades WHERE Nombre = 'Excursión al Museo de Ciencias')
BEGIN
    INSERT INTO Actividades (
        Nombre, Descripcion, FechaInicio, FechaFin, 
        LocalizacionId, PresupuestoEstimado, Aprobada, FechaCreacion, DepartamentoId
    )
    VALUES 
        -- ACTIVIDADES FUTURAS APROBADAS (aparecerán en el Home)
        (
            'Excursión al Museo de Ciencias',
            'Visita educativa al Museo de Ciencias con actividades interactivas para estudiantes de ESO.',
            DATEADD(day, 7, GETDATE()),
            DATEADD(day, 7, GETDATE()),
            @LocMuseo,
            500.00,
            1,
            GETDATE(),
            @DeptCiencias2
        ),
        (
            'Hackathon de Programación',
            'Competencia de desarrollo de software para estudiantes de FP. 8 horas para crear una aplicación funcional.',
            DATEADD(day, 14, GETDATE()),
            DATEADD(day, 14, GETDATE()),
            NULL,
            800.00,
            1,
            GETDATE(),
            @DeptInfo2
        ),
        (
            'Visita al Parque de Cabárceno',
            'Excursión educativa para conocer la biodiversidad y los ecosistemas. Incluye transporte y entrada.',
            DATEADD(day, 21, GETDATE()),
            DATEADD(day, 21, GETDATE()),
            @LocCabarceno,
            1200.00,
            1,
            GETDATE(),
            @DeptCiencias2
        ),
        (
            'Torneo Deportivo Interescolar',
            'Competencia deportiva con varias disciplinas: fútbol, baloncesto y voleibol.',
            DATEADD(day, 30, GETDATE()),
            DATEADD(day, 30, GETDATE()),
            NULL,
            600.00,
            1,
            GETDATE(),
            @DeptEF2
        ),
        (
            'Taller de Desarrollo Web',
            'Taller práctico sobre las últimas tecnologías en desarrollo web: React, Angular y Vue.',
            DATEADD(day, 45, GETDATE()),
            DATEADD(day, 47, GETDATE()),
            NULL,
            350.00,
            1,
            GETDATE(),
            @DeptInfo2
        ),
        
        -- ACTIVIDADES PASADAS REALIZADAS
        (
            'Jornada de Reciclaje y Sostenibilidad',
            'Taller de sensibilización sobre el reciclaje y cuidado ambiental.',
            DATEADD(day, -60, GETDATE()),
            DATEADD(day, -60, GETDATE()),
            NULL,
            150.00,
            1,
            DATEADD(day, -80, GETDATE()),
            @DeptCiencias2
        ),
        (
            'Excursión a la Playa del Sardinero',
            'Día de convivencia en la playa con actividades deportivas y recreativas.',
            DATEADD(day, -30, GETDATE()),
            DATEADD(day, -30, GETDATE()),
            @LocPlaya,
            400.00,
            1,
            DATEADD(day, -50, GETDATE()),
            @DeptEF2
        ),
        
        -- ACTIVIDADES PENDIENTES DE APROBACIÓN
        (
            'Conferencia sobre Inteligencia Artificial',
            'Charla sobre las últimas tendencias en IA y machine learning impartida por expertos del sector.',
            DATEADD(day, 60, GETDATE()),
            DATEADD(day, 60, GETDATE()),
            NULL,
            450.00,
            0,
            GETDATE(),
            @DeptInfo2
        );
    
    PRINT 'Actividades insertadas: 8';
END
ELSE
    PRINT 'Actividades ya existen';
GO

-- ====== 8. GRUPOS PARTICIPANTES ======
PRINT 'Insertando Grupos Participantes...';
DECLARE @Act1 INT = (SELECT Id FROM Actividades WHERE Nombre = 'Excursión al Museo de Ciencias');
DECLARE @Act3 INT = (SELECT Id FROM Actividades WHERE Nombre = 'Visita al Parque de Cabárceno');
DECLARE @Grupo1ESO_A INT = (SELECT Id FROM Grupos WHERE Nombre = '1º ESO A');
DECLARE @Grupo2ESO_A INT = (SELECT Id FROM Grupos WHERE Nombre = '2º ESO A');

IF @Act1 IS NOT NULL AND @Grupo1ESO_A IS NOT NULL AND NOT EXISTS (SELECT 1 FROM GrupoPartics WHERE ActividadId = @Act1)
BEGIN
    INSERT INTO GrupoPartics (ActividadId, GrupoId, NumeroParticipantes, FechaRegistro)
    VALUES 
        (@Act1, @Grupo1ESO_A, 25, GETDATE()),
        (@Act3, @Grupo2ESO_A, 28, GETDATE());
    PRINT 'Grupos Participantes insertados: 2';
END
ELSE
    PRINT 'Grupos Participantes ya existen o no se encontraron actividades/grupos';
GO

-- ====== 9. PROFESORES RESPONSABLES ======
PRINT 'Insertando Profesores Responsables...';
DECLARE @ActMuseo INT = (SELECT Id FROM Actividades WHERE Nombre = 'Excursión al Museo de Ciencias');
DECLARE @ProfCiencias UNIQUEIDENTIFIER = (SELECT TOP 1 Uuid FROM Profesores WHERE Correo = 'laura.sanchez@ies.edu');

IF @ActMuseo IS NOT NULL AND @ProfCiencias IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ProfResponsables WHERE ActividadId = @ActMuseo)
BEGIN
    INSERT INTO ProfResponsables (ActividadId, ProfesorUuid, EsCoordinador, FechaAsignacion)
    VALUES (@ActMuseo, @ProfCiencias, 1, GETDATE());
    PRINT 'Profesores Responsables insertados: 1';
END
ELSE
    PRINT 'Profesores Responsables ya existen o no se encontraron actividades/profesores';
GO

-- ====== 10. PROFESORES PARTICIPANTES ======
PRINT 'Insertando Profesores Participantes...';
DECLARE @ActMuseo2 INT = (SELECT Id FROM Actividades WHERE Nombre = 'Excursión al Museo de Ciencias');
DECLARE @ProfMate UNIQUEIDENTIFIER = (SELECT TOP 1 Uuid FROM Profesores WHERE Correo = 'ana.fernandez@ies.edu');

IF @ActMuseo2 IS NOT NULL AND @ProfMate IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ProfParticipantes WHERE ActividadId = @ActMuseo2)
BEGIN
    INSERT INTO ProfParticipantes (ActividadId, ProfesorUuid, FechaRegistro, Observaciones)
    VALUES (@ActMuseo2, @ProfMate, GETDATE(), 'Acompañante');
    PRINT 'Profesores Participantes insertados: 1';
END
ELSE
    PRINT 'Profesores Participantes ya existen o no se encontraron actividades/profesores';
GO

-- ========================================
-- VERIFICACIÓN FINAL
-- ========================================
PRINT '';
PRINT '========================================';
PRINT 'RESUMEN DE DATOS EN LA BASE DE DATOS';
PRINT '========================================';

SELECT 'Departamentos' AS Tabla, COUNT(*) AS Total FROM Departamentos
UNION ALL
SELECT 'Cursos', COUNT(*) FROM Cursos
UNION ALL
SELECT 'Grupos', COUNT(*) FROM Grupos
UNION ALL
SELECT 'Profesores', COUNT(*) FROM Profesores
UNION ALL
SELECT 'Usuarios', COUNT(*) FROM Usuarios
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
SELECT 'Profesores Participantes', COUNT(*) FROM ProfParticipantes;

PRINT '';
PRINT 'Base de datos poblada correctamente!';
PRINT '';

-- Ver actividades futuras (las que aparecerán en el home)
PRINT 'ACTIVIDADES FUTURAS APROBADAS (aparecer án en Home):';
SELECT 
    Id,
    Nombre,
    FechaInicio,
    PresupuestoEstimado,
    CASE WHEN Aprobada = 1 THEN 'Sí' ELSE 'No' END AS Aprobada
FROM Actividades
WHERE FechaInicio > GETDATE() AND Aprobada = 1
ORDER BY FechaInicio;
GO

PRINT '';
PRINT 'Población completada!';
