import 'package:flutter/material.dart';
import 'package:proyecto_santi/config.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/services/notification_service.dart';
import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/models/departamento.dart';

/// Clase para manejar la autenticación de la aplicación con API C# ACEX
class Auth extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  late final AuthService _authService;
  late final ProfesorService _profesorService;
  
  bool _isAuthenticated = false;
  Profesor? _currentUser;
  String? _jwtToken;
  
  Auth() {
    _authService = AuthService(_apiService);
    _profesorService = ProfesorService(_apiService);
  }

  bool get isAuthenticated => _isAuthenticated;
  Profesor? get currentUser => _currentUser;
  String? get token => _jwtToken;

  /// Inicia sesión con email y contraseña
  Future<bool> login(String email, String password) async {
    try {
      // La API C# de ACEX valida email y password
      final loginResult = await _authService.login(email, password);
      
      if (loginResult != null && loginResult['token'] != null) {
        _jwtToken = loginResult['token'];
        
        final usuario = loginResult['usuario'];
        
        // ✅ MEJORADO: Calcular expiración del token (24 horas por defecto)
        final tokenExpiry = DateTime.now().add(Duration(hours: 24));
        
        // Guardamos el token, email y expiración en almacenamiento seguro
        await SecureStorageConfig.storeUserCredentials(
          email,
          usuario?['id']?.toString() ?? '',
          jwtToken: _jwtToken,
          tokenExpiry: tokenExpiry,
        );
        
        // Creamos un objeto Profesor temporal con los datos del usuario
        // Esto es para mantener compatibilidad con el resto de la app
        _currentUser = Profesor(
          uuid: usuario?['id']?.toString() ?? '',
          dni: '',
          nombre: usuario?['nombreUsuario']?.toString() ?? 'Usuario',
          apellidos: '',
          correo: usuario?['email']?.toString() ?? email,
          password: '',
          rol: usuario?['rol']?.toString() ?? 'Usuario',
          activo: 1,
          urlFoto: null,
          esJefeDep: 0,
          depart: Departamento(
            id: 0,
            codigo: usuario?['rol']?.toString() ?? 'USR',
            nombre: usuario?['rol']?.toString() ?? 'Usuario',
          ),
        );
        
        _isAuthenticated = true;
        
        // Enviar token FCM al backend para notificaciones push
        final userId = usuario?['id']?.toString();
        if (userId != null) {
          await NotificationService().sendTokenToBackend(userId);
          
          // Suscribirse a tópicos relevantes
          await NotificationService().subscribeToTopic('all_users');
          if (usuario?['rol']?.toString() == 'Profesor' || 
              usuario?['rol']?.toString() == 'Coordinador') {
            await NotificationService().subscribeToTopic('profesores');
          }
        }
        
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
    // Desuscribirse de tópicos de notificaciones
    await NotificationService().unsubscribeFromTopic('all_users');
    await NotificationService().unsubscribeFromTopic('profesores');
    
    _isAuthenticated = false;
    _currentUser = null;
    _jwtToken = null;
    _authService.logout();
    
    // Limpia las credenciales almacenadas
    await SecureStorageConfig.clearUserCredentials();
    
    notifyListeners();
  }

  /// ✅ MEJORADO: Verifica si hay una sesión activa al iniciar la app y la restaura
  Future<void> checkAuthStatus() async {
    try {
      final credentials = await SecureStorageConfig.getUserCredentials();
      final email = credentials['email'];
      final userId = credentials['uuid'];
      final savedToken = credentials['jwtToken'];
      
      // Verificar si tenemos token guardado
      if (savedToken != null && savedToken.isNotEmpty) {
        // Verificar si el token ha expirado
        final isExpired = await SecureStorageConfig.isTokenExpired();
        
        if (!isExpired) {
          // ✅ Token válido - Restaurar sesión automáticamente
          print('[Auth] 🔄 Restaurando sesión desde token guardado...');
          
          _jwtToken = savedToken;
          _apiService.setToken(savedToken);
          
          // Intentar obtener datos del usuario actual
          try {
            final profesores = await _profesorService.fetchProfesores();
            final profesor = profesores.firstWhere(
              (p) => p.correo == email && p.activo == 1,
              orElse: () => throw Exception('Profesor no encontrado'),
            );
            
            _currentUser = profesor;
            _isAuthenticated = true;
            
            // Reconfigurar notificaciones
            await NotificationService().sendTokenToBackend(userId ?? '');
            await NotificationService().subscribeToTopic('all_users');
            if (profesor.rol == 'Profesor' || profesor.rol == 'Coordinador') {
              await NotificationService().subscribeToTopic('profesores');
            }
            
            print('[Auth] ✅ Sesión restaurada exitosamente para: ${profesor.nombre}');
          } catch (e) {
            print('[Auth] ⚠️ Error obteniendo datos de usuario, usando datos guardados: $e');
            
            // Crear usuario temporal con datos guardados
            _currentUser = Profesor(
              uuid: userId ?? '',
              dni: '',
              nombre: email ?? 'Usuario',
              apellidos: '',
              correo: email ?? '',
              password: '',
              rol: 'Usuario',
              activo: 1,
              urlFoto: null,
              esJefeDep: 0,
              depart: Departamento(id: 0, codigo: 'USR', nombre: 'Usuario'),
            );
            _isAuthenticated = true;
          }
        } else {
          // Token expirado - Limpiar y requerir login
          print('[Auth] ⏰ Token expirado. Se requiere login nuevamente.');
          await logout();
        }
      } else if (email != null && email.isNotEmpty) {
        // Tenemos email pero no token - Requerir login
        print('[Auth] 📧 Email guardado pero sin token. Se requiere login.');
        _isAuthenticated = false;
      }
    } catch (e) {
      print('[Auth] ❌ Error verificando estado de autenticación: $e');
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
        final updatedProfesor = await _profesorService.getProfesorByUuid(_currentUser!.uuid);
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
