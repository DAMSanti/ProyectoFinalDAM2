# 🚀 Guía Rápida - Configuración ACEXAPI + Flutter

## ✅ Cambios Aplicados

### 🔧 Configuración Corregida

**ANTES (Incorrecto):**
- ❌ API: `http://4.233.223.75:8080/api` (Spring Boot Java)
- ❌ Endpoints: `/actividad`, `/profesor`, `/foto`
- ❌ Sin autenticación JWT
- ❌ No compatible con la API real

**DESPUÉS (Correcto):**
- ✅ API: `http://localhost:5121/api` (ACEXAPI C# .NET)
- ✅ Endpoints: `/Actividad`, `/Profesor`, `/Foto`, `/Auth`
- ✅ Autenticación JWT implementada
- ✅ Compatible con ACEXAPI C#

---

## 📋 Pasos para Ejecutar

### 1️⃣ Iniciar la API (ACEXAPI)

```powershell
# Navegar a la carpeta de la API
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\ACEXAPI

# Verificar que SQL Server esté corriendo
# (debe estar en 127.0.0.1,1433)

# Ejecutar la API
dotnet run

# Deberías ver algo como:
# info: Microsoft.Hosting.Lifetime[14]
#       Now listening on: http://localhost:5121
# info: Microsoft.Hosting.Lifetime[0]
#       Application started.
```

**La API estará disponible en:**
- 🌐 API: http://localhost:5121/api
- 📚 Swagger: http://localhost:5121/swagger

### 2️⃣ Ejecutar la App Flutter

```powershell
# En una NUEVA ventana de PowerShell
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\proyecto_santi

# Ejecutar en Chrome (Web)
flutter run -d chrome

# O en Windows Desktop
flutter run -d windows
```

---

## 🔑 Autenticación

### Cómo Funciona Ahora

1. **Usuario ingresa su email** en la app Flutter
2. **Flutter llama a** `POST /api/Auth/login`
3. **API devuelve** un JWT token
4. **Flutter almacena** el token de forma segura
5. **Todas las peticiones** incluyen: `Authorization: Bearer {token}`

### Ejemplo de Login

```dart
// En Flutter
final auth = Provider.of<Auth>(context, listen: false);
await auth.login('profesor@acex.com', 'cualquier_password');
// La password no se valida en la API actual
```

```json
// Respuesta de la API
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "usuario": {
    "id": 1,
    "email": "profesor@acex.com",
    "nombreCompleto": "profesor@acex.com",
    "rol": "Usuario"
  }
}
```

---

## 📁 Archivos Modificados

### `lib/config.dart`
```dart
class AppConfig {
  // ✅ URL corregida
  static const String apiBaseUrl = 'http://localhost:5121/api';
  
  // ✅ Endpoints corregidos (capitalizados)
  static const String actividadEndpoint = '/Actividad';
  static const String profesorEndpoint = '/Profesor';
  static const String fotoEndpoint = '/Foto';
  static const String authEndpoint = '/Auth';
  
  // ✅ URL de archivos corregida
  static const String imagenesBaseUrl = 'http://localhost:5121/uploads';
}
```

### `lib/services/api_service.dart`
```dart
class ApiService {
  String? _jwtToken; // ✅ Nuevo: almacena el token JWT
  
  // ✅ Nuevo: método para establecer token
  void setToken(String? token) {
    _jwtToken = token;
  }
  
  // ✅ Interceptor que agrega el token automáticamente
  _dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      if (_jwtToken != null) {
        options.headers['Authorization'] = 'Bearer $_jwtToken';
      }
      return handler.next(options);
    },
  ));
  
  // ✅ Nuevo: método de login con JWT
  Future<Map<String, dynamic>?> login(String email, String nombreCompleto) async {
    final response = await _dio.post('${AppConfig.authEndpoint}/login', ...);
    // Retorna token y datos de usuario
  }
}
```

### `lib/models/auth.dart`
```dart
class Auth extends ChangeNotifier {
  String? _jwtToken; // ✅ Nuevo: almacena JWT
  
  Future<bool> login(String email, String password) async {
    // ✅ Usa el nuevo sistema de autenticación JWT
    final loginResult = await _apiService.login(email, email);
    
    if (loginResult != null && loginResult['token'] != null) {
      _jwtToken = loginResult['token'];
      _apiService.setToken(_jwtToken); // ✅ Configura el token
      // ...
    }
  }
}
```

---

## 🧪 Probar la Configuración

### 1. Verificar que la API esté corriendo

```powershell
# En PowerShell o tu navegador
curl http://localhost:5121/swagger
# Debería abrir Swagger UI
```

### 2. Probar el endpoint de login

```powershell
curl -X POST http://localhost:5121/api/Auth/login `
  -H "Content-Type: application/json" `
  -d '{"email":"test@acex.com","nombreCompleto":"Test User"}'

# Debería devolver un JSON con el token
```

### 3. Verificar endpoints con autenticación

```powershell
# Primero obtén un token con el comando anterior
$token = "tu_token_aqui"

curl http://localhost:5121/api/Profesor `
  -H "Authorization: Bearer $token"

# Debería devolver la lista de profesores
```

---

## ⚠️ Solución de Problemas Comunes

### ❌ Error: "Connection refused" o "No connection could be made"

**Problema:** La API no está corriendo o está en otro puerto

**Solución:**
```powershell
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\ACEXAPI
dotnet run
```

### ❌ Error: "401 Unauthorized"

**Problema:** Token JWT inválido o expirado

**Solución:**
1. Cierra sesión en la app Flutter
2. Vuelve a iniciar sesión
3. Verifica que el JWT Key en `appsettings.json` sea el mismo

### ❌ Error: "Cannot connect to SQL Server"

**Problema:** SQL Server no está corriendo

**Solución:**
```powershell
# Verificar estado de SQL Server
Get-Service -Name MSSQL*

# Iniciar SQL Server (si está detenido)
Start-Service -Name "MSSQL$SQLEXPRESS"
# O el nombre de tu servicio SQL Server
```

### ❌ Error: "The server requested authentication method unknown to the client"

**Problema:** Problema con la cadena de conexión SQL Server

**Solución:** Verifica en `ACEXAPI/appsettings.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=127.0.0.1,1433;Database=ACEXAPI;User Id=sa;Password=Semicrol_10;MultipleActiveResultSets=true;TrustServerCertificate=True;Encrypt=False"
  }
}
```

---

## 📊 Estructura de la API C#

```
ACEXAPI/
├── Controllers/
│   ├── ActividadController.cs    ✅ GET, POST, PUT, DELETE
│   ├── AuthController.cs         ✅ POST /login (JWT)
│   ├── ProfesorController.cs     ✅ GET, POST, PUT, DELETE
│   ├── FotoController.cs         ✅ GET, POST /upload, DELETE
│   └── CatalogosController.cs    ✅ Departamentos, Cursos, Grupos
├── Models/
│   ├── Actividad.cs
│   ├── Profesor.cs
│   ├── Foto.cs
│   └── Usuario.cs
├── Services/
│   ├── JwtService.cs            ✅ Generación de tokens
│   └── FileStorageService.cs   ✅ Gestión de archivos
└── appsettings.json             ✅ Configuración (JWT, SQL)
```

---

## 🎯 Siguiente Paso: Ejecutar Todo

**Terminal 1 (API):**
```powershell
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\ACEXAPI
dotnet run
```

**Terminal 2 (Flutter):**
```powershell
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\proyecto_santi
flutter run -d chrome
```

**¡Listo!** 🎉 Tu aplicación ahora está conectada correctamente a ACEXAPI.

---

## 📝 Resumen de Cambios

| Aspecto | Antes (❌) | Después (✅) |
|---------|-----------|-------------|
| **API** | Spring Boot Java | C# .NET 8.0 ACEXAPI |
| **URL Base** | `http://4.233.223.75:8080/api` | `http://localhost:5121/api` |
| **Endpoints** | `/actividad` (minúscula) | `/Actividad` (capitalizado) |
| **Autenticación** | Sin JWT | Con JWT tokens |
| **Base de Datos** | MySQL | SQL Server |
| **Puerto** | 8080 | 5121 |
| **Swagger** | No configurado | `http://localhost:5121/swagger` |

---

## 🔗 Enlaces Útiles

- 📚 Swagger UI: http://localhost:5121/swagger
- 🌐 API Base: http://localhost:5121/api
- 📝 Documentación ACEXAPI: Revisa los controladores en `ACEXAPI/Controllers/`

**¿Necesitas ayuda?** Revisa los logs en la consola de la API y de Flutter.
