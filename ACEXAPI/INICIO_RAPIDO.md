# ?? INICIO RÁPIDO - ACEXAPI

## ? Estado: CONFIGURACIÓN COMPLETA

Tu base de datos ya está creada y lista. Solo necesitas ejecutar la aplicación.

---

## ?? EJECUTAR AHORA

### Visual Studio:
```
Presiona F5 o clic en el botón "Start"
```

### Línea de comandos:
```powershell
dotnet run
```

**Swagger se abrirá automáticamente en:** `https://localhost:{puerto}/`

---

## ?? LO QUE YA ESTÁ LISTO

? **SQL Server:** Corriendo en 127.0.0.1,1433  
? **Base de Datos:** ACEXAPI creada  
? **Tablas:** 13 tablas operativas  
? **Datos:** 3 departamentos + 3 cursos  
? **Connection String:** Configurado  
? **Build:** Exitoso  

---

## ?? PROBAR RÁPIDAMENTE

### 1. Ver Departamentos
```
GET https://localhost:{puerto}/api/departamentos
```

Deberías ver:
```json
[
  { "id": 1, "nombre": "Informática", "descripcion": "Departamento de Informática" },
  { "id": 2, "nombre": "Matemáticas", "descripcion": "Departamento de Matemáticas" },
  { "id": 3, "nombre": "Lengua", "descripcion": "Departamento de Lengua y Literatura" }
]
```

### 2. Ver Cursos
```
GET https://localhost:{puerto}/api/cursos
```

### 3. Crear una Actividad (requiere JWT)
Primero necesitas autenticarte. Si no tienes el endpoint de auth implementado, puedes:

#### Opción A: Crear directamente en SQL
```sql
USE ACEXAPI;
GO

INSERT INTO Actividades (Nombre, Descripcion, FechaInicio, Aprobada, DepartamentoId)
VALUES ('Excursión Museo', 'Visita al museo de ciencias', GETUTCDATE(), 1, 1);
GO
```

#### Opción B: Implementar endpoint de autenticación (si no existe)
Consulta la documentación de JWT en tu proyecto.

---

## ?? DATOS ACTUALES EN LA BD

### Departamentos (3):
- Informática
- Matemáticas  
- Lengua

### Cursos (3):
- 1º ESO (ESO)
- 2º ESO (ESO)
- 1º Bach (BACH)

---

## ?? VERIFICAR CONEXIÓN

Si quieres verificar que todo está bien antes de ejecutar:

```powershell
# Probar conexión
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -d ACEXAPI -Q "SELECT COUNT(*) AS Tablas FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'"

# Ver departamentos
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -d ACEXAPI -Q "SELECT * FROM Departamentos"
```

---

## ?? DOCUMENTACIÓN COMPLETA

- **CONFIGURACION_COMPLETA.md** - Estado completo del sistema
- **Scripts/INSTRUCCIONES_CONFIGURACION.md** - Guía detallada
- **Scripts/README_DatabaseSetup.md** - Configuración de BD

---

## ?? ¡LISTO!

Tu API está completamente configurada y lista para usar.

**Siguiente paso:** Presiona **F5** en Visual Studio
