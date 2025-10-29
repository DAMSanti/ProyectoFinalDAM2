-- ==========================================
-- MIGRACIÓN: Responsable en Actividades y Departamento en Profesores
-- Fecha: 2025-10-29
-- ==========================================
-- CAMBIOS:
-- 1. En Actividades: departamentoId -> ResponsableId (FK a Profesores)
-- 2. En Profesores: Agregar departamentoId (FK a Departamentos)
-- ==========================================

USE ACEX;
GO

-- ==========================================
-- PASO 1: Agregar columna ResponsableId en Actividades (temporal, nullable)
-- ==========================================
PRINT 'Paso 1: Agregando columna ResponsableId en Actividades...';

ALTER TABLE Actividades
ADD ResponsableId VARCHAR(50) NULL;
GO

-- ==========================================
-- PASO 2: Copiar datos de departamentoId a ResponsableId
-- ==========================================
PRINT 'Paso 2: Migrando datos del responsable (si existe SolicitanteId, usarlo como ResponsableId)...';

-- Si existe SolicitanteId, copiarlo a ResponsableId
UPDATE Actividades
SET ResponsableId = SolicitanteId
WHERE SolicitanteId IS NOT NULL;
GO

-- ==========================================
-- PASO 3: Eliminar la columna departamentoId de Actividades
-- ==========================================
PRINT 'Paso 3: Eliminando columna departamentoId de Actividades...';

-- Primero eliminar la restricción de FK si existe
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Actividades_Departamentos')
BEGIN
    ALTER TABLE Actividades DROP CONSTRAINT FK_Actividades_Departamentos;
    PRINT '  - FK_Actividades_Departamentos eliminada';
END
GO

-- Eliminar la columna
ALTER TABLE Actividades
DROP COLUMN departamentoId;
GO

-- ==========================================
-- PASO 4: Agregar departamentoId a la tabla Profesores
-- ==========================================
PRINT 'Paso 4: Agregando columna departamentoId en Profesores...';

ALTER TABLE Profesores
ADD departamentoId INT NULL;
GO

-- ==========================================
-- PASO 5: Crear Foreign Keys
-- ==========================================
PRINT 'Paso 5: Creando Foreign Keys...';

-- FK de Actividades.ResponsableId -> Profesores.uuid
ALTER TABLE Actividades
ADD CONSTRAINT FK_Actividades_ResponsableProfesor 
FOREIGN KEY (ResponsableId) REFERENCES Profesores(uuid)
ON DELETE SET NULL;
PRINT '  - FK_Actividades_ResponsableProfesor creada';
GO

-- FK de Profesores.departamentoId -> Departamentos.id
ALTER TABLE Profesores
ADD CONSTRAINT FK_Profesores_Departamentos 
FOREIGN KEY (departamentoId) REFERENCES Departamentos(id)
ON DELETE SET NULL;
PRINT '  - FK_Profesores_Departamentos creada';
GO

-- ==========================================
-- PASO 6: Asignar departamentos a profesores existentes (opcional)
-- ==========================================
PRINT 'Paso 6: Asignando departamentos a profesores existentes...';

-- Ejemplo: Asignar el departamento 1 (ajusta según tus datos)
-- UPDATE Profesores
-- SET departamentoId = 1
-- WHERE departamentoId IS NULL;

PRINT 'Nota: Los profesores existentes tienen departamentoId = NULL';
PRINT 'Debes asignarlos manualmente o mediante otro script';
GO

-- ==========================================
-- VERIFICACIÓN
-- ==========================================
PRINT '';
PRINT '==========================================';
PRINT 'VERIFICACIÓN DE CAMBIOS';
PRINT '==========================================';

-- Verificar estructura de Actividades
PRINT 'Columnas de Actividades:';
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Actividades'
AND COLUMN_NAME IN ('ResponsableId', 'departamentoId', 'SolicitanteId');

-- Verificar estructura de Profesores
PRINT '';
PRINT 'Columnas de Profesores:';
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Profesores'
AND COLUMN_NAME IN ('departamentoId', 'uuid');

-- Verificar FKs
PRINT '';
PRINT 'Foreign Keys creadas:';
SELECT 
    fk.name AS FK_Name,
    tp.name AS Parent_Table,
    cp.name AS Parent_Column,
    tr.name AS Referenced_Table,
    cr.name AS Referenced_Column
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.tables AS tp ON fkc.parent_object_id = tp.object_id
INNER JOIN sys.columns AS cp ON fkc.parent_object_id = cp.object_id AND fkc.parent_column_id = cp.column_id
INNER JOIN sys.tables AS tr ON fkc.referenced_object_id = tr.object_id
INNER JOIN sys.columns AS cr ON fkc.referenced_object_id = cr.object_id AND fkc.referenced_column_id = cr.column_id
WHERE fk.name IN ('FK_Actividades_ResponsableProfesor', 'FK_Profesores_Departamentos');

PRINT '';
PRINT '==========================================';
PRINT 'MIGRACIÓN COMPLETADA EXITOSAMENTE';
PRINT '==========================================';
GO
