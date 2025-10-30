-- Migration: Agregar campos Descripcion y TipoLocalizacion a ActividadLocalizaciones
-- Fecha: 2025-10-30
-- Descripción: Permite registrar una descripción y el tipo de cada localización en una actividad

USE ACEXAPI;
GO

-- 1. Agregar columna Descripcion si no existe
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ActividadLocalizaciones]') AND name = 'Descripcion')
BEGIN
    ALTER TABLE [dbo].[ActividadLocalizaciones]
    ADD [Descripcion] NVARCHAR(500) NULL;
    PRINT 'Columna Descripcion agregada exitosamente';
END
ELSE
BEGIN
    PRINT 'Columna Descripcion ya existe';
END
GO

-- 2. Agregar columna TipoLocalizacion si no existe
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ActividadLocalizaciones]') AND name = 'TipoLocalizacion')
BEGIN
    ALTER TABLE [dbo].[ActividadLocalizaciones]
    ADD [TipoLocalizacion] NVARCHAR(50) NULL;
    PRINT 'Columna TipoLocalizacion agregada exitosamente';
END
ELSE
BEGIN
    PRINT 'Columna TipoLocalizacion ya existe';
END
GO

-- 3. Actualizar tipos por defecto para localizaciones existentes
UPDATE [dbo].[ActividadLocalizaciones]
SET [TipoLocalizacion] = CASE 
    WHEN EsPrincipal = 1 THEN 'Punto de salida'
    ELSE 'Actividad'
END
WHERE [TipoLocalizacion] IS NULL;

PRINT 'Tipos de localización por defecto asignados';
GO

-- 4. Verificar los cambios
SELECT TOP 10
    al.Id,
    a.Nombre as Actividad,
    l.Nombre as Localizacion,
    al.TipoLocalizacion,
    al.Descripcion,
    al.EsPrincipal,
    al.Orden
FROM [dbo].[ActividadLocalizaciones] al
INNER JOIN [dbo].[Actividades] a ON al.ActividadId = a.Id
INNER JOIN [dbo].[Localizaciones] l ON al.LocalizacionId = l.Id
ORDER BY al.ActividadId, al.Orden;
GO

PRINT 'Migration completada exitosamente';
GO
