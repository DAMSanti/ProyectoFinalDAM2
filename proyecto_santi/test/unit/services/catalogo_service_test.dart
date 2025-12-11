import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/services/catalogo_service.dart';
import 'package:proyecto_santi/models/departamento.dart';
@GenerateMocks([ApiService])
import 'catalogo_service_test.mocks.dart';
void main() {
  group('CatalogoService Integration Tests', () {
    late MockApiService mockApiService;
    late CatalogoService catalogoService;
    setUp(() {
      mockApiService = MockApiService();
      catalogoService = CatalogoService(mockApiService);
    });
    group('fetchDepartamentos', () {
      test('debe retornar lista de departamentos cuando la API responde correctamente', () async {
        final mockResponse = Response(
          requestOptions: RequestOptions(path: '/api/departamentos'),
          statusCode: 200,
          data: [
            {'id': 1, 'codigo': 'INF', 'nombre': 'Informática', 'descripcion': 'Dep. Informática'},
            {'id': 2, 'codigo': 'MAT', 'nombre': 'Matemáticas', 'descripcion': 'Dep. Matemáticas'},
            {'id': 3, 'codigo': 'LEN', 'nombre': 'Lengua', 'descripcion': 'Dep. Lengua'},
          ],
        );
        when(mockApiService.getData(any)).thenAnswer((_) async => mockResponse);
        final departamentos = await catalogoService.fetchDepartamentos();
        expect(departamentos, isA<List<Departamento>>());
        expect(departamentos.length, 3);
        expect(departamentos[0].nombre, 'Informática');
        expect(departamentos[1].codigo, 'MAT');
        expect(departamentos[2].id, 3);
        verify(mockApiService.getData(any)).called(1);
      });
      test('debe retornar lista vacía cuando no hay departamentos', () async {
        final mockResponse = Response(
          requestOptions: RequestOptions(path: '/api/departamentos'),
          statusCode: 200,
          data: [],
        );
        when(mockApiService.getData(any)).thenAnswer((_) async => mockResponse);
        final departamentos = await catalogoService.fetchDepartamentos();
        expect(departamentos, isEmpty);
      });
      test('debe lanzar ApiException cuando el servidor responde con error', () async {
        final mockResponse = Response(
          requestOptions: RequestOptions(path: '/api/departamentos'),
          statusCode: 500,
          data: null,
        );
        when(mockApiService.getData(any)).thenAnswer((_) async => mockResponse);
        expect(
          () => catalogoService.fetchDepartamentos(),
          throwsA(isA<ApiException>()),
        );
      });
    });
    group('createDepartamento', () {
      test('debe crear departamento y retornar el objeto creado', () async {
        final nuevoDepto = {
          'codigo': 'FIS',
          'nombre': 'Física',
          'descripcion': 'Departamento de Física',
        };
        final mockResponse = Response(
          requestOptions: RequestOptions(path: '/api/departamentos'),
          statusCode: 201,
          data: {
            'id': 4,
            'codigo': 'FIS',
            'nombre': 'Física',
            'descripcion': 'Departamento de Física',
          },
        );
        when(mockApiService.postData(any, any)).thenAnswer((_) async => mockResponse);
        final resultado = await catalogoService.createDepartamento(nuevoDepto);
        expect(resultado, isA<Departamento>());
        expect(resultado.id, 4);
        expect(resultado.nombre, 'Física');
        verify(mockApiService.postData(any, nuevoDepto)).called(1);
      });
      test('debe lanzar excepción si el código ya existe (409 Conflict)', () async {
        final deptoExistente = {
          'codigo': 'INF',
          'nombre': 'Informática Duplicada',
        };
        when(mockApiService.postData(any, any)).thenThrow(
          ApiException('El código ya existe', statusCode: 409),
        );
        expect(
          () => catalogoService.createDepartamento(deptoExistente),
          throwsA(isA<ApiException>()),
        );
      });
    });
    group('updateDepartamento', () {
      test('debe actualizar departamento correctamente', () async {
        final datosActualizados = {
          'nombre': 'Informática y Comunicaciones',
          'descripcion': 'Departamento actualizado',
        };
        final mockResponse = Response(
          requestOptions: RequestOptions(path: '/api/departamentos/1'),
          statusCode: 200,
          data: {
            'id': 1,
            'codigo': 'INF',
            'nombre': 'Informática y Comunicaciones',
            'descripcion': 'Departamento actualizado',
          },
        );
        when(mockApiService.putData(any, any)).thenAnswer((_) async => mockResponse);
        final resultado = await catalogoService.updateDepartamento(1, datosActualizados);
        expect(resultado.nombre, 'Informática y Comunicaciones');
        expect(resultado.descripcion, 'Departamento actualizado');
      });
      test('debe lanzar excepción si el departamento no existe (404)', () async {
        when(mockApiService.putData(any, any)).thenThrow(
          ApiException('Departamento no encontrado', statusCode: 404),
        );
        expect(
          () => catalogoService.updateDepartamento(999, {'nombre': 'Test'}),
          throwsA(isA<ApiException>()),
        );
      });
    });
    group('deleteDepartamento', () {
      test('debe eliminar departamento y retornar true', () async {
        final mockResponse = Response(
          requestOptions: RequestOptions(path: '/api/departamentos/1'),
          statusCode: 204,
          data: null,
        );
        when(mockApiService.deleteData(any)).thenAnswer((_) async => mockResponse);
        final resultado = await catalogoService.deleteDepartamento(1);
        expect(resultado, true);
        verify(mockApiService.deleteData(argThat(contains('1')))).called(1);
      });
      test('debe retornar false si la eliminación falla', () async {
        final mockResponse = Response(
          requestOptions: RequestOptions(path: '/api/departamentos/1'),
          statusCode: 400,
          data: {'error': 'No se puede eliminar, tiene dependencias'},
        );
        when(mockApiService.deleteData(any)).thenAnswer((_) async => mockResponse);
        final resultado = await catalogoService.deleteDepartamento(1);
        expect(resultado, false);
      });
    });
    group('Flujo completo CRUD', () {
      test('debe poder crear, leer, actualizar y eliminar un departamento', () async {
        when(mockApiService.postData(any, any)).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 201,
          data: {'id': 10, 'codigo': 'NEW', 'nombre': 'Nuevo Depto'},
        ));
        final nuevo = await catalogoService.createDepartamento({
          'codigo': 'NEW',
          'nombre': 'Nuevo Depto',
        });
        expect(nuevo.id, 10);
        when(mockApiService.getData(any)).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: [{'id': 10, 'codigo': 'NEW', 'nombre': 'Nuevo Depto'}],
        ));
        final lista = await catalogoService.fetchDepartamentos();
        expect(lista.any((d) => d.id == 10), true);
        when(mockApiService.putData(any, any)).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {'id': 10, 'codigo': 'NEW', 'nombre': 'Depto Actualizado'},
        ));
        final actualizado = await catalogoService.updateDepartamento(10, {
          'nombre': 'Depto Actualizado',
        });
        expect(actualizado.nombre, 'Depto Actualizado');
        when(mockApiService.deleteData(any)).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 204,
          data: null,
        ));
        final eliminado = await catalogoService.deleteDepartamento(10);
        expect(eliminado, true);
      });
    });
  });
}