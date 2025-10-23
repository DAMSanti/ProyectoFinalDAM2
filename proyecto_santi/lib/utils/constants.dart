/// Constantes de la aplicación
library;

class AppConstants {
  // Información de la aplicación
  static const String appName = 'ACEX';
  static const String appVersion = '1.0.0';
  
  // Dimensiones de pantalla (para responsive design)
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  
  // Padding y márgenes estándar
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  // Border radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  
  // Iconos tamaños
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  
  // Estados de actividad
  static const String estadoPendiente = 'PENDIENTE';
  static const String estadoAprobada = 'APROBADA';
  static const String estadoRechazada = 'RECHAZADA';
  static const String estadoEnCurso = 'EN_CURSO';
  static const String estadoFinalizada = 'FINALIZADA';
  static const String estadoCancelada = 'CANCELADA';
  
  // Tipos de actividad
  static const String tipoExtraescolar = 'EXTRAESCOLAR';
  static const String tipoComplementaria = 'COMPLEMENTARIA';
  static const String tipoFormacion = 'FORMACION';
  
  // Roles de usuario
  static const String rolProfesor = 'PROFESOR';
  static const String rolJefeDepartamento = 'JEFE_DEP';
  static const String rolEquipoDirectivo = 'ED';
  static const String rolAdmin = 'ADMIN';
  
  // Mensajes de error comunes
  static const String errorConnection = 'Error de conexión. Verifica tu conexión a internet.';
  static const String errorServer = 'Error del servidor. Inténtalo más tarde.';
  static const String errorUnknown = 'Ha ocurrido un error desconocido.';
  static const String errorAuth = 'Error de autenticación. Verifica tus credenciales.';
  
  // Mensajes de éxito
  static const String successSave = 'Guardado exitosamente';
  static const String successDelete = 'Eliminado exitosamente';
  static const String successUpdate = 'Actualizado exitosamente';
  static const String successLogin = 'Bienvenido de nuevo';
  
  // Durations para animaciones
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // Límites
  static const int maxPhotosPerActivity = 10;
  static const int maxDescriptionLength = 500;
  static const int maxCommentLength = 200;
  
  // Formatos de archivo soportados
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> supportedDocumentFormats = ['pdf', 'doc', 'docx'];
}
