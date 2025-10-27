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
      print('[CatalogoService] Fetching departamentos from: ${AppConfig.departamentosEndpoint}');
      final response = await _apiService.getData(AppConfig.departamentosEndpoint);
      
      print('[CatalogoService] Response status: ${response.statusCode}');
      print('[CatalogoService] Response data type: ${response.data.runtimeType}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List;
        print('[CatalogoService] Raw data: $data');
        
        final departamentos = data.map((json) {
          print('[CatalogoService] Parsing departamento: $json');
          return Departamento.fromJson(json);
        }).toList();
        
        print('[CatalogoService] Parsed ${departamentos.length} departamentos');
        return departamentos;
      }
      throw ApiException('Error al obtener departamentos', statusCode: response.statusCode);
    } catch (e) {
      print('[CatalogoService ERROR] fetchDepartamentos: $e');
      rethrow;
    }
  }

  // ==================== CURSOS ====================

  /// Obtiene todos los cursos
  Future<List<Curso>> fetchCursos() async {
    try {
      print('[CatalogoService] Fetching cursos from: /Curso');
      final response = await _apiService.getData('/Curso');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List;
        final cursos = data.map((json) => Curso.fromJson(json)).toList();
        print('[CatalogoService] Parsed ${cursos.length} cursos');
        return cursos;
      }
      throw ApiException('Error al obtener cursos', statusCode: response.statusCode);
    } catch (e) {
      print('[CatalogoService ERROR] fetchCursos: $e');
      rethrow;
    }
  }

  // ==================== GRUPOS ====================

  /// Obtiene todos los grupos
  Future<List<Grupo>> fetchGrupos() async {
    try {
      print('[CatalogoService] Fetching grupos from: /Grupo');
      final response = await _apiService.getData('/Grupo');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List;
        final grupos = data.map((json) => Grupo.fromJson(json)).toList();
        print('[CatalogoService] Parsed ${grupos.length} grupos');
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
      print('[CatalogoService] Fetching grupos for curso $cursoId');
      final response = await _apiService.getData('/Curso/$cursoId/grupos');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List;
        final grupos = data.map((json) => Grupo.fromJson(json)).toList();
        print('[CatalogoService] Parsed ${grupos.length} grupos for curso $cursoId');
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
      print('[CatalogoService] Fetching grupos participantes for actividad $actividadId');
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
      print('[CatalogoService] Updating grupos participantes for actividad $actividadId');
      final response = await _apiService.putData(
        '/Actividad/$actividadId/grupos-participantes',
        {'grupos': grupos},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('[CatalogoService ERROR] updateGruposParticipantes: $e');
      rethrow;
    }
  }
}
