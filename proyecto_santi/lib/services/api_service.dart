import 'package:dio/dio.dart';
import 'package:proyecto_santi/config.dart';

/// Excepción personalizada para errores de la API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Servicio base para comunicación con la API ACEX (C# .NET)
/// 
/// Esta clase proporciona los métodos genéricos HTTP (GET, POST, PUT, DELETE)
/// y gestiona el token JWT de autenticación.
/// 
/// Para operaciones específicas, usar los servicios especializados:
/// - [ActividadService] para actividades
/// - [ProfesorService] para profesores
/// - [PhotoService] para fotos
/// - [CatalogoService] para departamentos, cursos y grupos
/// - [AuthService] para autenticación
/// - [LocalizacionService] para localizaciones
class ApiService {
  late final Dio _dio;
  // Token compartido entre TODAS las instancias de ApiService
  static String? _jwtToken;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectionTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Interceptor para logging (útil para debug)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => print('[API] $obj'),
    ));

    // Interceptor para agregar JWT token automáticamente
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_jwtToken != null) {
          options.headers['Authorization'] = 'Bearer $_jwtToken';
          print('[API] Token agregado a la petición: ${options.uri.path}');
        } else {
          print('[API] ⚠️ No hay token disponible para: ${options.uri.path}');
        }
        return handler.next(options);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) {
        print('[API Error] ${error.message}');
        return handler.next(error);
      },
    ));
  }

  /// Acceso directo al cliente Dio para casos especiales (FormData, etc.)
  Dio get dio => _dio;

  /// Establece el token JWT para las peticiones (compartido entre todas las instancias)
  void setToken(String? token) {
    _jwtToken = token;
    print('[API] Token configurado globalmente: ${token?.substring(0, 20)}...');
  }

  /// Obtiene el token actual
  String? get token => _jwtToken;

  /// Manejo genérico de errores
  ApiException _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiException('Error de conexión: Tiempo de espera agotado');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          String message = 'Error del servidor: $statusCode';
          
          // Manejo específico de errores HTTP
          if (statusCode == 401) {
            message = 'No autorizado. Por favor, inicia sesión nuevamente.';
          } else if (statusCode == 403) {
            message = 'No tienes permisos para realizar esta acción.';
          } else if (statusCode == 404) {
            message = 'Recurso no encontrado.';
          } else if (statusCode == 500) {
            message = 'Error interno del servidor.';
          }
          
          return ApiException(
            message,
            statusCode: statusCode,
            data: error.response?.data,
          );
        case DioExceptionType.cancel:
          return ApiException('Petición cancelada');
        default:
          return ApiException('Error de conexión: ${error.message}');
      }
    }
    return ApiException('Error desconocido: $error');
  }

  // ==================== MÉTODOS GENÉRICOS HTTP ====================

  /// GET genérico
  Future<Response> getData(String endpoint) async {
    try {
      return await _dio.get(endpoint);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST genérico
  Future<Response> postData(String endpoint, Map<String, dynamic> data) async {
    try {
      return await _dio.post(endpoint, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT genérico
  Future<Response> putData(String endpoint, Map<String, dynamic> data) async {
    try {
      return await _dio.put(endpoint, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE genérico
  Future<Response> deleteData(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } catch (e) {
      throw _handleError(e);
    }
  }
}
