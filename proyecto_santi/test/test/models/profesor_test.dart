import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/models/departamento.dart';

void main() {
  group('Profesor Model Tests', () {
    final departamentoJson = {
      'id': 1,
      'codigo': 'INF',
      'nombre': 'Informática',
    };

    test('Debería crearse correctamente desde JSON completo', () {
      // Arrange
      final json = {
        'uuid': '123e4567-e89b-12d3-a456-426614174000',
        'dni': '12345678A',
        'nombre': 'Juan',
        'apellidos': 'Pérez García',
        'correo': 'juan.perez@example.com',
        'password': 'hashedPassword123',
        'rol': 'Profesor',
        'activo': 1,
        'urlFoto': 'https://example.com/foto.jpg',
        'esJefeDep': 1,
        'depart': departamentoJson,
      };

      // Act
      final profesor = Profesor.fromJson(json);

      // Assert
      expect(profesor.uuid, '123e4567-e89b-12d3-a456-426614174000');
      expect(profesor.dni, '12345678A');
      expect(profesor.nombre, 'Juan');
      expect(profesor.apellidos, 'Pérez García');
      expect(profesor.correo, 'juan.perez@example.com');
      expect(profesor.password, 'hashedPassword123');
      expect(profesor.rol, 'Profesor');
      expect(profesor.activo, 1);
      expect(profesor.urlFoto, 'https://example.com/foto.jpg');
      expect(profesor.esJefeDep, 1);
      expect(profesor.depart, isNotNull);
      expect(profesor.depart.nombre, 'Informática');
    });

    test('Debería manejar urlFoto nula correctamente', () {
      // Arrange
      final json = {
        'uuid': '123e4567-e89b-12d3-a456-426614174001',
        'dni': '87654321B',
        'nombre': 'María',
        'apellidos': 'López Sánchez',
        'correo': 'maria.lopez@example.com',
        'password': 'password456',
        'rol': 'Coordinador',
        'activo': 1,
        'urlFoto': null,
        'esJefeDep': 0,
        'depart': departamentoJson,
      };

      // Act
      final profesor = Profesor.fromJson(json);

      // Assert
      expect(profesor.urlFoto, null);
      expect(profesor.nombre, 'María');
      expect(profesor.esJefeDep, 0);
    });

    test('Debería convertirse a JSON correctamente', () {
      // Arrange
      final departamento = Departamento.fromJson(departamentoJson);
      final profesor = Profesor(
        uuid: 'test-uuid-123',
        dni: '11111111C',
        nombre: 'Carlos',
        apellidos: 'Martínez Ruiz',
        correo: 'carlos@test.com',
        password: 'pass789',
        rol: 'Administrador',
        activo: 1,
        urlFoto: 'http://test.com/photo.png',
        esJefeDep: 1,
        depart: departamento,
      );

      // Act
      final json = profesor.toJson();

      // Assert
      expect(json['uuid'], 'test-uuid-123');
      expect(json['dni'], '11111111C');
      expect(json['nombre'], 'Carlos');
      expect(json['apellidos'], 'Martínez Ruiz');
      expect(json['correo'], 'carlos@test.com');
      expect(json['password'], 'pass789');
      expect(json['rol'], 'Administrador');
      expect(json['activo'], 1);
      expect(json['urlFoto'], 'http://test.com/photo.png');
      expect(json['esJefeDep'], 1);
      expect(json['depart'], isNotNull);
      expect(json['depart']['nombre'], 'Informática');
    });

    test('Debería crear profesor sin foto', () {
      // Arrange
      final departamento = Departamento(id: 2, codigo: 'MAT', nombre: 'Matemáticas');
      
      // Act
      final profesor = Profesor(
        uuid: 'uuid-sin-foto',
        dni: '22222222D',
        nombre: 'Ana',
        apellidos: 'González',
        correo: 'ana@test.com',
        password: 'secure123',
        rol: 'Profesor',
        activo: 1,
        esJefeDep: 0,
        depart: departamento,
      );

      // Assert
      expect(profesor.urlFoto, null);
      expect(profesor.nombre, 'Ana');
      expect(profesor.depart.nombre, 'Matemáticas');
    });

    test('fromJson y toJson deberían ser inversos', () {
      // Arrange
      final jsonOriginal = {
        'uuid': 'reverse-test-uuid',
        'dni': '33333333E',
        'nombre': 'Pedro',
        'apellidos': 'Fernández',
        'correo': 'pedro@test.com',
        'password': 'pwd999',
        'rol': 'Tutor',
        'activo': 1,
        'urlFoto': 'http://foto.com/pedro.jpg',
        'esJefeDep': 0,
        'depart': departamentoJson,
      };

      // Act
      final profesor = Profesor.fromJson(jsonOriginal);
      final jsonResultado = profesor.toJson();

      // Assert
      expect(jsonResultado['uuid'], jsonOriginal['uuid']);
      expect(jsonResultado['dni'], jsonOriginal['dni']);
      expect(jsonResultado['nombre'], jsonOriginal['nombre']);
      expect(jsonResultado['correo'], jsonOriginal['correo']);
      expect(jsonResultado['depart']['nombre'], 'Informática');
    });

    test('Debería manejar profesor inactivo', () {
      // Arrange
      final json = {
        'uuid': 'inactive-uuid',
        'dni': '44444444F',
        'nombre': 'Luis',
        'apellidos': 'Rodríguez',
        'correo': 'luis@test.com',
        'password': 'pass000',
        'rol': 'Profesor',
        'activo': 0,
        'urlFoto': null,
        'esJefeDep': 0,
        'depart': departamentoJson,
      };

      // Act
      final profesor = Profesor.fromJson(json);

      // Assert
      expect(profesor.activo, 0);
      expect(profesor.nombre, 'Luis');
    });

    test('Debería identificar jefe de departamento', () {
      // Arrange
      final departamento = Departamento(id: 3, codigo: 'FIS', nombre: 'Física');
      final profesor = Profesor(
        uuid: 'jefe-uuid',
        dni: '55555555G',
        nombre: 'Carmen',
        apellidos: 'Vega',
        correo: 'carmen@test.com',
        password: 'jefe123',
        rol: 'Jefe de Departamento',
        activo: 1,
        esJefeDep: 1,
        depart: departamento,
      );

      // Assert
      expect(profesor.esJefeDep, 1);
      expect(profesor.rol, 'Jefe de Departamento');
      expect(profesor.depart.nombre, 'Física');
    });
  });
}
