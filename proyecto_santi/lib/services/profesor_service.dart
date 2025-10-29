import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/config.dart';

/// Servicio para gestión de profesores
class ProfesorService {
  final ApiService _apiService;

  ProfesorService(this._apiService);

  /// Obtiene todos los profesores
  Future<List<Profesor>> fetchProfesores() async {
    try {
      final response = await _apiService.getData(AppConfig.profesorEndpoint);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        
        final profesores = data.map((json) {
          return Profesor.fromJson(json);
        }).toList();
        
        return profesores;
      }
      throw ApiException('Error al obtener profesores', statusCode: response.statusCode);
    } catch (e) {
      print('[ProfesorService ERROR] fetchProfesores: $e');
      rethrow;
    }
  }

  /// Verifica si un profesor existe por UUID
  Future<Profesor?> getProfesorByUuid(String uuid) async {
    try {
      final response = await _apiService.getData('${AppConfig.profesorEndpoint}/$uuid');
      
      if (response.statusCode == 200 && response.data != null) {
        return Profesor.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('[ProfesorService ERROR] getProfesorByUuid: $e');
      return null;
    }
  }

  /// Crea un nuevo profesor
  Future<Profesor?> createProfesor(Profesor profesor) async {
    try {
      final response = await _apiService.postData(
        AppConfig.profesorEndpoint,
        profesor.toJson(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Profesor.fromJson(response.data);
      }
      throw ApiException('Error al crear profesor', statusCode: response.statusCode);
    } catch (e) {
      print('[ProfesorService ERROR] createProfesor: $e');
      rethrow;
    }
  }

  /// Actualiza un profesor
  Future<Profesor?> updateProfesor(String uuid, Profesor profesor) async {
    try {
      final response = await _apiService.putData(
        '${AppConfig.profesorEndpoint}/$uuid',
        profesor.toJson(),
      );
      
      if (response.statusCode == 200) {
        return Profesor.fromJson(response.data);
      }
      throw ApiException('Error al actualizar profesor', statusCode: response.statusCode);
    } catch (e) {
      print('[ProfesorService ERROR] updateProfesor: $e');
      rethrow;
    }
  }

  /// Elimina un profesor
  Future<bool> deleteProfesor(String uuid) async {
    try {
      final response = await _apiService.deleteData('${AppConfig.profesorEndpoint}/$uuid');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('[ProfesorService ERROR] deleteProfesor: $e');
      rethrow;
    }
  }

  /// Obtiene los profesores participantes de una actividad
  Future<List<String>> fetchProfesoresParticipantes(int actividadId) async {
    try {
      final response = await _apiService.getData('/Actividad/$actividadId/profesores-participantes');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List;
        final result = data.map((e) => e.toString()).toList();
        return result;
      }
      throw ApiException('Error al obtener profesores participantes', statusCode: response.statusCode);
    } catch (e) {
      print('[ProfesorService ERROR] fetchProfesoresParticipantes: $e');
      rethrow;
    }
  }

  /// Actualiza los profesores participantes de una actividad
  Future<bool> updateProfesoresParticipantes(int actividadId, List<String> profesoresIds) async {
    try {
      // El backend espera List<string> directamente, no un objeto con 'profesoresIds'
      final response = await _apiService.put(
        '/Actividad/$actividadId/profesores-participantes',
        profesoresIds,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('[ProfesorService ERROR] updateProfesoresParticipantes: $e');
      rethrow;
    }
  }
}
