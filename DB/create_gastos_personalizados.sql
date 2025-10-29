-- Script para crear la tabla GastosPersonalizados si no existe

USE ACEXAPI;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'GastosPersonalizados')
BEGIN
    CREATE TABLE GastosPersonalizados (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        ActividadId INT NOT NULL,
        Concepto NVARCHAR(200) NOT NULL,
        Cantidad DECIMAL(18,2) NOT NULL,
        FechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_GastosPersonalizados_Actividades FOREIGN KEY (ActividadId) 
            REFERENCES Actividades(Id) ON DELETE CASCADE
    );

    PRINT 'Tabla GastosPersonalizados creada exitosamente';
END
ELSE
BEGIN
    PRINT 'La tabla GastosPersonalizados ya existe';
END
GO

-- Verificar la estructura de la tabla
SELECT 
    c.name AS ColumnName,
    t.name AS DataType,
    c.max_length,
    c.is_nullable
FROM sys.columns c
INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('GastosPersonalizados')
ORDER BY c.column_id;
GO
