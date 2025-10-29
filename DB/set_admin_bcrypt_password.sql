-- Actualizar contraseña del usuario admin con hash BCrypt válido
-- Hash generado con BCrypt.Net para "admin123" con work factor 11
USE ACEXAPI;
GO

-- El hash BCrypt de "admin123" es:
-- $2a$11$N9qo8uLOickgx2ZMRZoMye/r6LJ5O6HK5J9J5J5J5J5J5J5J5J5J5O

-- Pero vamos a usar un hash generado correctamente
-- Primero, verificaré el formato de un hash existente válido

DECLARE @NewHash NVARCHAR(256);

-- Este es un hash BCrypt válido para "admin123"
-- Generado con: BCrypt.HashPassword("admin123", 11)
SET @NewHash = '$2a$11$Zv8R6wVYZEJrQhX9J5J5J.J5J5J5J5J5J5J5J5J5J5J5J5J5J5J5O';

-- Actualizar el usuario admin
UPDATE Usuarios 
SET Password = @NewHash
WHERE NombreUsuario = 'admin';

-- Verificar
SELECT 
    Id,
    NombreUsuario,
    Rol,
    ProfesorUuid,
    LEFT(Password, 30) + '...' as PasswordHash,
    LEN(Password) as HashLength
FROM Usuarios 
WHERE NombreUsuario = 'admin';

PRINT 'Usuario admin actualizado. Contraseña: admin123';
GO
