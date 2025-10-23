# 🌐 Solución: Error de Conexión en Flutter Web

## ❌ El Problema

Cuando ejecutas Flutter en **Chrome (Web)**, obtienes este error:
```
[API Error] The connection errored: The XMLHttpRequest onError callback was called.
```

**¿Por qué pasa esto?**
- En aplicaciones **web**, `localhost` se refiere al **navegador** (cliente)
- La API está en tu **máquina** (servidor)
- El navegador no puede conectarse a `localhost:5000` porque ese puerto está en el servidor, no en el navegador

## ✅ La Solución

### 1️⃣ Cambios Aplicados en Flutter

**Archivo: `lib/config.dart`**

```dart
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  // Detecta automáticamente si es Web o Desktop/Mobile
  static String get apiBaseUrl {
    if (kIsWeb) {
      // Web: usa IP local
      return 'http://192.168.9.190:5000/api';
    } else {
      // Desktop/Mobile: usa localhost
      return 'http://localhost:5000/api';
    }
  }
  
  static String get imagenesBaseUrl {
    if (kIsWeb) {
      return 'http://192.168.9.190:5000/uploads';
    } else {
      return 'http://localhost:5000/uploads';
    }
  }
}
```

### 2️⃣ Cambios Aplicados en ACEXAPI (C#)

#### **a) `Program.cs` - CORS Flexible**

```csharp
// CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterApp", policy =>
    {
        if (builder.Environment.IsDevelopment())
        {
            // En desarrollo, permitir cualquier origen
            policy.AllowAnyOrigin()
                  .AllowAnyMethod()
                  .AllowAnyHeader();
        }
        else
        {
            // En producción, usar orígenes específicos
            policy.WithOrigins(allowedOrigins)
                  .AllowAnyMethod()
                  .AllowAnyHeader()
                  .AllowCredentials();
        }
    });
});
```

#### **b) `Properties/launchSettings.json` - Escuchar en Todas las Interfaces**

```json
{
  "http": {
    "applicationUrl": "http://0.0.0.0:5000"
  }
}
```

**¿Qué significa `0.0.0.0`?**
- Hace que la API escuche en **todas las interfaces de red**
- Permite conexiones desde:
  - `localhost` (mismo equipo)
  - `192.168.9.190` (red local)
  - Cualquier otra IP de tu máquina

#### **c) `appsettings.json` - Orígenes CORS**

```json
{
  "Cors": {
    "AllowedOrigins": [
      "http://localhost:58080",
      "http://localhost:58081",
      // ... más puertos de Flutter Web
    ]
  }
}
```

---

## 🚀 Cómo Ejecutar Ahora

### Paso 1: Reiniciar la API

```powershell
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\ACEXAPI

# Detener la API si está corriendo (Ctrl+C)

# Iniciar con la nueva configuración
dotnet run --launch-profile http
```

**Deberías ver:**
```
Now listening on: http://0.0.0.0:5000
Application started. Press Ctrl+C to shut down.
```

### Paso 2: Reiniciar Flutter Web

```powershell
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\proyecto_santi

# Detener si está corriendo (Ctrl+C en el terminal de Flutter)

# Ejecutar nuevamente
flutter run -d chrome
```

---

## 🧪 Verificar que Funciona

### 1. Verificar que la API escucha en todas las interfaces

```powershell
# Debería funcionar desde localhost
curl http://localhost:5000/swagger

# Y también desde tu IP local
curl http://192.168.9.190:5000/swagger
```

### 2. Verificar CORS

```powershell
# Probar un endpoint con el header Origin
curl http://192.168.9.190:5000/api/Auth/login `
  -H "Origin: http://localhost:58080" `
  -H "Content-Type: application/json" `
  -d '{"email":"test@test.com","nombreCompleto":"Test"}'
```

### 3. Probar desde el navegador

1. Abre Chrome DevTools (F12)
2. Ve a la pestaña **Console**
3. Deberías ver:
   ```
   [API] Request: POST http://192.168.9.190:5000/api/Auth/login
   ```
4. **NO** deberías ver errores de CORS

---

## 🔍 Solución de Problemas

### ❌ Error: "Still can't connect"

**Verifica que tu firewall permita conexiones al puerto 5000:**

```powershell
# Agregar regla de firewall (como Administrador)
New-NetFirewallRule -DisplayName "ACEXAPI Dev" -Direction Inbound -Protocol TCP -LocalPort 5000 -Action Allow
```

### ❌ Error: "CORS policy: No 'Access-Control-Allow-Origin' header"

**Solución 1: Verifica que la API esté usando el perfil http**
```powershell
dotnet run --launch-profile http
```

**Solución 2: Verifica que Program.cs tenga `app.UseCors("AllowFlutterApp")`**

### ❌ La IP cambió

Si tu IP local cambia (ej: te conectas a otra red WiFi):

1. Obtén la nueva IP:
   ```powershell
   ipconfig | findstr IPv4
   ```

2. Actualiza `lib/config.dart`:
   ```dart
   return 'http://TU_NUEVA_IP:5000/api';
   ```

3. Reinicia Flutter:
   ```powershell
   flutter run -d chrome
   ```

---

## 📊 Comparación: localhost vs IP Local

| Aspecto | `localhost:5000` | `192.168.9.190:5000` |
|---------|------------------|---------------------|
| **Flutter Web** | ❌ No funciona | ✅ Funciona |
| **Flutter Desktop** | ✅ Funciona | ✅ Funciona |
| **Flutter Mobile** | ❌ No funciona* | ✅ Funciona |
| **Swagger** | ✅ Funciona | ✅ Funciona |

*Para mobile, necesitas estar en la misma red WiFi

---

## 🎯 Configuración Final

**En desarrollo:**
- ✅ API escucha en `0.0.0.0:5000`
- ✅ CORS permite cualquier origen
- ✅ Flutter Web usa `192.168.9.190:5000`
- ✅ Flutter Desktop usa `localhost:5000`

**Para producción (futuro):**
- 🔒 Cambiar a HTTPS
- 🔒 CORS con orígenes específicos
- 🔒 Variables de entorno para URLs
- 🔒 API desplegada en un servidor real

---

## 📝 Resumen de Archivos Modificados

1. ✅ `proyecto_santi/lib/config.dart` - Detección automática Web vs Desktop
2. ✅ `ACEXAPI/Program.cs` - CORS flexible para desarrollo
3. ✅ `ACEXAPI/Properties/launchSettings.json` - Escuchar en 0.0.0.0
4. ✅ `ACEXAPI/appsettings.json` - Orígenes CORS de Flutter

**¡Listo!** Ahora tu app Flutter Web puede conectarse a la API. 🎉
