import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// ConfiguraciÃ³n de la aplicaciÃ³n
class AppConfig {
  // URL base de la API (ACEXAPI C# .NET)
  // En web usamos la IP local porque localhost no funciona en el navegador
  static String get apiBaseUrl {
    if (kIsWeb) {
      // Para web, usa localhost en desarrollo
      return 'http://localhost:5000/api';
    } else {
      // Para desktop/mobile, localhost funciona bien
      return 'http://localhost:5000/api';
    }
  }
  
  // URL de imágenes
  static String get imagenesBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/uploads';
    } else {
      return 'http://localhost:5000/uploads';
    }
  }
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Endpoints de la API
  static const String actividadEndpoint = '/Actividad';
  static const String profesorEndpoint = '/Profesor';
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
  static Future<void> storeUserCredentials(String email, String uuid) async {
    await _secureStorage.write(key: _keyUserEmail, value: email);
    await _secureStorage.write(key: _keyUserUuid, value: uuid);
  }

  /// Recupera las credenciales del usuario
  static Future<Map<String, String?>> getUserCredentials() async {
    return {
      'email': await _secureStorage.read(key: _keyUserEmail),
      'uuid': await _secureStorage.read(key: _keyUserUuid),
    };
  }

  /// Limpia las credenciales del usuario (logout)
  static Future<void> clearUserCredentials() async {
    await _secureStorage.delete(key: _keyUserEmail);
    await _secureStorage.delete(key: _keyUserUuid);
  }

  /// Limpia toda la informaciÃ³n almacenada
  static Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
