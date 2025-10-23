-- Script para crear usuario de prueba en ACEXAPI
-- La contraseña "admin123" está hasheada con BCrypt

USE ProyectoACEX;  -- Cambia esto por el nombre de tu base de datos
GO

-- Eliminar usuario de prueba si existe
DELETE FROM Usuarios WHERE Email = 'admin@acexapi.com';
GO

-- Crear usuario administrador de prueba
-- Email: admin@acexapi.com
-- Password: admin123
-- Hash BCrypt generado: (debes generar uno usando BCrypt)
INSERT INTO Usuarios (Id, Email, NombreCompleto, Password, Rol, FechaCreacion, Activo)
VALUES (
    NEWID(),
    'admin@acexapi.com',
    'Administrador ACEX',
    '$2a$11$XZ4QJ5Z5Z5Z5Z5Z5Z5Z5ZuXXXXXXXXXXXXXXXXXXXXXXXXXXX',  -- REEMPLAZAR con hash real
    'Administrador',
    GETUTCDATE(),
    1
);
GO

-- Verificar que se creó
SELECT * FROM Usuarios WHERE Email = 'admin@acexapi.com';
GO

-- INSTRUCCIONES PARA GENERAR EL HASH:
-- 1. En C#, ejecuta:
--    using BCrypt.Net;
--    var hash = BCrypt.Net.BCrypt.HashPassword("admin123");
--    Console.WriteLine(hash);
-- 2. Reemplaza el hash en este script con el generado
-- 3. Ejecuta este script en SQL Server Management Studio o Azure Data Studio
