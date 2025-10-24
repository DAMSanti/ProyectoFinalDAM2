import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_santi/services/api_service.dart';

void main() {
  group('ApiService Tests', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    test('ApiService debería inicializarse correctamente', () {
      // Assert
      expect(apiService, isNotNull);
      expect(apiService, isA<ApiService>());
    });

    // Nota: Para tests más completos de API, necesitarías mock/fake data
    // y dependencias como mockito. Estos son ejemplos básicos.
    
    test('fetchFutureActivities debería retornar una Future<List>', () async {
      // Arrange & Act
      final result = apiService.fetchFutureActivities();

      // Assert
      expect(result, isA<Future<List>>());
    });
  });
}
