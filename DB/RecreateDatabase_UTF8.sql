-- Script para recrear la base de datos ACEXAPI con collation UTF-8
-- Ejecutar desde SQLCMD o SQL Server Management Studio

USE master;
GO

-- Cerrar todas las conexiones activas a la base de datos
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ACEXAPI')
BEGIN
    ALTER DATABASE ACEXAPI SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ACEXAPI;
END
GO

-- Crear la base de datos con collation Latin1_General_100_CI_AS_SC_UTF8
-- Esta collation soporta UTF-8 nativamente
CREATE DATABASE ACEXAPI
COLLATE Latin1_General_100_CI_AS_SC_UTF8;
GO

USE ACEXAPI;
GO

PRINT 'Base de datos ACEXAPI recreada con collation UTF-8';
PRINT 'Ejecuta ahora las migraciones de Entity Framework para crear las tablas';
GO
