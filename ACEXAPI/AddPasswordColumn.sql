-- Script para agregar la columna Password a la tabla Usuarios
-- Si la columna ya existe, no hace nada

IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[dbo].[Usuarios]') 
    AND name = 'Password'
)
BEGIN
    ALTER TABLE [dbo].[Usuarios]
    ADD [Password] NVARCHAR(256) NOT NULL DEFAULT '';
    
    PRINT 'Columna Password agregada exitosamente a la tabla Usuarios';
END
ELSE
BEGIN
    PRINT 'La columna Password ya existe en la tabla Usuarios';
END
GO
