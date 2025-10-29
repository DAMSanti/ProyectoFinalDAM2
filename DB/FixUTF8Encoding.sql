-- Corregir codificación UTF-8 de actividades
USE ACEXAPI;
GO

-- Usar el prefijo N para Unicode
UPDATE Actividades SET Nombre = N'Jornada de Orientación Académica' WHERE Id = 32;
UPDATE Actividades SET Nombre = N'Torneo de Fútbol Sala' WHERE Id = 33;
UPDATE Actividades SET Nombre = N'Excursión a Parque Natural' WHERE Id = 31;

-- Verificar
SELECT Id, Nombre FROM Actividades WHERE Id IN (31, 32, 33);
GO
