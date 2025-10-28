-- Script para modificar tabla Alojamientos y crear tabla GastosPersonalizados
-- Fecha: 2025-10-28

USE ACEXAPI;
GO

-- ============================================
-- PARTE 1: Modificar tabla Alojamientos
-- ============================================

PRINT 'Modificando tabla Alojamientos...';

-- Verificar si las columnas existen antes de eliminarlas
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Alojamientos') AND name = 'TipoAlojamiento')
BEGIN
    ALTER TABLE Alojamientos DROP COLUMN TipoAlojamiento;
    PRINT 'Columna TipoAlojamiento eliminada';
END

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Alojamientos') AND name = 'NumeroHabitaciones')
BEGIN
    ALTER TABLE Alojamientos DROP COLUMN NumeroHabitaciones;
    PRINT 'Columna NumeroHabitaciones eliminada';
END

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Alojamientos') AND name = 'PrecioPorNoche')
BEGIN
    ALTER TABLE Alojamientos DROP COLUMN PrecioPorNoche;
    PRINT 'Columna PrecioPorNoche eliminada';
END

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Alojamientos') AND name = 'Servicios')
BEGIN
    ALTER TABLE Alojamientos DROP COLUMN Servicios;
    PRINT 'Columna Servicios eliminada';
END

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Alojamientos') AND name = 'Latitud')
BEGIN
    ALTER TABLE Alojamientos DROP COLUMN Latitud;
    PRINT 'Columna Latitud eliminada';
END

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Alojamientos') AND name = 'Longitud')
BEGIN
    ALTER TABLE Alojamientos DROP COLUMN Longitud;
    PRINT 'Columna Longitud eliminada';
END

PRINT 'Tabla Alojamientos modificada correctamente';
PRINT '';

-- ============================================
-- PARTE 2: Crear tabla GastosPersonalizados
-- ============================================

PRINT 'Creando tabla GastosPersonalizados...';

-- Verificar si la tabla ya existe
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'GastosPersonalizados')
BEGIN
    CREATE TABLE GastosPersonalizados (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        ActividadId INT NOT NULL,
        Concepto NVARCHAR(200) NOT NULL,
        Cantidad DECIMAL(18,2) NOT NULL,
        FechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
        
        -- Constraint para relación con Actividades
        CONSTRAINT FK_GastosPersonalizados_Actividades 
            FOREIGN KEY (ActividadId) REFERENCES Actividades(Id) ON DELETE CASCADE
    );

    -- Índice para mejorar búsquedas por ActividadId
    CREATE INDEX IX_GastosPersonalizados_ActividadId 
        ON GastosPersonalizados(ActividadId);

    PRINT 'Tabla GastosPersonalizados creada correctamente';
END
ELSE
BEGIN
    PRINT 'La tabla GastosPersonalizados ya existe';
END

PRINT '';

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

PRINT '========================================';
PRINT 'VERIFICACIÓN DE CAMBIOS';
PRINT '========================================';
PRINT '';

-- Mostrar estructura de Alojamientos
PRINT 'Columnas actuales de Alojamientos:';
SELECT 
    COLUMN_NAME as 'Columna',
    DATA_TYPE as 'Tipo',
    IS_NULLABLE as 'Permite NULL'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Alojamientos'
ORDER BY ORDINAL_POSITION;

PRINT '';

-- Mostrar estructura de GastosPersonalizados
PRINT 'Columnas de GastosPersonalizados:';
SELECT 
    COLUMN_NAME as 'Columna',
    DATA_TYPE as 'Tipo',
    IS_NULLABLE as 'Permite NULL'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'GastosPersonalizados'
ORDER BY ORDINAL_POSITION;

PRINT '';

-- Mostrar datos de alojamientos
PRINT 'Alojamientos existentes:';
SELECT 
    Id,
    Nombre,
    Ciudad,
    Activo
FROM Alojamientos
ORDER BY Id;

PRINT '';
PRINT '========================================';
PRINT 'SCRIPT COMPLETADO EXITOSAMENTE';
PRINT '========================================';

GO
