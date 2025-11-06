import 'package:proyecto_santi/models/usuario.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:dio/dio.dart';

/// Servicio para gestionar operaciones CRUD de usuarios
class UsuarioService {
  final ApiService _apiService;

  UsuarioService(this._apiService);

  /// Obtiene todos los usuarios
  Future<List<Usuario>> fetchUsuarios() async {
    try {
      final response = await _apiService.dio.get('/Usuarios');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => Usuario.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Error al cargar usuarios: ${response.statusCode}');
      }
    } catch (e) {
      print('[ERROR] UsuarioService.fetchUsuarios: $e');
      throw Exception('Error al cargar usuarios: $e');
    }
  }

  /// Obtiene un usuario por ID
  Future<Usuario?> fetchUsuarioById(String id) async {
    try {
      final response = await _apiService.dio.get('/Usuarios/$id');
      
      if (response.statusCode == 200) {
        return Usuario.fromJson(response.data as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print('[ERROR] UsuarioService.fetchUsuarioById: $e');
      return null;
    }
  }

  /// Crea un nuevo usuario
  Future<Usuario?> createUsuario(Map<String, dynamic> usuarioData) async {
    try {
      final response = await _apiService.dio.post(
        '/Usuarios',
        data: usuarioData,
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Usuario.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Error al crear usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('[ERROR] UsuarioService.createUsuario: $e');
      throw Exception('Error al crear usuario: $e');
    }
  }

  /// Actualiza un usuario existente
  Future<bool> updateUsuario(String id, Map<String, dynamic> usuarioData) async {
    try {
      final response = await _apiService.dio.put(
        '/Usuarios/$id',
        data: usuarioData,
      );
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('[ERROR] UsuarioService.updateUsuario: $e');
      throw Exception('Error al actualizar usuario: $e');
    }
  }

  /// Elimina un usuario
  Future<bool> deleteUsuario(String id) async {
    try {
      final response = await _apiService.dio.delete('/Usuarios/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('[ERROR] UsuarioService.deleteUsuario: $e');
      throw Exception('Error al eliminar usuario: $e');
    }
  }

  /// Cambia el estado activo/inactivo de un usuario
  Future<bool> toggleUsuarioActivo(String id, bool activo) async {
    try {
      final response = await _apiService.dio.patch(
        '/Usuarios/$id/estado',
        data: {'activo': activo},
      );
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('[ERROR] UsuarioService.toggleUsuarioActivo: $e');
      throw Exception('Error al cambiar estado del usuario: $e');
    }
  }

  /// Cambia la contraseña de un usuario
  Future<bool> changePassword(String id, String newPassword) async {
    try {
      final response = await _apiService.dio.post(
        '/Usuarios/$id/cambiar-password',
        data: {'password': newPassword},
      );
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('[ERROR] UsuarioService.changePassword: $e');
      throw Exception('Error al cambiar contraseña: $e');
    }
  }
}
