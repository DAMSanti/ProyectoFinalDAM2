-- =============================================
-- Script: Prueba de Conexión Rápida
-- Descripción: Ejecuta esto primero para verificar que puedes conectarte
-- =============================================

-- Información del servidor
SELECT 
    @@SERVERNAME AS 'Nombre del Servidor',
    @@VERSION AS 'Versión de SQL Server',
    SERVERPROPERTY('ProductVersion') AS 'Versión del Producto',
    SERVERPROPERTY('ProductLevel') AS 'Service Pack',
    SERVERPROPERTY('Edition') AS 'Edición',
    GETDATE() AS 'Fecha y Hora del Servidor';

-- Usuario actual
SELECT 
    SYSTEM_USER AS 'Usuario del Sistema',
    SUSER_NAME() AS 'Nombre del Usuario',
    IS_SRVROLEMEMBER('sysadmin') AS 'Es Administrador del Servidor (1=Sí)'
;

-- Bases de datos disponibles
SELECT 
    name AS 'Base de Datos',
    database_id AS 'ID',
    create_date AS 'Fecha de Creación',
    state_desc AS 'Estado'
FROM sys.databases
ORDER BY name;

PRINT '================================================';
PRINT 'Si ves esta información, la conexión funciona!';
PRINT '================================================';
PRINT 'Ahora puedes ejecutar: CreateDatabase.sql';
