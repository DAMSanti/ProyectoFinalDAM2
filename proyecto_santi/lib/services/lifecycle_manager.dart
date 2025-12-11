import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/auth.dart';
class LifecycleManager with WidgetsBindingObserver {
  final Auth _auth;
  DateTime? _pausedTime;
  static const Duration _maxBackgroundTime = Duration(hours: 12);
  LifecycleManager(this._auth) {
    WidgetsBinding.instance.addObserver(this);
    print('[LifecycleManager] 🎬 Iniciado');
  }
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print('[LifecycleManager] 🛑 Detenido');
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.inactive:
        print('[LifecycleManager] ⏸️  App inactiva (transición)');
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
        print('[LifecycleManager] 🔌 App desconectada (cerrándose)');
        break;
      case AppLifecycleState.hidden:
        print('[LifecycleManager] 👻 App oculta');
        break;
    }
  }
  void _onAppResumed() async {
    print('[LifecycleManager] ▶️  App resumida (primer plano)');
    if (_pausedTime != null) {
      final timeInBackground = DateTime.now().difference(_pausedTime!);
      print('[LifecycleManager] ⏱️  Tiempo en segundo plano: ${timeInBackground.inMinutes} minutos');
      if (timeInBackground > _maxBackgroundTime) {
        print('[LifecycleManager] ⚠️  Tiempo excedido, revalidando sesión...');
        await _auth.checkAuthStatus();
      } else {
        print('[LifecycleManager] ✅ Sesión sigue válida');
        if (_auth.isAuthenticated) {
          await _auth.updateCurrentUser();
        }
      }
      _pausedTime = null;
    }
  }
  void _onAppPaused() {
    _pausedTime = DateTime.now();
    print('[LifecycleManager] ⏸️  App pausada (segundo plano) - ${_pausedTime}');
  }
  bool shouldRevalidateSession() {
    if (_pausedTime == null) return false;
    final timeInBackground = DateTime.now().difference(_pausedTime!);
    return timeInBackground > _maxBackgroundTime;
  }
}