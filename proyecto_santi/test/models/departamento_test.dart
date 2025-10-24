import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_santi/models/departamento.dart';

void main() {
  group('Departamento Model Tests', () {
    test('Debería crearse correctamente desde JSON completo', () {
      // Arrange
      final json = {
        'id': 1,
        'codigo': 'INF',
        'nombre': 'Informática',
      };

      // Act
      final departamento = Departamento.fromJson(json);

      // Assert
      expect(departamento.id, 1);
      expect(departamento.codigo, 'INF');
      expect(departamento.nombre, 'Informática');
    });

    test('Debería convertirse a JSON correctamente', () {
      // Arrange
      final departamento = Departamento(
        id: 2,
        codigo: 'MAT',
        nombre: 'Matemáticas',
      );

      // Act
      final json = departamento.toJson();

      // Assert
      expect(json['id'], 2);
      expect(json['codigo'], 'MAT');
      expect(json['nombre'], 'Matemáticas');
    });

    test('Debería manejar diferentes tipos de departamentos', () {
      // Arrange
      final departamentos = [
        {'id': 1, 'codigo': 'FIS', 'nombre': 'Física'},
        {'id': 2, 'codigo': 'QUI', 'nombre': 'Química'},
        {'id': 3, 'codigo': 'BIO', 'nombre': 'Biología'},
      ];

      // Act
      final result = departamentos.map((json) => Departamento.fromJson(json)).toList();

      // Assert
      expect(result.length, 3);
      expect(result[0].codigo, 'FIS');
      expect(result[1].codigo, 'QUI');
      expect(result[2].codigo, 'BIO');
    });

    test('Debería crear instancia con constructor directo', () {
      // Act
      final departamento = Departamento(
        id: 99,
        codigo: 'TEST',
        nombre: 'Departamento de Prueba',
      );

      // Assert
      expect(departamento.id, 99);
      expect(departamento.codigo, 'TEST');
      expect(departamento.nombre, 'Departamento de Prueba');
    });

    test('fromJson y toJson deberían ser inversos', () {
      // Arrange
      final jsonOriginal = {
        'id': 10,
        'codigo': 'ART',
        'nombre': 'Artística',
      };

      // Act
      final departamento = Departamento.fromJson(jsonOriginal);
      final jsonResultado = departamento.toJson();

      // Assert
      expect(jsonResultado['id'], jsonOriginal['id']);
      expect(jsonResultado['codigo'], jsonOriginal['codigo']);
      expect(jsonResultado['nombre'], jsonOriginal['nombre']);
    });
  });
}
