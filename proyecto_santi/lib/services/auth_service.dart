import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/services/profesor_service.dart';
import 'package:proyecto_santi/config.dart';
class AuthService {
  final ApiService _apiService;
  final ProfesorService _profesorService;
  AuthService(this._apiService) : _profesorService = ProfesorService(_apiService);
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      print('[Auth] Intentando login con: $email');
      final response = await _apiService.postData(
        '${AppConfig.authEndpoint}/login',
        {
          'nombreUsuario': email, 
          'password': password,
        },
      );
      print('[Auth] Response status: ${response.statusCode}');
      print('[Auth] Response data: ${response.data}');
      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['token'];
        if (token != null) {
          _apiService.setToken(token);
          print('[Auth] Token establecido correctamente');
          return response.data;
        }
      }
      print('[Auth] Login falló - no hay token en la respuesta');
      return null;
    } catch (e) {
      print('[Auth Error] Login failed: $e');
      print('[Auth Error] Error type: ${e.runtimeType}');
      return null;
    }
  }
  Future<Profesor?> authenticate(String email, String password) async {
    try {
      final loginResult = await login(email, password);
      if (loginResult != null) {
        final profesores = await _profesorService.fetchProfesores();
        final profesor = profesores.firstWhere(
          (p) => p.correo == email && p.activo == 1,
          orElse: () => throw Exception('Profesor no encontrado'),
        );
        return profesor;
      }
      return null;
    } catch (e) {
      print('[Auth Error] Authentication failed: $e');
      return null;
    }
  }
  void logout() {
    _apiService.setToken(null);
  }
  String? get token => _apiService.token;
  bool get isAuthenticated => _apiService.token != null;
}