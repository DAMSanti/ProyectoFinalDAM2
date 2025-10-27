-- Script para crear tabla intermedia ActividadLocalizaciones
-- Permite relación muchos-a-muchos entre Actividades y Localizaciones

USE ACEXAPI;
GO

-- Crear la tabla intermedia
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ActividadLocalizaciones')
BEGIN
    CREATE TABLE ActividadLocalizaciones (
        Id INT PRIMARY KEY IDENTITY(1,1),
        ActividadId INT NOT NULL,
        LocalizacionId INT NOT NULL,
        EsPrincipal BIT NOT NULL DEFAULT 0,
        Orden INT NOT NULL DEFAULT 0,
        FechaAsignacion DATETIME2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_ActividadLocalizaciones_Actividad FOREIGN KEY (ActividadId) REFERENCES Actividades(Id) ON DELETE CASCADE,
        CONSTRAINT FK_ActividadLocalizaciones_Localizacion FOREIGN KEY (LocalizacionId) REFERENCES Localizaciones(Id) ON DELETE CASCADE,
        CONSTRAINT UQ_ActividadLocalizacion UNIQUE (ActividadId, LocalizacionId)
    );
    
    PRINT 'Tabla ActividadLocalizaciones creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla ActividadLocalizaciones ya existe';
END
GO

-- Migrar datos existentes de la columna LocalizacionId en Actividades
INSERT INTO ActividadLocalizaciones (ActividadId, LocalizacionId, EsPrincipal, Orden)
SELECT 
    Id as ActividadId,
    LocalizacionId,
    1 as EsPrincipal,  -- La localización existente será la principal
    1 as Orden
FROM Actividades
WHERE LocalizacionId IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM ActividadLocalizaciones 
    WHERE ActividadId = Actividades.Id AND LocalizacionId = Actividades.LocalizacionId
);

PRINT 'Datos migrados desde Actividades.LocalizacionId';
GO

-- Verificar los datos
SELECT 
    al.Id,
    a.Nombre as Actividad,
    l.Nombre as Localizacion,
    al.EsPrincipal,
    al.Orden
FROM ActividadLocalizaciones al
INNER JOIN Actividades a ON al.ActividadId = a.Id
INNER JOIN Localizaciones l ON al.LocalizacionId = l.Id
ORDER BY al.ActividadId, al.Orden;
GO
