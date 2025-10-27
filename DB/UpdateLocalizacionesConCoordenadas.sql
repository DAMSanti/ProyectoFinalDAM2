-- Script para actualizar las localizaciones existentes con coordenadas

USE ACEXDB;
GO

-- Actualizar Museo de Ciencias (Santander)
UPDATE Localizaciones
SET Latitud = 43.4623, Longitud = -3.8099
WHERE Nombre = 'Museo de Ciencias' AND Ciudad = 'Santander';

-- Actualizar Torrelavega
UPDATE Localizaciones
SET Latitud = 43.3506, Longitud = -4.0462
WHERE Nombre = 'Torrelavega' AND Ciudad = 'Torrelavega';

-- Verificar las actualizaciones
SELECT Id, Nombre, Ciudad, Latitud, Longitud, EsPrincipal, Icono
FROM Localizaciones
WHERE Latitud IS NOT NULL OR Longitud IS NOT NULL;

GO
