# 🔐 Sistema de Autenticación con Contraseña - ACEXAPI

## ✅ Cambios Implementados

### 1️⃣ **Backend (ACEXAPI - C#)**

#### **Modelo Usuario Actualizado**
Se agregó el campo `Password` al modelo `Usuario`:

```csharp
[Required]
[MaxLength(256)]
public string Password { get; set; } = string.Empty; // Hash BCrypt
```

#### **Servicio de Contraseñas (BCrypt)**
Creados dos archivos:
- `Services/IPasswordService.cs` - Interfaz
- `Services/PasswordService.cs` - Implementación con BCrypt

```csharp
public string HashPassword(string password);
public bool VerifyPassword(string password, string hash);
```

#### **AuthController Actualizado**
- ✅ Login requiere email + password (antes solo email)
- ✅ Valida credenciales contra la base de datos
- ✅ No crea usuarios automáticamente
- ✅ Devuelve error 401 si credenciales son inválidas

#### **DevController (Solo Desarrollo)**
Nuevo controlador con endpoints útiles:
- `POST /api/Dev/seed-users` - Crea usuarios de prueba
- `POST /api/Dev/hash-password` - Genera hash BCrypt
- `GET /api/Dev/list-users` - Lista todos los usuarios

---

### 2️⃣ **Frontend (Flutter)**

#### **ApiService Actualizado**
```dart
Future<Map<String, dynamic>?> login(String email, String password)
```
Ahora envía `password` en lugar de `nombreCompleto`.

#### **Auth Model Actualizado**
- ✅ Método `login()` requiere email + password
- ✅ No hace login automático al iniciar app
- ✅ Usuario debe ingresar credenciales cada vez

---

## 🚀 Cómo Usar

### Paso 1: Instalar Dependencias

```powershell
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\ACEXAPI
dotnet restore
```

Esto instalará el paquete `BCrypt.Net-Next` agregado al `.csproj`.

---

### Paso 2: Actualizar la Base de Datos

La tabla `Usuarios` ahora tiene una columna `Password`. Tienes **2 opciones**:

#### **Opción A: Recrear la Base de Datos (Más Fácil)**

```powershell
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\ACEXAPI
dotnet ef database drop --force
dotnet ef migrations add AddPasswordToUsuario
dotnet ef database update
```

#### **Opción B: Migración Manual (Conserva Datos)**

```powershell
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\ACEXAPI
dotnet ef migrations add AddPasswordToUsuario
dotnet ef database update
```

Si tienes usuarios existentes sin contraseña, deberás actualizarlos manualmente en SQL Server.

---

### Paso 3: Crear Usuarios de Prueba

#### **Usando el Endpoint DevController (Recomendado)**

1. Inicia la API:
```powershell
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\ACEXAPI
dotnet run
```

2. Abre tu navegador en: http://localhost:5000/swagger

3. Ve a `Dev` → `POST /api/Dev/seed-users` → Click en "Try it out" → "Execute"

Esto creará automáticamente estos usuarios:

| Email | Contraseña | Rol |
|-------|-----------|-----|
| admin@acexapi.com | `admin123` | Administrador |
| profesor@acexapi.com | `profesor123` | Profesor |
| coordinador@acexapi.com | `coord123` | Coordinador |
| usuario@acexapi.com | `usuario123` | Usuario |

---

### Paso 4: Probar el Login desde Flutter

1. Inicia la API (si no está corriendo):
```powershell
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\ACEXAPI
dotnet run
```

2. Inicia Flutter Web:
```powershell
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\proyecto_santi
flutter run -d chrome
```

3. En la pantalla de login:
   - **Email:** `admin@acexapi.com`
   - **Contraseña:** `admin123`

---

## 🧪 Probar la API Directamente

### Con cURL (PowerShell)

```powershell
# Login correcto
curl http://localhost:5000/api/Auth/login `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body '{"email":"admin@acexapi.com","password":"admin123"}'

# Login incorrecto (password mal)
curl http://localhost:5000/api/Auth/login `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body '{"email":"admin@acexapi.com","password":"wrongpassword"}'
```

### Con Swagger

1. Abre http://localhost:5000/swagger
2. Ve a `Auth` → `POST /api/Auth/login`
3. Click en "Try it out"
4. Ingresa:
```json
{
  "email": "admin@acexapi.com",
  "password": "admin123"
}
```
5. Click en "Execute"

**Respuesta Exitosa:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "usuario": {
    "id": "guid-aqui",
    "email": "admin@acexapi.com",
    "nombreCompleto": "Administrador ACEX",
    "rol": "Administrador"
  }
}
```

**Respuesta con Error:**
```json
{
  "message": "Credenciales inválidas"
}
```

---

## 📋 Credenciales de Prueba

Después de ejecutar `/api/Dev/seed-users`:

### Administrador
- **Email:** `admin@acexapi.com`
- **Password:** `admin123`
- **Rol:** Administrador

### Profesor
- **Email:** `profesor@acexapi.com`
- **Password:** `profesor123`
- **Rol:** Profesor

### Coordinador
- **Email:** `coordinador@acexapi.com`
- **Password:** `coord123`
- **Rol:** Coordinador

### Usuario
- **Email:** `usuario@acexapi.com`
- **Password:** `usuario123`
- **Rol:** Usuario

---

## 🔧 Solución de Problemas

### ❌ Error: "Column 'Password' does not exist"

**Solución:** Ejecuta las migraciones de Entity Framework:
```powershell
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\ACEXAPI
dotnet ef migrations add AddPasswordToUsuario
dotnet ef database update
```

### ❌ Error: "No se pudo encontrar el tipo BCrypt"

**Solución:** Restaura los paquetes NuGet:
```powershell
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\ACEXAPI
dotnet restore
```

### ❌ Error: "Credenciales inválidas" (pero estoy seguro que están bien)

**Verificaciones:**
1. Asegúrate de que ejecutaste `/api/Dev/seed-users`
2. Verifica que el usuario existe:
   ```powershell
   # En Swagger: GET /api/Dev/list-users
   ```
3. Revisa los logs de la API en la consola

### ❌ El formulario de login en Flutter no envía la contraseña

**Verifica que el formulario tenga:**
```dart
TextFormField(
  obscureText: true,  // Para ocultar la contraseña
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese su contraseña';
    }
    return null;
  },
)
```

---

## 🔐 Seguridad

### ✅ Buenas Prácticas Implementadas
- ✅ Contraseñas hasheadas con **BCrypt** (nunca en texto plano)
- ✅ Validación de entrada (email, password no vacíos)
- ✅ Mensajes de error genéricos (no revelamos si el email existe)
- ✅ JWT tokens con expiración

### ⚠️ Pendiente para Producción
- 🔒 Usar HTTPS en producción
- 🔒 Implementar límite de intentos de login (rate limiting)
- 🔒 Agregar captcha después de X intentos fallidos
- 🔒 Implementar refresh tokens
- 🔒 **Eliminar `DevController`** en producción
- 🔒 Logs de auditoría para accesos

---

## 📝 Resumen de Archivos Modificados

### Backend (C#)
1. ✅ `Models/Usuario.cs` - Agregado campo Password
2. ✅ `Services/IPasswordService.cs` - Nueva interfaz
3. ✅ `Services/PasswordService.cs` - Implementación BCrypt
4. ✅ `Controllers/AuthController.cs` - Validación de password
5. ✅ `Controllers/DevController.cs` - Utilidades de desarrollo
6. ✅ `Program.cs` - Registro de PasswordService
7. ✅ `ACEXAPI.csproj` - Agregado BCrypt.Net-Next

### Frontend (Flutter)
1. ✅ `lib/services/api_service.dart` - Login con password
2. ✅ `lib/models/auth.dart` - Requiere password, no auto-login

---

## 🎯 Próximos Pasos

1. ✅ Ejecuta `dotnet restore` para instalar BCrypt
2. ✅ Ejecuta migraciones EF para agregar columna Password
3. ✅ Inicia la API con `dotnet run`
4. ✅ Ejecuta `/api/Dev/seed-users` en Swagger
5. ✅ Prueba login desde Flutter con `admin@acexapi.com` / `admin123`

**¡Listo! Ahora tu API requiere autenticación real con contraseña. 🎉**
