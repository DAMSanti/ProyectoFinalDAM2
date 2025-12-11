import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/models/grupo.dart';
import 'package:proyecto_santi/models/grupo_participante.dart';
import 'package:proyecto_santi/models/localizacion.dart';
import 'package:proyecto_santi/services/services.dart';
class ActivityDetailDataService {
  final ApiService _apiService;
  final ProfesorService _profesorService;
  final CatalogoService _catalogoService;
  final LocalizacionService _localizacionService;
  ActivityDetailDataService({
    required ApiService apiService,
    required ProfesorService profesorService,
    required CatalogoService catalogoService,
    required LocalizacionService localizacionService,
  })  : _apiService = apiService,
        _profesorService = profesorService,
        _catalogoService = catalogoService,
        _localizacionService = localizacionService;
  Future<Map<String, dynamic>> loadParticipantes(int actividadId) async {
    try {
      final profesoresResponse = await _apiService.getData(
        '/Actividad/$actividadId/profesores',
      );
      final List<Profesor> profesores = [];
      if (profesoresResponse.statusCode == 200) {
        final profesoresData = profesoresResponse.data as List;
        for (var pData in profesoresData) {
          try {
            profesores.add(Profesor.fromJson(pData as Map<String, dynamic>));
          } catch (e) {
          }
        }
      }
      final gruposResponse = await _apiService.getData(
        '/Actividad/$actividadId/grupos',
      );
      final List<GrupoParticipante> grupos = [];
      if (gruposResponse.statusCode == 200) {
        final gruposData = gruposResponse.data as List;
        for (var gpData in gruposData) {
          try {
            final gpMap = gpData as Map<String, dynamic>;
            final grupoData = gpMap['grupo'] as Map<String, dynamic>?;
            if (grupoData != null) {
              final grupo = Grupo.fromJson(grupoData);
              final numeroParticipantes = gpMap['numeroParticipantes'] as int? ?? grupo.numeroAlumnos;
              grupos.add(GrupoParticipante(
                grupo: grupo,
                numeroParticipantes: numeroParticipantes,
              ));
            }
          } catch (e) {
          }
        }
      }
      return {
        'profesores': profesores,
        'grupos': grupos,
      };
    } catch (e) {
      rethrow;
    }
  }
  Future<List<Localizacion>> loadLocalizaciones(int actividadId) async {
    try {
      final localizacionesData = await _localizacionService.fetchLocalizaciones(actividadId);
      return localizacionesData
          .map((data) => Localizacion.fromJson(data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
  Future<Map<String, dynamic>> loadAllData(int actividadId) async {
    try {
      final results = await Future.wait([
        loadParticipantes(actividadId),
        loadLocalizaciones(actividadId),
      ]);
      final participantes = results[0] as Map<String, dynamic>;
      final localizaciones = results[1] as List<Localizacion>;
      return {
        'profesores': participantes['profesores'],
        'grupos': participantes['grupos'],
        'localizaciones': localizaciones,
      };
    } catch (e) {
      rethrow;
    }
  }
  bool hasParticipantesChanges({
    required List<Profesor> current,
    required List<Profesor> original,
    required List<GrupoParticipante> currentGroups,
    required List<GrupoParticipante> originalGroups,
  }) {
    if (current.length != original.length) return true;
    for (var profesor in current) {
      if (!original.any((p) => p.uuid == profesor.uuid)) {
        return true;
      }
    }
    if (currentGroups.length != originalGroups.length) return true;
    for (var grupo in currentGroups) {
      final original = originalGroups.firstWhere(
        (g) => g.grupo.id == grupo.grupo.id,
        orElse: () => grupo,
      );
      if (original != grupo) {
        if (original.numeroParticipantes != grupo.numeroParticipantes) {
          return true;
        }
      }
    }
    return false;
  }
  int calculateTotalAlumnos(List<GrupoParticipante> grupos) {
    return grupos.fold(0, (sum, gp) => sum + gp.numeroParticipantes);
  }
}