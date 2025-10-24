import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_santi/utils/date_formatter.dart';

void main() {
  group('DateFormatter.formatDate Tests', () {
    test('Debería formatear fecha como dd/MM/yyyy', () {
      final date = DateTime(2025, 10, 23);
      final result = DateFormatter.formatDate(date);
      
      expect(result, '23/10/2025');
    });

    test('Debería agregar cero a día de un dígito', () {
      final date = DateTime(2025, 10, 5);
      final result = DateFormatter.formatDate(date);
      
      expect(result, '05/10/2025');
    });

    test('Debería agregar cero a mes de un dígito', () {
      final date = DateTime(2025, 3, 23);
      final result = DateFormatter.formatDate(date);
      
      expect(result, '23/03/2025');
    });
  });

  group('DateFormatter.formatTime Tests', () {
    test('Debería formatear hora como HH:mm', () {
      final time = DateTime(2025, 10, 23, 14, 30);
      final result = DateFormatter.formatTime(time);
      
      expect(result, '14:30');
    });

    test('Debería agregar cero a horas de un dígito', () {
      final time = DateTime(2025, 10, 23, 9, 30);
      final result = DateFormatter.formatTime(time);
      
      expect(result, '09:30');
    });

    test('Debería agregar cero a minutos de un dígito', () {
      final time = DateTime(2025, 10, 23, 14, 5);
      final result = DateFormatter.formatTime(time);
      
      expect(result, '14:05');
    });
  });

  group('DateFormatter.formatDateTime Tests', () {
    test('Debería formatear fecha y hora', () {
      final dateTime = DateTime(2025, 10, 23, 14, 30);
      final result = DateFormatter.formatDateTime(dateTime);
      
      expect(result, '23/10/2025 14:30');
    });
  });

  group('DateFormatter.parseIsoString Tests', () {
    test('Debería parsear string ISO 8601', () {
      final result = DateFormatter.parseIsoString('2025-10-23T14:30:00');
      
      expect(result, isNotNull);
      expect(result!.year, 2025);
      expect(result.month, 10);
      expect(result.day, 23);
      expect(result.hour, 14);
      expect(result.minute, 30);
    });

    test('Debería retornar null para string vacío', () {
      final result = DateFormatter.parseIsoString('');
      
      expect(result, null);
    });

    test('Debería retornar null para string null', () {
      final result = DateFormatter.parseIsoString(null);
      
      expect(result, null);
    });

    test('Debería retornar null para string inválido', () {
      final result = DateFormatter.parseIsoString('fecha-invalida');
      
      expect(result, null);
    });
  });

  group('DateFormatter.parseSpanishDate Tests', () {
    test('Debería parsear fecha en formato español', () {
      final result = DateFormatter.parseSpanishDate('23/10/2025');
      
      expect(result, isNotNull);
      expect(result!.day, 23);
      expect(result.month, 10);
      expect(result.year, 2025);
    });

    test('Debería retornar null para string vacío', () {
      final result = DateFormatter.parseSpanishDate('');
      
      expect(result, null);
    });

    test('Debería retornar null para string null', () {
      final result = DateFormatter.parseSpanishDate(null);
      
      expect(result, null);
    });
  });

  group('DateFormatter.daysBetween Tests', () {
    test('Debería calcular días entre fechas', () {
      final from = DateTime(2025, 10, 23);
      final to = DateTime(2025, 10, 28);
      
      final result = DateFormatter.daysBetween(from, to);
      
      expect(result, 5);
    });

    test('Debería retornar 0 para el mismo día', () {
      final from = DateTime(2025, 10, 23, 10, 0);
      final to = DateTime(2025, 10, 23, 18, 0);
      
      final result = DateFormatter.daysBetween(from, to);
      
      expect(result, 0);
    });

    test('Debería retornar negativo para fechas en orden inverso', () {
      final from = DateTime(2025, 10, 28);
      final to = DateTime(2025, 10, 23);
      
      final result = DateFormatter.daysBetween(from, to);
      
      expect(result, -5);
    });
  });

  group('DateFormatter.isToday Tests', () {
    test('Debería identificar fecha de hoy', () {
      final today = DateTime.now();
      final result = DateFormatter.isToday(today);
      
      expect(result, true);
    });

    test('Debería identificar que ayer no es hoy', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final result = DateFormatter.isToday(yesterday);
      
      expect(result, false);
    });

    test('Debería ignorar la hora al comparar', () {
      final now = DateTime.now();
      final todayDifferentTime = DateTime(now.year, now.month, now.day, 0, 0, 0);
      final result = DateFormatter.isToday(todayDifferentTime);
      
      expect(result, true);
    });
  });

  group('DateFormatter.isTomorrow Tests', () {
    test('Debería identificar fecha de mañana', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final result = DateFormatter.isTomorrow(tomorrow);
      
      expect(result, true);
    });

    test('Debería identificar que hoy no es mañana', () {
      final today = DateTime.now();
      final result = DateFormatter.isTomorrow(today);
      
      expect(result, false);
    });
  });

  group('DateFormatter.getRelativeDateText Tests', () {
    test('Debería retornar "Hoy" para fecha actual', () {
      final today = DateTime.now();
      final result = DateFormatter.getRelativeDateText(today);
      
      expect(result, 'Hoy');
    });

    test('Debería retornar "Mañana" para mañana', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final result = DateFormatter.getRelativeDateText(tomorrow);
      
      expect(result, 'Mañana');
    });

    test('Debería retornar "Ayer" para ayer', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final result = DateFormatter.getRelativeDateText(yesterday);
      
      expect(result, 'Ayer');
    });

    test('Debería retornar "En X días" para futuro cercano', () {
      final future = DateTime.now().add(const Duration(days: 3));
      final result = DateFormatter.getRelativeDateText(future);
      
      expect(result, contains('En'));
      expect(result, contains('días'));
    });

    test('Debería retornar "Hace X días" para pasado cercano', () {
      final past = DateTime.now().subtract(const Duration(days: 3));
      final result = DateFormatter.getRelativeDateText(past);
      
      expect(result, contains('Hace'));
      expect(result, contains('días'));
    });

    test('Debería retornar fecha formateada para fechas lejanas', () {
      final farFuture = DateTime.now().add(const Duration(days: 30));
      final result = DateFormatter.getRelativeDateText(farFuture);
      
      expect(result, contains('/'));
    });
  });

  group('DateFormatter.parseTimeString Tests', () {
    test('Debería parsear string de hora', () {
      final result = DateFormatter.parseTimeString('14:30');
      
      expect(result, isNotNull);
      expect(result!.hour, 14);
      expect(result.minute, 30);
    });

    test('Debería parsear hora con ceros', () {
      final result = DateFormatter.parseTimeString('09:05');
      
      expect(result, isNotNull);
      expect(result!.hour, 9);
      expect(result.minute, 5);
    });

    test('Debería retornar null para string vacío', () {
      final result = DateFormatter.parseTimeString('');
      
      expect(result, null);
    });

    test('Debería retornar null para string null', () {
      final result = DateFormatter.parseTimeString(null);
      
      expect(result, null);
    });

    test('Debería retornar null para formato incorrecto', () {
      final result = DateFormatter.parseTimeString('14-30');
      
      expect(result, null);
    });
  });

  group('DateFormatter.formatDuration Tests', () {
    test('Debería formatear duración con horas y minutos', () {
      const duration = Duration(hours: 2, minutes: 30);
      final result = DateFormatter.formatDuration(duration);
      
      expect(result, '2h 30min');
    });

    test('Debería formatear solo minutos cuando no hay horas', () {
      const duration = Duration(minutes: 45);
      final result = DateFormatter.formatDuration(duration);
      
      expect(result, '45min');
    });

    test('Debería formatear horas exactas', () {
      const duration = Duration(hours: 3);
      final result = DateFormatter.formatDuration(duration);
      
      expect(result, '3h 0min');
    });

    test('Debería manejar duraciones de 0 minutos', () {
      const duration = Duration();
      final result = DateFormatter.formatDuration(duration);
      
      expect(result, '0min');
    });
  });
}
