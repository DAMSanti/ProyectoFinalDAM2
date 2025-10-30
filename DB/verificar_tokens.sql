-- Verificar tokens FCM registrados
SELECT 
    u.NombreUsuario,
    t.Token,
    t.DeviceType,
    t.DeviceId,
    t.FechaCreacion,
    t.UltimaActualizacion,
    t.Activo
FROM FcmTokens t
LEFT JOIN Usuarios u ON t.UsuarioId = u.Id
ORDER BY t.FechaCreacion DESC;

-- Contar tokens activos
SELECT COUNT(*) as TokensActivos FROM FcmTokens WHERE Activo = 1;

-- Contar tokens por dispositivo
SELECT DeviceType, COUNT(*) as Total 
FROM FcmTokens 
WHERE Activo = 1 
GROUP BY DeviceType;
