/*
  MIGRACIÓN: Agregar columna Tipo a Actividades
  Fecha: 2024-10-29
  Descripción: 
    - Agregar columna Tipo (VARCHAR(20)) a tabla Actividades
    - Valores permitidos: 'Extraescolar', 'Complementaria'
    - Valor por defecto: 'Complementaria'
    - Actualizar actividades existentes con diferentes tipos
    - Marcar algunas actividades como Canceladas
*/

USE ACEXAPI;
GO

PRINT '==========================================';
PRINT 'INICIANDO MIGRACIÓN: Agregar Tipo a Actividades';
PRINT '==========================================';
PRINT '';

-- Paso 1: Agregar columna Tipo
PRINT 'Paso 1: Agregando columna Tipo en Actividades...';
ALTER TABLE Actividades ADD Tipo VARCHAR(20) NULL;
GO

-- Paso 2: Establecer valores por defecto para actividades existentes
-- Distribuir entre Extraescolar y Complementaria
PRINT 'Paso 2: Asignando valores de Tipo a actividades existentes...';

-- Obtener IDs de actividades
DECLARE @ids TABLE (Id INT, RowNum INT);
INSERT INTO @ids (Id, RowNum)
SELECT Id, ROW_NUMBER() OVER (ORDER BY FechaCreacion) as RowNum
FROM Actividades;

-- Asignar Extraescolar a actividades impares, Complementaria a pares
UPDATE a
SET Tipo = CASE 
    WHEN t.RowNum % 2 = 1 THEN 'Extraescolar'
    ELSE 'Complementaria'
END
FROM Actividades a
INNER JOIN @ids t ON a.Id = t.Id;

PRINT '  - ' + CAST(@@ROWCOUNT AS VARCHAR) + ' actividades actualizadas';
GO

-- Paso 3: Hacer la columna NOT NULL con valor por defecto
PRINT 'Paso 3: Configurando Tipo como NOT NULL con valor por defecto...';
ALTER TABLE Actividades ALTER COLUMN Tipo VARCHAR(20) NOT NULL;
ALTER TABLE Actividades ADD CONSTRAINT DF_Actividades_Tipo DEFAULT 'Complementaria' FOR Tipo;
GO

-- Paso 4: Agregar constraint CHECK
PRINT 'Paso 4: Agregando constraint CHECK para Tipo...';
ALTER TABLE Actividades ADD CONSTRAINT CK_Actividades_Tipo 
    CHECK (Tipo IN ('Extraescolar', 'Complementaria'));
GO

-- Paso 5: Actualizar algunas actividades a estado Cancelada
PRINT 'Paso 5: Marcando algunas actividades como Canceladas...';

-- Cancelar 2 actividades (aproximadamente 20% del total)
UPDATE TOP (2) Actividades
SET Estado = 'Cancelada'
WHERE Estado = 'Pendiente';

PRINT '  - ' + CAST(@@ROWCOUNT AS VARCHAR) + ' actividades marcadas como Canceladas';
GO

PRINT '';
PRINT '==========================================';
PRINT 'VERIFICACIÓN DE CAMBIOS';
PRINT '==========================================';

-- Verificar columna Tipo
PRINT 'Columna Tipo de Actividades:';
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Actividades' AND COLUMN_NAME = 'Tipo';

PRINT '';

-- Verificar constraint CHECK de Tipo
PRINT 'Constraints CHECK de Actividades (Tipo):';
SELECT 
    name as ConstraintName,
    definition as CheckDefinition
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('Actividades')
    AND name LIKE '%Tipo%';

PRINT '';

-- Distribución de Tipos
PRINT 'Distribución de Tipos en Actividades:';
SELECT Tipo, COUNT(*) as Cantidad
FROM Actividades
GROUP BY Tipo
ORDER BY Tipo;

PRINT '';

-- Distribución de Estados (incluyendo Canceladas)
PRINT 'Distribución de Estados en Actividades:';
SELECT Estado, COUNT(*) as Cantidad
FROM Actividades
GROUP BY Estado
ORDER BY Estado;

PRINT '';

-- Ejemplos de actividades con Tipo y Estado
PRINT 'Ejemplos de actividades con Tipo y Estado:';
SELECT TOP 10
    Id,
    Nombre,
    Tipo,
    Estado,
    FechaInicio
FROM Actividades
ORDER BY Id;

PRINT '';
PRINT '==========================================';
PRINT 'MIGRACIÓN COMPLETADA EXITOSAMENTE';
PRINT '==========================================';
PRINT '';
PRINT 'RESUMEN:';
PRINT '  - Columna Tipo agregada con valores: Extraescolar, Complementaria';
PRINT '  - Constraint CHECK aplicado';
PRINT '  - Actividades distribuidas entre tipos';
PRINT '  - Algunas actividades marcadas como Canceladas';
PRINT '';

GO

-- ROLLBACK (si es necesario revertir)
/*
PRINT 'ROLLBACK: Eliminando columna Tipo...';
ALTER TABLE Actividades DROP CONSTRAINT CK_Actividades_Tipo;
ALTER TABLE Actividades DROP CONSTRAINT DF_Actividades_Tipo;
ALTER TABLE Actividades DROP COLUMN Tipo;
PRINT 'Rollback completado';
*/
