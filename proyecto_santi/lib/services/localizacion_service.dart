import 'package:proyecto_santi/services/api_service.dart';

/// Servicio para gestionar localizaciones de actividades
class LocalizacionService {
  final ApiService _apiService;

  LocalizacionService(this._apiService);

  /// Obtiene todas las localizaciones del catálogo
  Future<List<Map<String, dynamic>>> fetchAllLocalizaciones() async {
    try {
      final response = await _apiService.getData('/Localizacion');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List;
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      throw ApiException('Error al obtener localizaciones del catálogo', statusCode: response.statusCode);
    } catch (e) {
      print('[LocalizacionService ERROR] fetchAllLocalizaciones: $e');
      rethrow;
    }
  }

  /// Crea una nueva localización en el catálogo
  Future<Map<String, dynamic>?> createLocalizacion({
    required String nombre,
    String? direccion,
    String? ciudad,
    String? provincia,
    String? codigoPostal,
    double? latitud,
    double? longitud,
    String? icono,
  }) async {
    try {
      print('[LocalizacionService] Creating new localización: $nombre');
      final response = await _apiService.postData('/Localizacion', {
        'nombre': nombre,
        'direccion': direccion,
        'ciudad': ciudad,
        'provincia': provincia,
        'codigoPostal': codigoPostal,
        'latitud': latitud,
        'longitud': longitud,
        'icono': icono,
      });
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('[LocalizacionService ERROR] createLocalizacion: $e');
      return null;
    }
  }

  /// Obtiene todas las localizaciones de una actividad
  Future<List<Map<String, dynamic>>> fetchLocalizaciones(int actividadId) async {
    try {
      final response = await _apiService.getData('/Actividad/$actividadId/localizaciones');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List;
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      throw ApiException('Error al obtener localizaciones', statusCode: response.statusCode);
    } catch (e) {
      print('[LocalizacionService ERROR] fetchLocalizaciones: $e');
      rethrow;
    }
  }

  /// Añade una localización a una actividad
  Future<bool> addLocalizacion(
    int actividadId, 
    int localizacionId, {
    bool esPrincipal = false,
    String? icono,
  }) async {
    try {
      print('[LocalizacionService] Adding localización $localizacionId to actividad $actividadId');
      final response = await _apiService.postData(
        '/Actividad/$actividadId/localizaciones/$localizacionId',
        {
          'esPrincipal': esPrincipal,
          if (icono != null) 'icono': icono,
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('[LocalizacionService ERROR] addLocalizacion: $e');
      return false;
    }
  }

  /// Elimina una localización de una actividad
  Future<bool> removeLocalizacion(int actividadId, int localizacionId) async {
    try {
      print('[LocalizacionService] Removing localización $localizacionId from actividad $actividadId');
      final response = await _apiService.deleteData('/Actividad/$actividadId/localizaciones/$localizacionId');
      
      return response.statusCode == 200;
    } catch (e) {
      print('[LocalizacionService ERROR] removeLocalizacion: $e');
      return false;
    }
  }

  /// Actualiza una localización de una actividad (si es principal)
  Future<bool> updateLocalizacion(
    int actividadId, 
    int localizacionId, {
    required bool esPrincipal,
    String? icono,
  }) async {
    try {
      print('[LocalizacionService] Updating localización $localizacionId in actividad $actividadId');
      final response = await _apiService.putData(
        '/Actividad/$actividadId/localizaciones/$localizacionId',
        {
          'esPrincipal': esPrincipal,
          if (icono != null) 'icono': icono,
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('[LocalizacionService ERROR] updateLocalizacion: $e');
      return false;
    }
  }
}
