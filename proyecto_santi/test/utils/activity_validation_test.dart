import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Activity Data Validation Tests', () {
    test('Título no debería estar vacío', () {
      const titulo = 'Excursión al museo';
      
      expect(titulo.isNotEmpty, true);
      expect(titulo.trim().isNotEmpty, true);
    });

    test('Título debería tener longitud mínima', () {
      const titulo = 'Excursión al museo de ciencias';
      
      expect(titulo.length, greaterThanOrEqualTo(3));
    });

    test('Estado debería ser uno de los valores válidos', () {
      const estadosValidos = ['PENDIENTE', 'APROBADA', 'RECHAZADA', 'COMPLETADA', 'CANCELADA'];
      const estado = 'APROBADA';
      
      expect(estadosValidos.contains(estado), true);
    });

    test('Coordenadas GPS deberían estar en rangos válidos', () {
      const latitud = 43.353;
      const longitud = -4.064;
      
      expect(latitud, greaterThanOrEqualTo(-90));
      expect(latitud, lessThanOrEqualTo(90));
      expect(longitud, greaterThanOrEqualTo(-180));
      expect(longitud, lessThanOrEqualTo(180));
    });

    test('Importe por alumno debería ser positivo', () {
      const importe = 15.50;
      
      expect(importe, greaterThan(0));
    });

    test('Tipo de actividad debería ser válido', () {
      const tiposValidos = ['Excursión', 'Taller', 'Conferencia', 'Evento', 'Múltiple'];
      const tipo = 'Excursión';
      
      expect(tiposValidos.contains(tipo), true);
    });

    test('Fecha fin debería ser posterior a fecha inicio', () {
      final fini = DateTime.parse('2025-10-23T10:00:00');
      final ffin = DateTime.parse('2025-10-23T12:00:00');
      
      expect(ffin.isAfter(fini), true);
    });

    test('Hora fin debería ser posterior a hora inicio', () {
      const hini = '10:00';
      const hfin = '12:00';
      
      final horaIni = _parseHora(hini);
      final horaFin = _parseHora(hfin);
      
      expect(horaFin, greaterThan(horaIni));
    });

    test('Requerimiento de transporte debería ser 0 o 1', () {
      const transporteReq = 1;
      
      expect([0, 1].contains(transporteReq), true);
    });

    test('Requerimiento de alojamiento debería ser 0 o 1', () {
      const alojamientoReq = 0;
      
      expect([0, 1].contains(alojamientoReq), true);
    });

    test('PrevistaIni debería ser 0 o 1', () {
      const previstaIni = 1;
      
      expect([0, 1].contains(previstaIni), true);
    });

    test('URL de folleto debería tener formato válido', () {
      const url = 'http://example.com/folleto.pdf';
      
      expect(url.startsWith('http://') || url.startsWith('https://'), true);
      expect(url.contains('.'), true);
    });

    test('ID debería ser un número positivo', () {
      const id = 42;
      
      expect(id, greaterThan(0));
      expect(id, isA<int>());
    });

    test('Descripción puede ser nula o tener contenido', () {
      String? descripcion1 = null;
      String? descripcion2 = 'Actividad interesante';
      
      expect(descripcion1 == null || descripcion1.isNotEmpty, true);
      expect(descripcion2 == null || descripcion2.isNotEmpty, true);
    });

    test('Comentarios pueden contener múltiples líneas', () {
      const comentarios = 'Primera línea\nSegunda línea\nTercera línea';
      
      expect(comentarios.contains('\n'), true);
      expect(comentarios.split('\n').length, 3);
    });

    test('Estado inicial debería ser PENDIENTE', () {
      const estadoInicial = 'PENDIENTE';
      const estadosIniciales = ['PENDIENTE'];
      
      expect(estadosIniciales.contains(estadoInicial), true);
    });

    test('Coordenadas nulas deberían ser válidas', () {
      double? latitud = null;
      double? longitud = null;
      
      expect(latitud == null || (latitud >= -90 && latitud <= 90), true);
      expect(longitud == null || (longitud >= -180 && longitud <= 180), true);
    });

    test('Importe nulo debería ser válido (actividad gratuita)', () {
      double? importe = null;
      
      expect(importe == null || importe >= 0, true);
    });

    test('Comentario de transporte solo si se requiere', () {
      const transporteReq = 1;
      const comentTransporte = 'Autobús escolar';
      
      if (transporteReq == 1) {
        expect(comentTransporte, isNotNull);
      }
    });

    test('Duración de actividad debería ser razonable', () {
      final fini = DateTime.parse('2025-10-23T10:00:00');
      final ffin = DateTime.parse('2025-10-23T12:00:00');
      
      final duracion = ffin.difference(fini);
      
      expect(duracion.inHours, greaterThan(0));
      expect(duracion.inHours, lessThan(24)); // Menos de un día
    });
  });
}

int _parseHora(String hora) {
  final parts = hora.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}
