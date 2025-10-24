import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_santi/models/photo.dart';
import 'package:proyecto_santi/models/actividad.dart';

void main() {
  group('Photo Model Tests', () {
    final actividadJson = {
      'id': 1,
      'titulo': 'Actividad Test',
      'descripcion': 'Descripción de prueba',
      'fini': '2025-10-23T10:00:00',
      'ffin': '2025-10-23T12:00:00',
      'estado': 'PENDIENTE',
    };

    test('Debería crearse correctamente desde JSON con URL', () {
      // Arrange
      final json = {
        'id': 1,
        'urlFoto': 'C:\\uploads\\actividad_photo.jpg',
        'descripcion': 'Foto de la excursión',
        'actividad': actividadJson,
      };

      // Act
      final photo = Photo.fromJson(json);

      // Assert
      expect(photo.id, 1);
      expect(photo.descripcion, 'Foto de la excursión');
      expect(photo.actividad, isNotNull);
      expect(photo.actividad.titulo, 'Actividad Test');
      expect(photo.urlFoto, contains('actividad/1/'));
      expect(photo.urlFoto, contains('actividad_photo.jpg'));
    });

    test('Debería manejar URL con espacios reemplazándolos por guiones bajos', () {
      // Arrange
      final json = {
        'id': 2,
        'urlFoto': 'C:\\uploads\\foto con espacios.jpg',
        'descripcion': 'Foto con espacios en nombre',
        'actividad': actividadJson,
      };

      // Act
      final photo = Photo.fromJson(json);

      // Assert
      expect(photo.urlFoto, contains('foto_con_espacios.jpg'));
      expect(photo.urlFoto, isNot(contains(' ')));
    });

    test('Debería manejar urlFoto nula correctamente', () {
      // Arrange
      final json = {
        'id': 3,
        'urlFoto': null,
        'descripcion': 'Sin foto',
        'actividad': actividadJson,
      };

      // Act
      final photo = Photo.fromJson(json);

      // Assert
      expect(photo.urlFoto, null);
      expect(photo.descripcion, 'Sin foto');
      expect(photo.actividad, isNotNull);
    });

    test('Debería usar descripción vacía cuando es nula', () {
      // Arrange
      final json = {
        'id': 4,
        'urlFoto': 'C:\\uploads\\test.jpg',
        'descripcion': null,
        'actividad': actividadJson,
      };

      // Act
      final photo = Photo.fromJson(json);

      // Assert
      expect(photo.descripcion, '');
    });

    test('Debería convertirse a JSON correctamente', () {
      // Arrange
      final actividad = Actividad.fromJson(actividadJson);
      final photo = Photo(
        id: 5,
        urlFoto: 'http://localhost:5000/images/actividad/1/test.jpg',
        descripcion: 'Foto de prueba',
        actividad: actividad,
      );

      // Act
      final json = photo.toJson();

      // Assert
      expect(json['id'], 5);
      expect(json['urlFoto'], 'http://localhost:5000/images/actividad/1/test.jpg');
      expect(json['descripcion'], 'Foto de prueba');
      expect(json['actividad'], isNotNull);
      expect(json['actividad']['titulo'], 'Actividad Test');
    });

    test('Debería permitir modificar la descripción', () {
      // Arrange
      final actividad = Actividad.fromJson(actividadJson);
      final photo = Photo(
        id: 6,
        urlFoto: 'http://test.com/photo.jpg',
        descripcion: 'Descripción original',
        actividad: actividad,
      );

      // Act
      photo.descripcion = 'Descripción modificada';

      // Assert
      expect(photo.descripcion, 'Descripción modificada');
    });

    test('Debería extraer nombre de archivo con barras invertidas (Windows)', () {
      // Arrange
      final json = {
        'id': 7,
        'urlFoto': 'C:\\Users\\Admin\\Documents\\uploads\\imagen_grande.png',
        'descripcion': 'Test Windows path',
        'actividad': actividadJson,
      };

      // Act
      final photo = Photo.fromJson(json);

      // Assert
      expect(photo.urlFoto, contains('imagen_grande.png'));
      expect(photo.urlFoto, isNot(contains('\\')));
    });

    test('Debería construir URL con ID de actividad correcto', () {
      // Arrange
      final actividadConId = {
        'id': 99,
        'titulo': 'Actividad Especial',
        'fini': '2025-11-01T09:00:00',
        'estado': 'APROBADA',
      };
      final json = {
        'id': 8,
        'urlFoto': 'C:\\uploads\\special_photo.jpg',
        'descripcion': 'Foto especial',
        'actividad': actividadConId,
      };

      // Act
      final photo = Photo.fromJson(json);

      // Assert
      expect(photo.urlFoto, contains('actividad/99/'));
      expect(photo.actividad.id, 99);
    });

    test('Debería manejar múltiples espacios en nombre de archivo', () {
      // Arrange
      final json = {
        'id': 9,
        'urlFoto': 'C:\\uploads\\foto  con   muchos    espacios.jpg',
        'descripcion': 'Espacios múltiples',
        'actividad': actividadJson,
      };

      // Act
      final photo = Photo.fromJson(json);

      // Assert
      expect(photo.urlFoto, contains('foto__con___muchos____espacios.jpg'));
    });

    test('fromJson debería crear objeto con todos los campos', () {
      // Arrange
      final json = {
        'id': 10,
        'urlFoto': 'C:\\path\\to\\file.jpg',
        'descripcion': 'Descripción completa',
        'actividad': {
          'id': 50,
          'titulo': 'Mi Actividad',
          'descripcion': 'Desc actividad',
          'fini': '2025-12-01T10:00:00',
          'estado': 'COMPLETADA',
        },
      };

      // Act
      final photo = Photo.fromJson(json);

      // Assert
      expect(photo.id, 10);
      expect(photo.urlFoto, isNotNull);
      expect(photo.descripcion, 'Descripción completa');
      expect(photo.actividad.titulo, 'Mi Actividad');
      expect(photo.actividad.estado, 'COMPLETADA');
    });
  });
}
