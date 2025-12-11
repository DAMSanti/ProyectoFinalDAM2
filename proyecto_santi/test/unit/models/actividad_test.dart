import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_santi/models/actividad.dart';
void main() {
  group('Actividad Model', () {
    group('Constructor', () {
      test('debe crear una Actividad con campos requeridos', () {
        final actividad = Actividad(
          id: 1,
          titulo: 'Excursión al museo',
          tipo: 'Extraescolar',
          fini: '2024-03-15',
          ffin: '2024-03-15',
          hini: '09:00',
          hfin: '14:00',
          previstaIni: 1,
          transporteReq: 1,
          alojamientoReq: 0,
          estado: 'Pendiente',
        );
        expect(actividad.id, 1);
        expect(actividad.titulo, 'Excursión al museo');
        expect(actividad.tipo, 'Extraescolar');
        expect(actividad.estado, 'Pendiente');
        expect(actividad.transporteReq, 1);
        expect(actividad.alojamientoReq, 0);
      });
      test('debe tener valores por defecto para listas vacías', () {
        final actividad = Actividad(
          id: 1,
          titulo: 'Charla',
          tipo: 'Complementaria',
          fini: '2024-04-01',
          ffin: '2024-04-01',
          hini: '10:00',
          hfin: '12:00',
          previstaIni: 1,
          transporteReq: 0,
          alojamientoReq: 0,
          estado: 'Aprobada',
        );
        expect(actividad.localizaciones, isEmpty);
        expect(actividad.profesoresParticipantesIds, isEmpty);
      });
    });
    group('fromJson', () {
      test('debe parsear JSON básico correctamente', () {
        final json = {
          'id': 1,
          'titulo': 'Visita a la fábrica',
          'tipo': 'Extraescolar',
          'descripcion': 'Visita técnica',
          'fini': '2024-05-10',
          'ffin': '2024-05-10',
          'hini': '08:30',
          'hfin': '15:00',
          'previstaIni': 1,
          'transporteReq': 1,
          'alojamientoReq': 0,
          'estado': 'Aprobada',
        };
        final actividad = Actividad.fromJson(json);
        expect(actividad.id, 1);
        expect(actividad.titulo, 'Visita a la fábrica');
        expect(actividad.descripcion, 'Visita técnica');
        expect(actividad.estado, 'Aprobada');
      });
      test('debe manejar precios como double', () {
        final json = {
          'id': 2,
          'titulo': 'Viaje a Barcelona',
          'tipo': 'Extraescolar',
          'fini': '2024-06-01',
          'ffin': '2024-06-03',
          'hini': '07:00',
          'hfin': '21:00',
          'previstaIni': 1,
          'transporteReq': 1,
          'precioTransporte': 150.50,
          'alojamientoReq': 1,
          'precioAlojamiento': 80.0,
          'estado': 'Pendiente',
          'importePorAlumno': 250.0,
        };
        final actividad = Actividad.fromJson(json);
        expect(actividad.precioTransporte, 150.50);
        expect(actividad.precioAlojamiento, 80.0);
        expect(actividad.importePorAlumno, 250.0);
      });
      test('debe manejar campos opcionales nulos', () {
        final json = {
          'id': 3,
          'titulo': 'Conferencia',
          'tipo': 'Complementaria',
          'fini': '2024-07-15',
          'ffin': '2024-07-15',
          'hini': '11:00',
          'hfin': '13:00',
          'previstaIni': 0,
          'transporteReq': 0,
          'alojamientoReq': 0,
          'estado': 'Borrador',
        };
        final actividad = Actividad.fromJson(json);
        expect(actividad.descripcion, isNull);
        expect(actividad.comentarios, isNull);
        expect(actividad.solicitante, isNull);
        expect(actividad.responsable, isNull);
        expect(actividad.localizacion, isNull);
      });
    });
    group('Validación de estados', () {
      test('debe aceptar estados válidos', () {
        final estadosValidos = ['Borrador', 'Pendiente', 'Aprobada', 'Rechazada', 'Finalizada'];
        for (final estado in estadosValidos) {
          final actividad = Actividad(
            id: 1,
            titulo: 'Test',
            tipo: 'Complementaria',
            fini: '2024-01-01',
            ffin: '2024-01-01',
            hini: '09:00',
            hfin: '10:00',
            previstaIni: 1,
            transporteReq: 0,
            alojamientoReq: 0,
            estado: estado,
          );
          expect(actividad.estado, estado);
        }
      });
    });
    group('Validación de fechas', () {
      test('debe almacenar fechas correctamente', () {
        final actividad = Actividad(
          id: 1,
          titulo: 'Evento',
          tipo: 'Extraescolar',
          fini: '2024-12-01',
          ffin: '2024-12-03',
          hini: '08:00',
          hfin: '20:00',
          previstaIni: 1,
          transporteReq: 0,
          alojamientoReq: 0,
          estado: 'Pendiente',
        );
        expect(actividad.fini, '2024-12-01');
        expect(actividad.ffin, '2024-12-03');
        expect(actividad.hini, '08:00');
        expect(actividad.hfin, '20:00');
      });
    });
  });
}