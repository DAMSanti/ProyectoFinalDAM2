-- ========================================
-- Agregar columnas Latitud y Longitud a Localizaciones
-- ========================================
USE ACEXAPI;
GO

-- Verificar si las columnas ya existen
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Localizaciones' AND COLUMN_NAME = 'Latitud')
BEGIN
    ALTER TABLE Localizaciones
    ADD Latitud FLOAT NULL;
    PRINT 'Columna Latitud agregada a Localizaciones';
END
ELSE
BEGIN
    PRINT 'Columna Latitud ya existe en Localizaciones';
END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Localizaciones' AND COLUMN_NAME = 'Longitud')
BEGIN
    ALTER TABLE Localizaciones
    ADD Longitud FLOAT NULL;
    PRINT 'Columna Longitud agregada a Localizaciones';
END
ELSE
BEGIN
    PRINT 'Columna Longitud ya existe en Localizaciones';
END
GO

-- ========================================
-- Agregar columna ProfesorUuid a Usuarios
-- ========================================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Usuarios' AND COLUMN_NAME = 'ProfesorUuid')
BEGIN
    ALTER TABLE Usuarios
    ADD ProfesorUuid UNIQUEIDENTIFIER NULL;
    PRINT 'Columna ProfesorUuid agregada a Usuarios';
    
    -- Agregar clave foránea
    ALTER TABLE Usuarios
    ADD CONSTRAINT FK_Usuarios_Profesores_ProfesorUuid
    FOREIGN KEY (ProfesorUuid) REFERENCES Profesores(Uuid)
    ON DELETE SET NULL;
    PRINT 'Clave foránea FK_Usuarios_Profesores_ProfesorUuid creada';
END
ELSE
BEGIN
    PRINT 'Columna ProfesorUuid ya existe en Usuarios';
END
GO

-- ========================================
-- Actualizar coordenadas de localizaciones existentes
-- ========================================
UPDATE Localizaciones SET Latitud = 43.4623, Longitud = -3.8100 WHERE Nombre = 'Museo de Ciencias';
UPDATE Localizaciones SET Latitud = 43.3582, Longitud = -3.8350 WHERE Nombre = 'Parque de Cabárceno';
UPDATE Localizaciones SET Latitud = 43.4788, Longitud = -3.7950 WHERE Nombre = 'Playa del Sardinero';
UPDATE Localizaciones SET Latitud = 43.3486, Longitud = -4.0467 WHERE Nombre = 'Centro Cultural';
UPDATE Localizaciones SET Latitud = 43.4647, Longitud = -3.8048 WHERE Nombre = 'Polideportivo Municipal';
GO

PRINT '';
PRINT '========================================';
PRINT 'MODIFICACIONES COMPLETADAS';
PRINT '========================================';
PRINT 'Se han agregado:';
PRINT '  - Latitud y Longitud a Localizaciones';
PRINT '  - ProfesorUuid a Usuarios (con FK)';
PRINT '  - Coordenadas GPS a localizaciones existentes';
PRINT '========================================';
GO
