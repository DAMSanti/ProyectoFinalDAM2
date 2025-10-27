# 📝 Resumen de Cambios - Modelo Actividad

## 🎯 Objetivo
Actualizar el modelo de Actividad para que coincida con la base de datos y añadir el campo departamento.

## ✅ Cambios Realizados

### 1. **Modelo Flutter** (`lib/models/actividad.dart`)

#### ➕ Campos Añadidos:
- `final Departamento? departamento;` - Relación con el departamento

#### ➖ Campos Eliminados:
- `double? latitud;` - Movido a tabla `localizaciones`
- `double? longitud;` - Movido a tabla `localizaciones`

#### 🔄 `fromJson()` Actualizado:
```dart
// Ahora maneja dos formatos:
// 1. Objeto departamento completo (API antigua/MySQL)
// 2. departamentoId + departamentoNombre separados (ACEXAPI/SQL Server)

if (json['departamento'] != null && json['departamento'] is Map) {
  departamento = Departamento.fromJson(json['departamento']);
} else if (json['departamentoId'] != null && json['departamentoNombre'] != null) {
  departamento = Departamento(
    id: json['departamentoId'],
    codigo: '',
    nombre: json['departamentoNombre'],
  );
}
```

### 2. **Base de Datos MySQL** (para casa)

#### 📄 Archivo: `DB/migration_add_departamento.sql`
Script de migración idempotente que:
- ✅ Verifica si la columna `departamento_id` existe
- ✅ La crea solo si no existe
- ✅ Añade la constraint de clave foránea
- ✅ Puede ejecutarse múltiples veces sin errores

**Ejecutar en casa:**
```bash
cd DB
mysql -u root -p proyecto < migration_add_departamento.sql
```

#### 📄 Archivo: `DB/databaseExport.sql`
Actualizado con la nueva estructura:
```sql
`departamento_id` int DEFAULT NULL,
KEY `fk_actividades_departamentos_idx` (`departamento_id`),
CONSTRAINT `fk_actividades_departamentos` 
  FOREIGN KEY (`departamento_id`) 
  REFERENCES `departamentos` (`id`) 
  ON DELETE SET NULL 
  ON UPDATE CASCADE
```

### 3. **API C# (ACEXAPI)** - ✅ Ya está lista

El backend en C# **ya tiene todo configurado**:
- ✅ Modelo `Actividad` con `DepartamentoId` y `Departamento`
- ✅ Servicio incluye `.Include(a => a.Departamento)`
- ✅ DTO devuelve `DepartamentoId` y `DepartamentoNombre`
- ✅ Base de datos SQL Server ya tiene la columna

### 4. **UI Flutter** (`activity_detail_info.dart`)

Actualizado para mostrar el nombre del departamento:
```dart
Text(
  actividad.departamento?.nombre ?? 'Sin departamento',
  style: TextStyle(fontSize: !isWeb ? 13.dg : 4.sp),
),
```

## 📊 Estructura Actual vs Antigua

### Campos que ya existen en la base de datos MySQL:
✅ `titulo`
✅ `tipo` (extraescolar/complementaria)
✅ `descripcion`
✅ `fini` / `ffin` (fechas)
✅ `hini` / `hfin` (horas)
✅ `prevista_ini`
✅ `transporte_req`
✅ `coment_transporte`
✅ `alojamiento_req`
✅ `coment_alojamiento`
✅ `comentarios`
✅ `estado`
✅ `coment_estado`
✅ `incidencias`
✅ `url_folleto`
✅ `solicitante_id`
✅ `importe_por_alumno`
**🆕 `departamento_id`** (añadido con migración)

### Campos movidos a tabla `localizaciones`:
❌ ~~`latitud`~~ → tabla `localizaciones`
❌ ~~`longitud`~~ → tabla `localizaciones`

## 🔄 Compatibilidad Instituto/Casa

### En el Instituto (SQL Server):
- ✅ La tabla `Actividades` ya tiene `DepartamentoId`
- ✅ La API ya devuelve el departamento
- ✅ No requiere migración SQL

### En Casa (MySQL):
- 🔄 Ejecutar script de migración: `migration_add_departamento.sql`
- ✅ El script es seguro y puede ejecutarse múltiples veces

## 📦 Sincronización Entre Ubicaciones

### Proceso recomendado:

1. **En el instituto:**
   ```bash
   git add .
   git commit -m "Actualizado modelo Actividad con departamento"
   git push origin main
   ```

2. **En casa:**
   ```bash
   git pull origin main
   cd DB
   mysql -u root -p proyecto < migration_add_departamento.sql
   ```

3. **Verificar:**
   ```sql
   USE proyecto;
   DESCRIBE actividades;
   ```
   Deberías ver `departamento_id` en la lista.

## 🧪 Pruebas

### Verificar que funciona:
1. ✅ Ejecutar la aplicación Flutter
2. ✅ Abrir el detalle de una actividad
3. ✅ Verificar que se muestra el departamento (o "Sin departamento")
4. ✅ Verificar que las imágenes siguen funcionando
5. ✅ Verificar que el botón de eliminar imágenes funciona

## 📝 Notas Importantes

### ⚠️ Diferencias de Base de Datos:
- **Instituto**: SQL Server (Microsoft) - Case insensitive
- **Casa**: MySQL - Case sensitive por defecto

### 🔧 Mapeo de Campos:
| Base de Datos MySQL | Modelo Flutter | API C# (ACEXAPI) |
|---------------------|----------------|------------------|
| `titulo` | `titulo` | `Nombre` |
| `fini` | `fini` | `FechaInicio` |
| `ffin` | `ffin` | `FechaFin` |
| `prevista_ini` | `previstaIni` | - |
| `transporte_req` | `transporteReq` | - |
| `coment_transporte` | `comentTransporte` | - |
| `alojamiento_req` | `alojamientoReq` | - |
| `coment_alojamiento` | `comentAlojamiento` | - |
| `coment_estado` | `comentEstado` | - |
| `importe_por_alumno` | `importePorAlumno` | `PresupuestoEstimado` |
| `departamento_id` | `departamento.id` | `DepartamentoId` |

### 🚀 Próximos Pasos:
1. ⏳ Completar campos faltantes en la API C# (tipo, hini, hfin, etc.)
2. ⏳ Crear tabla separada para transporte si es necesario
3. ⏳ Migrar `latitud`/`longitud` a tabla `localizaciones`

---

**Fecha**: 27 de octubre de 2025  
**Autor**: Santiago  
**Versión**: 1.0  
**Estado**: ✅ Completado - Listo para sincronizar en casa
