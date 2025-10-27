-- Script para agregar las columnas transporte_req y alojamiento_req a la tabla Actividades
-- Fecha: 2025-10-28
-- Nota: Estas columnas existen en el esquema original de MySQL pero pueden no existir en SQL Server

USE ACEXAPI;
GO

PRINT '==========================================';
PRINT 'Verificando columnas existentes...';
PRINT '==========================================';

-- Listar todas las columnas actuales de la tabla Actividades
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Actividades'
ORDER BY ORDINAL_POSITION;
GO

PRINT '';
PRINT '==========================================';
PRINT 'Agregando columnas si no existen...';
PRINT '==========================================';

-- Verificar si la columna transporte_req existe
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('Actividades') 
    AND name = 'transporte_req'
)
BEGIN
    ALTER TABLE Actividades
    ADD transporte_req INT NOT NULL DEFAULT 0;
    PRINT '✓ Columna transporte_req agregada correctamente';
END
ELSE
BEGIN
    PRINT '✓ La columna transporte_req ya existe';
END
GO

-- Verificar si la columna alojamiento_req existe
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('Actividades') 
    AND name = 'alojamiento_req'
)
BEGIN
    ALTER TABLE Actividades
    ADD alojamiento_req INT NOT NULL DEFAULT 0;
    PRINT '✓ Columna alojamiento_req agregada correctamente';
END
ELSE
BEGIN
    PRINT '✓ La columna alojamiento_req ya existe';
END
GO

PRINT '';
PRINT '==========================================';
PRINT 'Verificación final...';
PRINT '==========================================';

-- Verificar que las columnas existen ahora
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Actividades'
AND COLUMN_NAME IN ('transporte_req', 'alojamiento_req');
GO

-- Contar actividades actuales
DECLARE @count INT;
SELECT @count = COUNT(*) FROM Actividades;
PRINT '';
PRINT 'Total de actividades en la base de datos: ' + CAST(@count AS VARCHAR(10));
GO

PRINT '';
PRINT '==========================================';
PRINT 'Script ejecutado correctamente';
PRINT '==========================================';

