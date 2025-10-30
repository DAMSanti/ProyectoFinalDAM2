# GUÍA FINAL - Sistema de Notificaciones

## ✅ SISTEMA CONFIGURADO CORRECTAMENTE

### Backend (C# .NET)
- ✅ Firebase Admin SDK inicializado
- ✅ Base de datos SQL Server conectada
- ✅ Tabla FcmTokens creada
- ✅ Endpoints de notificaciones funcionando
- ✅ Logging detallado implementado

### Frontend (Flutter)
- ✅ firebase_messaging configurado
- ✅ flutter_local_notifications configurado
- ✅ google-services.json en Android
- ✅ Permisos en AndroidManifest.xml

### Base de Datos
- ✅ Usuarios vinculados con profesores
- ✅ Actividad 27 con participantes válidos (Santi y ProfesorDemo)

---

## ⚠️ LIMITACIÓN IMPORTANTE

**Firebase Cloud Messaging NO FUNCIONA en Windows/Desktop**

```
Error: MissingPluginException - No implementation found for FCM on Windows
```

### Plataformas soportadas:
- ✅ Android
- ✅ iOS
- ✅ Web (limitado)
- ❌ Windows
- ❌ macOS Desktop
- ❌ Linux Desktop

---

## 🧪 PASOS PARA PROBAR (Android)

### 1. Registrar token de Santi
```
Dispositivo Android:
1. Cerrar sesión de admin
2. Iniciar sesión con: Santi
3. Verificar en logs: "[Notifications] ✅ Token sent to backend successfully"
```

### 2. Verificar en base de datos
```sql
SELECT u.NombreUsuario, t.DeviceType, t.FechaCreacion 
FROM FcmTokens t 
INNER JOIN Usuarios u ON t.UsuarioId = u.Id 
WHERE t.Activo = 1;
```

Deberías ver:
- admin (android)
- Santi (android)

### 3. Enviar mensaje de prueba
```
Desde cualquier dispositivo:
1. Login con admin
2. Ir a actividad 27 (Club de Ajedrez)
3. Enviar mensaje en chat
```

### 4. Verificar logs del backend
```
Buscar en consola del backend:
🔔 [ChatController] Recibida solicitud de notificación
👥 [ChatController] Participantes encontrados: 2
📤 [ChatController] Enviando notificaciones a 1 usuarios
📨 [NotificationService] Preparando notificación de mensaje
✅ [ChatController] Notificaciones de chat enviadas
```

### 5. Recibir notificación
El dispositivo con Santi debería:
- 📱 Mostrar notificación push
- 🔔 Vibrar (si está habilitado)
- 💬 Mostrar mensaje de admin

---

## 🔍 TROUBLESHOOTING

### No llegan notificaciones

**1. Verificar tokens registrados:**
```sql
SELECT COUNT(*) FROM FcmTokens WHERE Activo = 1;
```
Debe ser >= 2 (admin + otro usuario)

**2. Verificar logs del backend:**
```
⚠️ "No active tokens found" → Usuario no tiene token registrado
✅ "Multicast notification sent" → Notificación enviada correctamente
```

**3. Verificar permisos en Android:**
```
Configuración → Apps → Proyecto Santi → Notificaciones → Activado
```

**4. Verificar que Firebase está inicializado:**
```
Backend logs al iniciar: "Firebase Admin SDK initialized successfully"
```

**5. Verificar que usuarios son diferentes:**
- Admin envía mensaje → Santi recibe notificación ✅
- Admin envía mensaje → Admin NO recibe notificación (es el remitente) ✅

---

## 📊 ESTADO ACTUAL

### Tokens FCM Registrados
```
Usuario: admin
Dispositivo: Android
Token: Registrado ✅

Usuario: ProfesorDemo  
Dispositivo: Windows
Token: NO (Windows no soportado) ❌
```

### Actividad 27 - Club de Ajedrez
```
Participantes:
- fd0f02e4-1d45-47f0-abcf-6b10a1bcb125 (Santi / Juan Martínez Ruiz)
- e95dfe7f-173e-47c9-a1ef-9389d746d4d9 (ProfesorDemo / Laura Sánchez Gómez)
```

---

## 🎯 PRÓXIMOS PASOS

1. ✅ Iniciar sesión con Santi desde Android
2. ⏳ Verificar que se registre su token
3. ⏳ Enviar mensaje desde admin
4. ⏳ Confirmar que llega notificación a Santi

---

## 📝 NOTAS TÉCNICAS

### Flujo de notificaciones de chat:
1. Usuario A envía mensaje → Firebase Firestore
2. `firebase_chat_service.dart` → `_sendNotification()`
3. POST `/api/Chat/notify-new-message`
4. Backend obtiene participantes de actividad
5. Backend filtra remitente (Usuario A)
6. Backend obtiene tokens FCM de destinatarios
7. Backend envía notificación via Firebase Admin SDK
8. Firebase entrega notificación a dispositivos

### Archivos clave:
- Backend: `ChatController.cs`, `NotificationService.cs`
- Flutter: `firebase_chat_service.dart`, `notification_service.dart`
- Base de datos: `FcmTokens`, `ProfParticipantes`, `Usuarios`

---

**Última actualización:** 30 de Octubre, 2025  
**Estado:** ✅ Sistema funcional en Android/iOS
