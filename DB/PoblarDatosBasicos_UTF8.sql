-- Poblar datos básicos en UTF-8
USE ACEXAPI;
GO

-- Insertar usuario admin
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE Email = 'admin@acexapi.com')
BEGIN
    INSERT INTO Usuarios (Email, NombreCompleto, Password, Rol, FechaCreacion, Activo)
    VALUES ('admin@acexapi.com', 'Administrador', '$2a$11$xQGKwN9p7HzH2YzYfJYvT.3vD4QwXc0F9j5O8W.gZmL6iNLwYzN9m', 'Admin', GETDATE(), 1);
    PRINT 'Usuario admin creado';
END

-- Insertar Departamentos
IF NOT EXISTS (SELECT 1 FROM Departamentos WHERE Nombre = 'Informática')
BEGIN
    INSERT INTO Departamentos (Nombre, Descripcion) VALUES
    ('Informática', 'Departamento de Informática y Tecnología'),
    ('Matemáticas', 'Departamento de Matemáticas'),
    ('Lengua Española', 'Departamento de Lengua y Literatura'),
    ('Ciencias Naturales', 'Departamento de Biología y Geología'),
    ('Educación Física', 'Departamento de Educación Física y Deportes'),
    ('Idiomas', 'Departamento de Inglés y Francés');
    PRINT 'Departamentos insertados';
END

-- Insertar Cursos
IF NOT EXISTS (SELECT 1 FROM Cursos WHERE Nombre = '1º ESO')
BEGIN
    INSERT INTO Cursos (Nombre) VALUES
    ('1º ESO'),
    ('2º ESO'),
    ('3º ESO'),
    ('4º ESO'),
    ('1º Bachillerato'),
    ('2º Bachillerato'),
    ('1º DAW'),
    ('2º DAW');
    PRINT 'Cursos insertados';
END

-- Insertar Grupos
DECLARE @Curso1Id INT = (SELECT Id FROM Cursos WHERE Nombre = '1º ESO');
DECLARE @Curso2Id INT = (SELECT Id FROM Cursos WHERE Nombre = '2º ESO');
DECLARE @CursoDAW1Id INT = (SELECT Id FROM Cursos WHERE Nombre = '1º DAW');
DECLARE @CursoDAW2Id INT = (SELECT Id FROM Cursos WHERE Nombre = '2º DAW');

IF NOT EXISTS (SELECT 1 FROM Grupos WHERE Nombre = '1º ESO A')
BEGIN
    INSERT INTO Grupos (CursoId, Nombre, NumeroAlumnos) VALUES
    (@Curso1Id, '1º ESO A', 25),
    (@Curso1Id, '1º ESO B', 28),
    (@Curso2Id, '2º ESO A', 24),
    (@Curso2Id, '2º ESO B', 26),
    (@CursoDAW1Id, '1º DAW', 30),
    (@CursoDAW2Id, '2º DAW', 28);
    PRINT 'Grupos insertados';
END

-- Insertar Localizaciones
IF NOT EXISTS (SELECT 1 FROM Localizaciones WHERE Nombre = 'Museo de Ciencias')
BEGIN
    INSERT INTO Localizaciones (Nombre, Direccion, Ciudad, Provincia, CodigoPostal) VALUES
    ('Museo de Ciencias', 'Calle Principal 123', 'Santander', 'Cantabria', '39001'),
    ('Parque Natural', 'Carretera Nacional km 45', 'Cabárceno', 'Cantabria', '39600'),
    ('Playa del Sardinero', 'Paseo Marítimo', 'Santander', 'Cantabria', '39005'),
    ('Polideportivo Municipal', 'Avenida de los Deportes', 'Santander', 'Cantabria', '39010');
    PRINT 'Localizaciones insertadas';
END

-- Insertar Empresas de Transporte
IF NOT EXISTS (SELECT 1 FROM EmpTransportes WHERE Nombre = 'Autobuses del Norte')
BEGIN
    INSERT INTO EmpTransportes (Cif, Nombre, Direccion, Telefono, Email) VALUES
    ('A12345678', 'Autobuses del Norte', 'Polígono Industrial 5', '942111222', 'contacto@autosnorte.es'),
    ('B87654321', 'Transportes Cántabros', 'Calle Industria 10', '942333444', 'info@transcantabros.es');
    PRINT 'Empresas de transporte insertadas';
END

-- Insertar algunos profesores
DECLARE @DeptInfo INT = (SELECT Id FROM Departamentos WHERE Nombre = 'Informática');
DECLARE @DeptMate INT = (SELECT Id FROM Departamentos WHERE Nombre = 'Matemáticas');

IF NOT EXISTS (SELECT 1 FROM Profesores WHERE Dni = '12345678A')
BEGIN
    INSERT INTO Profesores (Uuid, Dni, Nombre, Apellidos, Correo, Telefono, DepartamentoId, Activo) VALUES
    (NEWID(), '12345678A', 'Juan', 'García López', 'juan.garcia@ies.es', '942111111', @DeptInfo, 1),
    (NEWID(), '87654321B', 'María', 'Sánchez Gómez', 'maria.sanchez@ies.es', '942222222', @DeptMate, 1),
    (NEWID(), '11223344C', 'Pedro', 'Martínez Ruiz', 'pedro.martinez@ies.es', '942333333', @DeptInfo, 1);
    PRINT 'Profesores insertados';
END

-- Insertar una actividad de ejemplo
DECLARE @LocMuseo INT = (SELECT Id FROM Localizaciones WHERE Nombre = 'Museo de Ciencias');
DECLARE @ProfeUuid UNIQUEIDENTIFIER = (SELECT TOP 1 Uuid FROM Profesores WHERE Dni = '12345678A');

IF NOT EXISTS (SELECT 1 FROM Actividades WHERE Nombre = 'Excursión al Museo de Ciencias')
BEGIN
    INSERT INTO Actividades (
        Nombre, Descripcion, FechaInicio, FechaFin, 
        DepartamentoId, LocalizacionId, 
        PresupuestoEstimado, Aprobada, FechaCreacion
    ) VALUES (
        'Excursión al Museo de Ciencias',
        'Visita educativa al Museo de Ciencias con actividades interactivas sobre física y química',
        DATEADD(DAY, 15, GETDATE()),
        DATEADD(DAY, 15, GETDATE()),
        @DeptInfo,
        @LocMuseo,
        500.00,
        1,
        GETDATE()
    );
    
    DECLARE @ActividadId INT = SCOPE_IDENTITY();
    
    -- Asignar profesor responsable
    INSERT INTO ProfResponsables (ActividadId, ProfesorUuid, EsCoordinador, FechaAsignacion)
    VALUES (@ActividadId, @ProfeUuid, 1, GETDATE());
    
    PRINT 'Actividad de ejemplo insertada';
END

PRINT '';
PRINT '========================================';
PRINT 'DATOS BÁSICOS INSERTADOS CON ÉXITO';
PRINT '========================================';
PRINT 'Usuario: admin@acexapi.com';
PRINT 'Password: admin123';
PRINT '========================================';
