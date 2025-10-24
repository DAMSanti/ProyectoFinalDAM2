import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_santi/utils/validators.dart';

void main() {
  group('Validators.required Tests', () {
    test('Valor no vacío debería retornar null', () {
      final result = Validators.required('texto');
      expect(result, null);
    });

    test('Valor vacío debería retornar error', () {
      final result = Validators.required('');
      expect(result, isNotNull);
      expect(result, contains('obligatorio'));
    });

    test('Valor null debería retornar error', () {
      final result = Validators.required(null);
      expect(result, isNotNull);
    });

    test('Debería usar fieldName personalizado', () {
      final result = Validators.required('', fieldName: 'Nombre');
      expect(result, contains('Nombre'));
    });

    test('Espacios en blanco deberían considerarse vacíos', () {
      final result = Validators.required('   ');
      expect(result, isNotNull);
    });
  });

  group('Validators.email Tests', () {
    test('Email válido debería retornar null', () {
      final result = Validators.email('usuario@ejemplo.com');
      expect(result, null);
    });

    test('Email con punto debería retornar null', () {
      final result = Validators.email('nombre.apellido@dominio.es');
      expect(result, null);
    });

    test('Email sin @ debería retornar error', () {
      final result = Validators.email('usuario.ejemplo.com');
      expect(result, isNotNull);
      expect(result, contains('válido'));
    });

    test('Email vacío debería retornar error', () {
      final result = Validators.email('');
      expect(result, isNotNull);
      expect(result, contains('obligatorio'));
    });

    test('Email null debería retornar error', () {
      final result = Validators.email(null);
      expect(result, isNotNull);
    });

    test('Email sin dominio debería retornar error', () {
      final result = Validators.email('usuario@');
      expect(result, isNotNull);
    });
  });

  group('Validators.password Tests', () {
    test('Password con longitud suficiente debería retornar null', () {
      final result = Validators.password('MiPassword123');
      expect(result, null);
    });

    test('Password de exactamente 6 caracteres debería retornar null', () {
      final result = Validators.password('Pass12');
      expect(result, null);
    });

    test('Password muy corto debería retornar error', () {
      final result = Validators.password('123', minLength: 6);
      expect(result, isNotNull);
      expect(result, contains('6 caracteres'));
    });

    test('Password vacío debería retornar error', () {
      final result = Validators.password('');
      expect(result, isNotNull);
      expect(result, contains('obligatoria'));
    });

    test('Password null debería retornar error', () {
      final result = Validators.password(null);
      expect(result, isNotNull);
    });

    test('Debería permitir minLength personalizado', () {
      final result = Validators.password('1234', minLength: 8);
      expect(result, isNotNull);
      expect(result, contains('8 caracteres'));
    });
  });

  group('Validators.confirmPassword Tests', () {
    test('Passwords que coinciden deberían retornar null', () {
      final result = Validators.confirmPassword('Pass123', 'Pass123');
      expect(result, null);
    });

    test('Passwords que no coinciden deberían retornar error', () {
      final result = Validators.confirmPassword('Pass123', 'Pass456');
      expect(result, isNotNull);
      expect(result, contains('no coinciden'));
    });

    test('Confirmación vacía debería retornar error', () {
      final result = Validators.confirmPassword('', 'Pass123');
      expect(result, isNotNull);
      expect(result, contains('Confirma'));
    });

    test('Confirmación null debería retornar error', () {
      final result = Validators.confirmPassword(null, 'Pass123');
      expect(result, isNotNull);
    });
  });

  group('Validators.dni Tests', () {
    test('DNI válido formato correcto debería retornar null', () {
      final result = Validators.dni('12345678A');
      expect(result, null);
    });

    test('DNI sin letra debería retornar error', () {
      final result = Validators.dni('12345678');
      expect(result, isNotNull);
      expect(result, contains('inválido'));
    });

    test('DNI con letra minúscula debería aceptarse (se convierte a mayúscula)', () {
      final result = Validators.dni('12345678a');
      expect(result, null);
    });

    test('DNI vacío debería retornar error', () {
      final result = Validators.dni('');
      expect(result, isNotNull);
      expect(result, contains('obligatorio'));
    });

    test('DNI null debería retornar error', () {
      final result = Validators.dni(null);
      expect(result, isNotNull);
    });

    test('DNI con formato incorrecto debería retornar error', () {
      final result = Validators.dni('ABC12345');
      expect(result, isNotNull);
    });
  });

  group('Validators.numberInRange Tests', () {
    test('Número dentro del rango debería retornar null', () {
      final result = Validators.numberInRange('50', min: 0, max: 100);
      expect(result, null);
    });

    test('Número en el límite inferior debería retornar null', () {
      final result = Validators.numberInRange('0', min: 0, max: 100);
      expect(result, null);
    });

    test('Número en el límite superior debería retornar null', () {
      final result = Validators.numberInRange('100', min: 0, max: 100);
      expect(result, null);
    });

    test('Número fuera del rango (mayor) debería retornar error', () {
      final result = Validators.numberInRange('150', min: 0, max: 100);
      expect(result, isNotNull);
      expect(result, contains('entre'));
    });

    test('Número fuera del rango (menor) debería retornar error', () {
      final result = Validators.numberInRange('-10', min: 0, max: 100);
      expect(result, isNotNull);
    });

    test('Texto no numérico debería retornar error', () {
      final result = Validators.numberInRange('abc', min: 0, max: 100);
      expect(result, isNotNull);
      expect(result, contains('número válido'));
    });

    test('Valor vacío debería retornar error', () {
      final result = Validators.numberInRange('', min: 0, max: 100);
      expect(result, isNotNull);
    });

    test('Debería aceptar decimales', () {
      final result = Validators.numberInRange('50.5', min: 0, max: 100);
      expect(result, null);
    });

    test('Debería usar fieldName personalizado', () {
      final result = Validators.numberInRange('150', min: 0, max: 100, fieldName: 'Precio');
      expect(result, contains('Precio'));
    });
  });

  group('Validators.minLength Tests', () {
    test('Texto con longitud suficiente debería retornar null', () {
      final result = Validators.minLength('Hola mundo', 5);
      expect(result, null);
    });

    test('Texto con longitud exacta debería retornar null', () {
      final result = Validators.minLength('Hola', 4);
      expect(result, null);
    });

    test('Texto muy corto debería retornar error', () {
      final result = Validators.minLength('Hi', 5);
      expect(result, isNotNull);
      expect(result, contains('5 caracteres'));
    });

    test('Texto vacío debería retornar error', () {
      final result = Validators.minLength('', 5);
      expect(result, isNotNull);
      expect(result, contains('obligatorio'));
    });

    test('Debería usar fieldName personalizado', () {
      final result = Validators.minLength('Hi', 5, fieldName: 'Descripción');
      expect(result, contains('Descripción'));
    });
  });

  group('Validators.maxLength Tests', () {
    test('Texto dentro del límite debería retornar null', () {
      final result = Validators.maxLength('Hola', 10);
      expect(result, null);
    });

    test('Texto con longitud exacta debería retornar null', () {
      final result = Validators.maxLength('12345', 5);
      expect(result, null);
    });

    test('Texto que excede límite debería retornar error', () {
      final result = Validators.maxLength('Texto muy largo', 5);
      expect(result, isNotNull);
      expect(result, contains('5 caracteres'));
    });

    test('Texto null debería retornar null', () {
      final result = Validators.maxLength(null, 5);
      expect(result, null);
    });

    test('Texto vacío debería retornar null', () {
      final result = Validators.maxLength('', 5);
      expect(result, null);
    });

    test('Debería usar fieldName personalizado', () {
      final result = Validators.maxLength('Texto muy largo para comentario', 10, fieldName: 'Comentario');
      expect(result, contains('Comentario'));
    });
  });
}
