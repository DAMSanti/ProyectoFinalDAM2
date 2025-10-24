-- ========================================
-- Script para poblar la base de datos ACEXAPI con datos de ejemplo
-- ADAPTADO AL ESQUEMA REAL DE LA BD
-- ========================================
USE ACEXAPI;
GO

-- ========================================
-- 1. DEPARTAMENTOS
-- ========================================
INSERT INTO Departamentos (Nombre, Descripcion)
VALUES 
    ('Informática', 'Departamento de Informática y Comunicaciones'),
    ('Matemáticas', 'Departamento de Matemáticas'),
    ('Lengua y Literatura', 'Departamento de Lengua Castellana y Literatura'),
    ('Ciencias Naturales', 'Departamento de Biología y Geología'),
    ('Educación Física', 'Departamento de Educación Física y Deportes'),
    ('Idiomas', 'Departamento de Inglés y Francés');
GO

-- ========================================
-- 2. CURSOS
-- ========================================
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
GO

-- ========================================
-- 4. PROFESORES
-- ========================================
DECLARE @DeptInfo INT = (SELECT Id FROM Departamentos WHERE Nombre = 'Informática');
DECLARE @DeptMate INT = (SELECT Id FROM Departamentos WHERE Nombre = 'Matemáticas');
DECLARE @DeptLengua INT = (SELECT Id FROM Departamentos WHERE Nombre = 'Lengua y Literatura');
DECLARE @DeptCiencias INT = (SELECT Id FROM Departamentos WHERE Nombre = 'Ciencias Naturales');
DECLARE @DeptEF INT = (SELECT Id FROM Departamentos WHERE Nombre = 'Educación Física');

INSERT INTO Profesores (Uuid, Dni, Nombre, Apellidos, Correo, Telefono, DepartamentoId, Activo)
VALUES 
    (NEWID(), '12345678A', 'María', 'García López', 'maria.garcia@ies.edu', '600111222', @DeptInfo, 1),
    (NEWID(), '23456789B', 'Juan', 'Martínez Ruiz', 'juan.martinez@ies.edu', '600222333', @DeptInfo, 1),
    (NEWID(), '34567890C', 'Ana', 'Fernández Sanz', 'ana.fernandez@ies.edu', '600333444', @DeptMate, 1),
    (NEWID(), '45678901D', 'Carlos', 'López Pérez', 'carlos.lopez@ies.edu', '600444555', @DeptLengua, 1),
    (NEWID(), '56789012E', 'Laura', 'Sánchez Gómez', 'laura.sanchez@ies.edu', '600555666', @DeptCiencias, 1),
    (NEWID(), '67890123F', 'Roberto', 'Díaz Martín', 'roberto.diaz@ies.edu', '600666777', @DeptEF, 1);
GO

-- ========================================
-- 5. LOCALIZACIONES (con coordenadas GPS)
-- ========================================
INSERT INTO Localizaciones (Nombre, Direccion, Ciudad, Provincia, CodigoPostal, Latitud, Longitud)
VALUES 
    ('Museo de Ciencias', 'Calle Museo 1', 'Santander', 'Cantabria', '39001', 43.4623, -3.8100),
    ('Parque de Cabárceno', 'Carretera Nacional 634', 'Cabárceno', 'Cantabria', '39693', 43.3582, -3.8350),
    ('Playa del Sardinero', 'Paseo Pérez Galdós', 'Santander', 'Cantabria', '39005', 43.4788, -3.7950),
    ('Centro Cultural', 'Plaza Mayor 5', 'Torrelavega', 'Cantabria', '39300', 43.3486, -4.0467),
    ('Polideportivo Municipal', 'Avenida Deporte 10', 'Santander', 'Cantabria', '39010', 43.4647, -3.8048);
GO

-- ========================================
-- 6. EMPRESAS DE TRANSPORTE
-- ========================================
INSERT INTO EmpTransportes (Nombre, Direccion, Telefono, Email, Cif)
VALUES 
    ('Autocares del Norte', 'Polígono Industrial 1', '942123456', 'info@autocaresnorte.com', 'B12345678'),
    ('Transportes Cántabros', 'Calle Transporte 20', '942234567', 'contacto@transcantabros.com', 'B23456789'),
    ('Viajes Escolares S.L.', 'Avenida Educación 15', '942345678', 'escolar@viajesescol.com', 'B34567890');
GO

-- ========================================
-- 7. ACTIVIDADES
-- ========================================
DECLARE @DeptInfo2 INT = (SELECT Id FROM Departamentos WHERE Nombre = 'Informática');
DECLARE @DeptCiencias2 INT = (SELECT Id FROM Departamentos WHERE Nombre = 'Ciencias Naturales');
DECLARE @DeptEF2 INT = (SELECT Id FROM Departamentos WHERE Nombre = 'Educación Física');

DECLARE @LocMuseo INT = (SELECT Id FROM Localizaciones WHERE Nombre = 'Museo de Ciencias');
DECLARE @LocCabarceno INT = (SELECT Id FROM Localizaciones WHERE Nombre = 'Parque de Cabárceno');
DECLARE @LocPlaya INT = (SELECT Id FROM Localizaciones WHERE Nombre = 'Playa del Sardinero');
DECLARE @LocCultural INT = (SELECT Id FROM Localizaciones WHERE Nombre = 'Centro Cultural');
DECLARE @LocPolideportivo INT = (SELECT Id FROM Localizaciones WHERE Nombre = 'Polideportivo Municipal');

DECLARE @EmpTransp1 INT = (SELECT Id FROM EmpTransportes WHERE Nombre = 'Autocares del Norte');

INSERT INTO Actividades (
    Nombre, Descripcion, FechaInicio, FechaFin,
    LocalizacionId, PresupuestoEstimado, CostoReal,
    Aprobada, FechaCreacion, DepartamentoId, EmpTransporteId
)
VALUES 
    -- Actividades futuras aprobadas
    (
        'Excursión al Museo de Ciencias',
        'Visita educativa al Museo de Ciencias con actividades interactivas para estudiantes de ESO.',
        DATEADD(day, 7, GETDATE()),
        DATEADD(day, 7, GETDATE()),
        @LocMuseo,
        500.00,
        NULL,
        1,
        GETDATE(),
        @DeptCiencias2,
        NULL
    ),
    (
        'Hackathon de Programación',
        'Competencia de desarrollo de software para estudiantes de FP. Los equipos tendrán 8 horas para crear una aplicación funcional.',
        DATEADD(day, 14, GETDATE()),
        DATEADD(day, 14, GETDATE()),
        @LocCultural,
        800.00,
        NULL,
        1,
        GETDATE(),
        @DeptInfo2,
        NULL
    ),
    (
        'Visita al Parque de Cabárceno',
        'Excursión educativa para conocer la biodiversidad y los ecosistemas. Incluye transporte y entrada.',
        DATEADD(day, 21, GETDATE()),
        DATEADD(day, 21, GETDATE()),
        @LocCabarceno,
        1200.00,
        NULL,
        1,
        GETDATE(),
        @DeptCiencias2,
        @EmpTransp1
    ),
    (
        'Torneo Deportivo Interescolar',
        'Competencia deportiva con varias disciplinas: fútbol, baloncesto y voleibol.',
        DATEADD(day, 30, GETDATE()),
        DATEADD(day, 30, GETDATE()),
        @LocPolideportivo,
        600.00,
        NULL,
        1,
        GETDATE(),
        @DeptEF2,
        NULL
    ),
    (
        'Taller de Desarrollo Web',
        'Taller práctico sobre las últimas tecnologías en desarrollo web: React, Angular y Vue.',
        DATEADD(day, 45, GETDATE()),
        DATEADD(day, 47, GETDATE()),
        @LocCultural,
        350.00,
        NULL,
        1,
        GETDATE(),
        @DeptInfo2,
        NULL
    ),
    
    -- Actividades pasadas realizadas
    (
        'Jornada de Reciclaje y Sostenibilidad',
        'Taller de sensibilización sobre el reciclaje y cuidado ambiental.',
        DATEADD(day, -60, GETDATE()),
        DATEADD(day, -60, GETDATE()),
        NULL,
        150.00,
        140.00,
        1,
        DATEADD(day, -80, GETDATE()),
        @DeptCiencias2,
        NULL
    ),
    (
        'Concurso de Matemáticas',
        'Competición interna para resolver retos matemáticos divertidos.',
        DATEADD(day, -45, GETDATE()),
        DATEADD(day, -45, GETDATE()),
        NULL,
        100.00,
        95.00,
        1,
        DATEADD(day, -60, GETDATE()),
        (SELECT Id FROM Departamentos WHERE Nombre = 'Matemáticas'),
        NULL
    ),
    (
        'Excursión a la Playa del Sardinero',
        'Día de convivencia en la playa con actividades deportivas y recreativas.',
        DATEADD(day, -30, GETDATE()),
        DATEADD(day, -30, GETDATE()),
        @LocPlaya,
        400.00,
        380.00,
        1,
        DATEADD(day, -50, GETDATE()),
        @DeptEF2,
        NULL
    ),
    
    -- Actividades pendientes de aprobación
    (
        'Conferencia sobre Inteligencia Artificial',
        'Charla sobre las últimas tendencias en IA y machine learning impartida por expertos del sector.',
        DATEADD(day, 60, GETDATE()),
        DATEADD(day, 60, GETDATE()),
        @LocCultural,
        450.00,
        NULL,
        0,
        GETDATE(),
        @DeptInfo2,
        NULL
    ),
    (
        'Campamento de Verano STEM',
        'Campamento educativo de 5 días con actividades de ciencia, tecnología, ingeniería y matemáticas.',
        DATEADD(day, 90, GETDATE()),
        DATEADD(day, 95, GETDATE()),
        NULL,
        3500.00,
        NULL,
        0,
        GETDATE(),
        @DeptInfo2,
        NULL
    );
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

IF @Act1 IS NOT NULL
BEGIN
    INSERT INTO GrupoPartics (ActividadId, GrupoId, NumeroParticipantes)
    VALUES 
        (@Act1, @Grupo1ESO_A, 25),
        (@Act1, @Grupo2ESO_A, 25);
END

IF @Act2 IS NOT NULL
BEGIN
    INSERT INTO GrupoPartics (ActividadId, GrupoId, NumeroParticipantes)
    VALUES 
        (@Act2, @Grupo1ASIR, 20),
        (@Act2, @Grupo2DAW, 20);
END

IF @Act3 IS NOT NULL
BEGIN
    INSERT INTO GrupoPartics (ActividadId, GrupoId, NumeroParticipantes)
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

DECLARE @Prof1 UNIQUEIDENTIFIER = (SELECT TOP 1 Uuid FROM Profesores WHERE Correo = 'maria.garcia@ies.edu');
DECLARE @Prof2 UNIQUEIDENTIFIER = (SELECT TOP 1 Uuid FROM Profesores WHERE Correo = 'juan.martinez@ies.edu');
DECLARE @Prof3 UNIQUEIDENTIFIER = (SELECT TOP 1 Uuid FROM Profesores WHERE Correo = 'ana.fernandez@ies.edu');
DECLARE @Prof4 UNIQUEIDENTIFIER = (SELECT TOP 1 Uuid FROM Profesores WHERE Correo = 'laura.sanchez@ies.edu');

IF @Act1_R IS NOT NULL
BEGIN
    INSERT INTO ProfResponsables (ActividadId, ProfesorUuid, EsCoordinador)
    VALUES (@Act1_R, @Prof4, 1);
    
    INSERT INTO ProfParticipantes (ActividadId, ProfesorUuid)
    VALUES 
        (@Act1_R, @Prof4),
        (@Act1_R, @Prof3);
END

IF @Act2_R IS NOT NULL
BEGIN
    INSERT INTO ProfResponsables (ActividadId, ProfesorUuid, EsCoordinador)
    VALUES (@Act2_R, @Prof1, 1);
    
    INSERT INTO ProfParticipantes (ActividadId, ProfesorUuid)
    VALUES 
        (@Act2_R, @Prof1),
        (@Act2_R, @Prof2);
END

IF @Act3_R IS NOT NULL
BEGIN
    INSERT INTO ProfResponsables (ActividadId, ProfesorUuid, EsCoordinador)
    VALUES (@Act3_R, @Prof4, 1);
    
    INSERT INTO ProfParticipantes (ActividadId, ProfesorUuid)
    VALUES 
        (@Act3_R, @Prof4),
        (@Act3_R, @Prof1),
        (@Act3_R, @Prof3);
END
GO

-- ========================================
-- 10. CONTRATOS (Simplificado para esquema actual)
-- ========================================
DECLARE @ActTransp INT = (SELECT Id FROM Actividades WHERE Nombre = 'Visita al Parque de Cabárceno');

IF @ActTransp IS NOT NULL
BEGIN
    INSERT INTO Contratos (ActividadId, NombreProveedor, Descripcion, Monto, FechaContrato)
    VALUES 
        (@ActTransp, 'Autocares del Norte', 'Servicio de transporte al Parque de Cabárceno', 650.00, GETDATE());
END
GO

-- ========================================
-- 11. USUARIOS (para login - vinculados a profesores)
-- ========================================
-- Nota: Las contraseñas deben hashearse en producción
-- Contraseña de ejemplo: "Password123" (debe hashearse con BCrypt o similar)
DECLARE @ProfMaria UNIQUEIDENTIFIER = (SELECT TOP 1 Uuid FROM Profesores WHERE Correo = 'maria.garcia@ies.edu');
DECLARE @ProfJuan UNIQUEIDENTIFIER = (SELECT TOP 1 Uuid FROM Profesores WHERE Correo = 'juan.martinez@ies.edu');
DECLARE @ProfAna UNIQUEIDENTIFIER = (SELECT TOP 1 Uuid FROM Profesores WHERE Correo = 'ana.fernandez@ies.edu');
DECLARE @ProfCarlos UNIQUEIDENTIFIER = (SELECT TOP 1 Uuid FROM Profesores WHERE Correo = 'carlos.lopez@ies.edu');

IF @ProfMaria IS NOT NULL
BEGIN
    INSERT INTO Usuarios (Id, Email, NombreCompleto, Password, Rol, FechaCreacion, Activo, ProfesorUuid)
    VALUES 
        (NEWID(), 'maria.garcia@ies.edu', 'María García López', 'Password123', 'Coordinador', GETDATE(), 1, @ProfMaria);
END

IF @ProfJuan IS NOT NULL
BEGIN
    INSERT INTO Usuarios (Id, Email, NombreCompleto, Password, Rol, FechaCreacion, Activo, ProfesorUuid)
    VALUES 
        (NEWID(), 'juan.martinez@ies.edu', 'Juan Martínez Ruiz', 'Password123', 'Profesor', GETDATE(), 1, @ProfJuan);
END

IF @ProfAna IS NOT NULL
BEGIN
    INSERT INTO Usuarios (Id, Email, NombreCompleto, Password, Rol, FechaCreacion, Activo, ProfesorUuid)
    VALUES 
        (NEWID(), 'ana.fernandez@ies.edu', 'Ana Fernández Sanz', 'Password123', 'Profesor', GETDATE(), 1, @ProfAna);
END

IF @ProfCarlos IS NOT NULL
BEGIN
    INSERT INTO Usuarios (Id, Email, NombreCompleto, Password, Rol, FechaCreacion, Activo, ProfesorUuid)
    VALUES 
        (NEWID(), 'carlos.lopez@ies.edu', 'Carlos López Pérez', 'Password123', 'Profesor', GETDATE(), 1, @ProfCarlos);
END

-- Usuario administrador sin profesor asociado
INSERT INTO Usuarios (Id, Email, NombreCompleto, Password, Rol, FechaCreacion, Activo, ProfesorUuid)
VALUES 
    (NEWID(), 'admin@ies.edu', 'Administrador Sistema', 'Admin123', 'Administrador', GETDATE(), 1, NULL);
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
SELECT 'Contratos', COUNT(*) FROM Contratos
UNION ALL
SELECT 'Usuarios', COUNT(*) FROM Usuarios;

PRINT '';
PRINT 'Base de datos poblada correctamente!';
PRINT '';

-- Ver actividades futuras (las que aparecerán en el home)
SELECT 
    Id,
    Nombre,
    FechaInicio,
    FechaFin,
    PresupuestoEstimado,
    CASE WHEN Aprobada = 1 THEN 'Sí' ELSE 'No' END AS Aprobada
FROM Actividades
WHERE FechaInicio > GETDATE()
ORDER BY FechaInicio;
GO
