import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Auth extends ChangeNotifier {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(String username, String password) async {
    // Simula la autenticación
    await _storage.write(key: 'username', value: 'ACEX Database');
    await _storage.write(key: 'correo', value: 'ACEX2025@hotmail.com');
    await _storage.write(key: 'rol', value: 'ED');
    _isAuthenticated = true;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    String? username = await _storage.read(key: 'username');
    _isAuthenticated = username != null;
    notifyListeners();
  }
}