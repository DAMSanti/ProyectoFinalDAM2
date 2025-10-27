# Migración: Precios de Transporte y Alojamiento

## Fecha
27 de octubre de 2025

## Objetivo
Agregar campos a la tabla `actividades` para almacenar los precios del transporte y alojamiento.

## Cambios en la Base de Datos

### Nuevos Campos Agregados

1. **precio_transporte** (DECIMAL(10,2))
   - Almacena el precio final del transporte contratado
   - Puede ser NULL si no se ha contratado transporte
   - Se ubica después de `coment_transporte`

2. **precio_alojamiento** (DECIMAL(10,2))
   - Almacena el precio total del alojamiento
   - Puede ser NULL si no se requiere alojamiento
   - Se ubica después de `coment_alojamiento`

3. **nombre_alojamiento** (VARCHAR(200))
   - Almacena el nombre o descripción del alojamiento
   - Puede ser NULL
   - Se ubica después de `precio_alojamiento`

## Ejecución de la Migración

### Opción 1: Desde MySQL Workbench o línea de comandos
```bash
mysql -u root -p proyecto < migration_add_precios_transporte_alojamiento.sql
```

### Opción 2: Copiar y pegar en MySQL Workbench
Abrir el archivo `migration_add_precios_transporte_alojamiento.sql` y ejecutar.

## Verificación

Después de ejecutar la migración, verificar que los campos existen:

```sql
DESCRIBE actividades;
```

Deberías ver las tres nuevas columnas:
- `precio_transporte`
- `precio_alojamiento`
- `nombre_alojamiento`

## Cambios en el Código

### Backend (C#)
- **Modelo actualizado**: `ACEXAPI/Models/Actividad.cs`
  - Agregadas propiedades: `PrecioTransporte`, `PrecioAlojamiento`, `NombreAlojamiento`
  - Modelo sincronizado con todos los campos de la base de datos

### Frontend (Flutter) - Pendiente
- Actualizar modelo `Actividad` en Flutter
- Crear interfaz para gestionar transporte y alojamiento
- Implementar selección de empresas de transporte
- Implementar formulario de alojamiento

## Funcionalidad Planificada

### Transporte
1. Checkbox para indicar si requiere transporte
2. Cuando se marca, mostrar:
   - Lista de empresas de transporte (de la tabla `emp_transporte`)
   - Opción para solicitar presupuesto a 3 empresas
   - Campo para introducir el precio final contratado
   - Comentarios sobre el transporte

### Alojamiento
1. Checkbox para indicar si requiere alojamiento
2. Cuando se marca, mostrar:
   - Campo para el nombre del alojamiento
   - Campo para el precio del alojamiento
   - Comentarios sobre el alojamiento

### Cálculo del Presupuesto
El presupuesto total de la actividad incluirá:
- Importe por alumno × número de alumnos
- Precio del transporte (si aplica)
- Precio del alojamiento (si aplica)
- Otros gastos

## Notas
- Los campos son opcionales (NULL) para mantener compatibilidad con actividades existentes
- El precio del transporte puede venir de la tabla `contratos` cuando se contrata una empresa
- El sistema permitirá introducir manualmente los precios o tomarlos de los contratos
