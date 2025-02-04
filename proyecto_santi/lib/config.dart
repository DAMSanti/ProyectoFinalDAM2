import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageConfig {
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> storeFirebaseConfig() async {
    await _secureStorage.write(key: 'apiKey', value: 'AIzaSyDif9U1CH2ssVLTK0yDeh2-_C8SOlhTr7E');
    await _secureStorage.write(key: 'authDomain', value: 'acexchat.firebaseapp.com');
    await _secureStorage.write(key: 'projectId', value: 'acexchat');
    await _secureStorage.write(key: 'storageBucket', value: 'acexchat.firebasestorage.app');
    await _secureStorage.write(key: 'messagingSenderId', value: '312191800375');
    await _secureStorage.write(key: 'appId', value: '1:312191800375:web:763bafc4184da334099bb2');
    await _secureStorage.write(key: 'measurementId', value: 'G-B2VED5543T');
  }

  static Future<Map<String, String?>> retrieveFirebaseConfig() async {
    final apiKey = await _secureStorage.read(key: 'apiKey');
    final authDomain = await _secureStorage.read(key: 'authDomain');
    final projectId = await _secureStorage.read(key: 'projectId');
    final storageBucket = await _secureStorage.read(key: 'storageBucket');
    final messagingSenderId = await _secureStorage.read(key: 'messagingSenderId');
    final appId = await _secureStorage.read(key: 'appId');
    final measurementId = await _secureStorage.read(key: 'measurementId');

    return {
      'apiKey': apiKey,
      'authDomain': authDomain,
      'projectId': projectId,
      'storageBucket': storageBucket,
      'messagingSenderId': messagingSenderId,
      'appId': appId,
      'measurementId': measurementId,
    };
  }
}

bool shouldShowAppBar() {
  return !(kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS);
}