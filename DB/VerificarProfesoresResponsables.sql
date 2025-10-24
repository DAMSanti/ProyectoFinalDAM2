-- Verificar si hay profesores responsables asignados a las actividades
SELECT 
    a.Id AS ActividadId,
    a.Nombre AS ActividadNombre,
    a.Descripcion,
    a.FechaInicio,
    a.FechaFin,
    pr.EsCoordinador,
    p.Nombre AS ProfesorNombre,
    p.Apellidos AS ProfesorApellidos
FROM Actividades a
LEFT JOIN ProfResponsables pr ON a.Id = pr.ActividadId
LEFT JOIN Profesores p ON pr.ProfesorUuid = p.Uuid
WHERE a.Id IN (1028, 1029, 1030)
ORDER BY a.Id;
