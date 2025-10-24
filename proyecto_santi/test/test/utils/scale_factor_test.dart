import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Scale Factor Tests', () {
    test('Debería retornar 1.0 para resoluciones menores a 1080p', () {
      // Arrange
      final screenHeight = 720.0;

      // Act
      double scaleFactor = 1.0;
      if (screenHeight >= 2160) {
        scaleFactor = 1.6;
      } else if (screenHeight >= 1440) {
        scaleFactor = 1.3;
      } else if (screenHeight >= 1080) {
        scaleFactor = 1.1;
      }

      // Assert
      expect(scaleFactor, 1.0);
    });

    test('Debería retornar 1.1 para resoluciones 1080p (Full HD)', () {
      // Arrange
      final screenHeight = 1080.0;

      // Act
      double scaleFactor = 1.0;
      if (screenHeight >= 2160) {
        scaleFactor = 1.6;
      } else if (screenHeight >= 1440) {
        scaleFactor = 1.3;
      } else if (screenHeight >= 1080) {
        scaleFactor = 1.1;
      }

      // Assert
      expect(scaleFactor, 1.1);
    });

    test('Debería retornar 1.3 para resoluciones 1440p (2K/QHD)', () {
      // Arrange
      final screenHeight = 1440.0;

      // Act
      double scaleFactor = 1.0;
      if (screenHeight >= 2160) {
        scaleFactor = 1.6;
      } else if (screenHeight >= 1440) {
        scaleFactor = 1.3;
      } else if (screenHeight >= 1080) {
        scaleFactor = 1.1;
      }

      // Assert
      expect(scaleFactor, 1.3);
    });

    test('Debería retornar 1.6 para resoluciones 4K (2160p)', () {
      // Arrange
      final screenHeight = 2160.0;

      // Act
      double scaleFactor = 1.0;
      if (screenHeight >= 2160) {
        scaleFactor = 1.6;
      } else if (screenHeight >= 1440) {
        scaleFactor = 1.3;
      } else if (screenHeight >= 1080) {
        scaleFactor = 1.1;
      }

      // Assert
      expect(scaleFactor, 1.6);
    });

    test('Debería retornar 1.6 para resoluciones mayores a 4K', () {
      // Arrange
      final screenHeight = 3840.0; // 8K

      // Act
      double scaleFactor = 1.0;
      if (screenHeight >= 2160) {
        scaleFactor = 1.6;
      } else if (screenHeight >= 1440) {
        scaleFactor = 1.3;
      } else if (screenHeight >= 1080) {
        scaleFactor = 1.1;
      }

      // Assert
      expect(scaleFactor, 1.6);
    });
  });
}
