-- =======================================================================
-- MIGRACIÓN: Crear tabla Alojamientos y actualizar Actividades
-- Fecha: 2025-10-27
-- Descripción: Crea una tabla separada para gestionar alojamientos con
--              información completa (nombre, dirección, teléfono, etc.)
--              y actualiza Actividades para usar AlojamientoId
-- =======================================================================

USE ACEXAPI;
GO

-- 1. Crear tabla Alojamientos
CREATE TABLE Alojamientos (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(200) NOT NULL,
    Direccion NVARCHAR(300) NULL,
    Ciudad NVARCHAR(100) NULL,
    CodigoPostal NVARCHAR(20) NULL,
    Provincia NVARCHAR(100) NULL,
    Telefono NVARCHAR(20) NULL,
    Email NVARCHAR(200) NULL,
    Web NVARCHAR(MAX) NULL,
    TipoAlojamiento NVARCHAR(50) NULL, -- Hotel, Hostal, Albergue, Casa Rural, etc.
    NumeroHabitaciones INT NULL,
    CapacidadTotal INT NULL,
    PrecioPorNoche DECIMAL(10,2) NULL,
    Servicios NVARCHAR(1000) NULL, -- WiFi, Desayuno, Parking, etc.
    Observaciones NVARCHAR(1000) NULL,
    Activo BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 NOT NULL DEFAULT GETDATE(),
    Latitud DECIMAL(10,7) NULL,
    Longitud DECIMAL(10,7) NULL
);
GO

-- 2. Migrar datos existentes: Crear alojamientos desde nombre_alojamiento
-- Solo si hay actividades con nombre de alojamiento
IF EXISTS (SELECT 1 FROM Actividades WHERE nombre_alojamiento IS NOT NULL)
BEGIN
    -- Insertar alojamientos únicos desde los nombres existentes
    INSERT INTO Alojamientos (Nombre, PrecioPorNoche, Activo, FechaCreacion)
    SELECT DISTINCT 
        nombre_alojamiento,
        precio_alojamiento,
        1,
        GETDATE()
    FROM Actividades
    WHERE nombre_alojamiento IS NOT NULL;

    PRINT 'Alojamientos migrados desde nombres existentes';
END
GO

-- 3. Agregar columna AlojamientoId a Actividades
ALTER TABLE Actividades
ADD AlojamientoId INT NULL;
GO

-- 4. Actualizar referencias: Asignar AlojamientoId basado en nombre_alojamiento
UPDATE a
SET a.AlojamientoId = al.Id
FROM Actividades a
INNER JOIN Alojamientos al ON a.nombre_alojamiento = al.Nombre
WHERE a.nombre_alojamiento IS NOT NULL;
GO

-- 5. Crear foreign key
ALTER TABLE Actividades
ADD CONSTRAINT FK_Actividades_Alojamientos
FOREIGN KEY (AlojamientoId) REFERENCES Alojamientos(Id)
ON DELETE SET NULL;
GO

-- 6. Eliminar columnas antiguas de Actividades
ALTER TABLE Actividades
DROP COLUMN IF EXISTS nombre_alojamiento;

ALTER TABLE Actividades
DROP COLUMN IF EXISTS precio_alojamiento;
GO

-- 7. Insertar algunos alojamientos de ejemplo
INSERT INTO Alojamientos (Nombre, Direccion, Ciudad, Provincia, Telefono, TipoAlojamiento, CapacidadTotal, PrecioPorNoche, Servicios, Activo)
VALUES 
    ('Hotel Escolar Madrid', 'Calle Gran Vía 28', 'Madrid', 'Madrid', '910123456', 'Hotel', 100, 45.00, 'WiFi, Desayuno incluido, Parking', 1),
    ('Albergue Juvenil Barcelona', 'Paseo Marítimo 15', 'Barcelona', 'Barcelona', '931234567', 'Albergue', 60, 25.00, 'WiFi, Cocina compartida', 1),
    ('Casa Rural El Pinar', 'Carretera Nacional km 23', 'Cuenca', 'Cuenca', '969876543', 'Casa Rural', 30, 35.00, 'WiFi, Comedor, Jardín', 1),
    ('Hostal Centro Sevilla', 'Calle Sierpes 45', 'Sevilla', 'Sevilla', '954321098', 'Hostal', 40, 30.00, 'WiFi, Aire acondicionado', 1);
GO

-- 8. Verificar la migración
PRINT '================================================';
PRINT 'VERIFICACIÓN DE LA MIGRACIÓN';
PRINT '================================================';

-- Contar alojamientos
DECLARE @TotalAlojamientos INT;
SELECT @TotalAlojamientos = COUNT(*) FROM Alojamientos;
PRINT 'Total de alojamientos creados: ' + CAST(@TotalAlojamientos AS VARCHAR(10));

-- Contar actividades con alojamiento asignado
DECLARE @ActividadesConAlojamiento INT;
SELECT @ActividadesConAlojamiento = COUNT(*) FROM Actividades WHERE AlojamientoId IS NOT NULL;
PRINT 'Actividades con alojamiento asignado: ' + CAST(@ActividadesConAlojamiento AS VARCHAR(10));

-- Mostrar estructura de la nueva tabla
PRINT '';
PRINT 'Estructura de tabla Alojamientos:';
SELECT 
    COLUMN_NAME as Columna,
    DATA_TYPE as Tipo,
    IS_NULLABLE as Nullable
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Alojamientos'
ORDER BY ORDINAL_POSITION;

-- Mostrar algunos alojamientos de ejemplo
PRINT '';
PRINT 'Primeros alojamientos registrados:';
SELECT TOP 5
    Id,
    Nombre,
    Ciudad,
    TipoAlojamiento,
    PrecioPorNoche
FROM Alojamientos
ORDER BY Id;

PRINT '';
PRINT '================================================';
PRINT 'MIGRACIÓN COMPLETADA EXITOSAMENTE';
PRINT '================================================';
GO
