-- Verificar datos de alojamiento en la actividad 1028
USE ACEXAPI;
GO

-- Ver todas las columnas de la actividad 1028
SELECT 
    Id,
    Nombre,
    AlojamientoReq,
    AlojamientoId,
    precio_alojamiento,
    TransporteReq,
    EmpTransporteId,
    precio_transporte
FROM Actividades
WHERE Id = 1028;
GO

-- Ver si hay alojamientos en la tabla
SELECT TOP 5
    Id,
    Nombre,
    Ciudad
FROM Alojamientos
WHERE Activo = 1;
GO
