import 'package:proyecto_santi/models/gasto_personalizado.dart';
import 'package:proyecto_santi/services/api_service.dart';

/// Servicio para gestión de gastos personalizados
class GastoPersonalizadoService {
  final ApiService _apiService;

  GastoPersonalizadoService(this._apiService);

  /// Obtiene todos los gastos personalizados de una actividad
  Future<List<GastoPersonalizado>> fetchGastosByActividad(int actividadId) async {
    try {
      final response = await _apiService.getData('/GastoPersonalizado/actividad/$actividadId');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => GastoPersonalizado.fromJson(json)).toList();
      }
      throw ApiException('Error al obtener gastos personalizados', statusCode: response.statusCode);
    } catch (e) {
      print('[GastoPersonalizadoService ERROR] fetchGastosByActividad: $e');
      rethrow;
    }
  }

  /// Crea un nuevo gasto personalizado
  Future<GastoPersonalizado?> createGasto(GastoPersonalizado gasto) async {
    try {
      final response = await _apiService.postData(
        '/GastoPersonalizado',
        {
          'actividadId': gasto.actividadId,
          'concepto': gasto.concepto,
          'cantidad': gasto.cantidad,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return GastoPersonalizado.fromJson(response.data);
      }
      throw ApiException('Error al crear gasto personalizado', statusCode: response.statusCode);
    } catch (e) {
      print('[GastoPersonalizadoService ERROR] createGasto: $e');
      rethrow;
    }
  }

  /// Actualiza un gasto personalizado
  Future<bool> updateGasto(int id, GastoPersonalizado gasto) async {
    try {
      final response = await _apiService.putData(
        '/GastoPersonalizado/$id',
        {
          'actividadId': gasto.actividadId,
          'concepto': gasto.concepto,
          'cantidad': gasto.cantidad,
        },
      );
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('[GastoPersonalizadoService ERROR] updateGasto: $e');
      rethrow;
    }
  }

  /// Elimina un gasto personalizado
  Future<bool> deleteGasto(int id) async {
    try {
      final response = await _apiService.deleteData('/GastoPersonalizado/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('[GastoPersonalizadoService ERROR] deleteGasto: $e');
      rethrow;
    }
  }
}
