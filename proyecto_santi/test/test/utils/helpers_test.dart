import 'package:flutter_test/flutter_test.dart';

void main() {
  group('String Helpers Tests', () {
    test('Debería truncar texto largo correctamente', () {
      // Arrange
      String truncarTexto(String texto, int maxLength) {
        if (texto.length <= maxLength) return texto;
        return '${texto.substring(0, maxLength)}...';
      }

      // Act & Assert
      expect(truncarTexto('Texto corto', 20), 'Texto corto');
      expect(truncarTexto('Este es un texto muy largo que debe ser truncado', 20), 'Este es un texto muy...');
      expect(truncarTexto('Exacto', 6), 'Exacto');
    });

    test('Debería contar palabras en un texto', () {
      // Arrange
      int contarPalabras(String texto) {
        return texto.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
      }

      // Act & Assert
      expect(contarPalabras('Hola mundo'), 2);
      expect(contarPalabras('Una sola palabra larga aquí'), 5);
      expect(contarPalabras('  espacios   extra  '), 2);
      expect(contarPalabras(''), 0);
    });

    test('Debería obtener iniciales de nombre completo', () {
      // Arrange
      String obtenerIniciales(String nombreCompleto) {
        final partes = nombreCompleto.trim().split(' ');
        if (partes.length == 1) return partes[0][0].toUpperCase();
        return '${partes[0][0]}${partes[partes.length - 1][0]}'.toUpperCase();
      }

      // Act & Assert
      expect(obtenerIniciales('Juan Pérez'), 'JP');
      expect(obtenerIniciales('María García López'), 'ML');
      expect(obtenerIniciales('Carlos'), 'C');
    });

    test('Debería formatear número de teléfono', () {
      // Arrange
      String formatearTelefono(String telefono) {
        final digitos = telefono.replaceAll(RegExp(r'\D'), '');
        if (digitos.length == 9) {
          return '${digitos.substring(0, 3)} ${digitos.substring(3, 6)} ${digitos.substring(6)}';
        }
        return telefono;
      }

      // Act & Assert
      expect(formatearTelefono('612345678'), '612 345 678');
      expect(formatearTelefono('6-1-2-3-4-5-6-7-8'), '612 345 678');
      expect(formatearTelefono('123'), '123'); // no formatea si no tiene 9 dígitos
    });

    test('Debería normalizar espacios en blanco', () {
      // Arrange
      String normalizarEspacios(String texto) {
        return texto.trim().replaceAll(RegExp(r'\s+'), ' ');
      }

      // Act & Assert
      expect(normalizarEspacios('  texto   con    espacios  '), 'texto con espacios');
      expect(normalizarEspacios('sin espacios extra'), 'sin espacios extra');
      expect(normalizarEspacios('\n\ttabs\ny\nsaltos\n'), 'tabs y saltos');
    });

    test('Debería slug-ificar texto para URLs', () {
      // Arrange
      String slugify(String texto) {
        return texto
            .toLowerCase()
            .trim()
            .replaceAll(RegExp(r'[áàä]'), 'a')
            .replaceAll(RegExp(r'[éèë]'), 'e')
            .replaceAll(RegExp(r'[íìï]'), 'i')
            .replaceAll(RegExp(r'[óòö]'), 'o')
            .replaceAll(RegExp(r'[úùü]'), 'u')
            .replaceAll(RegExp(r'ñ'), 'n')
            .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
            .replaceAll(RegExp(r'-+'), '-')
            .replaceAll(RegExp(r'^-|-$'), '');
      }

      // Act & Assert
      expect(slugify('Excursión al Museo'), 'excursion-al-museo');
      expect(slugify('Actividad de Programación'), 'actividad-de-programacion');
      expect(slugify('Año 2025'), 'ano-2025');
    });

    test('Debería extraer dominio de email', () {
      // Arrange
      String? extraerDominioEmail(String email) {
        final partes = email.split('@');
        if (partes.length == 2) return partes[1];
        return null;
      }

      // Act & Assert
      expect(extraerDominioEmail('user@example.com'), 'example.com');
      expect(extraerDominioEmail('admin@gmail.com'), 'gmail.com');
      expect(extraerDominioEmail('invalid-email'), null);
    });

    test('Debería convertir a título case', () {
      // Arrange
      String toTitleCase(String texto) {
        return texto.split(' ').map((palabra) {
          if (palabra.isEmpty) return palabra;
          return palabra[0].toUpperCase() + palabra.substring(1).toLowerCase();
        }).join(' ');
      }

      // Act & Assert
      expect(toTitleCase('hola mundo'), 'Hola Mundo');
      expect(toTitleCase('TEXTO EN MAYÚSCULAS'), 'Texto En Mayúsculas');
      expect(toTitleCase('texto normal'), 'Texto Normal');
    });

    test('Debería remover acentos', () {
      // Arrange
      String removerAcentos(String texto) {
        return texto
            .replaceAll(RegExp(r'[áàäâ]'), 'a')
            .replaceAll(RegExp(r'[éèëê]'), 'e')
            .replaceAll(RegExp(r'[íìïî]'), 'i')
            .replaceAll(RegExp(r'[óòöô]'), 'o')
            .replaceAll(RegExp(r'[úùüû]'), 'u')
            .replaceAll(RegExp(r'ñ'), 'n');
      }

      // Act & Assert
      expect(removerAcentos('Montaña'), 'Montana');
      expect(removerAcentos('Año académico'), 'Ano academico');
      expect(removerAcentos('Programación'), 'Programacion');
    });

    test('Debería verificar si es palíndromo', () {
      // Arrange
      bool esPalindromo(String texto) {
        final limpio = texto.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        return limpio == limpio.split('').reversed.join('');
      }

      // Act & Assert
      expect(esPalindromo('anilina'), true);
      expect(esPalindromo('A man a plan a canal Panama'), true);
      expect(esPalindromo('hello'), false);
    });
  });

  group('Number Helpers Tests', () {
    test('Debería formatear números con separadores de miles', () {
      // Arrange
      String formatearNumero(int numero) {
        return numero.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
      }

      // Act & Assert
      expect(formatearNumero(1000), '1.000');
      expect(formatearNumero(1000000), '1.000.000');
      expect(formatearNumero(500), '500');
    });

    test('Debería calcular porcentaje', () {
      // Arrange
      double calcularPorcentaje(int parte, int total) {
        if (total == 0) return 0;
        return (parte / total) * 100;
      }

      // Act & Assert
      expect(calcularPorcentaje(50, 100), 50.0);
      expect(calcularPorcentaje(25, 100), 25.0);
      expect(calcularPorcentaje(100, 200), 50.0);
      expect(calcularPorcentaje(10, 0), 0.0); // evita división por cero
    });

    test('Debería formatear números decimales', () {
      // Arrange
      String formatearDecimal(double numero, int decimales) {
        return numero.toStringAsFixed(decimales);
      }

      // Act & Assert
      expect(formatearDecimal(3.14159, 2), '3.14');
      expect(formatearDecimal(2.71828, 3), '2.718');
      expect(formatearDecimal(10.5, 1), '10.5');
    });
  });

  group('Collection Helpers Tests', () {
    test('Debería agrupar elementos por criterio', () {
      // Arrange
      final actividades = [
        {'estado': 'PENDIENTE', 'titulo': 'Act 1'},
        {'estado': 'APROBADA', 'titulo': 'Act 2'},
        {'estado': 'PENDIENTE', 'titulo': 'Act 3'},
      ];

      Map<String, List<Map<String, String>>> agruparPorEstado(List<Map<String, String>> lista) {
        final resultado = <String, List<Map<String, String>>>{};
        for (var item in lista) {
          final estado = item['estado']!;
          resultado.putIfAbsent(estado, () => []).add(item);
        }
        return resultado;
      }

      // Act
      final agrupadas = agruparPorEstado(actividades);

      // Assert
      expect(agrupadas['PENDIENTE']?.length, 2);
      expect(agrupadas['APROBADA']?.length, 1);
    });

    test('Debería eliminar duplicados de lista', () {
      // Arrange
      List<T> eliminarDuplicados<T>(List<T> lista) {
        return lista.toSet().toList();
      }

      // Act & Assert
      expect(eliminarDuplicados([1, 2, 2, 3, 3, 3]), [1, 2, 3]);
      expect(eliminarDuplicados(['a', 'b', 'a', 'c']), ['a', 'b', 'c']);
    });

    test('Debería paginar resultados', () {
      // Arrange
      List<T> paginar<T>(List<T> lista, int pagina, int porPagina) {
        final inicio = (pagina - 1) * porPagina;
        final fin = inicio + porPagina;
        return lista.sublist(
          inicio,
          fin > lista.length ? lista.length : fin,
        );
      }

      final datos = List.generate(25, (i) => i + 1);

      // Act & Assert
      expect(paginar(datos, 1, 10), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
      expect(paginar(datos, 2, 10), [11, 12, 13, 14, 15, 16, 17, 18, 19, 20]);
      expect(paginar(datos, 3, 10), [21, 22, 23, 24, 25]);
    });
  });
}
