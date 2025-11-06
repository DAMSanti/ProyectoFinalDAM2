import 'package:proyecto_santi/models/departamento.dart';
import 'package:proyecto_santi/models/curso.dart';
import 'package:proyecto_santi/models/grupo.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/config.dart';

/// Servicio para gestión de catálogos (Departamentos, Cursos, Grupos)
class CatalogoService {
  final ApiService _apiService;

  CatalogoService(this._apiService);

  // ==================== DEPARTAMENTOS ====================

  /// Obtiene todos los departamentos
  Future<List<Departamento>> fetchDepartamentos() async {
    try {

      final response = await _apiService.getData(AppConfig.departamentosEndpoint);
      


      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List;

        
        final departamentos = data.map((json) {

          return Departamento.fromJson(json);
        }).toList();
        

        return departamentos;
      }
      throw ApiException('Error al obtener departamentos', statusCode: response.statusCode);
    } catch (e) {
      print('[CatalogoService ERROR] fetchDepartamentos: $e');
      rethrow;
    }
  }

  /// Crea un nuevo departamento
  Future<Departamento> createDepartamento(Map<String, dynamic> data) async {
    try {
      print('[CatalogoService] Creating departamento');
      print('[CatalogoService] Data: $data');
      
      final response = await _apiService.postData(AppConfig.departamentosEndpoint, data);
      
      print('[CatalogoService] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Departamento.fromJson(response.data);
      }
      throw ApiException('Error al crear departamento', statusCode: response.statusCode);
    } catch (e) {
      print('[CatalogoService ERROR] createDepartamento: $e');
      rethrow;
    }
  }

  /// Actualiza un departamento existente
  Future<Departamento> updateDepartamento(int id, Map<String, dynamic> data) async {
    try {
      print('[CatalogoService] Updating departamento $id');
      print('[CatalogoService] Data: $data');
      
      final response = await _apiService.putData('${AppConfig.departamentosEndpoint}/$id', data);
      
      print('[CatalogoService] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return Departamento.fromJson(response.data);
      }
      throw ApiException('Error al actualizar departamento', statusCode: response.statusCode);
    } catch (e) {
      print('[CatalogoService ERROR] updateDepartamento: $e');
      rethrow;
    }
  }

  // ==================== CURSOS ====================

  /// Obtiene todos los cursos
  Future<List<Curso>> fetchCursos() async {
    try {

      final response = await _apiService.getData('/Curso');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List;
        final cursos = data.map((json) => Curso.fromJson(json)).toList();

        return cursos;
      }
      throw ApiException('Error al obtener cursos', statusCode: response.statusCode);
    } catch (e) {
      print('[CatalogoService ERROR] fetchCursos: $e');
      rethrow;
    }
  }

  /// Crea un nuevo curso
  Future<Curso> createCurso(Map<String, dynamic> data) async {
    try {
      print('[CatalogoService] Creating curso');
      print('[CatalogoService] Data: $data');
      
      final response = await _apiService.postData('/Curso', data);
      
      print('[CatalogoService] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Curso.fromJson(response.data);
      }
      throw ApiException('Error al crear curso', statusCode: response.statusCode);
    } catch (e) {
      print('[CatalogoService ERROR] createCurso: $e');
      rethrow;
    }
  }

  /// Actualiza un curso existente
  Future<Curso> updateCurso(int id, Map<String, dynamic> data) async {
    try {
      print('[CatalogoService] Updating curso $id');
      print('[CatalogoService] Data: $data');
      
      final response = await _apiService.putData('/Curso/$id', data);
      
      print('[CatalogoService] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return Curso.fromJson(response.data);
      }
      throw ApiException('Error al actualizar curso', statusCode: response.statusCode);
    } catch (e) {
      print('[CatalogoService ERROR] updateCurso: $e');
      rethrow;
    }
  }

  // ==================== GRUPOS ====================

  /// Obtiene todos los grupos
  Future<List<Grupo>> fetchGrupos() async {
    try {

      final response = await _apiService.getData('/Grupo');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List;
        final grupos = data.map((json) => Grupo.fromJson(json)).toList();

        return grupos;
      }
      throw ApiException('Error al obtener grupos', statusCode: response.statusCode);
    } catch (e) {
      print('[CatalogoService ERROR] fetchGrupos: $e');
      rethrow;
    }
  }

  /// Obtiene los grupos de un curso específico
  Future<List<Grupo>> fetchGruposByCurso(int cursoId) async {
    try {

      final response = await _apiService.getData('/Curso/$cursoId/grupos');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List;
        final grupos = data.map((json) => Grupo.fromJson(json)).toList();

        return grupos;
      }
      throw ApiException('Error al obtener grupos del curso', statusCode: response.statusCode);
    } catch (e) {
      print('[CatalogoService ERROR] fetchGruposByCurso: $e');
      rethrow;
    }
  }

  /// Obtiene los grupos participantes de una actividad
  Future<List<Map<String, dynamic>>> fetchGruposParticipantes(int actividadId) async {
    try {

      final response = await _apiService.getData('/Actividad/$actividadId/grupos-participantes');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List;
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      throw ApiException('Error al obtener grupos participantes', statusCode: response.statusCode);
    } catch (e) {
      print('[CatalogoService ERROR] fetchGruposParticipantes: $e');
      rethrow;
    }
  }

  /// Actualiza los grupos participantes de una actividad
  Future<bool> updateGruposParticipantes(int actividadId, List<Map<String, dynamic>> grupos) async {
    try {
      // El backend espera List<GrupoParticipanteUpdateDto> directamente, no un objeto con 'grupos'
      final response = await _apiService.put(
        '/Actividad/$actividadId/grupos-participantes',
        grupos,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('[CatalogoService ERROR] updateGruposParticipantes: $e');
      rethrow;
    }
  }

  /// Crea un nuevo grupo
  Future<Grupo> createGrupo(Map<String, dynamic> data) async {
    try {
      print('[CatalogoService] Creating grupo');
      print('[CatalogoService] Data: $data');
      
      final response = await _apiService.postData('/Grupo', data);
      
      print('[CatalogoService] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Grupo.fromJson(response.data);
      }
      throw ApiException('Error al crear grupo', statusCode: response.statusCode);
    } catch (e) {
      print('[CatalogoService ERROR] createGrupo: $e');
      rethrow;
    }
  }

  /// Actualiza un grupo existente
  Future<Grupo> updateGrupo(int id, Map<String, dynamic> data) async {
    try {
      print('[CatalogoService] Updating grupo $id');
      print('[CatalogoService] Data: $data');
      
      final response = await _apiService.putData('/Grupo/$id', data);
      
      print('[CatalogoService] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return Grupo.fromJson(response.data);
      }
      throw ApiException('Error al actualizar grupo', statusCode: response.statusCode);
    } catch (e) {
      print('[CatalogoService ERROR] updateGrupo: $e');
      rethrow;
    }
  }
}
