-- Actualizar contraseña del usuario admin con hash BCrypt válido para "admin123"
USE ACEXAPI;
GO

UPDATE Usuarios 
SET Password = '$2a$11$okk61ntIWMmyLtnoum6YUu4loeXAWPYNcxYZK/eZTVDvjJJI54Ae2'
WHERE NombreUsuario = 'admin';
GO

-- Verificar la actualización
SELECT 
    Id,
    NombreUsuario,
    Rol,
    ProfesorUuid,
    LEFT(Password, 30) + '...' as PasswordHash,
    LEN(Password) as HashLength
FROM Usuarios 
WHERE NombreUsuario = 'admin';

PRINT '';
PRINT '✓ Contraseña actualizada correctamente';
PRINT '  Usuario: admin';
PRINT '  Contraseña: admin123';
PRINT '  Hash BCrypt generado con work factor 11';
GO
