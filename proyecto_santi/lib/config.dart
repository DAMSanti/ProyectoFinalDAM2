import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'dart:io' show Platform;
class AppConfig {
  static const bool useProductionServer = true;
  static const String productionUrl = 'https:
  static const String productionUrlFallback = 'http:
  static const String localUrl = 'http:
  static const String localAndroidUrl = 'http:
  static String get apiBaseUrl {
    if (kIsWeb && kReleaseMode) {
      return '/api';
    }
    if (useProductionServer) {
      return '$productionUrl/api';
    }
    if (kIsWeb) {
      return '$localUrl/api';
    } else {
      try {
        if (Platform.isAndroid) {
          return '$localAndroidUrl/api';
        } else if (Platform.isIOS) {
          return '$localUrl/api';
        }
      } catch (e) {
      }
      return '$localUrl/api';
    }
  }
  static String get imagenesBaseUrl {
    if (kIsWeb && kReleaseMode) {
      return '/uploads';
    }
    if (useProductionServer) {
      return '$productionUrl/uploads';
    }
    if (kIsWeb) {
      return '$localUrl/uploads';
    } else {
      try {
        if (Platform.isAndroid) {
          return '$localAndroidUrl/uploads';
        } else if (Platform.isIOS) {
          return '$localUrl/uploads';
        }
      } catch (e) {
      }
      return '$localUrl/uploads';
    }
  }
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const String actividadEndpoint = '/Actividad';
  static const String profesorEndpoint = '/Profesor';
  static const String departamentosEndpoint = '/Departamento';
  static const String fotoEndpoint = '/Foto';
  static const String authEndpoint = '/Auth';
  static const String catalogosEndpoint = '/Catalogos';
  static const String contratoEndpoint = '/Contrato';
}
class SecureStorageConfig {
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _keyApiKey = 'apiKey';
  static const String _keyAuthDomain = 'authDomain';
  static const String _keyProjectId = 'projectId';
  static const String _keyStorageBucket = 'storageBucket';
  static const String _keyMessagingSenderId = 'messagingSenderId';
  static const String _keyAppId = 'appId';
  static const String _keyMeasurementId = 'measurementId';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyUserUuid = 'userUuid';
  static const String _keyJwtToken = 'jwtToken'; 
  static const String _keyTokenExpiry = 'tokenExpiry'; 
  static const String _keyUserRol = 'userRol'; 
  static const String _keyUserNombre = 'userNombre'; 
  static Future<void> storeFirebaseConfig() async {
    await _secureStorage.write(key: _keyApiKey, value: 'AIzaSyDif9U1CH2ssVLTK0yDeh2-_C8SOlhTr7E');
    await _secureStorage.write(key: _keyAuthDomain, value: 'acexchat.firebaseapp.com');
    await _secureStorage.write(key: _keyProjectId, value: 'acexchat');
    await _secureStorage.write(key: _keyStorageBucket, value: 'acexchat.firebasestorage.app');
    await _secureStorage.write(key: _keyMessagingSenderId, value: '312191800375');
    await _secureStorage.write(key: _keyAppId, value: '1:312191800375:web:763bafc4184da334099bb2');
    await _secureStorage.write(key: _keyMeasurementId, value: 'G-B2VED5543T');
  }
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
    if (jwtToken != null) {
      await _secureStorage.write(key: _keyJwtToken, value: jwtToken);
    }
    if (tokenExpiry != null) {
      await _secureStorage.write(key: _keyTokenExpiry, value: tokenExpiry.toIso8601String());
    }
    if (rol != null) {
      await _secureStorage.write(key: _keyUserRol, value: rol);
    }
    if (nombre != null) {
      await _secureStorage.write(key: _keyUserNombre, value: nombre);
    }
    if (profesorUuid != null) {
      await _secureStorage.write(key: 'profesorUuid', value: profesorUuid);
    }
  }
  static Future<Map<String, String?>> getUserCredentials() async {
    return {
      'email': await _secureStorage.read(key: _keyUserEmail),
      'uuid': await _secureStorage.read(key: _keyUserUuid),
      'jwtToken': await _secureStorage.read(key: _keyJwtToken), 
      'tokenExpiry': await _secureStorage.read(key: _keyTokenExpiry), 
      'rol': await _secureStorage.read(key: _keyUserRol), 
      'nombre': await _secureStorage.read(key: _keyUserNombre), 
      'profesorUuid': await _secureStorage.read(key: 'profesorUuid'), 
    };
  }
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
  static Future<void> clearUserCredentials() async {
    await _secureStorage.delete(key: _keyUserEmail);
    await _secureStorage.delete(key: _keyUserUuid);
    await _secureStorage.delete(key: _keyJwtToken); 
    await _secureStorage.delete(key: _keyTokenExpiry); 
    await _secureStorage.delete(key: _keyUserRol); 
    await _secureStorage.delete(key: _keyUserNombre); 
  }
  static Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}