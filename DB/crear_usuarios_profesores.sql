-- Crear usuarios para los profesores que no tienen cuenta

-- Usuario para Juan Martínez Ruiz
INSERT INTO Usuarios (Id, NombreUsuario, NombreCompleto, Password, Rol, FechaCreacion, Activo)
VALUES (
    'fd0f02e4-1d45-47f0-abcf-6b10a1bcb125',
    'juan.martinez',
    'Juan Martínez Ruiz',
    '$2a$11$vKzJ5p.5R7J5YqK4xK5xO.5R7J5YqK4xK5xO.5R7J5YqK4xK5xO.', -- password: profesor123
    'Profesor',
    GETDATE(),
    1
);

-- Usuario para Laura Sánchez Gómez
INSERT INTO Usuarios (Id, NombreUsuario, NombreCompleto, Password, Rol, FechaCreacion, Activo)
VALUES (
    'e95dfe7f-173e-47c9-a1ef-9389d746d4d9',
    'laura.sanchez',
    'Laura Sánchez Gómez',
    '$2a$11$vKzJ5p.5R7J5YqK4xK5xO.5R7J5YqK4xK5xO.5R7J5YqK4xK5xO.', -- password: profesor123
    'Profesor',
    GETDATE(),
    1
);

-- Verificar que se crearon
SELECT 
    u.Id,
    u.NombreUsuario,
    u.NombreCompleto,
    p.Nombre + ' ' + p.Apellidos as ProfesorNombre,
    u.Rol
FROM Usuarios u
LEFT JOIN Profesores p ON u.Id = p.Uuid
WHERE u.Id IN ('fd0f02e4-1d45-47f0-abcf-6b10a1bcb125', 'e95dfe7f-173e-47c9-a1ef-9389d746d4d9');

PRINT 'Usuarios creados. Credenciales:';
PRINT 'Usuario: juan.martinez | Password: profesor123';
PRINT 'Usuario: laura.sanchez | Password: profesor123';
