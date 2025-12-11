import 'package:dio/dio.dart';
import 'package:proyecto_santi/config.dart';
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  ApiException(this.message, {this.statusCode, this.data});
  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
class ApiService {
  late final Dio _dio;
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
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_jwtToken != null) {
          options.headers['Authorization'] = 'Bearer $_jwtToken';
        }
        return handler.next(options);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) {
        if (error.response?.statusCode == 401 || error.response?.statusCode == 500) {
          print('[API Error] ${error.response?.statusCode}: ${error.message}');
        }
        return handler.next(error);
      },
    ));
  }
  Dio get dio => _dio;
  void setToken(String? token) {
    _jwtToken = token;
  }
  String? get token => _jwtToken;
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
  Future<Response> getData(String endpoint) async {
    try {
      return await _dio.get(endpoint);
    } catch (e) {
      throw _handleError(e);
    }
  }
  Future<Response> postData(String endpoint, Map<String, dynamic> data) async {
    try {
      return await _dio.post(endpoint, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  Future<Response> putData(String endpoint, Map<String, dynamic> data) async {
    try {
      return await _dio.put(endpoint, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  Future<Response> put(String endpoint, dynamic data) async {
    try {
      return await _dio.put(endpoint, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  Future<Response> deleteData(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } catch (e) {
      throw _handleError(e);
    }
  }
}