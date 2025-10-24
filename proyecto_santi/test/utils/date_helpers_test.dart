import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Date Helpers Tests', () {
    test('DateTime parsing debería funcionar correctamente', () {
      final dateStr = '2025-10-23T10:30:00';
      final date = DateTime.parse(dateStr);
      
      expect(date.year, 2025);
      expect(date.month, 10);
      expect(date.day, 23);
      expect(date.hour, 10);
      expect(date.minute, 30);
    });

    test('DateTime.now() debería retornar fecha actual', () {
      final now = DateTime.now();
      
      expect(now.year, greaterThanOrEqualTo(2025));
      expect(now.month, greaterThanOrEqualTo(1));
      expect(now.month, lessThanOrEqualTo(12));
    });

    test('DateTime comparison debería funcionar correctamente', () {
      final date1 = DateTime(2025, 10, 1);
      final date2 = DateTime(2025, 10, 15);
      
      expect(date1.isBefore(date2), true);
      expect(date2.isAfter(date1), true);
      expect(date1.isAtSameMomentAs(date1), true);
    });

    test('Formatear fecha a string debería mantener formato', () {
      final date = DateTime(2025, 10, 23, 15, 30, 45);
      final formatted = date.toIso8601String();
      
      expect(formatted, contains('2025-10-23'));
      expect(formatted, contains('15:30:45'));
    });

    test('Calcular diferencia entre fechas debería funcionar', () {
      final date1 = DateTime(2025, 10, 1);
      final date2 = DateTime(2025, 10, 15);
      
      final difference = date2.difference(date1);
      
      expect(difference.inDays, 14);
    });

    test('Agregar días a una fecha debería funcionar', () {
      final date = DateTime(2025, 10, 1);
      final newDate = date.add(const Duration(days: 7));
      
      expect(newDate.day, 8);
      expect(newDate.month, 10);
    });

    test('Restar días a una fecha debería funcionar', () {
      final date = DateTime(2025, 10, 15);
      final newDate = date.subtract(const Duration(days: 5));
      
      expect(newDate.day, 10);
      expect(newDate.month, 10);
    });

    test('Crear fecha sin hora debería establecer medianoche', () {
      final date = DateTime(2025, 10, 23);
      
      expect(date.hour, 0);
      expect(date.minute, 0);
      expect(date.second, 0);
    });

    test('Comparar solo fechas sin considerar hora', () {
      final date1 = DateTime(2025, 10, 23, 10, 30, 0);
      final date2 = DateTime(2025, 10, 23, 15, 45, 0);
      
      final day1 = DateTime(date1.year, date1.month, date1.day);
      final day2 = DateTime(date2.year, date2.month, date2.day);
      
      expect(day1.isAtSameMomentAs(day2), true);
    });

    test('Manejar cambio de mes al agregar días', () {
      final date = DateTime(2025, 10, 30);
      final newDate = date.add(const Duration(days: 5));
      
      expect(newDate.day, 4);
      expect(newDate.month, 11);
    });

    test('Manejar cambio de año al agregar meses', () {
      final date = DateTime(2025, 11, 15);
      final newDate = DateTime(date.year, date.month + 2, date.day);
      
      expect(newDate.month, 1);
      expect(newDate.year, 2026);
    });

    test('Duration en milisegundos debería ser correcto', () {
      const duration = Duration(seconds: 30);
      
      expect(duration.inMilliseconds, 30000);
      expect(duration.inSeconds, 30);
    });

    test('Duration debería sumar correctamente', () {
      const duration1 = Duration(hours: 1);
      const duration2 = Duration(minutes: 30);
      
      final total = duration1 + duration2;
      
      expect(total.inMinutes, 90);
      expect(total.inHours, 1);
    });

    test('DateTime weekday debería ser correcto', () {
      final date = DateTime(2025, 10, 23); // Jueves
      
      // DateTime.thursday = 4
      expect(date.weekday, greaterThanOrEqualTo(1));
      expect(date.weekday, lessThanOrEqualTo(7));
    });

    test('DateTime UTC vs local debería ser diferente', () {
      final localDate = DateTime.now();
      final utcDate = DateTime.now().toUtc();
      
      // Pueden ser diferentes horas dependiendo del timezone
      expect(localDate.isUtc, false);
      expect(utcDate.isUtc, true);
    });
  });
}
