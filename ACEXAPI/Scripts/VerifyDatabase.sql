-- =============================================
-- Script: Verificar Instalación y Conexión
-- Descripción: Script para verificar que todo está configurado correctamente
-- =============================================

-- 1. Verificar el nombre del servidor
PRINT '1. NOMBRE DEL SERVIDOR:';
SELECT @@SERVERNAME AS 'Nombre del Servidor';
GO

-- 2. Verificar la versión de SQL Server
PRINT '2. VERSIÓN DE SQL SERVER:';
SELECT @@VERSION AS 'Versión de SQL Server';
GO

-- 3. Verificar que la base de datos existe
PRINT '3. BASE DE DATOS ACEXAPI:';
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ACEXAPI')
BEGIN
    PRINT '   ? La base de datos ACEXAPI existe';
    
    USE ACEXAPI;
    
    -- 4. Contar tablas
    PRINT '4. TABLAS EN LA BASE DE DATOS:';
    SELECT 
        COUNT(*) AS 'Total de Tablas',
        (SELECT COUNT(*) FROM Departamentos) AS 'Departamentos',
        (SELECT COUNT(*) FROM Cursos) AS 'Cursos',
        (SELECT COUNT(*) FROM Grupos) AS 'Grupos',
        (SELECT COUNT(*) FROM Profesores) AS 'Profesores',
        (SELECT COUNT(*) FROM Localizaciones) AS 'Localizaciones',
        (SELECT COUNT(*) FROM EmpTransportes) AS 'EmpTransportes',
        (SELECT COUNT(*) FROM Actividades) AS 'Actividades',
        (SELECT COUNT(*) FROM Usuarios) AS 'Usuarios';
    
    -- 5. Listar todas las tablas
    PRINT '5. LISTA DE TABLAS:';
    SELECT 
        TABLE_NAME AS 'Tabla',
        TABLE_TYPE AS 'Tipo'
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_TYPE = 'BASE TABLE'
    ORDER BY TABLE_NAME;
    
    -- 6. Ver datos iniciales
    PRINT '6. DATOS INICIALES:';
    PRINT '   Departamentos:';
    SELECT * FROM Departamentos;
    
    PRINT '   Cursos:';
    SELECT * FROM Cursos;
    
END
ELSE
BEGIN
    PRINT '   ? La base de datos ACEXAPI NO existe';
    PRINT '   Por favor, ejecuta primero el script CreateDatabase.sql';
END
GO

-- 7. Verificar permisos del usuario actual
PRINT '7. USUARIO ACTUAL Y PERMISOS:';
SELECT 
    SYSTEM_USER AS 'Usuario del Sistema',
    USER_NAME() AS 'Usuario de la Base de Datos',
    IS_SRVROLEMEMBER('sysadmin') AS 'Es SysAdmin (1=Sí, 0=No)',
    HAS_DBACCESS('ACEXAPI') AS 'Tiene Acceso a ACEXAPI (1=Sí, 0=No)';
GO

PRINT '================================================';
PRINT 'Verificación completada';
PRINT '================================================';
