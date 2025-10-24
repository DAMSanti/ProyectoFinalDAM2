import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_santi/models/actividad.dart';

void main() {
  group('Actividad Model Tests', () {
    test('Debería crearse correctamente desde JSON completo', () {
      // Arrange
      final json = {
        'id': 1,
        'titulo': 'Test Activity',
        'tipo': 'Excursión',
        'descripcion': 'Test Description',
        'fini': '2025-10-23T10:00:00',
        'ffin': '2025-10-23T12:00:00',
        'hini': '10:00',
        'hfin': '12:00',
        'previstaIni': 1,
        'transporteReq': 1,
        'comentTransporte': 'Bus escolar',
        'alojamientoReq': 0,
        'comentAlojamiento': null,
        'comentarios': 'Actividad de prueba',
        'estado': 'PENDIENTE',
        'comentEstado': null,
        'incidencias': null,
        'urlFolleto': 'http://example.com/folleto.pdf',
        'solicitante': null,
        'importePorAlumno': 15.50,
        'latitud': 43.353,
        'longitud': -4.064,
      };

      // Act
      final actividad = Actividad.fromJson(json);

      // Assert
      expect(actividad.id, 1);
      expect(actividad.titulo, 'Test Activity');
      expect(actividad.tipo, 'Excursión');
      expect(actividad.descripcion, 'Test Description');
      expect(actividad.fini, '2025-10-23T10:00:00');
      expect(actividad.ffin, '2025-10-23T12:00:00');
      expect(actividad.hini, '10:00');
      expect(actividad.hfin, '12:00');
      expect(actividad.previstaIni, 1);
      expect(actividad.transporteReq, 1);
      expect(actividad.comentTransporte, 'Bus escolar');
      expect(actividad.alojamientoReq, 0);
      expect(actividad.estado, 'PENDIENTE');
      expect(actividad.importePorAlumno, 15.50);
      expect(actividad.latitud, 43.353);
      expect(actividad.longitud, -4.064);
    });

    test('Debería manejar campos nulos correctamente', () {
      // Arrange
      final json = {
        'id': 1,
        'titulo': 'Test Activity',
        'tipo': 'Taller',
        'fini': '2025-10-23T10:00:00',
        'ffin': '2025-10-23T12:00:00',
        'hini': '10:00',
        'hfin': '12:00',
        'previstaIni': 0,
        'transporteReq': 0,
        'alojamientoReq': 0,
        'estado': 'PENDIENTE',
      };

      // Act
      final actividad = Actividad.fromJson(json);

      // Assert
      expect(actividad.id, 1);
      expect(actividad.titulo, 'Test Activity');
      expect(actividad.descripcion, null);
      expect(actividad.comentTransporte, null);
      expect(actividad.comentAlojamiento, null);
      expect(actividad.comentarios, null);
      expect(actividad.comentEstado, null);
      expect(actividad.incidencias, null);
      expect(actividad.urlFolleto, null);
      expect(actividad.solicitante, null);
      expect(actividad.importePorAlumno, null);
      expect(actividad.latitud, null);
      expect(actividad.longitud, null);
    });

    test('Debería convertirse a JSON correctamente', () {
      // Arrange
      final json = {
        'id': 1,
        'titulo': 'Test Activity',
        'tipo': 'Conferencia',
        'descripcion': 'Test Description',
        'fini': '2025-10-23T10:00:00',
        'ffin': '2025-10-23T12:00:00',
        'hini': '10:00',
        'hfin': '12:00',
        'previstaIni': 1,
        'transporteReq': 1,
        'alojamientoReq': 0,
        'estado': 'APROBADA',
        'importePorAlumno': 25.0,
      };
      final actividad = Actividad.fromJson(json);

      // Act
      final result = actividad.toJson();

      // Assert
      expect(result['id'], 1);
      expect(result['titulo'], 'Test Activity');
      expect(result['descripcion'], 'Test Description');
      expect(result['tipo'], 'Conferencia');
      expect(result['estado'], 'APROBADA');
      expect(result['importePorAlumno'], 25.0);
    });

    test('Debería permitir modificar título y descripción', () {
      // Arrange
      final json = {
        'id': 1,
        'titulo': 'Título Original',
        'tipo': 'Evento',
        'descripcion': 'Descripción Original',
        'fini': '2025-10-23T10:00:00',
        'ffin': '2025-10-23T12:00:00',
        'hini': '10:00',
        'hfin': '12:00',
        'previstaIni': 1,
        'transporteReq': 0,
        'alojamientoReq': 0,
        'estado': 'PENDIENTE',
      };
      final actividad = Actividad.fromJson(json);

      // Act
      actividad.titulo = 'Título Modificado';
      actividad.descripcion = 'Descripción Modificada';

      // Assert
      expect(actividad.titulo, 'Título Modificado');
      expect(actividad.descripcion, 'Descripción Modificada');
    });

    test('Debería manejar coordenadas GPS modificables', () {
      // Arrange
      final json = {
        'id': 1,
        'titulo': 'Actividad con GPS',
        'tipo': 'Excursión',
        'fini': '2025-10-23T10:00:00',
        'ffin': '2025-10-23T12:00:00',
        'hini': '10:00',
        'hfin': '12:00',
        'previstaIni': 1,
        'transporteReq': 1,
        'alojamientoReq': 0,
        'estado': 'APROBADA',
        'latitud': 40.4168,
        'longitud': -3.7038,
      };
      final actividad = Actividad.fromJson(json);

      // Act
      actividad.latitud = 41.3851;
      actividad.longitud = 2.1734;

      // Assert
      expect(actividad.latitud, 41.3851);
      expect(actividad.longitud, 2.1734);
    });

    test('Debería manejar diferentes estados de actividad', () {
      // Arrange
      final estados = ['PENDIENTE', 'APROBADA', 'RECHAZADA', 'COMPLETADA', 'CANCELADA'];
      
      for (var estado in estados) {
        final json = {
          'id': 1,
          'titulo': 'Test',
          'tipo': 'Test',
          'fini': '2025-10-23T10:00:00',
          'ffin': '2025-10-23T12:00:00',
          'hini': '10:00',
          'hfin': '12:00',
          'previstaIni': 0,
          'transporteReq': 0,
          'alojamientoReq': 0,
          'estado': estado,
        };
        
        // Act
        final actividad = Actividad.fromJson(json);
        
        // Assert
        expect(actividad.estado, estado);
      }
    });

    test('Debería manejar actividad con solicitante', () {
      // Arrange
      final json = {
        'id': 1,
        'titulo': 'Actividad con Solicitante',
        'tipo': 'Taller',
        'fini': '2025-10-23T10:00:00',
        'ffin': '2025-10-23T12:00:00',
        'hini': '10:00',
        'hfin': '12:00',
        'previstaIni': 1,
        'transporteReq': 0,
        'alojamientoReq': 0,
        'estado': 'PENDIENTE',
        'solicitante': {
          'uuid': 'test-uuid',
          'dni': '12345678A',
          'nombre': 'Juan',
          'apellidos': 'Pérez',
          'correo': 'juan@test.com',
          'password': 'pass',
          'rol': 'Profesor',
          'activo': 1,
          'esJefeDep': 0,
          'depart': {
            'id': 1,
            'codigo': 'INF',
            'nombre': 'Informática',
          },
        },
      };

      // Act
      final actividad = Actividad.fromJson(json);

      // Assert
      expect(actividad.solicitante, isNotNull);
      expect(actividad.solicitante?.nombre, 'Juan');
      expect(actividad.solicitante?.apellidos, 'Pérez');
    });

    test('Debería manejar requerimientos de transporte y alojamiento', () {
      // Arrange
      final jsonConTransporte = {
        'id': 1,
        'titulo': 'Con Transporte',
        'tipo': 'Excursión',
        'fini': '2025-10-23T10:00:00',
        'ffin': '2025-10-23T12:00:00',
        'hini': '10:00',
        'hfin': '12:00',
        'previstaIni': 1,
        'transporteReq': 1,
        'comentTransporte': 'Autobús de 50 plazas',
        'alojamientoReq': 1,
        'comentAlojamiento': 'Hotel 3 estrellas',
        'estado': 'APROBADA',
      };

      // Act
      final actividad = Actividad.fromJson(jsonConTransporte);

      // Assert
      expect(actividad.transporteReq, 1);
      expect(actividad.comentTransporte, 'Autobús de 50 plazas');
      expect(actividad.alojamientoReq, 1);
      expect(actividad.comentAlojamiento, 'Hotel 3 estrellas');
    });

    test('fromJson y toJson deberían ser inversos para todos los campos', () {
      // Arrange
      final jsonOriginal = {
        'id': 99,
        'titulo': 'Actividad Completa',
        'tipo': 'Múltiple',
        'descripcion': 'Descripción completa',
        'fini': '2025-12-01T08:00:00',
        'ffin': '2025-12-05T18:00:00',
        'hini': '08:00',
        'hfin': '18:00',
        'previstaIni': 1,
        'transporteReq': 1,
        'comentTransporte': 'Varios buses',
        'alojamientoReq': 1,
        'comentAlojamiento': 'Albergue',
        'comentarios': 'Actividad importante',
        'estado': 'APROBADA',
        'comentEstado': 'Aprobada por dirección',
        'incidencias': 'Ninguna',
        'urlFolleto': 'http://test.com/folleto.pdf',
        'importePorAlumno': 150.0,
        'latitud': 43.5,
        'longitud': -5.5,
      };

      // Act
      final actividad = Actividad.fromJson(jsonOriginal);
      final jsonResultado = actividad.toJson();

      // Assert
      expect(jsonResultado['id'], jsonOriginal['id']);
      expect(jsonResultado['titulo'], jsonOriginal['titulo']);
      expect(jsonResultado['tipo'], jsonOriginal['tipo']);
      expect(jsonResultado['descripcion'], jsonOriginal['descripcion']);
      expect(jsonResultado['estado'], jsonOriginal['estado']);
      expect(jsonResultado['importePorAlumno'], jsonOriginal['importePorAlumno']);
    });
  });
}
