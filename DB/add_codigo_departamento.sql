-- Agregar columna Codigo a la tabla Departamentos
ALTER TABLE Departamentos ADD Codigo NVARCHAR(10) NULL;
GO

-- Actualizar los códigos de cada departamento
UPDATE Departamentos SET Codigo = 'INF' WHERE Id = 1;
UPDATE Departamentos SET Codigo = 'ADM' WHERE Id = 2;
UPDATE Departamentos SET Codigo = 'FAB' WHERE Id = 3;
UPDATE Departamentos SET Codigo = 'MAT' WHERE Id = 4;
UPDATE Departamentos SET Codigo = 'LEN' WHERE Id = 5;
UPDATE Departamentos SET Codigo = 'SOC' WHERE Id = 6;
UPDATE Departamentos SET Codigo = 'FYQ' WHERE Id = 7;
UPDATE Departamentos SET Codigo = 'EFI' WHERE Id = 8;
UPDATE Departamentos SET Codigo = 'BIO' WHERE Id = 9;
UPDATE Departamentos SET Codigo = 'ING' WHERE Id = 10;
GO

-- Verificar los cambios
SELECT Id, Nombre, Codigo FROM Departamentos ORDER BY Id;
GO
