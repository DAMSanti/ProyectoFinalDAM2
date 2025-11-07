import 'dart:convert';
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
      // Limpiar sesión anterior antes de iniciar nueva sesión
      await _clearSession();
      
      // La API C# de ACEX valida email y password
      final loginResult = await _authService.login(email, password);
      
      if (loginResult != null && loginResult['token'] != null) {
        _jwtToken = loginResult['token'];
        
        final usuario = loginResult['usuario'];
        
        // ✅ MEJORADO: Calcular expiración del token (24 horas por defecto)
        final tokenExpiry = DateTime.now().add(Duration(hours: 24));
        
        final userRol = usuario?['rol']?.toString() ?? 'Usuario';
        final userNombre = usuario?['nombreUsuario']?.toString() ?? 'Usuario';
        
        // Obtener el profesorUuid del usuario PRIMERO
        final profesorUuid = usuario?['profesorUuid']?.toString();
        
        // Guardamos el token, email, rol, nombre, profesorUuid y expiración en almacenamiento seguro
        await SecureStorageConfig.storeUserCredentials(
          email,
          usuario?['id']?.toString() ?? '',
          jwtToken: _jwtToken,
          tokenExpiry: tokenExpiry,
          rol: userRol,
          nombre: userNombre,
          profesorUuid: profesorUuid, // ✅ FIX HOT RESTART: Guardar profesorUuid
        );
        
        print('[Auth] Usuario ID: ${usuario?['id']}');
        print('[Auth] Profesor UUID: $profesorUuid');
        print('[Auth] Rol: $userRol');
        
        // Creamos un objeto Profesor temporal con los datos del usuario
        // Si tiene profesorUuid, usar ese; si no, usar el ID del usuario
        _currentUser = Profesor(
          uuid: profesorUuid ?? usuario?['id']?.toString() ?? '',
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
    
    await _clearSession();
    
    notifyListeners();
  }

  /// Limpia la sesión sin notificar (usado internamente)
  Future<void> _clearSession() async {
    _isAuthenticated = false;
    _currentUser = null;
    _jwtToken = null;
    _authService.logout();
    
    // Limpia las credenciales almacenadas
    await SecureStorageConfig.clearUserCredentials();
  }

  /// ✅ MEJORADO: Verifica si hay una sesión activa al iniciar la app y la restaura
  Future<void> checkAuthStatus() async {
    try {
      final credentials = await SecureStorageConfig.getUserCredentials();
      final email = credentials['email'];
      final userId = credentials['uuid'];
      final profesorUuid = credentials['profesorUuid']; // ✅ FIX HOT RESTART: Leer profesorUuid guardado
      final savedToken = credentials['jwtToken'];
      
      // Verificar si tenemos token guardado
      if (savedToken != null && savedToken.isNotEmpty) {
        // Verificar si el token ha expirado
        final isExpired = await SecureStorageConfig.isTokenExpired();
        
        if (!isExpired) {
          // ✅ Token válido - Restaurar sesión automáticamente
          print('[Auth] 🔄 Restaurando sesión desde token guardado...');
          print('[Auth] 🔑 Profesor UUID restaurado: $profesorUuid');
          
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
            
            // Reconfigurar notificaciones - usar profesorUuid si está disponible
            final notificationId = profesorUuid ?? userId ?? '';
            await NotificationService().sendTokenToBackend(notificationId);
            await NotificationService().subscribeToTopic('all_users');
            if (profesor.rol == 'Profesor' || profesor.rol == 'Coordinador') {
              await NotificationService().subscribeToTopic('profesores');
            }
            
            print('[Auth] ✅ Sesión restaurada exitosamente para: ${profesor.nombre}');
          } catch (e) {
            print('[Auth] ⚠️ Error obteniendo datos de usuario, usando datos guardados: $e');
            
            // ✅ FIXED: Usar rol y nombre guardados en lugar de valores por defecto
            final savedRol = credentials['rol'] ?? 'Usuario';
            final savedNombre = credentials['nombre'] ?? email ?? 'Usuario';
            
            // Si no tenemos profesorUuid guardado, intentar obtenerlo del endpoint de usuarios
            String? finalProfesorUuid = profesorUuid;
            if (finalProfesorUuid == null && savedRol == 'Profesor') {
              try {
                print('[Auth] 🔍 Intentando obtener profesorUuid del backend...');
                final response = await _apiService.dio.get('/Usuarios');
                if (response.statusCode == 200) {
                  final usuarios = response.data as List;
                  final usuario = usuarios.firstWhere(
                    (u) => u['email']?.toString().toLowerCase() == email?.toLowerCase(),
                    orElse: () => null,
                  );
                  if (usuario != null) {
                    finalProfesorUuid = usuario['profesorUuid']?.toString();
                    print('[Auth] ✅ ProfesorUuid obtenido del backend: $finalProfesorUuid');
                    
                    // Guardarlo para la próxima vez
                    if (finalProfesorUuid != null) {
                      await SecureStorageConfig.storeUserCredentials(
                        email ?? '',
                        userId ?? '',
                        jwtToken: savedToken,
                        tokenExpiry: credentials['tokenExpiry'] != null 
                          ? DateTime.parse(credentials['tokenExpiry']!) 
                          : null,
                        rol: savedRol,
                        nombre: savedNombre,
                        profesorUuid: finalProfesorUuid,
                      );
                    }
                  }
                }
              } catch (backendError) {
                print('[Auth] ⚠️ No se pudo obtener profesorUuid del backend: $backendError');
              }
            }
            
            // Crear usuario temporal con datos guardados - USAR PROFESORUUID
            _currentUser = Profesor(
              uuid: finalProfesorUuid ?? userId ?? '', // ✅ FIX HOT RESTART: Priorizar profesorUuid sobre userId
              dni: '',
              nombre: savedNombre,
              apellidos: '',
              correo: email ?? '',
              password: '',
              rol: savedRol,
              activo: 1,
              urlFoto: null,
              esJefeDep: 0,
              depart: Departamento(
                id: 0, 
                codigo: savedRol.substring(0, 3).toUpperCase(), 
                nombre: savedRol
              ),
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
