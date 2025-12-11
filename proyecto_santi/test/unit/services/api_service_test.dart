import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_santi/services/api_service.dart';
void main() {
  group('ApiException', () {
    test('debe crear excepción con mensaje', () {
      final exception = ApiException('Error de prueba');
      expect(exception.message, 'Error de prueba');
      expect(exception.statusCode, isNull);
      expect(exception.data, isNull);
    });
    test('debe crear excepción con código de estado', () {
      final exception = ApiException(
        'No autorizado',
        statusCode: 401,
      );
      expect(exception.message, 'No autorizado');
      expect(exception.statusCode, 401);
    });
    test('debe crear excepción con datos adicionales', () {
      final errorData = {'field': 'email', 'error': 'Formato inválido'};
      final exception = ApiException(
        'Error de validación',
        statusCode: 400,
        data: errorData,
      );
      expect(exception.message, 'Error de validación');
      expect(exception.statusCode, 400);
      expect(exception.data, errorData);
    });
    test('toString debe mostrar mensaje y código', () {
      final exception = ApiException('Error', statusCode: 500);
      final result = exception.toString();
      expect(result, contains('ApiException'));
      expect(result, contains('Error'));
      expect(result, contains('500'));
    });
  });
  group('ApiService', () {
    late ApiService apiService;
    setUp(() {
      apiService = ApiService();
    });
    group('Token Management', () {
      test('debe iniciar sin token', () {
        expect(apiService.token, isNull);
      });
      test('debe establecer token correctamente', () {
        const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
        apiService.setToken(token);
        expect(apiService.token, token);
      });
      test('debe poder eliminar token (logout)', () {
        apiService.setToken('some-token');
        apiService.setToken(null);
        expect(apiService.token, isNull);
      });
      test('token debe ser compartido entre instancias (singleton pattern)', () {
        final apiService1 = ApiService();
        final apiService2 = ApiService();
        const token = 'shared-token';
        apiService1.setToken(token);
        expect(apiService2.token, token);
        apiService1.setToken(null);
      });
    });
    group('Dio Instance', () {
      test('debe exponer instancia de Dio', () {
        expect(apiService.dio, isNotNull);
      });
      test('Dio debe tener configuración base correcta', () {
        final options = apiService.dio.options;
        expect(options.headers['Content-Type'], 'application/json');
        expect(options.headers['Accept'], 'application/json');
      });
    });
  });
}