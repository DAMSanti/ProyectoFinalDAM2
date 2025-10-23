-- Script para insertar actividades de prueba en ACEXAPI
USE ACEXAPI;
GO

-- Insertar actividades futuras (para que aparezcan en el home)
INSERT INTO Actividades (Nombre, Descripcion, FechaInicio, FechaFin, PresupuestoEstimado, CostoReal, Aprobada, FechaCreacion)
VALUES 
    ('Excursión al Museo de Ciencias', 
     'Visita educativa al Museo de Ciencias con actividades interactivas para estudiantes.', 
     DATEADD(day, 7, GETDATE()), 
     DATEADD(day, 7, GETDATE()), 
     500.00, 
     NULL, 
     1, 
     GETDATE()),
    
    ('Taller de Robótica', 
     'Taller práctico de programación y construcción de robots para estudiantes de secundaria.', 
     DATEADD(day, 14, GETDATE()), 
     DATEADD(day, 16, GETDATE()), 
     800.00, 
     NULL, 
     1, 
     GETDATE()),
    
    ('Campamento de Verano', 
     'Campamento educativo con actividades al aire libre, deportes y talleres creativos.', 
     DATEADD(day, 30, GETDATE()), 
     DATEADD(day, 37, GETDATE()), 
     3500.00, 
     NULL, 
     1, 
     GETDATE()),
    
    ('Conferencia de Tecnología', 
     'Conferencia sobre las últimas tendencias en inteligencia artificial y programación.', 
     DATEADD(day, 21, GETDATE()), 
     DATEADD(day, 21, GETDATE()), 
     1200.00, 
     NULL, 
     1, 
     GETDATE()),
    
    ('Excursión a la Playa', 
     'Día de convivencia en la playa con actividades deportivas y recreativas.', 
     DATEADD(day, 10, GETDATE()), 
     DATEADD(day, 10, GETDATE()), 
     600.00, 
     NULL, 
     1, 
     GETDATE()),
    
    ('Torneo Deportivo Interescolar', 
     'Competencia deportiva entre diferentes escuelas con varias disciplinas.', 
     DATEADD(day, 45, GETDATE()), 
     DATEADD(day, 47, GETDATE()), 
     2000.00, 
     NULL, 
     1, 
     GETDATE());

GO

-- Verificar las actividades insertadas
SELECT 
    Id, 
    Nombre, 
    Descripcion, 
    FechaInicio, 
    FechaFin, 
    PresupuestoEstimado, 
    Aprobada
FROM Actividades
ORDER BY FechaInicio;
GO
