import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/alojamiento.dart';
import 'package:proyecto_santi/models/empresa_transporte.dart';
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
      
      // Combinar fecha y hora para FechaInicio y FechaFin
      String fechaInicioConHora = actividad.fini;
      String fechaFinConHora = actividad.ffin;
      
      // Si hay hora de inicio, combinarla con la fecha
      if (actividad.hini.isNotEmpty && actividad.hini != '00:00:00') {
        final fechaInicio = DateTime.parse(actividad.fini);
        final horaPartes = actividad.hini.split(':');
        final fechaConHora = DateTime(
          fechaInicio.year,
          fechaInicio.month,
          fechaInicio.day,
          int.parse(horaPartes[0]),
          int.parse(horaPartes[1]),
          horaPartes.length > 2 ? int.parse(horaPartes[2]) : 0,
        );
        fechaInicioConHora = fechaConHora.toIso8601String();
      }
      
      // Si hay hora de fin, combinarla con la fecha
      if (actividad.hfin.isNotEmpty && actividad.hfin != '00:00:00') {
        final fechaFin = DateTime.parse(actividad.ffin);
        final horaPartes = actividad.hfin.split(':');
        final fechaConHora = DateTime(
          fechaFin.year,
          fechaFin.month,
          fechaFin.day,
          int.parse(horaPartes[0]),
          int.parse(horaPartes[1]),
          horaPartes.length > 2 ? int.parse(horaPartes[2]) : 0,
        );
        fechaFinConHora = fechaConHora.toIso8601String();
      }
      
      print('[ActividadService] FechaInicio con hora: $fechaInicioConHora');
      print('[ActividadService] FechaFin con hora: $fechaFinConHora');
      
      // Preparar FormData en lugar de JSON
      final formData = FormData.fromMap({
        'Nombre': actividad.titulo,
        'Descripcion': actividad.descripcion,
        'FechaInicio': fechaInicioConHora,
        'FechaFin': fechaFinConHora,
        'PresupuestoEstimado': actividad.presupuestoEstimado,
        'CostoReal': actividad.costoReal,
        'Estado': actividad.estado,
        'Tipo': actividad.tipo,
        'ResponsableId': actividad.responsable?.uuid,
        'TransporteReq': actividad.transporteReq,
        'PrecioTransporte': actividad.precioTransporte,
        'EmpresaTransporteId': actividad.empresaTransporte?.id,
        'AlojamientoReq': actividad.alojamientoReq,
        'PrecioAlojamiento': actividad.precioAlojamiento,
        'AlojamientoId': actividad.alojamiento?.id,
        // LocalizacionId es opcional
      });
      
      print('[ActividadService] FormData preparado con ResponsableId: ${actividad.responsable?.uuid}');
      print('[ActividadService] FormData - TransporteReq: ${actividad.transporteReq}, PrecioTransporte: ${actividad.precioTransporte}, EmpresaTransporteId: ${actividad.empresaTransporte?.id}');
      print('[ActividadService] FormData - AlojamientoReq: ${actividad.alojamientoReq}, PrecioAlojamiento: ${actividad.precioAlojamiento}, AlojamientoId: ${actividad.alojamiento?.id}');
      print('[ActividadService] FormData - PresupuestoEstimado: ${actividad.presupuestoEstimado}');
      print('[ActividadService] FormData - CostoReal: ${actividad.costoReal}');
      print('[ActividadService] URL: ${AppConfig.apiBaseUrl}${AppConfig.actividadEndpoint}/$id');
      
      // Imprimir todo el contenido del FormData
      print('[ActividadService] ========== FORMDATA COMPLETO ==========');
      formData.fields.forEach((field) {
        print('[ActividadService] ${field.key}: ${field.value}');
      });
      print('[ActividadService] ==========================================');
      
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

  /// Obtiene todas las empresas de transporte
  Future<List<EmpresaTransporte>> fetchEmpresasTransporte() async {
    try {
      print('[ActividadService] Fetching empresas de transporte');
      print('[ActividadService] URL: ${AppConfig.apiBaseUrl}/EmpTransporte');
      
      final response = await _apiService.getData('/EmpTransporte');
      
      print('[ActividadService] Response status: ${response.statusCode}');
      print('[ActividadService] Response data type: ${response.data.runtimeType}');
      print('[ActividadService] Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        final List<dynamic> list = response.data as List;
        print('[ActividadService] Lista parseada - Cantidad: ${list.length}');
        
        final empresas = list.map((json) {
          print('[ActividadService] Parseando: $json');
          return EmpresaTransporte.fromJson(json);
        }).toList();
        
        print('[ActividadService] Empresas cargadas exitosamente: ${empresas.length}');
        return empresas;
      }
      throw ApiException('Error al obtener empresas de transporte', statusCode: response.statusCode);
    } catch (e) {
      print('[ActividadService ERROR] fetchEmpresasTransporte: $e');
      if (e is DioException) {
        print('[ActividadService ERROR] Response: ${e.response?.data}');
        print('[ActividadService ERROR] Status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  /// Obtiene todos los alojamientos activos
  Future<List<Alojamiento>> fetchAlojamientos() async {
    try {
      print('[ActividadService] Fetching alojamientos');
      print('[ActividadService] URL: ${AppConfig.apiBaseUrl}/Alojamiento?soloActivos=true');
      
      final response = await _apiService.getData('/Alojamiento?soloActivos=true');
      
      print('[ActividadService] Response status: ${response.statusCode}');
      print('[ActividadService] Response data type: ${response.data.runtimeType}');
      print('[ActividadService] Response data count: ${(response.data as List).length}');
      
      if (response.statusCode == 200) {
        final List<dynamic> list = response.data as List;
        print('[ActividadService] Lista parseada - Cantidad: ${list.length}');
        
        final alojamientos = list.map((json) {
          print('[ActividadService] Parseando alojamiento: ${json['nombre']}');
          return Alojamiento.fromJson(json);
        }).toList();
        
        print('[ActividadService] Alojamientos cargados exitosamente: ${alojamientos.length}');
        return alojamientos;
      }
      throw ApiException('Error al obtener alojamientos', statusCode: response.statusCode);
    } catch (e) {
      print('[ActividadService ERROR] fetchAlojamientos: $e');
      if (e is DioException) {
        print('[ActividadService ERROR] Response: ${e.response?.data}');
        print('[ActividadService ERROR] Status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }
}
