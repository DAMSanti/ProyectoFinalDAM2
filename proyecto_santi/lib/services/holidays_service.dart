import 'dart:convert';
import 'package:http/http.dart' as http;
class Holiday {
  final DateTime date;
  final String name;
  final bool isNational;
  Holiday({
    required this.date,
    required this.name,
    this.isNational = true,
  });
  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      date: DateTime.parse(json['date']),
      name: json['localName'] ?? json['name'],
      isNational: json['global'] ?? true,
    );
  }
}
class HolidaysService {
  static const String _baseUrl = 'https:
  static final Map<int, List<Holiday>> _cache = {};
  static List<Holiday> _getStaticHolidays(int year) {
    return [
      Holiday(date: DateTime(year, 1, 1), name: 'Año Nuevo'),
      Holiday(date: DateTime(year, 1, 6), name: 'Día de Reyes'),
      Holiday(date: DateTime(year, 5, 1), name: 'Día del Trabajo'),
      Holiday(date: DateTime(year, 8, 15), name: 'Asunción de la Virgen'),
      Holiday(date: DateTime(year, 10, 12), name: 'Fiesta Nacional de España'),
      Holiday(date: DateTime(year, 11, 1), name: 'Todos los Santos'),
      Holiday(date: DateTime(year, 12, 6), name: 'Día de la Constitución'),
      Holiday(date: DateTime(year, 12, 8), name: 'Inmaculada Concepción'),
      Holiday(date: DateTime(year, 12, 25), name: 'Navidad'),
      Holiday(date: DateTime(year, 4, 14), name: 'Viernes Santo'),
      Holiday(date: DateTime(year, 4, 17), name: 'Lunes de Pascua'),
    ];
  }
  static Future<List<Holiday>> getHolidays(int year, {String countryCode = 'ES'}) async {
    final cacheKey = year * 1000 + countryCode.hashCode % 1000;
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/PublicHolidays/$year/$countryCode'),
      ).timeout(Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final holidays = data.map((json) => Holiday.fromJson(json)).toList();
        _cache[year] = holidays;
        return holidays;
      } else {
        final holidays = _getStaticHolidays(year);
        _cache[year] = holidays;
        return holidays;
      }
    } catch (e) {
      final holidays = _getStaticHolidays(year);
      _cache[year] = holidays;
      return holidays;
    }
  }
  static Future<Holiday?> isHoliday(DateTime date) async {
    final holidays = await getHolidays(date.year);
    try {
      return holidays.firstWhere(
        (h) => h.date.year == date.year && 
               h.date.month == date.month && 
               h.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }
  static Future<void> preloadHolidays(DateTime start, DateTime end) async {
    final years = <int>{};
    for (var date = start; date.isBefore(end); date = DateTime(date.year, date.month + 1)) {
      years.add(date.year);
    }
    for (var year in years) {
      await getHolidays(year);
    }
  }
}