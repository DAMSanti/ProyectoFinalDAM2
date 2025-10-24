# Cambios en Base de Datos - Coordenadas y Usuarios

## Fecha: 24 de Octubre de 2025

## Resumen de Cambios

Se han realizado modificaciones importantes en la base de datos para agregar funcionalidad de mapas y sistema de login con profesores.

---

## 1. Localizaciones - Coordenadas GPS

### Cambios en la tabla `Localizaciones`:
- ✅ Se agregó columna `Latitud` (FLOAT NULL)
- ✅ Se agregó columna `Longitud` (FLOAT NULL)

### Datos actualizados:
| Localización | Latitud | Longitud |
|--------------|---------|----------|
| Museo de Ciencias | 43.4623 | -3.8100 |
| Parque de Cabárceno | 43.3582 | -3.8350 |
| Playa del Sardinero | 43.4788 | -3.7950 |
| Centro Cultural | 43.3486 | -4.0467 |
| Polideportivo Municipal | 43.4647 | -3.8048 |

### Propósito:
Las coordenadas GPS permitirán mostrar las localizaciones de las actividades en un mapa interactivo.

---

## 2. Usuarios - Relación con Profesores

### Cambios en la tabla `Usuarios`:
- ✅ Se agregó columna `ProfesorUuid` (UNIQUEIDENTIFIER NULL)
- ✅ Se agregó clave foránea `FK_Usuarios_Profesores_ProfesorUuid`
  - Referencias: `Profesores(Uuid)`
  - ON DELETE SET NULL

### Datos insertados:

#### Usuarios vinculados a Profesores:
| Email | Nombre Completo | Rol | Profesor Vinculado |
|-------|-----------------|-----|-------------------|
| maria.garcia@ies.edu | María García López | Coordinador | ✓ |
| juan.martinez@ies.edu | Juan Martínez Ruiz | Profesor | ✓ |
| ana.fernandez@ies.edu | Ana Fernández Sanz | Profesor | ✓ |
| carlos.lopez@ies.edu | Carlos López Pérez | Profesor | ✓ |

#### Usuario administrador:
| Email | Nombre Completo | Rol | Profesor Vinculado |
|-------|-----------------|-----|-------------------|
| admin@ies.edu | Administrador Sistema | Administrador | - |

**Nota importante**: Las contraseñas están almacenadas en texto plano (`Password123` y `Admin123`) **solo para desarrollo**. En producción deben hashearse con BCrypt o similar.

### Propósito:
- Permitir que los profesores puedan hacer login en el sistema
- Vincular cada usuario con su perfil de profesor correspondiente
- Mantener roles diferenciados (Administrador, Coordinador, Profesor)

---

## 3. Cambios en el API (C# .NET)

### Modelos actualizados:

#### `Localizacion.cs`:
```csharp
public double? Latitud { get; set; }
public double? Longitud { get; set; }
```

#### `Usuario.cs`:
```csharp
public Guid? ProfesorUuid { get; set; }
public Profesor? Profesor { get; set; }
```

#### `Profesor.cs`:
```csharp
public ICollection<Usuario> Usuarios { get; set; } = new List<Usuario>();
```

### DTOs actualizados:

#### `ActividadDto.cs`:
```csharp
public double? Latitud { get; set; }
public double? Longitud { get; set; }
```

### Servicios actualizados:

#### `ActividadService.cs` - MapToDto():
```csharp
Latitud = actividad.Localizacion?.Latitud,
Longitud = actividad.Localizacion?.Longitud,
```

---

## 4. Scripts SQL ejecutados

### Script 1: `AgregarCoordenadasYUsuarioProfesor.sql`
- Modifica esquema de base de datos
- Agrega columnas Latitud y Longitud a Localizaciones
- Agrega columna ProfesorUuid a Usuarios con FK
- Actualiza coordenadas de localizaciones existentes

### Script 2: `PoblarBaseDatosAdaptado.sql` (actualizado)
- Sección 5: INSERT de Localizaciones ahora incluye Latitud y Longitud
- Sección 11 (nueva): INSERT de Usuarios vinculados a Profesores

---

## 5. Próximos pasos

### Para poner en funcionamiento:

1. **Reiniciar el API**:
   ```bash
   # Detener el API actual (Ctrl+C en el terminal donde corre)
   cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\ACEXAPI
   dotnet build
   dotnet run
   ```

2. **Hot reload en Flutter**:
   - El hot reload debería detectar automáticamente las coordenadas
   - Las actividades ahora incluirán `latitud` y `longitud` en el JSON

3. **Implementar vista de mapa**:
   - Usar las coordenadas para mostrar markers en un mapa
   - Considerar paquetes como `google_maps_flutter` o `flutter_map`

4. **Implementar login**:
   - Crear endpoint de autenticación que valide Email y Password
   - Generar JWT token al hacer login exitoso
   - Vincular sesión del usuario con su perfil de Profesor

### Seguridad (IMPORTANTE):

⚠️ **Antes de producción**:
- Hashear todas las contraseñas con BCrypt
- Implementar JWT para autenticación
- Validar tokens en cada request
- Implementar refresh tokens
- Agregar rate limiting en endpoints de login

---

## 6. Estado actual de la base de datos

```
Departamentos:           6
Cursos:                  8
Grupos:                  8
Profesores:              6 (con DNIs)
Localizaciones:          5 (con coordenadas GPS)
EmpTransportes:          3
Actividades:            10 (vinculadas a localizaciones con coordenadas)
GrupoPartics:            7
ProfResponsables:        3
ProfParticipantes:       7
Contratos:               1
Usuarios:                5 (4 profesores + 1 admin)
```

---

## Contactos de prueba para login:

| Email | Password | Rol |
|-------|----------|-----|
| admin@ies.edu | Admin123 | Administrador |
| maria.garcia@ies.edu | Password123 | Coordinador |
| juan.martinez@ies.edu | Password123 | Profesor |
| ana.fernandez@ies.edu | Password123 | Profesor |
| carlos.lopez@ies.edu | Password123 | Profesor |

