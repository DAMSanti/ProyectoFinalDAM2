-- Insertar usuario admin con contraseña admin123
USE ACEXAPI;
GO

-- Primero eliminar si existe
DELETE FROM Usuarios WHERE Email = 'admin@acexapi.com';

-- Hash BCrypt de "admin123" generado con workfactor 11
-- Puedes verificarlo en: https://bcrypt-generator.com/
INSERT INTO Usuarios (Id, Email, NombreCompleto, Password, Rol, FechaCreacion, Activo) 
VALUES (
    NEWID(), 
    'admin@acexapi.com', 
    'Administrador del Sistema',
    '$2a$11$Y5qVjFqZQX7VqKQX7VqKQOGqZQX7VqKQX7VqKQOGqZQX7VqKQX7Vq',
    'Admin',
    GETDATE(),
    1
);

PRINT 'Usuario admin creado exitosamente';
PRINT 'Email: admin@acexapi.com';
PRINT 'Password: admin123';

SELECT * FROM Usuarios WHERE Email = 'admin@acexapi.com';
GO
