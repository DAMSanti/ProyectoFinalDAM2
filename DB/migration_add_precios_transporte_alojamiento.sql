-- Migración: Agregar campos de precios para transporte y alojamiento
-- Fecha: 2025-10-27
-- Descripción: Agrega campos para almacenar los precios del transporte y alojamiento en la tabla actividades
-- Motor: SQL Server

USE ACEXAPI;
GO

-- Agregar campo para el precio del transporte (precio final contratado)
ALTER TABLE actividades 
ADD precio_transporte DECIMAL(10,2) NULL;
GO

-- Agregar campo para el precio del alojamiento
ALTER TABLE actividades 
ADD precio_alojamiento DECIMAL(10,2) NULL;
GO

-- Agregar campo para el nombre/descripción del alojamiento
ALTER TABLE actividades 
ADD nombre_alojamiento NVARCHAR(200) NULL;
GO

-- Agregar comentarios extendidos (SQL Server)
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Precio final del transporte contratado',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'TABLE',  @level1name = 'actividades',
    @level2type = N'COLUMN', @level2name = 'precio_transporte';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Precio total del alojamiento',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'TABLE',  @level1name = 'actividades',
    @level2type = N'COLUMN', @level2name = 'precio_alojamiento';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Nombre o descripción del alojamiento',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'TABLE',  @level1name = 'actividades',
    @level2type = N'COLUMN', @level2name = 'nombre_alojamiento';
GO

-- Verificar los cambios
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'actividades' 
  AND COLUMN_NAME IN ('precio_transporte', 'precio_alojamiento', 'nombre_alojamiento');
GO
