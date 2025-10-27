-- ========================================
-- Agregar columnas Latitud y Longitud a tabla Localizaciones
-- ========================================
USE ACEXAPI;
GO

-- Verificar si las columnas ya existen antes de agregarlas
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Localizaciones' AND COLUMN_NAME = 'Latitud')
BEGIN
    ALTER TABLE Localizaciones
    ADD Latitud DECIMAL(10, 7) NULL;
    
    PRINT 'Columna Latitud agregada correctamente';
END
ELSE
BEGIN
    PRINT 'La columna Latitud ya existe';
END

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Localizaciones' AND COLUMN_NAME = 'Longitud')
BEGIN
    ALTER TABLE Localizaciones
    ADD Longitud DECIMAL(10, 7) NULL;
    
    PRINT 'Columna Longitud agregada correctamente';
END
ELSE
BEGIN
    PRINT 'La columna Longitud ya existe';
END
GO

-- Verificar que las columnas se agregaron correctamente
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Localizaciones'
ORDER BY ORDINAL_POSITION;
GO

PRINT '';
PRINT 'Migración completada correctamente';
GO
