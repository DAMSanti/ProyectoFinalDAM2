-- =============================================
-- Migración: Cambiar tipo de ResponsableId
-- Descripción: Cambiar ResponsableId de VARCHAR a UNIQUEIDENTIFIER
-- Fecha: 2025-10-29
-- =============================================

PRINT 'Iniciando migración para cambiar tipo de ResponsableId...';

-- Paso 1: Eliminar la restricción de clave foránea si existe
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Actividades_Profesores_ResponsableId')
BEGIN
    PRINT 'Eliminando FK_Actividades_Profesores_ResponsableId...';
    ALTER TABLE Actividades DROP CONSTRAINT FK_Actividades_Profesores_ResponsableId;
END

-- Paso 2: Eliminar el índice si existe
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Actividades_ResponsableId' AND object_id = OBJECT_ID('Actividades'))
BEGIN
    PRINT 'Eliminando índice IX_Actividades_ResponsableId...';
    DROP INDEX IX_Actividades_ResponsableId ON Actividades;
END

-- Paso 3: Crear una nueva columna temporal
PRINT 'Creando columna temporal ResponsableId_New...';
ALTER TABLE Actividades ADD ResponsableId_New UNIQUEIDENTIFIER NULL;
GO

-- Paso 4: Migrar los datos existentes (convertir VARCHAR a UNIQUEIDENTIFIER)
PRINT 'Migrando datos de ResponsableId a ResponsableId_New...';
UPDATE Actividades 
SET ResponsableId_New = TRY_CAST(ResponsableId AS UNIQUEIDENTIFIER)
WHERE ResponsableId IS NOT NULL AND ResponsableId <> '';
GO

-- Paso 5: Eliminar la columna antigua
PRINT 'Eliminando columna antigua ResponsableId...';
ALTER TABLE Actividades DROP COLUMN ResponsableId;
GO

-- Paso 6: Renombrar la columna nueva
PRINT 'Renombrando ResponsableId_New a ResponsableId...';
EXEC sp_rename 'Actividades.ResponsableId_New', 'ResponsableId', 'COLUMN';
GO

-- Paso 7: Crear el índice
PRINT 'Creando índice IX_Actividades_ResponsableId...';
CREATE INDEX IX_Actividades_ResponsableId ON Actividades(ResponsableId);
GO

-- Paso 8: Agregar la restricción de clave foránea
PRINT 'Agregando FK_Actividades_Profesores_ResponsableId...';
ALTER TABLE Actividades 
ADD CONSTRAINT FK_Actividades_Profesores_ResponsableId 
FOREIGN KEY (ResponsableId) 
REFERENCES Profesores(Uuid)
ON DELETE SET NULL;
GO

-- Verificar la estructura
PRINT 'Verificando estructura de la tabla...';
SELECT 
    c.name AS ColumnName,
    t.name AS DataType,
    c.max_length AS MaxLength,
    c.is_nullable AS IsNullable
FROM sys.columns c
INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('Actividades')
AND c.name = 'ResponsableId';
GO

-- Verificar los datos migrados
PRINT 'Verificando datos migrados...';
SELECT 
    COUNT(*) AS TotalActividades,
    COUNT(ResponsableId) AS ActividadesConResponsable
FROM Actividades;
GO

PRINT 'Migración completada exitosamente!';

