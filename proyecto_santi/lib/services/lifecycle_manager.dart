import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/auth.dart';

/// 🔄 Gestor del ciclo de vida de la aplicación
/// Maneja el comportamiento cuando la app está en segundo plano o primer plano
/// Optimiza el consumo de recursos mientras mantiene la sesión activa
class LifecycleManager with WidgetsBindingObserver {
  final Auth _auth;
  DateTime? _pausedTime;
  
  // Configuración de tiempo máximo en segundo plano antes de revalidar sesión
  static const Duration _maxBackgroundTime = Duration(hours: 12);
  
  LifecycleManager(this._auth) {
    WidgetsBinding.instance.addObserver(this);
    print('[LifecycleManager] 🎬 Iniciado');
  }

  /// Libera los recursos del observer
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

  /// Se ejecuta cuando la app vuelve al primer plano
  void _onAppResumed() async {
    print('[LifecycleManager] ▶️  App resumida (primer plano)');
    
    // Si la app estuvo en segundo plano más del tiempo configurado, revalidar sesión
    if (_pausedTime != null) {
      final timeInBackground = DateTime.now().difference(_pausedTime!);
      print('[LifecycleManager] ⏱️  Tiempo en segundo plano: ${timeInBackground.inMinutes} minutos');
      
      if (timeInBackground > _maxBackgroundTime) {
        print('[LifecycleManager] ⚠️  Tiempo excedido, revalidando sesión...');
        await _auth.checkAuthStatus();
      } else {
        print('[LifecycleManager] ✅ Sesión sigue válida');
        
        // Opcional: Actualizar datos del usuario
        if (_auth.isAuthenticated) {
          await _auth.updateCurrentUser();
        }
      }
      
      _pausedTime = null;
    }
  }

  /// Se ejecuta cuando la app pasa a segundo plano
  void _onAppPaused() {
    _pausedTime = DateTime.now();
    print('[LifecycleManager] ⏸️  App pausada (segundo plano) - ${_pausedTime}');
    
    // Aquí puedes agregar lógica adicional como:
    // - Pausar timers
    // - Guardar estado temporal
    // - Reducir frecuencia de sincronización
  }

  /// Verifica si la sesión debe revalidarse basándose en el tiempo transcurrido
  bool shouldRevalidateSession() {
    if (_pausedTime == null) return false;
    
    final timeInBackground = DateTime.now().difference(_pausedTime!);
    return timeInBackground > _maxBackgroundTime;
  }
}
