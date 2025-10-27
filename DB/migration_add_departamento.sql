-- ============================================
-- SCRIPT DE MIGRACIÓN: Añadir departamento_id a actividades
-- Fecha: 2025-01-27
-- Descripción: Añade la columna departamento_id a la tabla actividades
--              Este script es idempotente (puede ejecutarse múltiples veces)
-- ============================================

USE proyecto;

-- Verificar si la columna ya existe antes de agregarla
SET @dbname = DATABASE();
SET @tablename = 'actividades';
SET @columnname = 'departamento_id';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE 
      TABLE_SCHEMA = @dbname
      AND TABLE_NAME = @tablename
      AND COLUMN_NAME = @columnname
  ) > 0,
  'SELECT "La columna departamento_id ya existe en la tabla actividades" AS mensaje;',
  'ALTER TABLE actividades ADD COLUMN departamento_id INT NULL AFTER solicitante_id, 
   ADD CONSTRAINT fk_actividades_departamentos FOREIGN KEY (departamento_id) 
   REFERENCES departamentos(id) ON UPDATE CASCADE ON DELETE SET NULL;'
));

PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Mensaje de confirmación
SELECT 'Migración completada: La tabla actividades ahora tiene la columna departamento_id' AS resultado;

-- ============================================
-- INSTRUCCIONES DE USO:
-- ============================================
-- 1. En el instituto: 
--    mysql -u root -p proyecto < migration_add_departamento.sql
--
-- 2. En casa:
--    mysql -u root -p proyecto < migration_add_departamento.sql
--
-- El script detectará automáticamente si la columna ya existe
-- y solo la creará si es necesario.
-- ============================================
