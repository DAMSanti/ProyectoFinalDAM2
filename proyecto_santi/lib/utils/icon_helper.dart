import 'package:flutter/material.dart';

/// Helper para convertir nombres de iconos en strings a IconData
class IconHelper {
  /// Mapa de nombres de iconos comunes a IconData
  static final Map<String, IconData> _iconMap = {
    // Iconos de ubicación
    'location_on': Icons.location_on,
    'location_pin': Icons.location_pin,
    'location_city': Icons.location_city,
    'place': Icons.place,
    'map': Icons.map,
    'pin_drop': Icons.pin_drop,
    
    // Iconos de edificios e instituciones
    'school': Icons.school,
    'business': Icons.business,
    'store': Icons.store,
    'local_library': Icons.local_library,
    'museum': Icons.museum,
    'apartment': Icons.apartment,
    'house': Icons.house,
    'home': Icons.home,
    
    // Iconos de transporte
    'directions_bus': Icons.directions_bus,
    'directions_car': Icons.directions_car,
    'train': Icons.train,
    'local_airport': Icons.local_airport,
    'directions_boat': Icons.directions_boat,
    
    // Iconos de naturaleza y recreación
    'park': Icons.park,
    'forest': Icons.forest,
    'beach_access': Icons.beach_access,
    'pool': Icons.pool,
    'landscape': Icons.landscape,
    'terrain': Icons.terrain,
    'hiking': Icons.hiking,
    
    // Iconos de comida y restaurantes
    'restaurant': Icons.restaurant,
    'local_cafe': Icons.local_cafe,
    'fastfood': Icons.fastfood,
    'local_dining': Icons.local_dining,
    
    // Iconos de entretenimiento
    'movie': Icons.movie,
    'theater_comedy': Icons.theater_comedy,
    'sports_soccer': Icons.sports_soccer,
    'sports_basketball': Icons.sports_basketball,
    'stadium': Icons.stadium,
    
    // Iconos de servicios
    'local_hospital': Icons.local_hospital,
    'local_pharmacy': Icons.local_pharmacy,
    'local_police': Icons.local_police,
    'local_fire_department': Icons.local_fire_department,
    
    // Iconos religiosos y culturales
    'church': Icons.church,
    'account_balance': Icons.account_balance,
    'castle': Icons.castle,
    
    // Iconos genéricos útiles
    'star': Icons.star,
    'flag': Icons.flag,
    'bookmark': Icons.bookmark,
    'favorite': Icons.favorite,
    'meeting_room': Icons.meeting_room,
    'event': Icons.event,
  };

  /// Convierte un nombre de icono a IconData
  /// Si no se encuentra, devuelve el icono por defecto
  static IconData getIcon(String? iconName, {IconData defaultIcon = Icons.location_on}) {
    if (iconName == null || iconName.isEmpty) {
      return defaultIcon;
    }
    return _iconMap[iconName] ?? defaultIcon;
  }

  /// Obtiene todos los nombres de iconos disponibles
  static List<String> getAllIconNames() {
    return _iconMap.keys.toList()..sort();
  }

  /// Obtiene todos los iconos disponibles como Map
  static Map<String, IconData> getAllIcons() {
    return Map.from(_iconMap);
  }

  /// Verifica si un nombre de icono existe
  static bool exists(String iconName) {
    return _iconMap.containsKey(iconName);
  }

  /// Obtiene el IconData por nombre, retorna null si no existe
  static IconData? tryGetIcon(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return null;
    }
    return _iconMap[iconName];
  }

  /// Obtiene el nombre del icono a partir del IconData
  /// Si no se encuentra, devuelve null
  static String? getIconName(IconData? iconData) {
    if (iconData == null) return null;
    
    for (var entry in _iconMap.entries) {
      if (entry.value.codePoint == iconData.codePoint) {
        return entry.key;
      }
    }
    return null;
  }
}
