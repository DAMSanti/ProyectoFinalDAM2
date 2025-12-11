import 'package:flutter/material.dart';
class IconHelper {
  static final Map<String, IconData> _iconMap = {
    'location_on': Icons.location_on,
    'location_pin': Icons.location_pin,
    'location_city': Icons.location_city,
    'place': Icons.place,
    'map': Icons.map,
    'pin_drop': Icons.pin_drop,
    'school': Icons.school,
    'business': Icons.business,
    'store': Icons.store,
    'local_library': Icons.local_library,
    'museum': Icons.museum,
    'apartment': Icons.apartment,
    'house': Icons.house,
    'home': Icons.home,
    'directions_bus': Icons.directions_bus,
    'directions_car': Icons.directions_car,
    'train': Icons.train,
    'local_airport': Icons.local_airport,
    'directions_boat': Icons.directions_boat,
    'park': Icons.park,
    'forest': Icons.forest,
    'beach_access': Icons.beach_access,
    'pool': Icons.pool,
    'landscape': Icons.landscape,
    'terrain': Icons.terrain,
    'hiking': Icons.hiking,
    'restaurant': Icons.restaurant,
    'local_cafe': Icons.local_cafe,
    'fastfood': Icons.fastfood,
    'local_dining': Icons.local_dining,
    'movie': Icons.movie,
    'theater_comedy': Icons.theater_comedy,
    'sports_soccer': Icons.sports_soccer,
    'sports_basketball': Icons.sports_basketball,
    'stadium': Icons.stadium,
    'local_hospital': Icons.local_hospital,
    'local_pharmacy': Icons.local_pharmacy,
    'local_police': Icons.local_police,
    'local_fire_department': Icons.local_fire_department,
    'church': Icons.church,
    'account_balance': Icons.account_balance,
    'castle': Icons.castle,
    'star': Icons.star,
    'flag': Icons.flag,
    'bookmark': Icons.bookmark,
    'favorite': Icons.favorite,
    'meeting_room': Icons.meeting_room,
    'event': Icons.event,
  };
  static IconData getIcon(String? iconName, {IconData defaultIcon = Icons.location_on}) {
    if (iconName == null || iconName.isEmpty) {
      return defaultIcon;
    }
    return _iconMap[iconName] ?? defaultIcon;
  }
  static List<String> getAllIconNames() {
    return _iconMap.keys.toList()..sort();
  }
  static Map<String, IconData> getAllIcons() {
    return Map.from(_iconMap);
  }
  static bool exists(String iconName) {
    return _iconMap.containsKey(iconName);
  }
  static IconData? tryGetIcon(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return null;
    }
    return _iconMap[iconName];
  }
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