import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/config.dart';

/// Servicio para gestión de actividades
class ActividadService {
  final ApiService _apiService;

  ActividadService(this._apiService);

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
      
      String endpoint = AppConfig.actividadEndpoint;
      if (queryParams.isNotEmpty) {
        final query = queryParams.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');
        endpoint += '?$query';
      }
      
      final response = await _apiService.getData(endpoint);
      
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
      print('[ActividadService ERROR] fetchActivities: $e');
      rethrow;
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
          print('[ActividadService Warning] Error parsing date for activity ${actividad.id}: $e');
          return false;
        }
      }).toList();
    } catch (e) {
      print('[ActividadService ERROR] fetchFutureActivities: $e');
      rethrow;
    }
  }

  /// Obtiene una actividad por ID
  Future<Actividad?> fetchActivityById(int id) async {
    try {
      final response = await _apiService.getData('${AppConfig.actividadEndpoint}/$id');
      
      if (response.statusCode == 200 && response.data != null) {
        return Actividad.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('[ActividadService Warning] Activity $id not found: $e');
      return null;
    }
  }

  /// Crea una nueva actividad
  Future<Actividad?> createActivity(Actividad actividad) async {
    try {
      final response = await _apiService.postData(
        AppConfig.actividadEndpoint,
        actividad.toJson(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Actividad.fromJson(response.data);
      }
      throw ApiException('Error al crear actividad', statusCode: response.statusCode);
    } catch (e) {
      print('[ActividadService ERROR] createActivity: $e');
      rethrow;
    }
  }

  /// Actualiza una actividad existente
  Future<Actividad?> updateActivity(int id, Actividad actividad) async {
    try {
      print('[ActividadService] ========== UPDATE ACTIVITY ==========');
      print('[ActividadService] ID: $id');
      
      // Preparar FormData en lugar de JSON
      final formData = FormData.fromMap({
        'Nombre': actividad.titulo,
        'Descripcion': actividad.descripcion,
        'FechaInicio': actividad.fini,
        'FechaFin': actividad.ffin,
        'PresupuestoEstimado': actividad.importePorAlumno,
        'Aprobada': actividad.estado == 'Aprobada',
        'SolicitanteId': actividad.solicitante?.uuid,
        'DepartamentoId': actividad.departamento?.id,
        // LocalizacionId y EmpTransporteId son opcionales
      });
      
      print('[ActividadService] FormData preparado con SolicitanteId: ${actividad.solicitante?.uuid}');
      print('[ActividadService] URL: ${AppConfig.apiBaseUrl}${AppConfig.actividadEndpoint}/$id');
      
      final response = await _apiService.dio.put(
        '${AppConfig.actividadEndpoint}/$id',
        data: formData,
      );
      
      print('[ActividadService] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('[ActividadService] Actividad actualizada correctamente');
        return Actividad.fromJson(response.data);
      }
      throw ApiException('Error al actualizar actividad', statusCode: response.statusCode);
    } catch (e) {
      print('[ActividadService] ========== ERROR EN UPDATE ==========');
      print('[ActividadService] Error: $e');
      if (e is DioException) {
        print('[ActividadService] Response data: ${e.response?.data}');
      }
      rethrow;
    }
  }

  /// Actualiza campos específicos de una actividad
  Future<Actividad?> updateActivityFields(int id, Map<String, dynamic> fields) async {
    try {
      print('[ActividadService] ========== UPDATE ACTIVITY FIELDS ==========');
      print('[ActividadService] ID: $id');
      print('[ActividadService] Campos a actualizar: $fields');
      print('[ActividadService] URL: ${AppConfig.apiBaseUrl}${AppConfig.actividadEndpoint}/$id');
      
      final response = await _apiService.putData(
        '${AppConfig.actividadEndpoint}/$id',
        fields,
      );
      
      print('[ActividadService] Response status: ${response.statusCode}');
      print('[ActividadService] Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        print('[ActividadService] Actividad actualizada correctamente');
        return Actividad.fromJson(response.data);
      }
      throw ApiException('Error al actualizar actividad', statusCode: response.statusCode);
    } catch (e) {
      print('[ActividadService] ========== ERROR EN UPDATE ==========');
      print('[ActividadService] Error tipo: ${e.runtimeType}');
      print('[ActividadService] Error detalles: $e');
      if (e is DioException) {
        print('[ActividadService] Response data: ${e.response?.data}');
        print('[ActividadService] Response headers: ${e.response?.headers}');
      }
      rethrow;
    }
  }

  /// Elimina una actividad
  Future<bool> deleteActivity(int id) async {
    try {
      final response = await _apiService.deleteData('${AppConfig.actividadEndpoint}/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('[ActividadService ERROR] deleteActivity: $e');
      rethrow;
    }
  }

  /// Sube un folleto PDF a una actividad
  Future<String> uploadFolleto(int actividadId, {String? filePath, Uint8List? fileBytes, required String fileName}) async {
    try {
      print('[ActividadService] Uploading folleto for actividad $actividadId');
      
      MultipartFile multipartFile;
      if (fileBytes != null) {
        // Web: usar bytes
        multipartFile = MultipartFile.fromBytes(fileBytes, filename: fileName);
      } else if (filePath != null) {
        // Móvil/Desktop: usar path
        multipartFile = await MultipartFile.fromFile(filePath, filename: fileName);
      } else {
        throw Exception('Se requiere filePath o fileBytes');
      }
      
      final formData = FormData.fromMap({
        'folleto': multipartFile,
      });
      
      final response = await _apiService.dio.post(
        '/Actividad/$actividadId/folleto',
        data: formData,
      );
      
      if (response.statusCode == 200) {
        return response.data['folletoUrl'];
      } else {
        throw Exception('Error al subir el folleto');
      }
    } catch (e) {
      print('[ActividadService ERROR] uploadFolleto: $e');
      rethrow;
    }
  }

  /// Elimina el folleto de una actividad
  Future<void> deleteFolleto(int actividadId) async {
    try {
      print('[ActividadService] Deleting folleto for actividad $actividadId');
      
      final response = await _apiService.deleteData('/Actividad/$actividadId/folleto');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar el folleto');
      }
    } catch (e) {
      print('[ActividadService ERROR] deleteFolleto: $e');
      rethrow;
    }
  }
}
