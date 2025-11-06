-- Script para actualizar los códigos de los departamentos existentes
-- Fecha: 2025-11-06
-- Basado en los datos existentes en la BD

-- NOTA: Los códigos ya están en la base de datos según databaseExport.sql
-- Este script es por si se necesita volver a poblar o corregir

-- Actualizar códigos de departamentos (basado en los IDs conocidos)
UPDATE departamentos SET codigo = 'INF' WHERE id_depar = 1;  -- Informática
UPDATE departamentos SET codigo = 'ADM' WHERE id_depar = 2;  -- Administración y Gestión
UPDATE departamentos SET codigo = 'FAB' WHERE id_depar = 3;  -- Fabricación Mecánica
UPDATE departamentos SET codigo = 'MAT' WHERE id_depar = 4;  -- Matemáticas
UPDATE departamentos SET codigo = 'LEN' WHERE id_depar = 5;  -- Lengua y Literatura
UPDATE departamentos SET codigo = 'SOC' WHERE id_depar = 6;  -- Ciencias Sociales
UPDATE departamentos SET codigo = 'FYQ' WHERE id_depar = 7;  -- Física y Química
UPDATE departamentos SET codigo = 'EFI' WHERE id_depar = 8;  -- Educación Física
UPDATE departamentos SET codigo = 'BIO' WHERE id_depar = 9;  -- Biología y Geología
UPDATE departamentos SET codigo = 'ING' WHERE id_depar = 10; -- Inglés

-- Verificar los cambios
SELECT id_depar, codigo, nombre FROM departamentos ORDER BY id_depar;
