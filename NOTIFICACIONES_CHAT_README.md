# 🔔 Sistema de Notificaciones de Chat - Configuración Completada

## ✅ Cambios Realizados

### **Backend (C#)**
1. ✅ Creado `ChatController.cs` con endpoint `/api/Chat/notify-new-message`
2. ✅ Tabla `FcmTokens` creada en la base de datos
3. ✅ `NotificationService` ya registrado en `Program.cs`

### **Frontend (Flutter)**
4. ✅ Actualizado `firebase_chat_service.dart` para enviar notificaciones
5. ✅ Agregado método `_sendNotification()` que llama al backend
6. ✅ Integrado en `sendTextMessage()` y `sendMediaMessage()`

## 🧪 Cómo Probar las Notificaciones

### **Paso 1: Iniciar el Backend**
```bash
cd ACEXAPI
dotnet run
```

### **Paso 2: Descargar Credenciales de Firebase**

⚠️ **IMPORTANTE**: Para que las notificaciones funcionen, necesitas:

1. Ir a [Firebase Console](https://console.firebase.google.com)
2. Seleccionar proyecto **acexchat**
3. **Configuración del proyecto** (⚙️) > **Cuentas de servicio**
4. Click **"Generar nueva clave privada"**
5. Guardar el archivo JSON descargado como:
   ```
   ACEXAPI/firebase-credentials.json
   ```
6. **Añadir a `.gitignore`**:
   ```gitignore
   firebase-credentials.json
   ```

### **Paso 3: Instalar FirebaseAdmin NuGet**
```bash
cd ACEXAPI
dotnet add package FirebaseAdmin
```

### **Paso 4: Reiniciar el Backend**
```bash
dotnet run
```

Verifica en los logs que veas:
```
Firebase Admin SDK initialized successfully
```

### **Paso 5: Probar desde la App Flutter**

1. **Compilar y ejecutar la app:**
   ```bash
   cd proyecto_santi
   flutter run
   ```

2. **Iniciar sesión** con dos usuarios diferentes en dos dispositivos/emuladores

3. **Enviar un mensaje** desde el Usuario 1

4. **Verificar** que el Usuario 2 recibe la notificación

## 🔍 Verificar que Funciona

### **1. Verificar Token FCM Registrado**
```sql
SELECT * FROM FcmTokens WHERE Activo = 1;
```

Si no hay tokens, el usuario debe:
- Cerrar sesión
- Volver a iniciar sesión
- El token se registra automáticamente en el login

### **2. Ver Logs del Backend**
```
[Notifications] FCM token registered for user {uuid}
[ChatController] Notificaciones de chat enviadas para actividad {id} desde {senderId} a {count} usuarios
```

### **3. Ver Logs de Flutter**
```
[ChatService] Notification sent successfully
[Notifications] Foreground message received: Mensaje de {nombre}
```

### **4. Probar Manualmente el Endpoint**

Con Postman o curl:

```http
POST http://localhost:5000/api/Chat/notify-new-message
Authorization: Bearer {tu_jwt_token}
Content-Type: application/json

{
  "actividadId": 1,
  "senderName": "Juan Pérez",
  "messagePreview": "Hola, esto es una prueba"
}
```

## 📱 Estados de la App y Notificaciones

| Estado App | Comportamiento |
|------------|---------------|
| **Abierta (foreground)** | ✅ Notificación local aparece arriba |
| **Background** | ✅ Notificación en barra de sistema |
| **Cerrada** | ✅ Notificación en barra de sistema |
| **Toca notificación** | 🔄 Abre la app (navegar al chat pendiente) |

## 🐛 Troubleshooting

### **Error: "No JWT token available"**
**Causa**: El usuario no está autenticado o el token expiró.
**Solución**: 
- Cerrar sesión y volver a iniciar
- Verificar que `Auth` guarda el token correctamente

### **Error: "Firebase not initialized"**
**Causa**: No existe `firebase-credentials.json` o está mal ubicado.
**Solución**:
1. Descargar credenciales de Firebase Console
2. Colocar en `ACEXAPI/firebase-credentials.json`
3. Reiniciar backend

### **Error: "No active tokens found"**
**Causa**: El usuario receptor no tiene token FCM registrado.
**Solución**:
1. El usuario receptor debe hacer login desde un dispositivo móvil
2. Verificar en la tabla `FcmTokens` que existe su registro
3. Si no existe, hay un problema en el registro del token

### **Notificaciones no llegan**
**Causas posibles**:
1. ❌ Firebase credentials no configuradas
2. ❌ Usuario no tiene token registrado
3. ❌ App en modo web (FCM limitado en web)
4. ❌ Permisos de notificaciones denegados

**Verificar**:
```sql
-- Ver si el usuario tiene tokens
SELECT * FROM FcmTokens WHERE UsuarioId = '{uuid_usuario}' AND Activo = 1;

-- Ver logs en backend
-- Buscar "[Notifications]" en la consola
```

### **Error: "No se pudo convertir actividadId a int"**
**Causa**: El `activityId` en el chat no es numérico.
**Solución**: Verifica que cuando abres el chat pasas el ID numérico de la actividad, no un string.

## 📋 Checklist Final

- [ ] ✅ Tabla `FcmTokens` creada
- [ ] ✅ `firebase-credentials.json` descargado y colocado
- [ ] ✅ `FirebaseAdmin` NuGet instalado
- [ ] ✅ Backend corriendo y muestra "Firebase Admin SDK initialized"
- [ ] ✅ Usuario inicia sesión en app móvil
- [ ] ✅ Token FCM registrado (verificar en DB)
- [ ] ✅ Enviar mensaje de prueba
- [ ] ✅ Notificación recibida ✨

## 🚀 Siguiente Paso: Agregar Navegación

Cuando el usuario toca la notificación, debe abrir el chat de esa actividad.

**Pendiente implementar**:
```dart
// En notification_service.dart -> _handleNuevoMensaje()
void _handleNuevoMensaje(Map<String, dynamic> data) {
  final chatId = data['chatId'];
  // TODO: Navegar al chat usando NavigatorKey
  // navigatorKey.currentState?.pushNamed('/chat', arguments: chatId);
}
```

## 📊 Monitoreo

### **Tokens Activos por Usuario**
```sql
SELECT 
    u.NombreUsuario,
    COUNT(t.Id) as TotalDispositivos,
    MAX(t.FechaCreacion) as UltimoRegistro
FROM Usuarios u
LEFT JOIN FcmTokens t ON u.Id = t.UsuarioId AND t.Activo = 1
GROUP BY u.Id, u.NombreUsuario
ORDER BY TotalDispositivos DESC;
```

### **Actividad de Notificaciones**
```sql
SELECT 
    DeviceType,
    COUNT(*) as Total,
    MAX(FechaCreacion) as UltimaRegistrada
FROM FcmTokens
WHERE Activo = 1
GROUP BY DeviceType;
```

---

**Actualizado**: 30 de Octubre, 2025  
**Estado**: ✅ Listo para probar (falta configurar Firebase credentials)
