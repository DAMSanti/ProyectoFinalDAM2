-- Migration: Agregar campos para gestión de localizaciones en actividades
-- Fecha: 2025-10-27
-- Descripción: Agrega campos esPrincipal e icono a la tabla Localizaciones

USE ACEXDB;
GO

-- 1. Agregar columna esPrincipal si no existe
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Localizaciones]') AND name = 'EsPrincipal')
BEGIN
    ALTER TABLE [dbo].[Localizaciones]
    ADD [EsPrincipal] BIT NOT NULL DEFAULT 0;
    PRINT 'Columna EsPrincipal agregada exitosamente';
END
ELSE
BEGIN
    PRINT 'Columna EsPrincipal ya existe';
END
GO

-- 2. Agregar columna icono si no existe
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Localizaciones]') AND name = 'Icono')
BEGIN
    ALTER TABLE [dbo].[Localizaciones]
    ADD [Icono] NVARCHAR(50) NULL;
    PRINT 'Columna Icono agregada exitosamente';
END
ELSE
BEGIN
    PRINT 'Columna Icono ya existe';
END
GO

-- 3. Actualizar localizaciones existentes en ActividadLocalizaciones
-- Marcar la primera localización de cada actividad como principal
WITH PrimeraLocalizacion AS (
    SELECT 
        ActividadId,
        MIN(LocalizacionId) as PrimeraLocalizacionId
    FROM [dbo].[ActividadLocalizaciones]
    GROUP BY ActividadId
)
UPDATE al
SET al.EsPrincipal = CASE 
    WHEN al.LocalizacionId = pl.PrimeraLocalizacionId THEN 1 
    ELSE 0 
END
FROM [dbo].[ActividadLocalizaciones] al
INNER JOIN PrimeraLocalizacion pl ON al.ActividadId = pl.ActividadId;

PRINT 'Datos de ActividadLocalizaciones actualizados';
GO

-- 4. Asignar iconos por defecto
UPDATE [dbo].[ActividadLocalizaciones]
SET Icono = CASE 
    WHEN EsPrincipal = 1 THEN 'location_pin'
    ELSE 'location_on'
END
WHERE Icono IS NULL;

PRINT 'Iconos por defecto asignados';
GO

PRINT 'Migration completada exitosamente';
GO
