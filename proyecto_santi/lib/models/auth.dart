import 'package:flutter/material.dart';
import 'package:proyecto_santi/config.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/models/profesor.dart';

/// Clase para manejar la autenticación de la aplicación con API C# ACEX
class Auth extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isAuthenticated = false;
  Profesor? _currentUser;
  String? _jwtToken;

  bool get isAuthenticated => _isAuthenticated;
  Profesor? get currentUser => _currentUser;
  String? get token => _jwtToken;

  /// Inicia sesión con email y contraseña
  Future<bool> login(String email, String password) async {
    try {
      // La API C# de ACEX valida email y password
      final loginResult = await _apiService.login(email, password);
      
      if (loginResult != null && loginResult['token'] != null) {
        _jwtToken = loginResult['token'];
        _apiService.setToken(_jwtToken);
        
        final usuario = loginResult['usuario'];
        
        // Guardamos el token y email en almacenamiento seguro
        await SecureStorageConfig.storeUserCredentials(
          email,
          usuario?['id']?.toString() ?? '',
        );
        
        // Creamos un objeto Profesor temporal con los datos del usuario
        // Esto es para mantener compatibilidad con el resto de la app
        _currentUser = Profesor(
          uuid: usuario?['id']?.toString() ?? '',
          dni: '',
          nombre: usuario?['nombreCompleto']?.toString().split(' ').first ?? 'Usuario',
          apellidos: usuario?['nombreCompleto']?.toString().split(' ').skip(1).join(' ') ?? '',
          correo: usuario?['email']?.toString() ?? email,
          telefono: null,
          fotoUrl: null,
          activo: true,
          departamentoId: null,
          departamentoNombre: usuario?['rol']?.toString() ?? 'Usuario',
        );
        
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      print('[Auth] Error en login: $e');
      return false;
    }
  }

  /// Cierra la sesión del usuario actual
  Future<void> logout() async {
    _isAuthenticated = false;
    _currentUser = null;
    _jwtToken = null;
    _apiService.setToken(null);
    
    // Limpia las credenciales almacenadas
    await SecureStorageConfig.clearUserCredentials();
    
    notifyListeners();
  }

  /// Verifica si hay una sesión activa al iniciar la app
  Future<void> checkAuthStatus() async {
    try {
      final credentials = await SecureStorageConfig.getUserCredentials();
      final email = credentials['email'];
      final userId = credentials['userId'];
      
      if (email != null && email.isNotEmpty && userId != null && userId.isNotEmpty) {
        // Tenemos credenciales guardadas, pero sin contraseña no podemos hacer login automático
        // El usuario deberá volver a ingresar su contraseña
        print('[Auth] Sesión expirada. Se requiere login nuevamente.');
        await logout();
      }
    } catch (e) {
      print('[Auth] Error verificando estado de autenticación: $e');
      _isAuthenticated = false;
      _currentUser = null;
      _jwtToken = null;
    }
    
    notifyListeners();
  }

  /// Actualiza los datos del usuario actual
  Future<void> updateCurrentUser() async {
    if (_currentUser != null && _jwtToken != null) {
      try {
        final updatedProfesor = await _apiService.getProfesorByUuid(_currentUser!.uuid);
        if (updatedProfesor != null) {
          _currentUser = updatedProfesor;
          notifyListeners();
        }
      } catch (e) {
        print('[Auth] Error actualizando usuario: $e');
      }
    }
  }

  /// Refresca el token JWT
  /// NOTA: Sin almacenar la contraseña, no podemos refrescar el token automáticamente
  /// El usuario deberá hacer login nuevamente
  Future<bool> refreshToken() async {
    print('[Auth] Token expirado. Se requiere login nuevamente.');
    return false;
  }
}