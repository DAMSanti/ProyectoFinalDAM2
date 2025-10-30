# Descripción y Tipo de Localización

## Resumen de Cambios

Se han añadido dos nuevos campos a la tabla `ActividadLocalizaciones` para permitir registrar información adicional sobre cada localización en el contexto de una actividad:

1. **Descripcion** (NVARCHAR(500), nullable): Comentario o descripción sobre la localización en el contexto de la actividad
2. **TipoLocalizacion** (NVARCHAR(50), nullable): Tipo de localización con los valores predefinidos:
   - "Punto de salida"
   - "Punto de llegada"
   - "Alojamiento"
   - "Actividad"

## Archivos Modificados

### Backend (C# .NET 8)

1. **DB/migration_add_descripcion_tipo_localizacion.sql**
   - Script de migración que añade las columnas a la tabla
   - Asigna valores por defecto a registros existentes

2. **ACEXAPI/Models/ActividadLocalizacion.cs**
   - Añadidas propiedades `Descripcion` y `TipoLocalizacion`

3. **ACEXAPI/DTOs/ActividadDto.cs**
   - `LocalizacionDto`: Añadidos campos `Descripcion` y `TipoLocalizacion`
   - `AddLocalizacionDto`: Añadidos campos `Descripcion` y `TipoLocalizacion`
   - `UpdateLocalizacionDto`: Añadidos campos `Descripcion` y `TipoLocalizacion`

4. **ACEXAPI/Services/ActividadService.cs**
   - Método `GetLocalizacionesAsync`: Incluye los nuevos campos en el mapeo
   - Método `AddLocalizacionAsync`: Acepta y guarda descripción y tipo
   - Método `UpdateLocalizacionAsync`: Acepta y actualiza descripción y tipo

5. **ACEXAPI/Controllers/ActividadController.cs**
   - Endpoints `POST /Actividad/{id}/localizaciones/{localizacionId}` y `PUT /Actividad/{id}/localizaciones/{localizacionId}`: Pasan los nuevos campos al servicio

### Frontend (Flutter/Dart)

1. **proyecto_santi/lib/models/localizacion.dart**
   - Añadidas propiedades `descripcion` y `tipoLocalizacion`
   - Actualizado `fromJson` y `toJson`

2. **proyecto_santi/lib/views/activityDetail/components/localizaciones/edit_localizacion_dialog.dart**
   - Añadido `DropdownButtonFormField` para seleccionar tipo de localización
   - Añadido `TextField` para descripción (máximo 500 caracteres)
   - Controlador `_descripcionController` para gestionar el texto
   - Iconos asociados a cada tipo de localización

3. **proyecto_santi/lib/views/activityDetail/components/localizaciones/add_localizacion_dialog.dart**
   - Actualizado `_editLocalizacion` para manejar los nuevos campos del diálogo
   - Comparación de cambios incluye descripción y tipo

4. **proyecto_santi/lib/services/localizacion_service.dart**
   - Método `addLocalizacion`: Añadidos parámetros `descripcion` y `tipoLocalizacion`
   - Método `updateLocalizacion`: Añadidos parámetros `descripcion` y `tipoLocalizacion`

5. **proyecto_santi/lib/views/activityDetail/activity_detail_view.dart**
   - Actualizada llamada a `addLocalizacion` para pasar los nuevos campos
   - Actualizada llamada a `updateLocalizacion` para pasar los nuevos campos

## Uso

### Desde la UI

1. Al editar una localización en una actividad, ahora se pueden:
   - Seleccionar el **tipo** de localización desde un desplegable con iconos
   - Añadir una **descripción** de hasta 500 caracteres

2. Los tipos disponibles son:
   - 🎯 **Punto de salida**: Lugar desde donde comienza la actividad
   - 🏁 **Punto de llegada**: Destino final de la actividad
   - 🏨 **Alojamiento**: Lugar donde se hospeda el grupo
   - 🎭 **Actividad**: Lugar donde se realiza la actividad principal

### Desde la API

**POST /Actividad/{id}/localizaciones/{localizacionId}**
```json
{
  "esPrincipal": true,
  "orden": 1,
  "icono": "location_pin",
  "descripcion": "Salida desde el instituto a las 8:00 AM",
  "tipoLocalizacion": "Punto de salida"
}
```

**PUT /Actividad/{id}/localizaciones/{localizacionId}**
```json
{
  "esPrincipal": false,
  "orden": 2,
  "icono": "hotel_rounded",
  "descripcion": "Hotel con desayuno incluido, habitaciones dobles",
  "tipoLocalizacion": "Alojamiento"
}
```

## Datos Por Defecto

Los registros existentes en la base de datos se inicializaron con:
- **TipoLocalizacion**: "Punto de salida" si `EsPrincipal = 1`, "Actividad" en caso contrario
- **Descripcion**: NULL

## Validaciones

- Descripción: Máximo 500 caracteres (validado en Flutter y backend)
- Tipo de localización: Máximo 50 caracteres
- Ambos campos son opcionales (nullable)

## Migración Ejecutada

La migración se ejecutó correctamente el 30 de octubre de 2025:
```
Columna Descripcion agregada exitosamente
Columna TipoLocalizacion agregada exitosamente
(4 rows affected)
Tipos de localización por defecto asignados
Migration completada exitosamente
```
