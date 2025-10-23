# ✅ Error 401 Solucionado

## 🔍 Problema Identificado

El error 401 ocurría porque después del login exitoso, Flutter intentaba buscar al usuario en la tabla `Profesores`, pero esa tabla no tiene los usuarios creados con `/api/Dev/seed-users`.

### ❌ Flujo Anterior (Causaba Error 401)
1. Usuario ingresa email/password ✅
2. API valida credenciales ✅
3. API devuelve token JWT ✅
4. Flutter intenta buscar en tabla `Profesores` ❌ (No existe el usuario)
5. Flutter lanza error 401

### ✅ Flujo Actual (Corregido)
1. Usuario ingresa email/password ✅
2. API valida credenciales ✅
3. API devuelve token JWT + datos del usuario ✅
4. Flutter crea objeto `Profesor` temporal con los datos del usuario ✅
5. Login exitoso ✅

---

## 🛠️ Cambios Realizados

### 1. Corregido `lib/models/auth.dart`

**Antes:**
```dart
// Intentaba buscar en la tabla Profesores
final profesores = await _apiService.fetchProfesores();
_currentUser = profesores.firstWhere((p) => p.correo == email);
```

**Ahora:**
```dart
// Usa los datos que vienen directamente del login
final usuario = loginResult['usuario'];
_currentUser = Profesor(
  uuid: usuario?['id']?.toString() ?? '',
  nombre: usuario?['nombreCompleto']?.toString().split(' ').first ?? 'Usuario',
  correo: usuario?['email']?.toString() ?? email,
  rol: usuario?['rol']?.toString() ?? 'Usuario',
  // ... otros campos
);
```

### 2. Corregido import en `lib/models/profesor.dart`

**Antes:**
```dart
import 'package:proyecto_santi/models/Departamento.dart'; // Mayúscula ❌
```

**Ahora:**
```dart
import 'package:proyecto_santi/models/departamento.dart'; // Minúscula ✅
```

---

## 🚀 Cómo Probar

### Paso 1: Iniciar la API

**Opción A: Usando el script** (Recomendado)
```powershell
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\ACEXAPI
.\start-api.bat
```

**Opción B: Manualmente**
```powershell
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\ACEXAPI
dotnet run
```

Espera a ver:
```
Now listening on: http://0.0.0.0:5000
```

### Paso 2: Crear Usuarios de Prueba (Si aún no lo hiciste)

1. Abre http://192.168.9.190:5000/swagger
2. Ve a **Dev → POST /api/Dev/seed-users**
3. Click "Try it out" → "Execute"

Esto crea:
- `admin@acexapi.com` / `admin123`
- `profesor@acexapi.com` / `profesor123`
- `coordinador@acexapi.com` / `coord123`
- `usuario@acexapi.com` / `usuario123`

### Paso 3: Ejecutar Flutter

En **otra terminal**:
```powershell
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\proyecto_santi
flutter run -d chrome
```

### Paso 4: Hacer Login

1. En la pantalla de login:
   - **Email:** `admin@acexapi.com`
   - **Password:** `admin123`
   - Click **"Iniciar sesión"**

2. **Resultado esperado:**
   - ✅ Login exitoso
   - ✅ Redirección a la pantalla principal
   - ✅ Usuario autenticado como "Administrador ACEX"

---

## 🧪 Verificar en los Logs

### Logs de Flutter (Terminal de flutter run)

**Antes (Error):**
```
[API] POST http://192.168.9.190:5000/api/Auth/login
[Auth] Warning: No se pudo obtener datos del profesor: ...
[Auth Error] ApiException: No autorizado. Status 401
```

**Ahora (Correcto):**
```
[API] POST http://192.168.9.190:5000/api/Auth/login
[API] Response: 200 OK
[Auth] Login exitoso para: admin@acexapi.com
```

### Logs de la API (Terminal de dotnet run)

Deberías ver:
```
info: Microsoft.EntityFrameworkCore.Database.Command[20101]
      SELECT TOP(1) ... FROM [Usuarios] AS [u]
      WHERE [u].[Email] = 'admin@acexapi.com' AND [u].[Activo] = 1
```

---

## 🔐 Datos del Usuario Después del Login

Después de hacer login con `admin@acexapi.com`, el objeto `_currentUser` tendrá:

```dart
Profesor {
  uuid: "guid-del-usuario",
  nombre: "Administrador",
  apellidos: "ACEX",
  correo: "admin@acexapi.com",
  rol: "Administrador",
  activo: 1,
  depart: Departamento {
    id: 0,
    codigo: "Administrador",
    nombre: "Administrador"
  }
}
```

---

## ❌ Si Aún Obtienes Error 401

### Verificación 1: ¿La API está corriendo?

```powershell
netstat -ano | findstr :5000
```

Deberías ver líneas con `LISTENING` en el puerto 5000.

### Verificación 2: ¿Los usuarios existen?

```powershell
sqlcmd -S 127.0.0.1,1433 -U sa -P Semicrol_10 -d ACEXAPI -Q "SELECT Email, Rol, LEN(Password) as HasPassword FROM Usuarios WHERE Email LIKE '%@acexapi.com'"
```

Deberías ver los 4 usuarios con `HasPassword > 0`.

### Verificación 3: ¿El password es correcto?

En Swagger, prueba:
```json
{
  "email": "admin@acexapi.com",
  "password": "admin123"
}
```

Respuesta esperada: **200 OK** con un token JWT.

### Verificación 4: ¿Flutter está usando la IP correcta?

Verifica `lib/config.dart`:
```dart
static String get apiBaseUrl {
  if (kIsWeb) {
    return 'http://192.168.9.190:5000/api';  // ✅ Debe ser tu IP
  } else {
    return 'http://localhost:5000/api';
  }
}
```

---

## 📝 Resumen de Archivos Modificados

1. ✅ `lib/models/auth.dart` - Ya no busca en tabla Profesores
2. ✅ `lib/models/profesor.dart` - Import corregido (departamento minúscula)
3. ✅ `ACEXAPI/start-api.bat` - Script para iniciar API fácilmente

---

## 🎯 Próximo Test

Una vez que hagas login exitoso, deberías poder:
- ✅ Ver tu nombre en la barra superior
- ✅ Navegar por la app
- ✅ Cerrar sesión
- ✅ Volver a iniciar sesión

**¡El login ahora debería funcionar perfectamente! 🎉**
