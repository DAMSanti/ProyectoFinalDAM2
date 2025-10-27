# Migración de Base de Datos - Departamento en Actividades

## 📋 Descripción de Cambios

Esta migración añade el campo `departamento_id` a la tabla `actividades` para relacionar cada actividad con un departamento específico.

### Cambios en la Base de Datos:

**Tabla `actividades`:**
- ✅ Añadida columna: `departamento_id INT NULL`
- ✅ Añadida clave foránea: `fk_actividades_departamentos` 
  - Referencias: `departamentos(id)`
  - ON UPDATE CASCADE
  - ON DELETE SET NULL

### Cambios en el Modelo Flutter:

**Archivo: `lib/models/actividad.dart`**
- ✅ Añadido campo: `final Departamento? departamento;`
- ✅ Actualizado `fromJson()` para parsear departamento desde API
- ✅ Actualizado `toJson()` para serializar departamento
- ❌ Eliminados campos: `latitud` y `longitud` (ahora en tabla `localizaciones`)

## 🔧 Instrucciones de Aplicación

### Opción 1: Migración Manual (Recomendado)

#### En el Instituto:
```bash
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\DB
mysql -u root -p proyecto < migration_add_departamento.sql
```

#### En Casa:
```bash
cd /ruta/a/tu/proyecto/DB
mysql -u root -p proyecto < migration_add_departamento.sql
```

### Opción 2: Mediante MySQL Workbench

1. Abrir MySQL Workbench
2. Conectar a tu servidor local
3. File → Open SQL Script → Seleccionar `migration_add_departamento.sql`
4. Ejecutar el script (⚡ icono de rayo)

## ⚠️ Importante

- ✅ **El script es idempotente**: Puede ejecutarse múltiples veces sin problemas
- ✅ **Verificación automática**: Solo añade la columna si no existe
- ✅ **Sin pérdida de datos**: Todos los datos existentes se mantienen
- ⚠️ **Valores NULL**: Las actividades existentes tendrán `departamento_id = NULL` hasta que se actualicen

## 🔄 Sincronización Entre Ubicaciones

### Primera vez en cada ubicación:

1. Hacer `git pull` para obtener el script de migración
2. Ejecutar el script de migración
3. Verificar que funcionó:
```sql
USE proyecto;
DESCRIBE actividades;
```

Deberías ver la columna `departamento_id` en la lista.

## 📝 Verificación Post-Migración

Ejecuta este query para verificar:

```sql
USE proyecto;

-- Ver estructura actualizada
SHOW CREATE TABLE actividades;

-- Verificar que la columna existe
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_KEY
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'proyecto' 
  AND TABLE_NAME = 'actividades' 
  AND COLUMN_NAME = 'departamento_id';
```

Resultado esperado:
```
COLUMN_NAME      | DATA_TYPE | IS_NULLABLE | COLUMN_KEY
departamento_id  | int       | YES         | MUL
```

## 🐛 Solución de Problemas

### Error: "Column already exists"
- ✅ **Solución**: Esto es normal, el script detectó que ya existe. No hay problema.

### Error: "Cannot add foreign key constraint"
- ⚠️ **Causa**: La tabla `departamentos` no existe o no tiene datos
- **Solución**: Verifica que la tabla `departamentos` exista y tenga la columna `id` como PRIMARY KEY

### Error: "Access denied"
- ⚠️ **Causa**: Usuario sin permisos
- **Solución**: Usa el usuario `root` o un usuario con permisos `ALTER TABLE`

## 📊 Actualizar la API (Backend)

Después de aplicar la migración, actualiza tu controlador C# para incluir el departamento:

```csharp
// En tu modelo de Actividad (C#)
public int? DepartamentoId { get; set; }
public Departamento? Departamento { get; set; }

// En tu query (incluir join)
.Include(a => a.Departamento)
```

## ✅ Checklist de Migración

- [ ] Git pull en el instituto
- [ ] Ejecutar migración en el instituto
- [ ] Verificar que funciona en el instituto
- [ ] Git pull en casa
- [ ] Ejecutar migración en casa
- [ ] Verificar que funciona en casa
- [ ] Actualizar API C# para incluir departamento
- [ ] Probar en la app Flutter que se muestra el departamento

---

**Fecha de creación**: 27 de octubre de 2025  
**Autor**: Santiago  
**Versión**: 1.0
