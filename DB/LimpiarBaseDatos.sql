-- Script para limpiar y repoblar la base de datos ACEXAPI con UTF-8
USE ACEXAPI;
GO

PRINT 'Limpiando base de datos...';

-- Deshabilitar constraints temporalmente
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';

-- Eliminar datos de todas las tablas (en orden inverso por dependencias)
DELETE FROM Fotos;
DELETE FROM Contratos;
DELETE FROM GrupoPartics;
DELETE FROM ProfParticipantes;
DELETE FROM ProfResponsables;
DELETE FROM Actividades;
DELETE FROM Grupos;
DELETE FROM Cursos;
DELETE FROM Profesores;
DELETE FROM EmpTransportes;
DELETE FROM Localizaciones;
DELETE FROM Departamentos;
DELETE FROM Usuarios;

-- Rehabilitar constraints
EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';

PRINT 'Base de datos limpiada correctamente';
PRINT '';
PRINT 'Ahora ejecuta el script de poblar datos...';
GO
