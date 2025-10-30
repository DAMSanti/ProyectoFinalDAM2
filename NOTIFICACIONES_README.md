# 🔔 Sistema de Notificaciones Push - ACEX

## 📋 Resumen

Se ha implementado un sistema completo de notificaciones push usando **Firebase Cloud Messaging (FCM)** para notificar a los usuarios cuando:
- ✅ Son añadidos a una actividad
- ✅ Reciben un mensaje de chat
- ✅ Se crea o actualiza una actividad en la que participan

## 🏗️ Arquitectura

### **Frontend (Flutter)**
- `notification_service.dart`: Maneja FCM en el cliente
- Integrado con `Auth` para enviar token al backend
- Listeners configurados para foreground, background y terminated

### **Backend (C# .NET)**
- `NotificationController.cs`: Endpoints para registrar tokens
- `NotificationService.cs`: Lógica para enviar notificaciones
- `FcmToken` model: Almacena tokens de dispositivos
- Firebase Admin SDK: Envía las notificaciones

## 📦 Requisitos

### **Flutter (Ya instalado)**
```yaml
firebase_core: ^3.11.0
firebase_messaging: ^15.1.8
flutter_local_notifications: ^18.0.1 # NUEVO - Ejecutar flutter pub get
```

### **C# Backend (Instalar)**
```bash
cd ACEXAPI
dotnet add package FirebaseAdmin
```

## 🔧 Configuración

### **1. Configurar Firebase Admin SDK en Backend**

#### a) Obtener credenciales de Firebase:
1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto: **acexchat**
3. Ve a **Configuración del proyecto** (⚙️) > **Cuentas de servicio**
4. Click en **Generar nueva clave privada**
5. Se descargará un archivo JSON

#### b) Colocar el archivo de credenciales:
```
ACEXAPI/
  ├── firebase-credentials.json  <-- Aquí
  ├── Program.cs
  └── ...
```

⚠️ **IMPORTANTE**: Añade este archivo a `.gitignore`:
```gitignore
firebase-credentials.json
```

### **2. Registrar el servicio en Program.cs**

Agrega esto en `ACEXAPI/Program.cs`:

```csharp
// Registrar el servicio de notificaciones
builder.Services.AddScoped<INotificationService, NotificationService>();
```

### **3. Crear migración para tabla FcmTokens**

```bash
cd ACEXAPI
dotnet ef migrations add AddFcmTokensTable
dotnet ef database update
```

O ejecutar manualmente este SQL:

```sql
USE ACEXAPI;
GO

CREATE TABLE FcmTokens (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId NVARCHAR(450) NOT NULL,
    Token NVARCHAR(500) NOT NULL,
    DeviceType NVARCHAR(50) NULL,
    DeviceId NVARCHAR(200) NULL,
    FechaCreacion DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UltimaActualizacion DATETIME2 NULL,
    Activo BIT NOT NULL DEFAULT 1,
    
    CONSTRAINT FK_FcmTokens_Usuarios FOREIGN KEY (UsuarioId) 
        REFERENCES Usuarios(Id) ON DELETE CASCADE
);

CREATE INDEX IX_FcmTokens_UsuarioId ON FcmTokens(UsuarioId);
CREATE INDEX IX_FcmTokens_Token ON FcmTokens(Token);
GO
```

### **4. Instalar dependencia Flutter**

```bash
cd proyecto_santi
flutter pub get
```

### **5. Configurar permisos Android**

Ya está configurado en tu `AndroidManifest.xml`, pero verifica que tenga:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### **6. Configurar permisos iOS**

En `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

## 🚀 Uso

### **Enviar notificaciones desde el backend**

#### **Cuando se añade un profesor a una actividad:**

```csharp
// En ActividadController o donde manejes la lógica
await _notificationService.NotifyProfesorAnadidoAsync(
    profesorUuid: "uuid-del-profesor",
    actividadId: 123,
    actividadNombre: "Excursión al museo"
);
```

#### **Cuando se crea una nueva actividad:**

```csharp
var dto = new ActividadNotificationDto
{
    ActividadId = actividad.Id,
    ActividadNombre = actividad.Nombre,
    FechaInicio = actividad.FechaInicio,
    ProfesoresUuids = listaDeProfesoresUuids
};

await _notificationService.NotifyNuevaActividadAsync(dto);
```

#### **Cuando hay un nuevo mensaje de chat:**

```csharp
var dto = new MensajeNotificationDto
{
    ChatId = "chat-id",
    SenderName = "Juan Pérez",
    MessagePreview = "Hola, ¿cómo estás?",
    RecipientUuid = "uuid-del-destinatario"
};

await _notificationService.NotifyNuevoMensajeAsync(dto);
```

### **Integración en controladores existentes**

#### **En ActividadController.cs - al crear actividad:**

```csharp
[HttpPost]
public async Task<ActionResult<ActividadDto>> Create(
    [FromForm] ActividadCreateDto dto, 
    IFormFile? folleto)
{
    var actividad = await _actividadService.CreateAsync(dto, folleto);
    
    // Obtener profesores participantes
    var profesoresIds = await _actividadService.GetProfesoresParticipantesAsync(actividad.Id);
    
    // Enviar notificación
    if (profesoresIds.Any())
    {
        await _notificationService.NotifyNuevaActividadAsync(new ActividadNotificationDto
        {
            ActividadId = actividad.Id,
            ActividadNombre = actividad.Nombre,
            FechaInicio = actividad.FechaInicio,
            ProfesoresUuids = profesoresIds
        });
    }
    
    return CreatedAtAction(nameof(GetById), new { id = actividad.Id }, actividad);
}
```

#### **Para notificaciones de chat:**

En tu servicio de chat (probablemente en Firebase), cuando se envíe un mensaje:

```csharp
// Después de guardar el mensaje en Firebase
await _notificationService.NotifyNuevoMensajeAsync(new MensajeNotificationDto
{
    ChatId = chatId,
    SenderName = senderName,
    MessagePreview = mensaje.Substring(0, Math.Min(50, mensaje.Length)),
    RecipientUuid = recipientId
});
```

## 🧪 Probar las notificaciones

### **1. Probar desde la app Flutter:**

Inicia sesión y el token FCM se registrará automáticamente.

### **2. Probar desde Postman:**

```http
POST {{baseUrl}}/api/Notification/test
Authorization: Bearer {{jwt_token}}
```

Esto enviará una notificación de prueba al usuario autenticado.

### **3. Probar notificación manual (Admin):**

```http
POST {{baseUrl}}/api/Notification/send?usuarioId=CA1989B6-551F-4964-92F7-00B4ED7D81DC
Authorization: Bearer {{admin_jwt_token}}
Content-Type: application/json

{
  "title": "Prueba Manual",
  "body": "Esta es una prueba de notificación",
  "type": "test",
  "data": {
    "key": "value"
  }
}
```

## 📱 Comportamiento de la App

### **¿La app se queda abierta en segundo plano?**

**Sí**, pero depende del sistema operativo:

#### **Android:**
- ✅ App en **foreground**: Notificación se muestra con `flutter_local_notifications`
- ✅ App en **background**: Firebase maneja la notificación, aparece en la barra
- ✅ App **cerrada/terminated**: Firebase la recibe, aparece en la barra
- 🔄 Si el sistema mata el proceso: Se pierde la sesión, debe hacer login

#### **iOS:**
- ✅ Comportamiento similar a Android
- ⚠️ iOS es más agresivo matando apps en background
- 🔄 Necesita login más frecuentemente

#### **Windows/Desktop:**
- ✅ App queda en memoria mientras esté abierta
- ⚠️ No soporta notificaciones push nativas (solo web/mobile)

### **¿La sesión persiste?**

**Actualmente NO** entre reinicios de app porque:
- Token JWT se guarda en memoria (`_jwtToken`)
- Email y UUID se guardan en `flutter_secure_storage`
- **NO se guarda la contraseña** por seguridad

**Para persistir la sesión:**
1. El token JWT tiene tiempo de expiración
2. Necesitarías implementar refresh tokens
3. O usar OAuth2 con tokens persistentes

## 🔒 Seguridad

### **Tokens FCM:**
- Se almacenan por usuario y dispositivo
- Se eliminan automáticamente si son inválidos
- Se borran al hacer logout

### **Autenticación:**
- Todos los endpoints requieren JWT válido
- Solo admins pueden enviar notificaciones personalizadas

## 🐛 Troubleshooting

### **"Firebase not initialized"**
- Verifica que `firebase-credentials.json` existe
- Revisa los logs del backend al iniciar

### **"No active tokens found"**
- El usuario no ha iniciado sesión desde la app móvil
- El token no se registró correctamente
- Revisa la tabla `FcmTokens` en la BD

### **Notificaciones no llegan en Android:**
```bash
# Verificar permisos
adb shell dumpsys package com.example.proyecto_santi | grep POST_NOTIFICATIONS

# Ver logs de Firebase
adb logcat | grep -i firebase
```

### **Error al enviar notificación:**
- Verifica que Firebase Admin SDK está configurado
- Revisa las credenciales de servicio
- Comprueba los logs: `[Notifications]` en backend

## 📊 Monitoreo

### **Ver tokens registrados:**

```sql
SELECT 
    u.NombreUsuario,
    t.DeviceType,
    t.FechaCreacion,
    t.UltimaActualizacion,
    t.Activo
FROM FcmTokens t
JOIN Usuarios u ON t.UsuarioId = u.Id
WHERE t.Activo = 1;
```

### **Ver estadísticas:**

```sql
SELECT 
    DeviceType,
    COUNT(*) as TotalTokens,
    COUNT(CASE WHEN Activo = 1 THEN 1 END) as TokensActivos
FROM FcmTokens
GROUP BY DeviceType;
```

## 🔄 Próximos pasos

1. ✅ Sistema base implementado
2. 🔲 Implementar refresh token para persistir sesión
3. 🔲 Agregar navegación al tocar notificación
4. 🔲 Implementar contador de mensajes no leídos
5. 🔲 Agregar preferencias de notificaciones por usuario
6. 🔲 Programar notificaciones (ej: recordatorios de actividades)

## 📝 Notas adicionales

- Las notificaciones funcionan mejor en **Android e iOS**
- En **web** las notificaciones son limitadas
- En **desktop** (Windows/Mac/Linux) no hay soporte nativo de FCM
- Para chat en tiempo real, ya tienes Firebase Realtime Database/Firestore
- Las notificaciones son **complementarias** al chat en tiempo real

---

**Creado:** 30 de Octubre, 2025  
**Versión:** 1.0  
**Autor:** GitHub Copilot
