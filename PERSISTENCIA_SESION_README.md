# 🔐 Persistencia de Sesión - Sistema de Autenticación

## 📋 Resumen

Sistema implementado para mantener la sesión del usuario activa incluso cuando la app está en segundo plano, optimizando el consumo de recursos y mejorando la experiencia del usuario (similar a WhatsApp, Instagram, etc.).

---

## ✅ ¿Qué se Implementó?

### 1. **Almacenamiento Seguro del Token JWT**
- ✅ Token JWT guardado en `flutter_secure_storage`
- ✅ Fecha de expiración del token almacenada
- ✅ Verificación automática de expiración

**Archivos modificados:**
- `lib/config.dart` - Agregadas funciones para guardar/recuperar token JWT
- `lib/models/auth.dart` - Guardar token al hacer login

### 2. **Restauración Automática de Sesión**
- ✅ Al abrir la app, verifica si hay token válido guardado
- ✅ Si el token es válido, restaura la sesión automáticamente
- ✅ Si el token expiró, requiere login nuevamente

**Método clave:** `Auth.checkAuthStatus()`

### 3. **Lifecycle Manager**
- ✅ Detecta cuando la app pasa a segundo plano
- ✅ Detecta cuando la app vuelve al primer plano
- ✅ Revalida la sesión si pasó mucho tiempo en segundo plano

**Archivo nuevo:** `lib/services/lifecycle_manager.dart`

---

## 🔄 Flujo de Autenticación

```
┌─────────────────────────────────────────────────────────────┐
│                    INICIO DE LA APP                          │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
          ┌────────────────────┐
          │ checkAuthStatus()   │
          └────────┬───────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
        ▼                     ▼
   ┌─────────┐          ┌──────────┐
   │Token    │          │No Token  │
   │Guardado?│          │Guardado  │
   └────┬────┘          └────┬─────┘
        │                    │
        ▼                    ▼
   ┌─────────┐          ┌──────────┐
   │¿Expiró? │          │Mostrar   │
   └────┬────┘          │Login     │
        │               └──────────┘
   ┌────┴────┐
   │         │
   ▼         ▼
┌─────┐  ┌─────────┐
│NO   │  │SÍ       │
└──┬──┘  └────┬────┘
   │          │
   ▼          ▼
┌─────────┐ ┌────────┐
│Restaurar│ │Mostrar │
│Sesión   │ │Login   │
└─────────┘ └────────┘
```

---

## 🚀 Características Implementadas

### **Persistencia de Sesión**
✅ La sesión se mantiene entre reinicios de la app
✅ Token JWT guardado de forma segura
✅ Verificación automática de expiración

### **Optimización de Recursos en Segundo Plano**
✅ App detecta cuando está en segundo plano
✅ Reduce operaciones innecesarias
✅ Revalida sesión solo cuando es necesario

### **Seguridad**
✅ Token guardado en `flutter_secure_storage` (encriptado)
✅ NO se guarda la contraseña del usuario
✅ Token con tiempo de expiración (24 horas por defecto)
✅ Revalidación automática después de tiempo prolongado en background

---

## 📱 Comportamiento de la App

### **Al Abrir la App:**
1. Verifica si hay token guardado
2. Si token es válido → Restaura sesión automáticamente
3. Si token expiró → Requiere login

### **Al Pasar a Segundo Plano:**
1. Guarda el timestamp de cuándo se pausó
2. Reduce actividades en background
3. Notificaciones siguen funcionando

### **Al Volver al Primer Plano:**
1. Calcula tiempo que estuvo en background
2. Si fue < 12 horas → Sesión sigue activa
3. Si fue > 12 horas → Revalida sesión
4. Actualiza datos del usuario

---

## ⚙️ Configuración

### **Tiempo de Expiración del Token**

Por defecto: **24 horas**

Modificar en `lib/models/auth.dart`:
```dart
final tokenExpiry = DateTime.now().add(Duration(hours: 24)); // Cambiar aquí
```

### **Tiempo Máximo en Segundo Plano**

Por defecto: **12 horas**

Modificar en `lib/services/lifecycle_manager.dart`:
```dart
static const Duration _maxBackgroundTime = Duration(hours: 12); // Cambiar aquí
```

---

## 🔍 Logs y Debugging

La app imprime logs útiles para debug:

```
[Auth] 🔄 Restaurando sesión desde token guardado...
[Auth] ✅ Sesión restaurada exitosamente para: Juan Pérez
[LifecycleManager] ▶️  App resumida (primer plano)
[LifecycleManager] ⏱️  Tiempo en segundo plano: 5 minutos
[LifecycleManager] ✅ Sesión sigue válida
```

---

## 🆚 Comparación: Antes vs Después

| Característica | ❌ Antes | ✅ Ahora |
|---------------|---------|---------|
| Persistencia de sesión | NO | SÍ |
| Login automático | NO | SÍ |
| Token guardado | NO | SÍ (encriptado) |
| Detección de background | NO | SÍ |
| Revalidación inteligente | NO | SÍ |
| Optimización de recursos | NO | SÍ |
| Expiración de token | NO | SÍ (24h) |

---

## 🔧 Mantenimiento y Mejoras Futuras

### **Opcional: Refresh Token**

Para sesiones más largas sin requerir login:

1. Backend debe implementar endpoint `/refresh-token`
2. Guardar refresh token además del access token
3. Al expirar access token, usar refresh token para obtener uno nuevo

### **Opcional: Biometría**

Para mayor seguridad en dispositivos móviles:

```dart
// Agregar dependencia
dependencies:
  local_auth: ^2.1.0

// Implementar en login
import 'package:local_auth/local_auth.dart';

Future<bool> authenticateWithBiometrics() async {
  final LocalAuthentication auth = LocalAuthentication();
  try {
    return await auth.authenticate(
      localizedReason: 'Escanea tu huella para acceder',
      options: const AuthenticationOptions(
        biometricOnly: true,
      ),
    );
  } catch (e) {
    return false;
  }
}
```

---

## 📊 Consumo de Recursos

### **Memoria**
- Token JWT: ~500 bytes
- Lifecycle Observer: ~100 bytes
- **Total adicional: < 1 KB**

### **Batería**
- Lifecycle listener: Costo despreciable
- Sin timers activos en background
- Notificaciones push manejadas por Firebase (muy eficiente)

### **Red**
- Sin polling en background
- Solo sincronización al volver al primer plano
- Notificaciones push no consumen datos significativos

---

## 🐛 Troubleshooting

### **Problema: Sesión no se restaura**

**Solución:**
1. Verificar que el token se guardó: 
   ```dart
   final creds = await SecureStorageConfig.getUserCredentials();
   print('Token: ${creds['jwtToken']}');
   ```

2. Verificar expiración:
   ```dart
   final expired = await SecureStorageConfig.isTokenExpired();
   print('¿Expirado?: $expired');
   ```

### **Problema: App consume mucha batería**

**Causa:** Probablemente no es por la persistencia de sesión.

**Investigar:**
- Timers activos
- Polling innecesario
- Listeners de Firebase mal configurados

---

## 📚 Referencias

- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [JWT Token Management](https://jwt.io/introduction)
- [Flutter App Lifecycle](https://docs.flutter.dev/development/ui/advanced/gestures#lifecycle-of-a-flutter-application)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)

---

## ✨ Conclusión

La implementación de persistencia de sesión mejora significativamente la experiencia del usuario sin sacrificar seguridad ni consumir recursos excesivos. El sistema es similar al usado por apps populares como WhatsApp, Instagram y Gmail.

**Beneficios principales:**
- ✅ Usuario no tiene que hacer login cada vez
- ✅ Sesión segura con token encriptado
- ✅ Bajo consumo de recursos
- ✅ Fácil de mantener y extender
