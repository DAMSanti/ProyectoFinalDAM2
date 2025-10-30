## 🔍 Diagnóstico del Sistema de Notificaciones

### **Error Encontrado y Solucionado:**

**Problema:** 
```
Unable to resolve service for type 'ACEXAPI.Services.INotificationService'
```

**Causa:**  
El servicio `INotificationService` estaba registrado **ANTES** del `DbContext`, pero `NotificationService` necesita `ApplicationDbContext` en su constructor.

**Solución:**  
Mover el registro del servicio **DESPUÉS** del DbContext en `Program.cs`:

```csharp
// ANTES (INCORRECTO)
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(dbConnectionString));

// DESPUÉS (CORRECTO)
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(dbConnectionString));
builder.Services.AddScoped<INotificationService, NotificationService>();
```

---

## ✅ Checklist de Verificación

### **1. Backend**
- [x] Tabla `FcmTokens` creada
- [x] `NotificationService` implementado
- [x] `INotificationService` registrado DESPUÉS del DbContext
- [x] `FirebaseAdmin` package instalado
- [x] Compilación exitosa
- [ ] **`firebase-credentials.json` configurado**
- [ ] Backend corriendo sin errores

### **2. Frontend**
- [x] `notification_service.dart` creado
- [x] `firebase_chat_service.dart` actualizado
- [x] `flutter_local_notifications` instalado
- [x] Integrado en Auth (login/logout)

### **3. Base de Datos**
- [x] Tabla `FcmTokens` existe
- [ ] Tokens FCM registrados (verificar después de login)

---

## 🧪 Pasos para Probar AHORA

### **Paso 1: Verificar Firebase Credentials**

¿El archivo existe?
```powershell
cd ACEXAPI
Test-Path firebase-credentials.json
```

Si dice `False`, descargar de:
1. https://console.firebase.google.com
2. Proyecto: **acexchat**
3. Configuración (⚙️) > Cuentas de servicio > Generar nueva clave privada

### **Paso 2: Iniciar Backend**

```powershell
cd ACEXAPI
dotnet run
```

**Buscar en logs:**
```
✅ "Firebase Admin SDK initialized successfully"
❌ "Firebase credentials file not found"
```

### **Paso 3: Iniciar App Flutter (Android)**

```powershell
cd proyecto_santi
flutter run
```

### **Paso 4: Hacer Login**

Al iniciar sesión, deberías ver en los logs del backend:
```
info: ACEXAPI.Services.NotificationService[0]
      FCM token registered for user {guid}
```

### **Paso 5: Verificar Token en BD**

```sql
SELECT * FROM FcmTokens WHERE Activo = 1;
```

Debería aparecer al menos 1 fila con el token del dispositivo.

### **Paso 6: Enviar Mensaje en Chat**

1. Abrir chat de una actividad
2. Enviar mensaje
3. Verificar logs del backend:
   ```
   [ChatController] Notificaciones de chat enviadas para actividad {id}
   ```

### **Paso 7: Verificar Notificación Recibida**

En otro dispositivo/sesión, deberías recibir la notificación.

---

## 🐛 Troubleshooting por Escenario

### **Escenario 1: "Firebase not initialized"**

**Logs:**
```
Firebase credentials file not found at: G:\...\ACEXAPI\firebase-credentials.json
```

**Solución:**
1. Descargar credenciales de Firebase Console
2. Guardar como `ACEXAPI/firebase-credentials.json`
3. Reiniciar backend

---

### **Escenario 2: "No active tokens found"**

**Logs:**
```
No active tokens found for user {guid}
```

**Causas:**
- Usuario no ha iniciado sesión desde móvil
- Token no se registró correctamente

**Verificar:**
```sql
-- ¿Hay tokens?
SELECT * FROM FcmTokens;

-- ¿El usuario tiene token?
SELECT * FROM FcmTokens WHERE UsuarioId = '{guid}';
```

**Solución:**
1. Cerrar sesión en la app
2. Volver a iniciar sesión
3. Verificar en logs backend: "FCM token registered"

---

### **Escenario 3: Token se registra pero no llegan notificaciones**

**Posibles causas:**

**A) Firebase credentials inválidas o expiradas**
```powershell
# Verificar contenido del archivo
cat ACEXAPI/firebase-credentials.json
```

Debe tener estructura:
```json
{
  "type": "service_account",
  "project_id": "acexchat",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...",
  "client_email": "...",
  ...
}
```

**B) Permisos de notificaciones denegados en Android**

Verificar:
```bash
adb shell dumpsys package com.example.proyecto_santi | grep POST_NOTIFICATIONS
```

Debe mostrar: `granted=true`

**C) App en Web (no soportado completamente)**

FCM tiene limitaciones en web. Probar en Android/iOS.

---

### **Escenario 4: "No JWT token available" en Flutter**

**Logs Flutter:**
```
[ChatService] No JWT token available, skipping notification
```

**Causa:** Usuario no autenticado o token expiró.

**Solución:** Reiniciar sesión.

---

### **Escenario 5: Error al enviar desde backend**

**Logs:**
```
Error sending notification to user {guid}
```

**Verificar:**
1. ¿Firebase está inicializado?
2. ¿El token FCM es válido?
3. ¿Hay conexión a internet?

---

## 📊 Queries Útiles

### **Ver todos los tokens activos**
```sql
SELECT 
    u.NombreUsuario,
    t.Token,
    t.DeviceType,
    t.FechaCreacion,
    t.Activo
FROM FcmTokens t
JOIN Usuarios u ON t.UsuarioId = u.Id
WHERE t.Activo = 1
ORDER BY t.FechaCreacion DESC;
```

### **Contar tokens por usuario**
```sql
SELECT 
    u.NombreUsuario,
    COUNT(t.Id) as TotalDispositivos
FROM Usuarios u
LEFT JOIN FcmTokens t ON u.Id = t.UsuarioId AND t.Activo = 1
GROUP BY u.Id, u.NombreUsuario
HAVING COUNT(t.Id) > 0;
```

### **Ver tokens por tipo de dispositivo**
```sql
SELECT 
    DeviceType,
    COUNT(*) as Total
FROM FcmTokens
WHERE Activo = 1
GROUP BY DeviceType;
```

---

## 🎯 Checklist Final Antes de Declarar "Funciona"

- [ ] Backend compila sin errores
- [ ] Backend inicia sin errores de servicio no registrado
- [ ] Firebase Admin SDK se inicializa correctamente
- [ ] Usuario puede hacer login desde app móvil
- [ ] Token FCM se registra en la BD
- [ ] Al enviar mensaje, backend recibe la petición
- [ ] Backend intenta enviar notificación
- [ ] Notificación llega al dispositivo receptor
- [ ] Notificación se muestra correctamente
- [ ] Al tocar la notificación, abre la app

---

## 🚀 Siguiente Acción

**AHORA MISMO:**
1. Reiniciar el backend con `dotnet run`
2. Verificar que no aparezca el error "Unable to resolve service"
3. Iniciar sesión en la app
4. Verificar que el token se registre
5. Enviar un mensaje de prueba

**Si todo lo anterior funciona y AÚN NO llegan notificaciones:**
- El problema está en Firebase (credentials o configuración)
- El problema está en el dispositivo (permisos)

---

**Actualizado:** 30 de Octubre, 2025  
**Estado:** ✅ Servicio registrado correctamente, listo para probar
