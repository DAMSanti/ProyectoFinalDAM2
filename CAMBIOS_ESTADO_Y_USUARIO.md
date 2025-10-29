# Cambios de Estado de Actividad y Modelo Usuario

## Fecha: 2024
Implementación de cambios en el modelo de datos para mejorar el workflow de actividades y simplificar el modelo de usuarios.

---

## 1. CAMBIO: Actividad.Aprobada → Actividad.Estado

### Modificación en Base de Datos
- **Antes**: Campo `Aprobada` (bit/boolean) - solo permitía True/False
- **Después**: Campo `Estado` (VARCHAR(20)) - enum con 3 valores: 'Pendiente', 'Aprobada', 'Cancelada'

### Razón del Cambio
El campo booleano `Aprobada` era limitante para representar el workflow completo de una actividad:
- Solo permitía dos estados (aprobada/no aprobada)
- No había forma de marcar actividades canceladas
- No había estado explícito de "pendiente de aprobación"

El nuevo enum `EstadoActividad` permite:
- **Pendiente**: Estado inicial cuando se crea la actividad
- **Aprobada**: Actividad aprobada y lista para ejecutarse
- **Cancelada**: Actividad cancelada (no se realizará)

### Archivos Modificados

#### Backend (C# .NET)

1. **ACEXAPI/Models/Actividad.cs**
   ```csharp
   // ANTES
   public bool Aprobada { get; set; } = false;
   
   // DESPUÉS
   [Required]
   [MaxLength(20)]
   public string Estado { get; set; } = EstadoActividad.Pendiente.ToString();
   ```

2. **ACEXAPI/Models/EstadoActividad.cs** (ya existía)
   ```csharp
   public enum EstadoActividad
   {
       Pendiente,
       Aprobada,
       Cancelada
   }
   ```

3. **ACEXAPI/DTOs/ActividadDto.cs**
   ```csharp
   // ANTES
   public bool Aprobada { get; set; }
   
   // DESPUÉS
   public string Estado { get; set; } = "Pendiente";
   ```

4. **ACEXAPI/DTOs/ActividadDto.cs - ActividadUpdateDto**
   ```csharp
   // ANTES
   public bool? Aprobada { get; set; }
   
   // DESPUÉS
   public string? Estado { get; set; }
   ```

5. **ACEXAPI/DTOs/ActividadDto.cs - ActividadListDto**
   ```csharp
   // ANTES
   public bool Aprobada { get; set; }
   
   // DESPUÉS
   public string Estado { get; set; } = "Pendiente";
   ```

6. **ACEXAPI/Services/ActividadService.cs**
   - GetAllAsync: `Estado = a.Estado` (en lugar de `Aprobada = a.Aprobada`)
   - UpdateAsync: `if (dto.Estado != null) actividad.Estado = dto.Estado;`
   - GetByIdAsync: `Estado = actividad.Estado`

7. **ACEXAPI/Controllers/DevController.cs**
   ```csharp
   // ANTES
   Aprobada = true,
   
   // DESPUÉS
   Estado = EstadoActividad.Aprobada.ToString(),
   ```

#### Frontend (Flutter/Dart)

8. **proyecto_santi/lib/models/actividad.dart**
   ```dart
   // fromJson
   // ANTES
   estado: (json['aprobada'] == true) ? 'Aprobada' : (json['estado']?.toString() ?? 'Pendiente'),
   
   // DESPUÉS
   estado: json['estado']?.toString() ?? 'Pendiente',
   
   // toJson
   // ANTES
   'aprobada': estado == 'Aprobada',
   
   // DESPUÉS
   'estado': estado,
   ```

---

## 2. CAMBIO: Modelo Usuario Simplificado

### Modificación en Base de Datos
- **Eliminado**: Campo `Correo` (VARCHAR)
- **Renombrado**: `NombreCompleto` → `NombreUsuario` (VARCHAR(200))

### Razón del Cambio
Simplificación del modelo de usuarios:
- El campo `Correo` era redundante ya que no se usaba para autenticación
- El `NombreUsuario` es más descriptivo del propósito del campo (nombre de inicio de sesión)

### Archivos Modificados

#### Backend (C# .NET)

1. **ACEXAPI/Models/Usuario.cs**
   ```csharp
   // ANTES
   [Required]
   [EmailAddress]
   [MaxLength(256)]
   public string Email { get; set; } = string.Empty;
   
   [Required]
   [MaxLength(200)]
   public string NombreCompleto { get; set; } = string.Empty;
   
   // DESPUÉS
   [Required]
   [MaxLength(200)]
   public string NombreUsuario { get; set; } = string.Empty;
   ```

---

## 3. SCRIPTS DE MIGRACIÓN SQL

### Script de Migración
**Archivo**: `DB/migration_estado_actividad_y_usuarios.sql`

Este script realiza:

1. **Cambio de Aprobada a Estado en Actividades**:
   ```sql
   -- Agregar columna Estado
   ALTER TABLE Actividades ADD Estado VARCHAR(20) NULL;
   
   -- Migrar datos: true → 'Aprobada', false → 'Pendiente'
   UPDATE Actividades SET Estado = CASE WHEN Aprobada = 1 THEN 'Aprobada' ELSE 'Pendiente' END;
   
   -- Hacer NOT NULL y agregar valor por defecto
   ALTER TABLE Actividades ALTER COLUMN Estado VARCHAR(20) NOT NULL;
   ALTER TABLE Actividades ADD CONSTRAINT DF_Actividades_Estado DEFAULT 'Pendiente' FOR Estado;
   
   -- Agregar constraint de validación
   ALTER TABLE Actividades ADD CONSTRAINT CK_Actividades_Estado 
       CHECK (Estado IN ('Pendiente', 'Aprobada', 'Cancelada'));
   
   -- Eliminar columna antigua
   ALTER TABLE Actividades DROP COLUMN Aprobada;
   ```

2. **Cambios en tabla Usuarios**:
   ```sql
   -- Agregar columna NombreUsuario
   ALTER TABLE Usuarios ADD NombreUsuario VARCHAR(200) NULL;
   
   -- Migrar datos de NombreCompleto a NombreUsuario
   UPDATE Usuarios SET NombreUsuario = NombreCompleto;
   
   -- Hacer NOT NULL
   ALTER TABLE Usuarios ALTER COLUMN NombreUsuario VARCHAR(200) NOT NULL;
   
   -- Eliminar columnas antiguas
   ALTER TABLE Usuarios DROP COLUMN NombreCompleto;
   ALTER TABLE Usuarios DROP COLUMN Correo;
   ```

### Orden de Ejecución de Migraciones

1. **PRIMERO**: `DB/migration_responsable_y_departamento_profesores.sql`
   - Cambios en estructura de Actividades (departamentoId → ResponsableId)
   - Agregar departamentoId a Profesores

2. **DESPUÉS**: `DB/migration_estado_actividad_y_usuarios.sql`
   - Cambio de Aprobada → Estado en Actividades
   - Cambios en tabla Usuarios

---

## 4. VERIFICACIÓN POST-MIGRACIÓN

### Consultas de Verificación

```sql
-- Verificar que todas las actividades tienen estado válido
SELECT Estado, COUNT(*) as Cantidad
FROM Actividades
GROUP BY Estado;

-- Verificar que no hay estados NULL o inválidos
SELECT * FROM Actividades
WHERE Estado IS NULL 
   OR Estado NOT IN ('Pendiente', 'Aprobada', 'Cancelada');

-- Verificar estructura de Usuarios
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Usuarios'
ORDER BY ORDINAL_POSITION;

-- Verificar que todos los usuarios tienen NombreUsuario
SELECT * FROM Usuarios WHERE NombreUsuario IS NULL;
```

---

## 5. IMPACTO EN LA APLICACIÓN

### Backend
- ✅ Todos los endpoints de actividades ahora devuelven `Estado` en lugar de `Aprobada`
- ✅ El campo Estado acepta los valores: "Pendiente", "Aprobada", "Cancelada"
- ✅ Validación automática del enum en el backend
- ✅ Datos de prueba actualizados con el nuevo formato

### Frontend
- ✅ El modelo Actividad en Flutter ahora usa el campo `estado` como string
- ✅ Compatible con los 3 estados: Pendiente, Aprobada, Cancelada
- ✅ Listo para mostrar filtros por estado en la UI

### API Endpoints Afectados
- `GET /api/actividades` - Devuelve Estado
- `GET /api/actividades/{id}` - Devuelve Estado
- `PUT /api/actividades/{id}` - Acepta Estado en el body
- `POST /api/actividades` - Estado por defecto "Pendiente"

---

## 6. PRÓXIMOS PASOS

### Tareas Pendientes
- [ ] Ejecutar scripts de migración en base de datos de desarrollo
- [ ] Ejecutar scripts de migración en base de datos de producción
- [ ] Actualizar UI de Flutter para mostrar estado con badge/chip
- [ ] Agregar filtro de estado en la pantalla de actividades
- [ ] Actualizar AuthController y servicios relacionados con Usuario
- [ ] Crear endpoint para cambiar estado de actividad (aprobar/cancelar)
- [ ] Agregar validación de permisos (solo coordinadores pueden aprobar)

### Consideraciones
- El campo Estado es VARCHAR para flexibilidad futura
- Se mantiene compatibilidad con datos existentes mediante migración automática
- Las actividades existentes con Aprobada=true → Estado='Aprobada'
- Las actividades existentes con Aprobada=false → Estado='Pendiente'

---

## 7. ROLLBACK

Si es necesario revertir los cambios:

```sql
-- ROLLBACK: Volver de Estado a Aprobada
ALTER TABLE Actividades ADD Aprobada BIT NULL;
UPDATE Actividades SET Aprobada = CASE WHEN Estado = 'Aprobada' THEN 1 ELSE 0 END;
ALTER TABLE Actividades ALTER COLUMN Aprobada BIT NOT NULL;
ALTER TABLE Actividades ADD CONSTRAINT DF_Actividades_Aprobada DEFAULT 0 FOR Aprobada;
ALTER TABLE Actividades DROP CONSTRAINT CK_Actividades_Estado;
ALTER TABLE Actividades DROP CONSTRAINT DF_Actividades_Estado;
ALTER TABLE Actividades DROP COLUMN Estado;

-- ROLLBACK: Usuarios
ALTER TABLE Usuarios ADD NombreCompleto VARCHAR(200) NULL;
ALTER TABLE Usuarios ADD Correo VARCHAR(256) NULL;
UPDATE Usuarios SET NombreCompleto = NombreUsuario;
ALTER TABLE Usuarios ALTER COLUMN NombreCompleto VARCHAR(200) NOT NULL;
ALTER TABLE Usuarios DROP COLUMN NombreUsuario;
```

⚠️ **ADVERTENCIA**: El rollback de Usuarios perderá el campo Correo ya que no se puede recuperar.

---

## RESUMEN DE CAMBIOS

| Componente | Antes | Después |
|------------|-------|---------|
| Actividad.Aprobada | bool | - (eliminado) |
| Actividad.Estado | - | VARCHAR(20) enum |
| Usuario.Correo | VARCHAR(256) | - (eliminado) |
| Usuario.NombreCompleto | VARCHAR(200) | - (eliminado) |
| Usuario.NombreUsuario | - | VARCHAR(200) |

**Estados válidos de actividad**: Pendiente, Aprobada, Cancelada
**Valor por defecto**: Pendiente
