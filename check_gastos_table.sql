-- Verificar conexión a la base de datos correcta
SELECT DB_NAME() AS 'Base de datos actual';

-- Verificar si la tabla GastosPersonalizados existe
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'GastosPersonalizados';

-- Ver la estructura completa de la tabla si existe
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'GastosPersonalizados'
ORDER BY ORDINAL_POSITION;

-- Ver todas las tablas que contienen 'Gasto' en el nombre
SELECT 
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME LIKE '%Gasto%'
ORDER BY TABLE_NAME;

-- Ver el contenido de la tabla (si existe)
IF OBJECT_ID('GastosPersonalizados', 'U') IS NOT NULL
BEGIN
    SELECT * FROM GastosPersonalizados;
END
ELSE
BEGIN
    SELECT 'La tabla GastosPersonalizados NO existe' AS Mensaje;
END
