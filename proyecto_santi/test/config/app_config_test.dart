import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_santi/config.dart';

void main() {
  group('AppConfig Tests', () {
    test('Debería tener URL base de API definida', () {
      // Act
      final url = AppConfig.apiBaseUrl;

      // Assert
      expect(url, isNotNull);
      expect(url, isNotEmpty);
      expect(url, contains('http'));
      expect(url, contains('/api'));
    });

    test('Debería tener URL de imágenes definida', () {
      // Act
      final url = AppConfig.imagenesBaseUrl;

      // Assert
      expect(url, isNotNull);
      expect(url, isNotEmpty);
      expect(url, contains('http'));
      expect(url, contains('/uploads'));
    });

    test('Debería tener timeouts configurados correctamente', () {
      // Assert
      expect(AppConfig.connectionTimeout, isNotNull);
      expect(AppConfig.receiveTimeout, isNotNull);
      expect(AppConfig.connectionTimeout.inSeconds, 30);
      expect(AppConfig.receiveTimeout.inSeconds, 30);
    });

    test('Debería tener todos los endpoints definidos', () {
      // Assert
      expect(AppConfig.actividadEndpoint, '/Actividad');
      expect(AppConfig.profesorEndpoint, '/Profesor');
      expect(AppConfig.fotoEndpoint, '/Foto');
      expect(AppConfig.authEndpoint, '/Auth');
      expect(AppConfig.catalogosEndpoint, '/Catalogos');
      expect(AppConfig.contratoEndpoint, '/Contrato');
    });

    test('Endpoints deberían comenzar con /', () {
      // Assert
      expect(AppConfig.actividadEndpoint, startsWith('/'));
      expect(AppConfig.profesorEndpoint, startsWith('/'));
      expect(AppConfig.fotoEndpoint, startsWith('/'));
      expect(AppConfig.authEndpoint, startsWith('/'));
      expect(AppConfig.catalogosEndpoint, startsWith('/'));
      expect(AppConfig.contratoEndpoint, startsWith('/'));
    });

    test('URLs base deberían usar protocolo HTTP', () {
      // Act
      final apiUrl = AppConfig.apiBaseUrl;
      final imageUrl = AppConfig.imagenesBaseUrl;

      // Assert
      expect(apiUrl, startsWith('http://'));
      expect(imageUrl, startsWith('http://'));
    });

    test('Timeout de conexión debería ser igual al de recepción', () {
      // Assert
      expect(
        AppConfig.connectionTimeout.inSeconds,
        equals(AppConfig.receiveTimeout.inSeconds),
      );
    });

    test('Endpoints no deberían tener espacios', () {
      // Assert
      expect(AppConfig.actividadEndpoint, isNot(contains(' ')));
      expect(AppConfig.profesorEndpoint, isNot(contains(' ')));
      expect(AppConfig.fotoEndpoint, isNot(contains(' ')));
      expect(AppConfig.authEndpoint, isNot(contains(' ')));
      expect(AppConfig.catalogosEndpoint, isNot(contains(' ')));
      expect(AppConfig.contratoEndpoint, isNot(contains(' ')));
    });

    test('URLs deberían contener puerto 5000', () {
      // Act
      final apiUrl = AppConfig.apiBaseUrl;
      final imageUrl = AppConfig.imagenesBaseUrl;

      // Assert
      expect(apiUrl, contains('5000'));
      expect(imageUrl, contains('5000'));
    });

    test('Timeouts deberían ser Duration válidos', () {
      // Assert
      expect(AppConfig.connectionTimeout, isA<Duration>());
      expect(AppConfig.receiveTimeout, isA<Duration>());
      expect(AppConfig.connectionTimeout.inMilliseconds, greaterThan(0));
      expect(AppConfig.receiveTimeout.inMilliseconds, greaterThan(0));
    });
  });

  group('SecureStorageConfig Tests', () {
    test('SecureStorageConfig debería ser accesible', () {
      expect(SecureStorageConfig, isNotNull);
    });

    // Nota: Los tests de métodos async de SecureStorage requieren
    // TestWidgetsFlutterBinding.ensureInitialized() y mocking
    // Por simplicidad, solo verificamos que la clase existe
  });
}
