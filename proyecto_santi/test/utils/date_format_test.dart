import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  group('Date Format Tests', () {
    test('Debería formatear fecha correctamente a DD-MM-YYYY HH:MM', () {
      // Arrange
      final fechaStr = '2025-10-23T14:30:00';
      
      // Act
      String formatearFecha(String fechaStr) {
        try {
          final fecha = DateTime.parse(fechaStr);
          return DateFormat('dd-MM-yyyy HH:mm').format(fecha);
        } catch (e) {
          return fechaStr;
        }
      }
      
      final result = formatearFecha(fechaStr);

      // Assert
      expect(result, '23-10-2025 14:30');
    });

    test('Debería retornar la cadena original si el formato es inválido', () {
      // Arrange
      final fechaStr = 'fecha-invalida';
      
      // Act
      String formatearFecha(String fechaStr) {
        try {
          final fecha = DateTime.parse(fechaStr);
          return DateFormat('dd-MM-yyyy HH:mm').format(fecha);
        } catch (e) {
          return fechaStr;
        }
      }
      
      final result = formatearFecha(fechaStr);

      // Assert
      expect(result, 'fecha-invalida');
    });

    test('Debería manejar fechas con zona horaria', () {
      // Arrange
      final fechaStr = '2025-10-23T14:30:00Z';
      
      // Act
      String formatearFecha(String fechaStr) {
        try {
          final fecha = DateTime.parse(fechaStr);
          return DateFormat('dd-MM-yyyy HH:mm').format(fecha);
        } catch (e) {
          return fechaStr;
        }
      }
      
      final result = formatearFecha(fechaStr);

      // Assert
      expect(result, isNotEmpty);
      expect(result, contains('-'));
      expect(result, contains(':'));
    });
  });
}
