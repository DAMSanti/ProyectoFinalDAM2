-- Limpiar participantes inválidos de la actividad 27
DELETE FROM ProfParticipantes WHERE ActividadId = 27;

-- Agregar usuarios REALES como participantes
-- Admin (ya tiene token registrado)
INSERT INTO ProfParticipantes (ActividadId, ProfesorUuid) 
VALUES (27, '1df7ee96-59fb-4031-9749-a06436863fd2');

-- Santi (existe pero necesita iniciar sesión para registrar token)
INSERT INTO ProfParticipantes (ActividadId, ProfesorUuid) 
VALUES (27, 'e2e54c18-45c7-45ef-a319-0de21bb34223');

-- Verificar
SELECT 
    pp.ProfesorUuid, 
    u.NombreUsuario,
    CASE WHEN t.Token IS NOT NULL THEN 'SI' ELSE 'NO' END as TieneToken
FROM ProfParticipantes pp
LEFT JOIN Usuarios u ON pp.ProfesorUuid = u.Id
LEFT JOIN FcmTokens t ON u.Id = t.UsuarioId AND t.Activo = 1
WHERE pp.ActividadId = 27;
