import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Configuración de la aplicación
class AppConfig {
  // 🌐 SERVIDOR DE PRODUCCIÓN - Cambia esto a true para usar el servidor remoto
  static const bool useProductionServer = true;
  static const String productionUrl = 'http://64.226.85.100';
  static const String localUrl = 'http://localhost:5000';
  static const String localAndroidUrl = 'http://192.168.1.42:5000';
  
  // URL base de la API (ACEXAPI C# .NET)
  // IMPORTANTE: Para Android físico en local, usar la IP local de tu PC en la misma red WiFi
  static String get apiBaseUrl {
    // Si está en modo producción, usa el servidor remoto
    if (useProductionServer) {
      return '$productionUrl/api';
    }
    
    if (kIsWeb) {
      // Para web, usa localhost
      return '$localUrl/api';
    } else {
      // Para mobile (Android/iOS) y desktop
      try {
        if (Platform.isAndroid) {
          // Para Android dispositivo físico: IP de tu PC en la red WiFi
          return '$localAndroidUrl/api';
        } else if (Platform.isIOS) {
          return '$localUrl/api';
        }
      } catch (e) {
        // Fallback para desktop
      }
      // Para desktop (Windows/Mac/Linux)
      return '$localUrl/api';
    }
  }
  
  // URL de imágenes
  static String get imagenesBaseUrl {
    // Si está en modo producción, usa el servidor remoto
    if (useProductionServer) {
      return '$productionUrl/uploads';
    }
    
    if (kIsWeb) {
      return '$localUrl/uploads';
    } else {
      try {
        if (Platform.isAndroid) {
          // Para Android dispositivo físico: IP de tu PC en la red WiFi
          return '$localAndroidUrl/uploads';
        } else if (Platform.isIOS) {
          return '$localUrl/uploads';
        }
      } catch (e) {
        // Fallback
      }
      return '$localUrl/uploads';
    }
  }
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Endpoints de la API
  static const String actividadEndpoint = '/Actividad';
  static const String profesorEndpoint = '/Profesor';
  static const String departamentosEndpoint = '/Departamento';
  static const String fotoEndpoint = '/Foto';
  static const String authEndpoint = '/Auth';
  static const String catalogosEndpoint = '/Catalogos';
  static const String contratoEndpoint = '/Contrato';
}

/// Almacenamiento seguro para Firebase y credenciales
class SecureStorageConfig {
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Claves para storage
  static const String _keyApiKey = 'apiKey';
  static const String _keyAuthDomain = 'authDomain';
  static const String _keyProjectId = 'projectId';
  static const String _keyStorageBucket = 'storageBucket';
  static const String _keyMessagingSenderId = 'messagingSenderId';
  static const String _keyAppId = 'appId';
  static const String _keyMeasurementId = 'measurementId';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyUserUuid = 'userUuid';
  static const String _keyJwtToken = 'jwtToken'; // ✅ NUEVO: Guardar token JWT
  static const String _keyTokenExpiry = 'tokenExpiry'; // ✅ NUEVO: Timestamp de expiración
  static const String _keyUserRol = 'userRol'; // ✅ NUEVO: Guardar rol del usuario
  static const String _keyUserNombre = 'userNombre'; // ✅ NUEVO: Guardar nombre del usuario

  /// Guarda la configuraciÃ³n de Firebase
  static Future<void> storeFirebaseConfig() async {
    await _secureStorage.write(key: _keyApiKey, value: 'AIzaSyDif9U1CH2ssVLTK0yDeh2-_C8SOlhTr7E');
    await _secureStorage.write(key: _keyAuthDomain, value: 'acexchat.firebaseapp.com');
    await _secureStorage.write(key: _keyProjectId, value: 'acexchat');
    await _secureStorage.write(key: _keyStorageBucket, value: 'acexchat.firebasestorage.app');
    await _secureStorage.write(key: _keyMessagingSenderId, value: '312191800375');
    await _secureStorage.write(key: _keyAppId, value: '1:312191800375:web:763bafc4184da334099bb2');
    await _secureStorage.write(key: _keyMeasurementId, value: 'G-B2VED5543T');
  }

  /// Recupera la configuraciÃ³n de Firebase
  static Future<Map<String, String?>> retrieveFirebaseConfig() async {
    return {
      'apiKey': await _secureStorage.read(key: _keyApiKey),
      'authDomain': await _secureStorage.read(key: _keyAuthDomain),
      'projectId': await _secureStorage.read(key: _keyProjectId),
      'storageBucket': await _secureStorage.read(key: _keyStorageBucket),
      'messagingSenderId': await _secureStorage.read(key: _keyMessagingSenderId),
      'appId': await _secureStorage.read(key: _keyAppId),
      'measurementId': await _secureStorage.read(key: _keyMeasurementId),
    };
  }

  /// Guarda las credenciales del usuario
  static Future<void> storeUserCredentials(
    String email, 
    String uuid, 
    {
      String? jwtToken, 
      DateTime? tokenExpiry,
      String? rol,
      String? nombre,
      String? profesorUuid,
    }
  ) async {
    await _secureStorage.write(key: _keyUserEmail, value: email);
    await _secureStorage.write(key: _keyUserUuid, value: uuid);
    
    // ✅ NUEVO: Guardar token JWT y su expiración
    if (jwtToken != null) {
      await _secureStorage.write(key: _keyJwtToken, value: jwtToken);
    }
    if (tokenExpiry != null) {
      await _secureStorage.write(key: _keyTokenExpiry, value: tokenExpiry.toIso8601String());
    }
    // ✅ NUEVO: Guardar rol y nombre
    if (rol != null) {
      await _secureStorage.write(key: _keyUserRol, value: rol);
    }
    if (nombre != null) {
      await _secureStorage.write(key: _keyUserNombre, value: nombre);
    }
    // ✅ FIX HOT RESTART: Guardar profesorUuid
    if (profesorUuid != null) {
      await _secureStorage.write(key: 'profesorUuid', value: profesorUuid);
    }
  }

  /// Recupera las credenciales del usuario
  static Future<Map<String, String?>> getUserCredentials() async {
    return {
      'email': await _secureStorage.read(key: _keyUserEmail),
      'uuid': await _secureStorage.read(key: _keyUserUuid),
      'jwtToken': await _secureStorage.read(key: _keyJwtToken), // ✅ NUEVO
      'tokenExpiry': await _secureStorage.read(key: _keyTokenExpiry), // ✅ NUEVO
      'rol': await _secureStorage.read(key: _keyUserRol), // ✅ NUEVO
      'nombre': await _secureStorage.read(key: _keyUserNombre), // ✅ NUEVO
      'profesorUuid': await _secureStorage.read(key: 'profesorUuid'), // ✅ FIX HOT RESTART
    };
  }
  
  /// ✅ NUEVO: Verifica si el token guardado está expirado
  static Future<bool> isTokenExpired() async {
    final expiryStr = await _secureStorage.read(key: _keyTokenExpiry);
    if (expiryStr == null) return true;
    
    try {
      final expiry = DateTime.parse(expiryStr);
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      return true;
    }
  }

  /// Limpia las credenciales del usuario (logout)
  static Future<void> clearUserCredentials() async {
    await _secureStorage.delete(key: _keyUserEmail);
    await _secureStorage.delete(key: _keyUserUuid);
    await _secureStorage.delete(key: _keyJwtToken); // ✅ NUEVO
    await _secureStorage.delete(key: _keyTokenExpiry); // ✅ NUEVO
    await _secureStorage.delete(key: _keyUserRol); // ✅ NUEVO
    await _secureStorage.delete(key: _keyUserNombre); // ✅ NUEVO
  }

  /// Limpia toda la informaciÃ³n almacenada
  static Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
