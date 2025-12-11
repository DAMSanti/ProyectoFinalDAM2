-- Migración para agregar columnas Descripcion y TipoLocalizacion a ActividadLocalizaciones
-- Fecha: 2025-12-09

USE ACEXAPI;
GO

-- Agregar columna Descripcion si no existe
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('ActividadLocalizaciones') AND name = 'Descripcion')
BEGIN
    ALTER TABLE ActividadLocalizaciones
    ADD Descripcion NVARCHAR(500) NULL;
    
    PRINT 'Columna Descripcion agregada a ActividadLocalizaciones';
END
ELSE
BEGIN
    PRINT 'Columna Descripcion ya existe en ActividadLocalizaciones';
END
GO

-- Agregar columna TipoLocalizacion si no existe
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('ActividadLocalizaciones') AND name = 'TipoLocalizacion')
BEGIN
    ALTER TABLE ActividadLocalizaciones
    ADD TipoLocalizacion NVARCHAR(50) NULL;
    
    PRINT 'Columna TipoLocalizacion agregada a ActividadLocalizaciones';
END
ELSE
BEGIN
    PRINT 'Columna TipoLocalizacion ya existe en ActividadLocalizaciones';
END
GO

-- Verificar la estructura final
SELECT 
    c.name AS ColumnName,
    t.name AS DataType,
    c.max_length AS MaxLength,
    c.is_nullable AS IsNullable
FROM sys.columns c
JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('ActividadLocalizaciones')
ORDER BY c.column_id;
GO

PRINT 'Migración completada exitosamente';
