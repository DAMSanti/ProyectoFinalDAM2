import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/services/auth_service.dart';
import 'package:proyecto_santi/models/profesor.dart';
@GenerateMocks([ApiService])
import 'auth_service_test.mocks.dart';
void main() {
  group('AuthService Integration Tests', () {
    late MockApiService mockApiService;
    late AuthService authService;
    setUp(() {
      mockApiService = MockApiService();
      authService = AuthService(mockApiService);
      mockApiService.setToken(null);
    });
    group('login', () {
      test('debe retornar datos de usuario con token válido', () async {
        final mockResponse = Response(
          requestOptions: RequestOptions(path: '/api/auth/login'),
          statusCode: 200,
          data: {
            'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.signature',
            'usuario': {
              'id': 1,
              'nombreUsuario': 'profesor1',
              'email': 'profesor@test.com',
              'rol': 'Profesor',
            },
          },
        );
        when(mockApiService.postData(any, any)).thenAnswer((_) async => mockResponse);
        final result = await authService.login('profesor@test.com', 'password123');
        expect(result, isNotNull);
        expect(result!['token'], isNotNull);
        expect(result['usuario']['rol'], 'Profesor');
        verify(mockApiService.postData(
          argThat(contains('login')),
          any,
        )).called(1);
        verify(mockApiService.setToken(any)).called(greaterThan(0));
      });
      test('debe retornar null con credenciales inválidas', () async {
        when(mockApiService.postData(any, any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 401,
              data: {'message': 'Credenciales inválidas'},
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        final result = await authService.login('usuario@test.com', 'wrongpassword');
        expect(result, isNull);
      });
      test('debe retornar null si no hay token en la respuesta', () async {
        final mockResponse = Response(
          requestOptions: RequestOptions(path: '/api/auth/login'),
          statusCode: 200,
          data: {
            'usuario': {'id': 1, 'nombreUsuario': 'test'},
          },
        );
        when(mockApiService.postData(any, any)).thenAnswer((_) async => mockResponse);
        final result = await authService.login('test@test.com', 'password');
        expect(result, isNull);
      });
      test('debe manejar errores de conexión gracefully', () async {
        when(mockApiService.postData(any, any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionTimeout,
            message: 'Connection timeout',
          ),
        );
        final result = await authService.login('test@test.com', 'password');
        expect(result, isNull);
      });
    });
    group('logout', () {
      test('debe limpiar el token al hacer logout', () {
        authService.logout();
        verify(mockApiService.setToken(null)).called(greaterThan(0));
      });
    });
    group('isAuthenticated', () {
      test('debe retornar false cuando no hay token', () {
        when(mockApiService.token).thenReturn(null);
        expect(authService.isAuthenticated, false);
      });
      test('debe retornar true cuando hay token', () {
        when(mockApiService.token).thenReturn('valid-token');
        expect(authService.isAuthenticated, true);
      });
    });
    group('Flujo completo de autenticación', () {
      test('login -> verificar autenticación -> logout', () async {
        final loginResponse = Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {
            'token': 'jwt-token-123',
            'usuario': {
              'id': 1,
              'nombreUsuario': 'admin',
              'rol': 'Admin',
            },
          },
        );
        when(mockApiService.postData(any, any)).thenAnswer((_) async => loginResponse);
        final loginResult = await authService.login('admin@test.com', 'admin123');
        expect(loginResult, isNotNull);
        expect(loginResult!['token'], 'jwt-token-123');
        verify(mockApiService.setToken('jwt-token-123')).called(greaterThan(0));
        authService.logout();
        verify(mockApiService.setToken(null)).called(greaterThan(0));
      });
    });
    group('Roles de usuario', () {
      test('debe identificar rol de Administrador', () async {
        final mockResponse = Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {
            'token': 'admin-token',
            'usuario': {
              'id': 1,
              'nombreUsuario': 'admin',
              'rol': 'Admin',
            },
          },
        );
        when(mockApiService.postData(any, any)).thenAnswer((_) async => mockResponse);
        final result = await authService.login('admin@test.com', 'password');
        expect(result!['usuario']['rol'], 'Admin');
      });
      test('debe identificar rol de Coordinador', () async {
        final mockResponse = Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {
            'token': 'coord-token',
            'usuario': {
              'id': 2,
              'nombreUsuario': 'coordinador',
              'rol': 'Coordinador',
            },
          },
        );
        when(mockApiService.postData(any, any)).thenAnswer((_) async => mockResponse);
        final result = await authService.login('coord@test.com', 'password');
        expect(result!['usuario']['rol'], 'Coordinador');
      });
    });
  });
}