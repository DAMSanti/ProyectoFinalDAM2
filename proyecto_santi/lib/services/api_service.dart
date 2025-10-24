import 'package:dio/dio.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/models/photo.dart';
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

/// Servicio principal para comunicación con la API ACEX (C# .NET)
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

  // ==================== MÉTODOS GENÉRICOS ====================

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

  // ==================== AUTENTICACIÓN ====================

  /// Autentica un usuario y obtiene el token JWT
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '${AppConfig.authEndpoint}/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['token'];
        if (token != null) {
          setToken(token);
          return response.data;
        }
      }
      return null;
    } catch (e) {
      print('[Auth Error] ${_handleError(e)}');
      return null;
    }
  }

  /// Autentica un profesor
  Future<Profesor?> authenticate(String email, String password) async {
    try {
      // Intentamos login con email y password
      final loginResult = await login(email, password);
      
      if (loginResult != null) {
        // Luego buscamos el profesor por correo
        final profesores = await fetchProfesores();
        final profesor = profesores.firstWhere(
          (p) => p.correo == email && p.activo == 1,
          orElse: () => throw Exception('Profesor no encontrado'),
        );
        return profesor;
      }
      return null;
    } catch (e) {
      print('[Auth Error] ${_handleError(e)}');
      return null;
    }
  }

  /// Verifica si un profesor existe por UUID
  Future<Profesor?> getProfesorByUuid(String uuid) async {
    try {
      final response = await _dio.get('${AppConfig.profesorEndpoint}/$uuid');
      
      if (response.statusCode == 200 && response.data != null) {
        return Profesor.fromJson(response.data);
      }
      return null;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== ACTIVIDADES ====================

  /// Obtiene todas las actividades (con paginación opcional)
  Future<List<Actividad>> fetchActivities({
    int? page,
    int? pageSize,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (pageSize != null) queryParams['pageSize'] = pageSize;
      if (search != null) queryParams['search'] = search;
      
      final response = await _dio.get(
        AppConfig.actividadEndpoint,
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        // La API C# puede devolver un objeto paginado o una lista directa
        dynamic data = response.data;
        
        // Si viene con paginación
        if (data is Map && data.containsKey('items')) {
          data = data['items'];
        }
        
        final List<dynamic> list = data as List;
        return list.map((json) => Actividad.fromJson(json)).toList();
      }
      throw ApiException('Error al obtener actividades', statusCode: response.statusCode);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtiene actividades futuras (hoy o posteriores)
  Future<List<Actividad>> fetchFutureActivities() async {
    try {
      final allActivities = await fetchActivities();
      final currentDate = DateTime.now();
      final today = DateTime(currentDate.year, currentDate.month, currentDate.day);
      
      return allActivities.where((actividad) {
        try {
          final activityDate = DateTime.parse(actividad.fini);
          final activityDay = DateTime(
            activityDate.year,
            activityDate.month,
            activityDate.day,
          );
          return activityDay.isAtSameMomentAs(today) || activityDay.isAfter(today);
        } catch (e) {
          print('[Warning] Error parsing date for activity ${actividad.id}: $e');
          return false;
        }
      }).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtiene una actividad por ID
  Future<Actividad?> fetchActivityById(int id) async {
    try {
      final response = await _dio.get('${AppConfig.actividadEndpoint}/$id');
      
      if (response.statusCode == 200 && response.data != null) {
        return Actividad.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('[Warning] Activity $id not found: ${_handleError(e)}');
      return null;
    }
  }

  /// Crea una nueva actividad
  Future<Actividad?> createActivity(Actividad actividad) async {
    try {
      final response = await _dio.post(
        AppConfig.actividadEndpoint,
        data: actividad.toJson(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Actividad.fromJson(response.data);
      }
      throw ApiException('Error al crear actividad', statusCode: response.statusCode);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Actualiza una actividad existente
  Future<Actividad?> updateActivity(int id, Actividad actividad) async {
    try {
      final response = await _dio.put(
        '${AppConfig.actividadEndpoint}/$id',
        data: actividad.toJson(),
      );
      
      if (response.statusCode == 200) {
        return Actividad.fromJson(response.data);
      }
      throw ApiException('Error al actualizar actividad', statusCode: response.statusCode);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Actualiza parcialmente una actividad (solo campos específicos)
  Future<Actividad?> updateActividad(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '${AppConfig.actividadEndpoint}/$id',
        data: data,
      );
      
      if (response.statusCode == 200) {
        return Actividad.fromJson(response.data);
      }
      throw ApiException('Error al actualizar actividad', statusCode: response.statusCode);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Elimina una actividad
  Future<bool> deleteActivity(int id) async {
    try {
      final response = await _dio.delete('${AppConfig.actividadEndpoint}/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== FOTOS ====================

  /// Obtiene todas las fotos
  Future<List<Photo>> fetchPhotos() async {
    try {
      final response = await _dio.get(AppConfig.fotoEndpoint);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Photo.fromJson(json)).toList();
      }
      throw ApiException('Error al obtener fotos', statusCode: response.statusCode);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtiene fotos de una actividad específica
  Future<List<Photo>> fetchPhotosByActivityId(int activityId) async {
    try {
      final response = await _dio.get('${AppConfig.fotoEndpoint}/actividad/$activityId');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Photo.fromJson(json)).toList();
      }
      throw ApiException('Error al obtener fotos', statusCode: response.statusCode);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Sube fotos para una actividad
  Future<bool> uploadPhotos({
    required int activityId,
    required List<String> filePaths,
    String? descripcion,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'actividadId': activityId,
        'descripcion': descripcion ?? '',
        'fotos': filePaths.map((path) => MultipartFile.fromFileSync(path)).toList(),
      });

      final response = await _dio.post(
        '${AppConfig.fotoEndpoint}/upload',
        data: formData,
      );

      return response.statusCode == 200;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Sube una foto individual para una actividad
  Future<Photo?> uploadPhoto({
    required int activityId,
    required String imagePath,
    String? descripcion,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'actividadId': activityId,
        'descripcion': descripcion ?? '',
        'foto': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.post(
        '${AppConfig.fotoEndpoint}/upload',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Photo.fromJson(response.data);
      }
      return null;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Elimina una foto
  Future<bool> deletePhoto(int id) async {
    try {
      final response = await _dio.delete('${AppConfig.fotoEndpoint}/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== PROFESORES ====================

  /// Obtiene todos los profesores
  Future<List<Profesor>> fetchProfesores() async {
    try {
      final response = await _dio.get(AppConfig.profesorEndpoint);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Profesor.fromJson(json)).toList();
      }
      throw ApiException('Error al obtener profesores', statusCode: response.statusCode);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Crea un nuevo profesor
  Future<Profesor?> createProfesor(Profesor profesor) async {
    try {
      final response = await _dio.post(
        AppConfig.profesorEndpoint,
        data: profesor.toJson(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Profesor.fromJson(response.data);
      }
      throw ApiException('Error al crear profesor', statusCode: response.statusCode);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Actualiza un profesor
  Future<Profesor?> updateProfesor(String uuid, Profesor profesor) async {
    try {
      final response = await _dio.put(
        '${AppConfig.profesorEndpoint}/$uuid',
        data: profesor.toJson(),
      );
      
      if (response.statusCode == 200) {
        return Profesor.fromJson(response.data);
      }
      throw ApiException('Error al actualizar profesor', statusCode: response.statusCode);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Elimina un profesor
  Future<bool> deleteProfesor(String uuid) async {
    try {
      final response = await _dio.delete('${AppConfig.profesorEndpoint}/$uuid');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw _handleError(e);
    }
  }
}
