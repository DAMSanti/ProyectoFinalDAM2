-- Script para habilitar y configurar el usuario 'sa'
-- Ejecutar en ambas instancias: SQLEXPRESS y SQLEXPRESS01

USE [master]
GO

-- Habilitar autenticacion mixta (SQL Server y Windows)
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', 
     N'Software\Microsoft\MSSQLServer\MSSQLServer',
     N'LoginMode', REG_DWORD, 2
GO

-- Habilitar usuario sa
ALTER LOGIN [sa] ENABLE
GO

-- Establecer contraseña para sa
ALTER LOGIN [sa] WITH PASSWORD = N'Semicrol_10'
GO

-- Verificar que sa esta habilitado
SELECT name, is_disabled 
FROM sys.server_principals 
WHERE name = 'sa'
GO

PRINT 'Usuario sa configurado correctamente!'
PRINT 'Usuario: sa'
PRINT 'Password: Semicrol_10'
GO
