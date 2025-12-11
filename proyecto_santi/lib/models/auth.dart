import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:proyecto_santi/config.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/services/notification_service.dart';
import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/models/departamento.dart';
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
  Future<bool> login(String email, String password) async {
    try {
      await _clearSession();
      final loginResult = await _authService.login(email, password);
      if (loginResult != null && loginResult['token'] != null) {
        _jwtToken = loginResult['token'];
        final usuario = loginResult['usuario'];
        final tokenExpiry = DateTime.now().add(Duration(hours: 24));
        final userRol = usuario?['rol']?.toString() ?? 'Usuario';
        final userNombre = usuario?['nombreUsuario']?.toString() ?? 'Usuario';
        final profesorUuid = usuario?['profesorUuid']?.toString();
        await SecureStorageConfig.storeUserCredentials(
          email,
          usuario?['id']?.toString() ?? '',
          jwtToken: _jwtToken,
          tokenExpiry: tokenExpiry,
          rol: userRol,
          nombre: userNombre,
          profesorUuid: profesorUuid, 
        );
        print('[Auth] Usuario ID: ${usuario?['id']}');
        print('[Auth] Profesor UUID: $profesorUuid');
        print('[Auth] Rol: $userRol');
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
        final userId = usuario?['id']?.toString();
        if (userId != null) {
          await NotificationService().sendTokenToBackend(userId);
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
  Future<void> logout() async {
    await NotificationService().unsubscribeFromTopic('all_users');
    await NotificationService().unsubscribeFromTopic('profesores');
    await _clearSession();
    notifyListeners();
  }
  Future<void> _clearSession() async {
    _isAuthenticated = false;
    _currentUser = null;
    _jwtToken = null;
    _authService.logout();
    await SecureStorageConfig.clearUserCredentials();
  }
  Future<void> checkAuthStatus() async {
    try {
      final credentials = await SecureStorageConfig.getUserCredentials();
      final email = credentials['email'];
      final userId = credentials['uuid'];
      final profesorUuid = credentials['profesorUuid']; 
      final savedToken = credentials['jwtToken'];
      if (savedToken != null && savedToken.isNotEmpty) {
        final isExpired = await SecureStorageConfig.isTokenExpired();
        if (!isExpired) {
          print('[Auth] 🔄 Restaurando sesión desde token guardado...');
          print('[Auth] 🔑 Profesor UUID restaurado: $profesorUuid');
          _jwtToken = savedToken;
          _apiService.setToken(savedToken);
          try {
            final profesores = await _profesorService.fetchProfesores();
            final profesor = profesores.firstWhere(
              (p) => p.correo == email && p.activo == 1,
              orElse: () => throw Exception('Profesor no encontrado'),
            );
            _currentUser = profesor;
            _isAuthenticated = true;
            final notificationId = profesorUuid ?? userId ?? '';
            await NotificationService().sendTokenToBackend(notificationId);
            await NotificationService().subscribeToTopic('all_users');
            if (profesor.rol == 'Profesor' || profesor.rol == 'Coordinador') {
              await NotificationService().subscribeToTopic('profesores');
            }
            print('[Auth] ✅ Sesión restaurada exitosamente para: ${profesor.nombre}');
          } catch (e) {
            print('[Auth] ⚠️ Error obteniendo datos de usuario, usando datos guardados: $e');
            final savedRol = credentials['rol'] ?? 'Usuario';
            final savedNombre = credentials['nombre'] ?? email ?? 'Usuario';
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
            _currentUser = Profesor(
              uuid: finalProfesorUuid ?? userId ?? '', 
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
          print('[Auth] ⏰ Token expirado. Se requiere login nuevamente.');
          await logout();
        }
      } else if (email != null && email.isNotEmpty) {
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
  Future<bool> refreshToken() async {
    print('[Auth] Token expirado. Se requiere login nuevamente.');
    return false;
  }
}