# ? CORRECCIÓN APLICADA - Tabla Usuarios

## ?? Problema Identificado

**Error Original:**
```
Mens. 1919, Nivel 16, Estado 1, Línea 196
Column 'Email' in table 'Usuarios' is of a type that is invalid 
for use as a key column in an index.
```

**Causa:**
La columna `Email` estaba definida como `NVARCHAR(MAX)`, lo cual **NO permite** crear índices únicos en SQL Server. Los índices requieren un tamaño máximo definido.

---

## ? Solución Aplicada

### 1. Script CreateDatabase.sql Corregido
- ? Cambiado `Email NVARCHAR(MAX)` a `Email NVARCHAR(256)`
- ? Cambiado `NombreCompleto NVARCHAR(MAX)` a `NombreCompleto NVARCHAR(200)`
- ? Cambiado `Rol NVARCHAR(MAX)` a `Rol NVARCHAR(50)`
- ? Índice único `IX_Usuarios_Email` ahora se crea correctamente

### 2. Modelo Usuario.cs Actualizado
```csharp
using System.ComponentModel.DataAnnotations;

namespace ACEXAPI.Models;

public class Usuario
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [Required]
    [EmailAddress]
    [MaxLength(256)]  // ? Coincide con la BD
    public string Email { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(200)]  // ? Coincide con la BD
    public string NombreCompleto { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(50)]   // ? Coincide con la BD
    public string Rol { get; set; } = "Usuario";
    
    public DateTime FechaCreacion { get; set; } = DateTime.UtcNow;
    
    public bool Activo { get; set; } = true;
}
```

### 3. Base de Datos Existente Corregida
? Script ejecutado: `Scripts/FixUsuariosTable.sql`
- Tabla `Usuarios` recreada con estructura correcta
- Índice único `IX_Usuarios_Email` creado exitosamente
- La tabla está lista para recibir datos

---

## ?? Estructura Final de la Tabla Usuarios

| Columna | Tipo | Longitud | Nullable | Notas |
|---------|------|----------|----------|-------|
| Id | UNIQUEIDENTIFIER | - | NO | PRIMARY KEY |
| Email | NVARCHAR | 256 | NO | UNIQUE INDEX |
| NombreCompleto | NVARCHAR | 200 | NO | - |
| Rol | NVARCHAR | 50 | NO | DEFAULT 'Usuario' |
| FechaCreacion | DATETIME2 | - | NO | DEFAULT GETUTCDATE() |
| Activo | BIT | - | NO | DEFAULT 1 |

**Índice:** `IX_Usuarios_Email` en columna `Email` (UNIQUE)

---

## ?? Próximos Pasos

### Crear Usuarios de Prueba

```sql
USE ACEXAPI;
GO

-- Insertar usuarios de prueba
INSERT INTO Usuarios (Email, NombreCompleto, Rol, Activo)
VALUES 
    ('admin@acexapi.com', 'Administrador Sistema', 'Administrador', 1),
    ('coordinador@acexapi.com', 'Coordinador Actividades', 'Coordinador', 1),
    ('profesor@acexapi.com', 'Profesor Ejemplo', 'Profesor', 1);
GO

-- Verificar
SELECT * FROM Usuarios;
GO
```

### Probar el Índice Único

```sql
-- Esto debería funcionar
INSERT INTO Usuarios (Email, NombreCompleto, Rol)
VALUES ('nuevo@acexapi.com', 'Nuevo Usuario', 'Usuario');

-- Esto debería fallar (email duplicado)
INSERT INTO Usuarios (Email, NombreCompleto, Rol)
VALUES ('admin@acexapi.com', 'Otro Admin', 'Administrador');
-- Error esperado: Violation of UNIQUE KEY constraint
```

---

## ? Verificación

### Estado Actual:
```
? Tabla Usuarios: Estructura correcta
? Columna Email: NVARCHAR(256) con índice único
? Modelo C#: Sincronizado con la base de datos
? Compilación: Exitosa
? Base de datos: Sin errores
```

### Comando de Verificación:
```powershell
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -d ACEXAPI -Q "SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Usuarios'"
```

---

## ?? Archivos Modificados

1. ? `Scripts/CreateDatabase.sql` - Script principal corregido
2. ? `Models/Usuario.cs` - Modelo con anotaciones de validación
3. ? `Scripts/FixUsuariosTable.sql` - Script de corrección (ya ejecutado)

---

## ?? Continuar con el Desarrollo

La aplicación está lista para ejecutarse:

```powershell
# Ejecutar la aplicación
dotnet run
```

O presiona **F5** en Visual Studio.

---

**? Problema resuelto. La tabla Usuarios ahora funciona correctamente con el índice único en Email.**
