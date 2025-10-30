-- Vincular usuarios con profesores existentes
-- NO tocamos admin porque ya tiene token FCM registrado
-- El resto de usuarios se vinculan a profesores de la BD

BEGIN TRANSACTION;

-- Verificar estado actual
SELECT 'ANTES DEL CAMBIO' as Estado, Id, NombreUsuario FROM Usuarios WHERE NombreUsuario != 'admin';

-- 1. Santi → Juan Martínez Ruiz
UPDATE Usuarios 
SET Id = 'fd0f02e4-1d45-47f0-abcf-6b10a1bcb125'
WHERE NombreUsuario = 'Santi';

-- 2. ProfesorDemo → Laura Sánchez Gómez
UPDATE Usuarios 
SET Id = 'e95dfe7f-173e-47c9-a1ef-9389d746d4d9'
WHERE NombreUsuario = 'ProfesorDemo';

-- 3. CoordinadorDemo → María García López
UPDATE Usuarios 
SET Id = '5aab0feb-6eeb-4307-9151-04514e2fc145'
WHERE NombreUsuario = 'CoordinadorDemo';

-- 4. AdministradorACEX → Roberto Díaz Martín
UPDATE Usuarios 
SET Id = 'fa7e6f09-947e-49e3-9e3b-3e77b2d9d798'
WHERE NombreUsuario = 'AdministradorACEX';

-- 5. UsuarioDemo → Ana Fernández Sanz
UPDATE Usuarios 
SET Id = '503a4110-361f-422e-80c6-4a7870ac32bb'
WHERE NombreUsuario = 'UsuarioDemo';

-- Verificar los cambios
SELECT 'DESPUÉS DEL CAMBIO' as Estado,
    u.Id,
    u.NombreUsuario,
    p.Nombre + ' ' + p.Apellidos as ProfesorVinculado,
    p.Correo as ProfesorEmail
FROM Usuarios u
LEFT JOIN Profesores p ON u.Id = p.Uuid
ORDER BY u.NombreUsuario;

PRINT '';
PRINT '✓ Usuarios vinculados con profesores (excepto admin)';
PRINT '';
PRINT '⚠️  Consecuencias:';
PRINT '   - Estos usuarios perderán sus tokens FCM antiguos';
PRINT '   - Deberán volver a iniciar sesión para registrar nuevos tokens';
PRINT '   - Las actividades 27 ahora podrán enviar notificaciones correctamente';
PRINT '';
PRINT '✅ Si todo está correcto, ejecuta: COMMIT;';
PRINT '❌ Si hay error, ejecuta: ROLLBACK;';

-- Descomentar la siguiente línea para aplicar los cambios:
-- COMMIT;
