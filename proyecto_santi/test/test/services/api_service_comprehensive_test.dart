import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_santi/services/api_service.dart';

void main() {
  group('ApiException Tests', () {
    test('Debería crear ApiException con mensaje', () {
      final exception = ApiException('Test error');
      
      expect(exception.message, 'Test error');
      expect(exception.statusCode, null);
      expect(exception.data, null);
    });

    test('Debería crear ApiException con código de estado', () {
      final exception = ApiException('Not Found', statusCode: 404);
      
      expect(exception.message, 'Not Found');
      expect(exception.statusCode, 404);
      expect(exception.toString(), contains('404'));
    });

    test('Debería crear ApiException con datos adicionales', () {
      final data = {'error': 'details'};
      final exception = ApiException('Error', statusCode: 500, data: data);
      
      expect(exception.message, 'Error');
      expect(exception.statusCode, 500);
      expect(exception.data, data);
    });

    test('toString debería incluir mensaje y código', () {
      final exception = ApiException('Server Error', statusCode: 500);
      final string = exception.toString();
      
      expect(string, contains('ApiException'));
      expect(string, contains('Server Error'));
      expect(string, contains('500'));
    });

    test('toString debería manejar null statusCode', () {
      final exception = ApiException('Unknown Error');
      final string = exception.toString();
      
      expect(string, contains('ApiException'));
      expect(string, contains('Unknown Error'));
      expect(string, contains('null'));
    });
  });

  group('ApiService Token Management Tests', () {
    test('Debería crear ApiService sin token inicial', () {
      final api = ApiService();
      
      expect(api.token, null);
    });

    test('Debería establecer y obtener token correctamente', () {
      final api = ApiService();
      const testToken = 'test-jwt-token-12345';
      
      api.setToken(testToken);
      
      expect(api.token, testToken);
    });

    test('Debería permitir cambiar el token', () {
      final api = ApiService();
      
      api.setToken('very-long-jwt-token-number-one-12345678');
      expect(api.token, 'very-long-jwt-token-number-one-12345678');
      
      api.setToken('very-long-jwt-token-number-two-87654321');
      expect(api.token, 'very-long-jwt-token-number-two-87654321');
    });

    test('Debería permitir eliminar el token estableciéndolo a null', () {
      final api = ApiService();
      
      api.setToken('some-very-long-token-for-testing-purposes-12345');
      expect(api.token, isNotNull);
      
      api.setToken(null);
      expect(api.token, null);
    });

    test('El token debería ser compartido entre instancias', () {
      final api1 = ApiService();
      final api2 = ApiService();
      
      api1.setToken('shared-token-between-all-instances-12345678');
      
      expect(api2.token, 'shared-token-between-all-instances-12345678');
      expect(api1.token, api2.token);
    });

    test('Cambiar token en una instancia debería afectar a todas', () {
      final api1 = ApiService();
      final api2 = ApiService();
      
      api1.setToken('token-from-first-api-instance-12345678');
      expect(api2.token, 'token-from-first-api-instance-12345678');
      
      api2.setToken('token-from-second-api-instance-87654321');
      expect(api1.token, 'token-from-second-api-instance-87654321');
    });

    test('Establecer null en una instancia debería afectar a todas', () {
      final api1 = ApiService();
      final api2 = ApiService();
      
      api1.setToken('shared-token-to-be-cleared-later-12345678');
      expect(api2.token, 'shared-token-to-be-cleared-later-12345678');
      
      api2.setToken(null);
      expect(api1.token, null);
      expect(api2.token, null);
    });
  });

  group('ApiService Basic Structure Tests', () {
    test('Debería crear instancia de ApiService', () {
      expect(() => ApiService(), returnsNormally);
    });

    test('Múltiples instancias deberían crearse sin errores', () {
      expect(() {
        final api1 = ApiService();
        final api2 = ApiService();
        final api3 = ApiService();
        
        expect(api1, isNotNull);
        expect(api2, isNotNull);
        expect(api3, isNotNull);
      }, returnsNormally);
    });

    test('Token debería persistir a través de recreación de instancias', () {
      var api1 = ApiService();
      api1.setToken('persistent-token-across-instances-12345678');
      
      var api2 = ApiService();
      expect(api2.token, 'persistent-token-across-instances-12345678');
      
      // Limpiar para otros tests
      api2.setToken(null);
    });
  });
}
