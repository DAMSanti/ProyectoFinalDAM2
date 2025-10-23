-- =============================================
-- Script: Corregir Tabla Usuarios
-- Descripción: Corrige el error del índice único en la columna Email
-- =============================================

USE ACEXAPI;
GO

PRINT 'Corrigiendo tabla Usuarios...';

-- 1. Eliminar el índice único si existe (con el nombre incorrecto)
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Usuarios_Email' AND object_id = OBJECT_ID('Usuarios'))
BEGIN
    DROP INDEX IX_Usuarios_Email ON Usuarios;
    PRINT '  ? Índice antiguo eliminado';
END
GO

-- 2. Verificar si hay datos en la tabla
DECLARE @count INT;
SELECT @count = COUNT(*) FROM Usuarios;

IF @count > 0
BEGIN
    PRINT '  ? La tabla tiene ' + CAST(@count AS NVARCHAR(10)) + ' registros. Se crearán copias de seguridad.';
    
    -- Crear tabla temporal con los datos
    SELECT * INTO Usuarios_Backup FROM Usuarios;
    PRINT '  ? Backup creado en Usuarios_Backup';
END
ELSE
BEGIN
    PRINT '  ? La tabla está vacía, no se necesita backup';
END
GO

-- 3. Eliminar la tabla actual
DROP TABLE Usuarios;
PRINT '  ? Tabla antigua eliminada';
GO

-- 4. Crear la tabla con la estructura correcta
CREATE TABLE Usuarios (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Email NVARCHAR(256) NOT NULL,
    NombreCompleto NVARCHAR(200) NOT NULL,
    Rol NVARCHAR(50) NOT NULL DEFAULT 'Usuario',
    FechaCreacion DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    Activo BIT NOT NULL DEFAULT 1
);
PRINT '  ? Tabla nueva creada con estructura correcta';
GO

-- 5. Crear el índice único correctamente
CREATE UNIQUE INDEX IX_Usuarios_Email ON Usuarios(Email);
PRINT '  ? Índice único creado correctamente';
GO

-- 6. Restaurar los datos si había backup
IF OBJECT_ID('Usuarios_Backup', 'U') IS NOT NULL
BEGIN
    INSERT INTO Usuarios (Id, Email, NombreCompleto, Rol, FechaCreacion, Activo)
    SELECT Id, 
           CAST(Email AS NVARCHAR(256)), 
           CAST(NombreCompleto AS NVARCHAR(200)),
           CAST(Rol AS NVARCHAR(50)),
           FechaCreacion, 
           Activo
    FROM Usuarios_Backup;
    
    DECLARE @restored INT;
    SELECT @restored = COUNT(*) FROM Usuarios;
    PRINT '  ? Restaurados ' + CAST(@restored AS NVARCHAR(10)) + ' registros';
    
    -- Opcional: Eliminar el backup
    -- DROP TABLE Usuarios_Backup;
    PRINT '  ? Backup conservado en Usuarios_Backup (puedes eliminarlo manualmente si todo funciona bien)';
END
GO

-- 7. Verificar la corrección
PRINT '';
PRINT '================================================';
PRINT 'VERIFICACIÓN FINAL:';
PRINT '================================================';

-- Verificar estructura de la tabla
SELECT 
    COLUMN_NAME AS Columna,
    DATA_TYPE AS TipoDato,
    CHARACTER_MAXIMUM_LENGTH AS LongitudMaxima,
    IS_NULLABLE AS Nullable
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Usuarios'
ORDER BY ORDINAL_POSITION;

-- Verificar el índice
SELECT 
    i.name AS NombreIndice,
    c.name AS Columna,
    i.is_unique AS EsUnico
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('Usuarios') AND i.name = 'IX_Usuarios_Email';

-- Contar registros
DECLARE @totalRecords INT;
SELECT @totalRecords = COUNT(*) FROM Usuarios;
PRINT 'Total de registros en Usuarios: ' + CAST(@totalRecords AS NVARCHAR(10));

PRINT '================================================';
PRINT '? Corrección completada exitosamente';
PRINT '================================================';
GO
