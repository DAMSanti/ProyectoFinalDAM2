# Solución: Mapa de Localizaciones y Sistema de Iconos

## Problema 1: Mapa solo muestra una localización

### Causa
El mapa filtra las localizaciones que tienen coordenadas (latitud/longitud). Si solo una localización tiene coordenadas, solo mostrará un marcador.

### Solución
```dart
final localizacionesConCoords = widget.localizaciones
    .where((loc) => loc.latitud != null && loc.longitud != null)
    .toList();
```

**Verificar**: Asegúrate de que todas las localizaciones tengan coordenadas en la base de datos.

## Problema 2: Guardar iconos personalizados de localizaciones

### Cambios en la Base de Datos

#### 1. Migración SQL
Ejecutar el script: `DB/migration_add_localizacion_fields.sql`

```sql
-- Agregar campos a tabla Localizaciones
ALTER TABLE [dbo].[Localizaciones] ADD [Icono] NVARCHAR(50) NULL;
ALTER TABLE [dbo].[Localizaciones] ADD [EsPrincipal] BIT NOT NULL DEFAULT 0;
ALTER TABLE [dbo].[Localizaciones] ADD [Orden] INT NOT NULL DEFAULT 0;
```

#### 2. Valores de icono
Los iconos se guardan como strings con el nombre del icono de Material Icons:
- `'location_on'` → `Icons.location_on`
- `'school'` → `Icons.school`
- `'museum'` → `Icons.museum`
- etc.

### Cambios en el Modelo C# (Backend)

```csharp
public class Localizacion
{
    // ... campos existentes ...
    
    [MaxLength(50)]
    public string? Icono { get; set; }
    
    public bool EsPrincipal { get; set; } = false;
    
    public int Orden { get; set; } = 0;
}
```

### Cambios en el Modelo Dart (Frontend)

```dart
class Localizacion {
  final String? icono; // Nombre del icono de Material Icons
  final bool esPrincipal;
  final int orden;
  
  // ...
}
```

### Nuevo Helper: IconHelper

Ubicación: `lib/utils/icon_helper.dart`

```dart
// Convertir nombre a IconData
IconData icono = IconHelper.getIcon('school'); // Returns Icons.school

// Verificar si existe
bool existe = IconHelper.exists('museum'); // true o false

// Obtener todos los iconos disponibles
Map<String, IconData> todosLosIconos = IconHelper.getAllIcons();
```

#### Iconos disponibles (categorías):

**Ubicación**:
- location_on, location_pin, location_city, place, map, pin_drop

**Edificios**:
- school, business, store, local_library, museum, apartment, house, home

**Transporte**:
- directions_bus, directions_car, train, local_airport, directions_boat

**Naturaleza**:
- park, forest, beach_access, pool, landscape, terrain, hiking

**Comida**:
- restaurant, local_cafe, fastfood, local_dining

**Entretenimiento**:
- movie, theater_comedy, sports_soccer, sports_basketball, stadium

**Servicios**:
- local_hospital, local_pharmacy, local_police, local_fire_department

**Cultura**:
- church, account_balance, castle

**Genéricos**:
- star, flag, bookmark, favorite, meeting_room, event

### Uso en el Mapa

```dart
LocalizacionesMapWidget(
  localizaciones: localizaciones,
  // Los iconos ahora se cargan desde la base de datos automáticamente
  // mediante el campo 'icono' de cada localización
)
```

El widget del mapa:
1. Lee el campo `icono` de cada localización
2. Usa `IconHelper.getIcon()` para convertirlo a `IconData`
3. Si no hay icono guardado, usa el icono por defecto según `esPrincipal`

### Flujo para guardar iconos

#### 1. En el diálogo de añadir/editar localización:

```dart
// Al seleccionar icono
String iconoSeleccionado = 'school'; // Nombre del icono

// Al guardar
final localizacion = {
  'nombre': 'Museo de Ciencias',
  'direccion': 'Calle Principal 123',
  'latitud': 43.3506,
  'longitud': -4.0462,
  'icono': iconoSeleccionado, // <-- Guardar el nombre
  'esPrincipal': false,
  'orden': 1,
};
```

#### 2. En el backend (LocalizacionController):

```csharp
[HttpPost]
public async Task<ActionResult<Localizacion>> Create(LocalizacionDto dto)
{
    var localizacion = new Localizacion
    {
        Nombre = dto.Nombre,
        Direccion = dto.Direccion,
        Latitud = dto.Latitud,
        Longitud = dto.Longitud,
        Icono = dto.Icono, // <-- Guardar en BD
        EsPrincipal = dto.EsPrincipal,
        Orden = dto.Orden
    };
    
    // ...
}
```

### Próximos pasos

1. ✅ Ejecutar migración SQL
2. ✅ Actualizar modelos C# y Dart
3. ✅ Crear IconHelper
4. ✅ Actualizar widget del mapa
5. ⏳ Actualizar diálogos de añadir/editar localización para seleccionar icono
6. ⏳ Actualizar API para incluir campo icono en respuestas

## Verificación

### 1. Verificar que las localizaciones tienen coordenadas:

```sql
SELECT Id, Nombre, Latitud, Longitud, Icono, EsPrincipal
FROM Localizaciones;
```

### 2. Verificar que aparecen múltiples marcadores:

- Debe haber un marcador por cada localización con coordenadas
- El marcador principal debe ser rojo
- Los marcadores secundarios deben ser naranjas
- Al hacer clic debe mostrar información

### 3. Verificar iconos personalizados:

```sql
UPDATE Localizaciones
SET Icono = 'school'
WHERE Id = 1;
```

Debe aparecer el icono de escuela en lugar del pin estándar.
