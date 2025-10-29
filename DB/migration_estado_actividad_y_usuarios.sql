-- ==========================================
-- MIGRACIÓN: Estado en Actividades y ajustes en Usuarios
-- Fecha: 2025-10-29
-- ==========================================
-- CAMBIOS:
-- 1. En Actividades: Aprobada (bit) -> Estado (varchar) con valores enum
-- 2. En Usuarios: Eliminar Correo, cambiar NombreCompleto a NombreUsuario
-- ==========================================

USE ACEX;
GO

-- ==========================================
-- PASO 1: Agregar columna Estado en Actividades (temporal, nullable)
-- ==========================================
PRINT 'Paso 1: Agregando columna Estado en Actividades...';

ALTER TABLE Actividades
ADD Estado VARCHAR(20) NULL;
GO

-- ==========================================
-- PASO 2: Migrar datos de Aprobada a Estado
-- ==========================================
PRINT 'Paso 2: Migrando datos de Aprobada a Estado...';

UPDATE Actividades
SET Estado = CASE 
    WHEN Aprobada = 1 THEN 'Aprobada'
    ELSE 'Pendiente'
END;
GO

-- ==========================================
-- PASO 3: Hacer Estado NOT NULL con valor por defecto
-- ==========================================
PRINT 'Paso 3: Configurando Estado como NOT NULL con valor por defecto...';

ALTER TABLE Actividades
ALTER COLUMN Estado VARCHAR(20) NOT NULL;
GO

ALTER TABLE Actividades
ADD CONSTRAINT DF_Actividades_Estado DEFAULT 'Pendiente' FOR Estado;
GO

-- ==========================================
-- PASO 4: Eliminar columna Aprobada
-- ==========================================
PRINT 'Paso 4: Eliminando columna Aprobada de Actividades...';

-- Eliminar constraint por defecto si existe
IF EXISTS (SELECT * FROM sys.default_constraints WHERE name = 'DF_Actividades_Aprobada')
BEGIN
    ALTER TABLE Actividades DROP CONSTRAINT DF_Actividades_Aprobada;
    PRINT '  - DF_Actividades_Aprobada eliminado';
END
GO

ALTER TABLE Actividades
DROP COLUMN Aprobada;
GO

-- ==========================================
-- PASO 5: Agregar constraint CHECK para valores válidos de Estado
-- ==========================================
PRINT 'Paso 5: Agregando constraint CHECK para Estado...';

ALTER TABLE Actividades
ADD CONSTRAINT CK_Actividades_Estado 
CHECK (Estado IN ('Pendiente', 'Aprobada', 'Cancelada'));
GO

-- ==========================================
-- PASO 6: Modificar tabla Usuarios
-- ==========================================
PRINT 'Paso 6: Modificando tabla Usuarios...';

-- Verificar si existe la columna Correo y eliminarla
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'Usuarios' AND COLUMN_NAME = 'Correo')
BEGIN
    ALTER TABLE Usuarios DROP COLUMN Correo;
    PRINT '  - Columna Correo eliminada';
END
GO

-- Verificar si existe NombreCompleto y renombrarla a NombreUsuario
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'Usuarios' AND COLUMN_NAME = 'NombreCompleto')
BEGIN
    EXEC sp_rename 'Usuarios.NombreCompleto', 'NombreUsuario', 'COLUMN';
    PRINT '  - Columna NombreCompleto renombrada a NombreUsuario';
END
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
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Actividades'
AND COLUMN_NAME IN ('Estado', 'Aprobada');

-- Verificar constraint CHECK
PRINT '';
PRINT 'Constraints CHECK de Actividades:';
SELECT 
    cc.name AS ConstraintName,
    cc.definition AS CheckDefinition
FROM sys.check_constraints AS cc
INNER JOIN sys.tables AS t ON cc.parent_object_id = t.object_id
WHERE t.name = 'Actividades';

-- Verificar estructura de Usuarios
PRINT '';
PRINT 'Columnas de Usuarios:';
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Usuarios'
AND COLUMN_NAME IN ('NombreUsuario', 'NombreCompleto', 'Correo');

-- Verificar datos migrados
PRINT '';
PRINT 'Distribución de Estados en Actividades:';
SELECT Estado, COUNT(*) AS Cantidad
FROM Actividades
GROUP BY Estado;

PRINT '';
PRINT '==========================================';
PRINT 'MIGRACIÓN COMPLETADA EXITOSAMENTE';
PRINT '==========================================';
GO
