import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_santi/utils/constants.dart';

void main() {
  group('AppConstants App Info Tests', () {
    test('Nombre de la app debería ser ACEX', () {
      expect(AppConstants.appName, 'ACEX');
    });

    test('Versión de la app debería estar definida', () {
      expect(AppConstants.appVersion, isNotEmpty);
      expect(AppConstants.appVersion, '1.0.0');
    });
  });

  group('AppConstants Breakpoints Tests', () {
    test('Mobile breakpoint debería ser 600', () {
      expect(AppConstants.mobileBreakpoint, 600);
    });

    test('Tablet breakpoint debería ser 900', () {
      expect(AppConstants.tabletBreakpoint, 900);
    });

    test('Desktop breakpoint debería ser 1200', () {
      expect(AppConstants.desktopBreakpoint, 1200);
    });

    test('Breakpoints deberían estar en orden ascendente', () {
      expect(AppConstants.mobileBreakpoint, lessThan(AppConstants.tabletBreakpoint));
      expect(AppConstants.tabletBreakpoint, lessThan(AppConstants.desktopBreakpoint));
    });
  });

  group('AppConstants Padding Tests', () {
    test('Padding XS debería ser 4.0', () {
      expect(AppConstants.paddingXS, 4.0);
    });

    test('Padding S debería ser 8.0', () {
      expect(AppConstants.paddingS, 8.0);
    });

    test('Padding M debería ser 16.0', () {
      expect(AppConstants.paddingM, 16.0);
    });

    test('Padding L debería ser 24.0', () {
      expect(AppConstants.paddingL, 24.0);
    });

    test('Padding XL debería ser 32.0', () {
      expect(AppConstants.paddingXL, 32.0);
    });

    test('Paddings deberían estar en orden ascendente', () {
      expect(AppConstants.paddingXS, lessThan(AppConstants.paddingS));
      expect(AppConstants.paddingS, lessThan(AppConstants.paddingM));
      expect(AppConstants.paddingM, lessThan(AppConstants.paddingL));
      expect(AppConstants.paddingL, lessThan(AppConstants.paddingXL));
    });
  });

  group('AppConstants Border Radius Tests', () {
    test('Radius S debería ser 4.0', () {
      expect(AppConstants.radiusS, 4.0);
    });

    test('Radius M debería ser 8.0', () {
      expect(AppConstants.radiusM, 8.0);
    });

    test('Radius L debería ser 16.0', () {
      expect(AppConstants.radiusL, 16.0);
    });

    test('Radius XL debería ser 24.0', () {
      expect(AppConstants.radiusXL, 24.0);
    });

    test('Radius deberían estar en orden ascendente', () {
      expect(AppConstants.radiusS, lessThan(AppConstants.radiusM));
      expect(AppConstants.radiusM, lessThan(AppConstants.radiusL));
      expect(AppConstants.radiusL, lessThan(AppConstants.radiusXL));
    });
  });

  group('AppConstants Icon Size Tests', () {
    test('Icon S debería ser 16.0', () {
      expect(AppConstants.iconS, 16.0);
    });

    test('Icon M debería ser 24.0', () {
      expect(AppConstants.iconM, 24.0);
    });

    test('Icon L debería ser 32.0', () {
      expect(AppConstants.iconL, 32.0);
    });

    test('Icon XL debería ser 48.0', () {
      expect(AppConstants.iconXL, 48.0);
    });

    test('Icon sizes deberían estar en orden ascendente', () {
      expect(AppConstants.iconS, lessThan(AppConstants.iconM));
      expect(AppConstants.iconM, lessThan(AppConstants.iconL));
      expect(AppConstants.iconL, lessThan(AppConstants.iconXL));
    });
  });

  group('AppConstants Estados de Actividad Tests', () {
    test('Estado PENDIENTE debería estar definido', () {
      expect(AppConstants.estadoPendiente, 'PENDIENTE');
    });

    test('Estado APROBADA debería estar definido', () {
      expect(AppConstants.estadoAprobada, 'APROBADA');
    });

    test('Estado RECHAZADA debería estar definido', () {
      expect(AppConstants.estadoRechazada, 'RECHAZADA');
    });

    test('Estado EN_CURSO debería estar definido', () {
      expect(AppConstants.estadoEnCurso, 'EN_CURSO');
    });

    test('Estado FINALIZADA debería estar definido', () {
      expect(AppConstants.estadoFinalizada, 'FINALIZADA');
    });

    test('Estado CANCELADA debería estar definido', () {
      expect(AppConstants.estadoCancelada, 'CANCELADA');
    });

    test('Todos los estados deberían ser strings no vacíos', () {
      expect(AppConstants.estadoPendiente, isNotEmpty);
      expect(AppConstants.estadoAprobada, isNotEmpty);
      expect(AppConstants.estadoRechazada, isNotEmpty);
      expect(AppConstants.estadoEnCurso, isNotEmpty);
      expect(AppConstants.estadoFinalizada, isNotEmpty);
      expect(AppConstants.estadoCancelada, isNotEmpty);
    });

    test('Estados deberían estar en mayúsculas', () {
      expect(AppConstants.estadoPendiente, equals(AppConstants.estadoPendiente.toUpperCase()));
      expect(AppConstants.estadoAprobada, equals(AppConstants.estadoAprobada.toUpperCase()));
    });
  });

  group('AppConstants Tipos de Actividad Tests', () {
    test('Tipo EXTRAESCOLAR debería estar definido', () {
      expect(AppConstants.tipoExtraescolar, 'EXTRAESCOLAR');
    });

    test('Tipo COMPLEMENTARIA debería estar definido', () {
      expect(AppConstants.tipoComplementaria, 'COMPLEMENTARIA');
    });

    test('Tipo FORMACION debería estar definido', () {
      expect(AppConstants.tipoFormacion, 'FORMACION');
    });

    test('Todos los tipos deberían estar en mayúsculas', () {
      expect(AppConstants.tipoExtraescolar, equals(AppConstants.tipoExtraescolar.toUpperCase()));
      expect(AppConstants.tipoComplementaria, equals(AppConstants.tipoComplementaria.toUpperCase()));
      expect(AppConstants.tipoFormacion, equals(AppConstants.tipoFormacion.toUpperCase()));
    });
  });

  group('AppConstants Roles de Usuario Tests', () {
    test('Rol PROFESOR debería estar definido', () {
      expect(AppConstants.rolProfesor, 'PROFESOR');
    });

    test('Rol JEFE_DEP debería estar definido', () {
      expect(AppConstants.rolJefeDepartamento, 'JEFE_DEP');
    });

    test('Rol ED debería estar definido', () {
      expect(AppConstants.rolEquipoDirectivo, 'ED');
    });

    test('Rol ADMIN debería estar definido', () {
      expect(AppConstants.rolAdmin, 'ADMIN');
    });

    test('Todos los roles deberían ser strings no vacíos', () {
      expect(AppConstants.rolProfesor, isNotEmpty);
      expect(AppConstants.rolJefeDepartamento, isNotEmpty);
      expect(AppConstants.rolEquipoDirectivo, isNotEmpty);
      expect(AppConstants.rolAdmin, isNotEmpty);
    });
  });

  group('AppConstants Mensajes de Error Tests', () {
    test('Error de conexión debería estar definido', () {
      expect(AppConstants.errorConnection, isNotEmpty);
      expect(AppConstants.errorConnection, contains('conexión'));
    });

    test('Error de servidor debería estar definido', () {
      expect(AppConstants.errorServer, isNotEmpty);
      expect(AppConstants.errorServer, contains('servidor'));
    });

    test('Error desconocido debería estar definido', () {
      expect(AppConstants.errorUnknown, isNotEmpty);
      expect(AppConstants.errorUnknown, contains('error'));
    });

    test('Error de autenticación debería estar definido', () {
      expect(AppConstants.errorAuth, isNotEmpty);
      expect(AppConstants.errorAuth, contains('autenticación'));
    });
  });

  group('AppConstants Mensajes de Éxito Tests', () {
    test('Mensaje de guardado exitoso debería estar definido', () {
      expect(AppConstants.successSave, isNotEmpty);
      expect(AppConstants.successSave, contains('exitosamente'));
    });

    test('Mensaje de eliminación exitosa debería estar definido', () {
      expect(AppConstants.successDelete, isNotEmpty);
      expect(AppConstants.successDelete, contains('exitosamente'));
    });

    test('Mensaje de actualización exitosa debería estar definido', () {
      expect(AppConstants.successUpdate, isNotEmpty);
      expect(AppConstants.successUpdate, contains('exitosamente'));
    });

    test('Mensaje de login exitoso debería estar definido', () {
      expect(AppConstants.successLogin, isNotEmpty);
      expect(AppConstants.successLogin, contains('Bienvenido'));
    });
  });

  group('AppConstants Animation Duration Tests', () {
    test('Animación rápida debería ser 150ms', () {
      expect(AppConstants.animationFast.inMilliseconds, 150);
    });

    test('Animación normal debería ser 300ms', () {
      expect(AppConstants.animationNormal.inMilliseconds, 300);
    });

    test('Animación lenta debería ser 500ms', () {
      expect(AppConstants.animationSlow.inMilliseconds, 500);
    });

    test('Duraciones deberían estar en orden ascendente', () {
      expect(AppConstants.animationFast.inMilliseconds, 
             lessThan(AppConstants.animationNormal.inMilliseconds));
      expect(AppConstants.animationNormal.inMilliseconds, 
             lessThan(AppConstants.animationSlow.inMilliseconds));
    });

    test('Todas las duraciones deberían ser positivas', () {
      expect(AppConstants.animationFast.inMilliseconds, greaterThan(0));
      expect(AppConstants.animationNormal.inMilliseconds, greaterThan(0));
      expect(AppConstants.animationSlow.inMilliseconds, greaterThan(0));
    });
  });

  group('AppConstants Límites Tests', () {
    test('Máximo de fotos por actividad debería ser 10', () {
      expect(AppConstants.maxPhotosPerActivity, 10);
    });

    test('Máximo de longitud de descripción debería ser 500', () {
      expect(AppConstants.maxDescriptionLength, 500);
    });

    test('Máximo de longitud de comentario debería ser 200', () {
      expect(AppConstants.maxCommentLength, 200);
    });

    test('Todos los límites deberían ser positivos', () {
      expect(AppConstants.maxPhotosPerActivity, greaterThan(0));
      expect(AppConstants.maxDescriptionLength, greaterThan(0));
      expect(AppConstants.maxCommentLength, greaterThan(0));
    });
  });

  group('AppConstants Formatos Soportados Tests', () {
    test('Formatos de imagen deberían estar definidos', () {
      expect(AppConstants.supportedImageFormats, isNotEmpty);
      expect(AppConstants.supportedImageFormats, contains('jpg'));
      expect(AppConstants.supportedImageFormats, contains('png'));
    });

    test('Formatos de documento deberían estar definidos', () {
      expect(AppConstants.supportedDocumentFormats, isNotEmpty);
      expect(AppConstants.supportedDocumentFormats, contains('pdf'));
    });

    test('Formatos de imagen deberían incluir JPG y PNG', () {
      expect(AppConstants.supportedImageFormats, containsAll(['jpg', 'jpeg', 'png']));
    });

    test('Formatos de documento deberían incluir PDF', () {
      expect(AppConstants.supportedDocumentFormats, contains('pdf'));
    });

    test('Listas de formatos no deberían estar vacías', () {
      expect(AppConstants.supportedImageFormats.length, greaterThan(0));
      expect(AppConstants.supportedDocumentFormats.length, greaterThan(0));
    });

    test('Formatos de imagen deberían tener al menos 3 tipos', () {
      expect(AppConstants.supportedImageFormats.length, greaterThanOrEqualTo(3));
    });

    test('GIF debería estar en formatos soportados', () {
      expect(AppConstants.supportedImageFormats, contains('gif'));
    });

    test('Word debería estar en formatos de documento soportados', () {
      expect(AppConstants.supportedDocumentFormats, containsAll(['doc', 'docx']));
    });
  });

  group('AppConstants Integration Tests', () {
    test('Padding M debería ser el doble de Padding S', () {
      expect(AppConstants.paddingM, equals(AppConstants.paddingS * 2));
    });

    test('Icon M debería ser mayor que Radius M', () {
      expect(AppConstants.iconM, greaterThan(AppConstants.radiusM));
    });

    test('Animación normal debería ser el doble de animación rápida', () {
      expect(AppConstants.animationNormal.inMilliseconds, 
             equals(AppConstants.animationFast.inMilliseconds * 2));
    });

    test('Desktop breakpoint debería ser el doble de mobile', () {
      expect(AppConstants.desktopBreakpoint, equals(AppConstants.mobileBreakpoint * 2));
    });

    test('Comentario debería ser más corto que descripción', () {
      expect(AppConstants.maxCommentLength, lessThan(AppConstants.maxDescriptionLength));
    });
  });
}
