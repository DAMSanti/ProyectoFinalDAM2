import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_santi/models/departamento.dart';
void main() {
  group('Departamento Model', () {
    group('Constructor', () {
      test('debe crear un Departamento con todos los campos', () {
        final departamento = Departamento(
          id: 1,
          codigo: 'INF',
          nombre: 'Informática',
          descripcion: 'Departamento de Informática',
        );
        expect(departamento.id, 1);
        expect(departamento.codigo, 'INF');
        expect(departamento.nombre, 'Informática');
        expect(departamento.descripcion, 'Departamento de Informática');
      });
      test('debe crear un Departamento con campos opcionales nulos', () {
        final departamento = Departamento(
          id: 2,
          nombre: 'Matemáticas',
        );
        expect(departamento.id, 2);
        expect(departamento.codigo, isNull);
        expect(departamento.nombre, 'Matemáticas');
        expect(departamento.descripcion, isNull);
      });
    });
    group('fromJson', () {
      test('debe parsear correctamente un JSON con todos los campos', () {
        final json = {
          'id': 1,
          'codigo': 'INF',
          'nombre': 'Informática',
          'descripcion': 'Departamento de Informática',
        };
        final departamento = Departamento.fromJson(json);
        expect(departamento.id, 1);
        expect(departamento.codigo, 'INF');
        expect(departamento.nombre, 'Informática');
        expect(departamento.descripcion, 'Departamento de Informática');
      });
      test('debe parsear JSON con claves alternativas (mayúsculas)', () {
        final json = {
          'Id': 3,
          'Nombre': 'Lengua',
          'Descripcion': 'Departamento de Lengua',
        };
        final departamento = Departamento.fromJson(json);
        expect(departamento.id, 3);
        expect(departamento.nombre, 'Lengua');
        expect(departamento.descripcion, 'Departamento de Lengua');
      });
      test('debe manejar campos faltantes sin fallar', () {
        final json = {
          'id': 4,
          'nombre': 'Física',
        };
        final departamento = Departamento.fromJson(json);
        expect(departamento.id, 4);
        expect(departamento.nombre, 'Física');
        expect(departamento.codigo, isNull);
        expect(departamento.descripcion, isNull);
      });
    });
    group('toJson', () {
      test('debe serializar correctamente a JSON', () {
        final departamento = Departamento(
          id: 1,
          codigo: 'INF',
          nombre: 'Informática',
          descripcion: 'Departamento de Informática',
        );
        final json = departamento.toJson();
        expect(json['id'], 1);
        expect(json['codigo'], 'INF');
        expect(json['nombre'], 'Informática');
        expect(json['descripcion'], 'Departamento de Informática');
      });
      test('debe incluir campos nulos en la serialización', () {
        final departamento = Departamento(
          id: 2,
          nombre: 'Matemáticas',
        );
        final json = departamento.toJson();
        expect(json.containsKey('codigo'), true);
        expect(json['codigo'], isNull);
        expect(json.containsKey('descripcion'), true);
        expect(json['descripcion'], isNull);
      });
    });
    group('Serialización bidireccional', () {
      test('toJson y fromJson deben ser operaciones inversas', () {
        final original = Departamento(
          id: 5,
          codigo: 'QUI',
          nombre: 'Química',
          descripcion: 'Departamento de Química',
        );
        final json = original.toJson();
        final restored = Departamento.fromJson(json);
        expect(restored.id, original.id);
        expect(restored.codigo, original.codigo);
        expect(restored.nombre, original.nombre);
        expect(restored.descripcion, original.descripcion);
      });
    });
  });
}