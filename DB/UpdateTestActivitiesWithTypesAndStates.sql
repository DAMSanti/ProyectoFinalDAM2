-- =============================================================================
-- Script: Actualizar Actividades con Tipos y Estados variados
-- Descripción: Actualiza actividades existentes y añade nuevas con diferentes
--              combinaciones de Tipo (Extraescolar/Complementaria) y 
--              Estado (Pendiente/Aprobada/Cancelada)
-- Base de Datos: ACEXAPI (SQL Server)
-- =============================================================================

USE ACEXAPI;
GO

PRINT '========================================';
PRINT 'Actualizando Actividades de Prueba';
PRINT '========================================';
PRINT '';

-- =============================================================================
-- PASO 1: Limpiar actividades de prueba anteriores (opcional)
-- =============================================================================
PRINT 'Paso 1: Limpiando actividades de prueba anteriores...';

-- Descomentar si quieres empezar desde cero
/*
DELETE FROM GrupoParticipantes WHERE ActividadId IN (SELECT Id FROM Actividades);
DELETE FROM ProfesoresResponsables WHERE ActividadId IN (SELECT Id FROM Actividades);
DELETE FROM ProfesoresParticipantes WHERE ActividadId IN (SELECT Id FROM Actividades);
DELETE FROM Fotos WHERE ActividadId IN (SELECT Id FROM Actividades);
DELETE FROM Actividades;
DBCC CHECKIDENT ('Actividades', RESEED, 0);
PRINT '✓ Actividades anteriores eliminadas';
*/
PRINT '✓ Omitiendo limpieza (comentado)';
PRINT '';

-- =============================================================================
-- PASO 2: Actualizar actividades existentes con Tipos y Estados variados
-- =============================================================================
PRINT 'Paso 2: Actualizando actividades existentes...';

-- Actualizar primera actividad: Extraescolar - Aprobada
UPDATE Actividades 
SET Tipo = 'Extraescolar', 
    Estado = 'Aprobada',
    Aprobada = 1
WHERE Nombre = 'Excursión al Museo de Ciencias';

-- Actualizar segunda actividad: Complementaria - Pendiente
UPDATE Actividades 
SET Tipo = 'Complementaria', 
    Estado = 'Pendiente',
    Aprobada = 0
WHERE Nombre = 'Taller de Robótica';

-- Actualizar tercera actividad: Extraescolar - Cancelada
UPDATE Actividades 
SET Tipo = 'Extraescolar', 
    Estado = 'Cancelada',
    Aprobada = 0
WHERE Nombre = 'Campamento de Verano';

-- Actualizar cuarta actividad: Complementaria - Aprobada
UPDATE Actividades 
SET Tipo = 'Complementaria', 
    Estado = 'Aprobada',
    Aprobada = 1
WHERE Nombre = 'Conferencia de Tecnología';

-- Actualizar quinta actividad: Extraescolar - Pendiente
UPDATE Actividades 
SET Tipo = 'Extraescolar', 
    Estado = 'Pendiente',
    Aprobada = 0
WHERE Nombre = 'Excursión a la Playa';

-- Actualizar sexta actividad: Complementaria - Cancelada
UPDATE Actividades 
SET Tipo = 'Complementaria', 
    Estado = 'Cancelada',
    Aprobada = 0
WHERE Nombre = 'Torneo Deportivo Interescolar';

PRINT '✓ Actividades existentes actualizadas';
PRINT '';

-- =============================================================================
-- PASO 3: Insertar nuevas actividades de prueba con variedad
-- =============================================================================
PRINT 'Paso 3: Insertando nuevas actividades de prueba...';

-- Actividad 7: Complementaria - Aprobada
INSERT INTO Actividades (Nombre, Descripcion, FechaInicio, FechaFin, PresupuestoEstimado, CostoReal, Estado, Tipo, Aprobada, FechaCreacion)
VALUES 
('Visita a la Biblioteca Municipal',
 'Visita guiada a la biblioteca con taller de fomento a la lectura.',
 DATEADD(day, 5, GETDATE()),
 DATEADD(day, 5, GETDATE()),
 150.00,
 NULL,
 'Aprobada',
 'Complementaria',
 1,
 GETDATE());

-- Actividad 8: Extraescolar - Aprobada
INSERT INTO Actividades (Nombre, Descripcion, FechaInicio, FechaFin, PresupuestoEstimado, CostoReal, Estado, Tipo, Aprobada, FechaCreacion)
VALUES 
('Club de Ajedrez',
 'Sesiones semanales de ajedrez para todos los niveles.',
 DATEADD(day, 3, GETDATE()),
 DATEADD(day, 90, GETDATE()),
 400.00,
 NULL,
 'Aprobada',
 'Extraescolar',
 1,
 GETDATE());

-- Actividad 9: Complementaria - Pendiente
INSERT INTO Actividades (Nombre, Descripcion, FechaInicio, FechaFin, PresupuestoEstimado, CostoReal, Estado, Tipo, Aprobada, FechaCreacion)
VALUES 
('Charla sobre Medio Ambiente',
 'Conferencia sobre sostenibilidad y cambio climático.',
 DATEADD(day, 12, GETDATE()),
 DATEADD(day, 12, GETDATE()),
 200.00,
 NULL,
 'Pendiente',
 'Complementaria',
 0,
 GETDATE());

-- Actividad 10: Extraescolar - Pendiente
INSERT INTO Actividades (Nombre, Descripcion, FechaInicio, FechaFin, PresupuestoEstimado, CostoReal, Estado, Tipo, Aprobada, FechaCreacion)
VALUES 
('Taller de Teatro',
 'Clases de interpretación y montaje de obra teatral.',
 DATEADD(day, 8, GETDATE()),
 DATEADD(day, 60, GETDATE()),
 900.00,
 NULL,
 'Pendiente',
 'Extraescolar',
 0,
 GETDATE());

-- Actividad 11: Complementaria - Cancelada
INSERT INTO Actividades (Nombre, Descripcion, FechaInicio, FechaFin, PresupuestoEstimado, CostoReal, Estado, Tipo, Aprobada, FechaCreacion)
VALUES 
('Visita a Empresa Local',
 'Visita a fábrica para conocer procesos de producción.',
 DATEADD(day, 15, GETDATE()),
 DATEADD(day, 15, GETDATE()),
 300.00,
 NULL,
 'Cancelada',
 'Complementaria',
 0,
 GETDATE());

-- Actividad 12: Extraescolar - Cancelada
INSERT INTO Actividades (Nombre, Descripcion, FechaInicio, FechaFin, PresupuestoEstimado, CostoReal, Estado, Tipo, Aprobada, FechaCreacion)
VALUES 
('Excursión a Parque Natural',
 'Salida al parque para estudio de flora y fauna.',
 DATEADD(day, 25, GETDATE()),
 DATEADD(day, 26, GETDATE()),
 700.00,
 NULL,
 'Cancelada',
 'Extraescolar',
 0,
 GETDATE());

-- Actividad 13: Complementaria - Aprobada (pasada - para historial)
INSERT INTO Actividades (Nombre, Descripcion, FechaInicio, FechaFin, PresupuestoEstimado, CostoReal, Estado, Tipo, Aprobada, FechaCreacion)
VALUES 
('Jornada de Orientación Académica',
 'Información sobre opciones de estudios superiores.',
 DATEADD(day, -7, GETDATE()),
 DATEADD(day, -7, GETDATE()),
 100.00,
 95.00,
 'Aprobada',
 'Complementaria',
 1,
 DATEADD(day, -30, GETDATE()));

-- Actividad 14: Extraescolar - Aprobada (pasada - para historial)
INSERT INTO Actividades (Nombre, Descripcion, FechaInicio, FechaFin, PresupuestoEstimado, CostoReal, Estado, Tipo, Aprobada, FechaCreacion)
VALUES 
('Torneo de Fútbol Sala',
 'Competencia interna de fútbol sala entre clases.',
 DATEADD(day, -14, GETDATE()),
 DATEADD(day, -12, GETDATE()),
 250.00,
 240.00,
 'Aprobada',
 'Extraescolar',
 1,
 DATEADD(day, -45, GETDATE()));

PRINT '✓ Nuevas actividades insertadas';
PRINT '';

-- =============================================================================
-- PASO 4: Verificar resultados
-- =============================================================================
PRINT '========================================';
PRINT 'RESUMEN DE ACTIVIDADES POR TIPO Y ESTADO';
PRINT '========================================';
PRINT '';

-- Contar por Tipo
SELECT 
    Tipo,
    COUNT(*) as 'Cantidad'
FROM Actividades
GROUP BY Tipo
ORDER BY Tipo;

PRINT '';

-- Contar por Estado
SELECT 
    Estado,
    COUNT(*) as 'Cantidad'
FROM Actividades
GROUP BY Estado
ORDER BY Estado;

PRINT '';

-- Resumen combinado
SELECT 
    Tipo,
    Estado,
    COUNT(*) as 'Cantidad'
FROM Actividades
GROUP BY Tipo, Estado
ORDER BY Tipo, Estado;

PRINT '';
PRINT '========================================';
PRINT 'LISTADO COMPLETO DE ACTIVIDADES';
PRINT '========================================';
PRINT '';

-- Listar todas las actividades
SELECT 
    Id,
    Nombre,
    Tipo,
    Estado,
    FechaInicio,
    FechaFin,
    PresupuestoEstimado,
    CostoReal,
    Aprobada
FROM Actividades
ORDER BY 
    CASE 
        WHEN Estado = 'Pendiente' THEN 1
        WHEN Estado = 'Aprobada' THEN 2
        WHEN Estado = 'Cancelada' THEN 3
        ELSE 4
    END,
    FechaInicio;

PRINT '';
PRINT '✓ Script completado exitosamente';
PRINT '';
GO
