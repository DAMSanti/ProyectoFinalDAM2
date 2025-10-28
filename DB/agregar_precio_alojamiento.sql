-- Agregar columna precio_alojamiento a la tabla Actividades
-- Esta columna guarda el precio específico del alojamiento para cada actividad

USE ACEXAPI;
GO

-- Verificar si la columna ya existe
IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'Actividades' 
    AND COLUMN_NAME = 'precio_alojamiento'
)
BEGIN
    ALTER TABLE Actividades
    ADD precio_alojamiento DECIMAL(10,2) NULL;
    
    PRINT 'Columna precio_alojamiento agregada correctamente';
END
ELSE
BEGIN
    PRINT 'La columna precio_alojamiento ya existe';
END
GO

-- Verificar la estructura actualizada
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Actividades'
AND COLUMN_NAME IN ('precio_transporte', 'precio_alojamiento')
ORDER BY ORDINAL_POSITION;
GO
