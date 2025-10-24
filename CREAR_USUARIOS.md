# 🔐 Crear Usuarios para ACEXAPI

## Problema Resuelto

Los usuarios **NO se pueden crear directamente desde SQL** porque las contraseñas deben estar hasheadas con BCrypt. Por eso, he creado dos métodos para crear usuarios de prueba.

## ✅ Método 1: Script Automático (RECOMENDADO)

### Pasos:

1. **Inicia la API:**
   ```powershell
   cd ACEXAPI
   dotnet run
   ```

2. **En otra terminal, ejecuta el script:**
   ```powershell
   .\crear-usuarios.ps1
   ```

3. **El script creará automáticamente estos usuarios:**

   | Rol | Email | Password |
   |-----|-------|----------|
   | Administrador | admin@acexapi.com | admin123 |
   | Coordinador | coordinador@acexapi.com | coord123 |
   | Profesor | profesor@acexapi.com | profesor123 |
   | Usuario | usuario@acexapi.com | usuario123 |

## ✅ Método 2: Endpoint de la API

### Opción A: Usar el endpoint de desarrollo

```powershell
# Con la API corriendo
Invoke-RestMethod -Uri "https://localhost:7139/api/dev/seed-users" -Method Post
```

### Opción B: Registrar usuarios manualmente

```powershell
$body = @{
    email = "tunombre@ies.edu"
    nombreCompleto = "Tu Nombre Completo"
    password = "tupassword123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://localhost:7139/api/auth/register" -Method Post -Body $body -ContentType "application/json"
```

## ✅ Método 3: Desde la aplicación Flutter

1. Inicia la aplicación
2. En la pantalla de login, busca el botón de "Registrar" (si existe)
3. Completa el formulario de registro

## 📋 Verificar usuarios creados

```powershell
# Con la API corriendo
Invoke-RestMethod -Uri "https://localhost:7139/api/dev/list-users" -Method Get
```

## 🎯 Iniciar proyecto completo con datos

### Orden recomendado:

```powershell
# 1. Poblar base de datos (tablas principales)
.\poblar-base-datos.ps1

# 2. Iniciar API
cd ACEXAPI
dotnet run

# 3. En otra terminal, crear usuarios
.\crear-usuarios.ps1

# 4. En otra terminal, iniciar Flutter
cd proyecto_santi
flutter run -d windows
```

## ⚠️ Notas Importantes

1. **Los usuarios se crean con `@acexapi.com`** en el dominio para distinguirlos de usuarios reales
2. **Las contraseñas están hasheadas con BCrypt** y no se pueden ver en la base de datos
3. **El endpoint `/api/dev/` solo debe usarse en desarrollo** - elimínalo en producción
4. **Puedes cambiar el rol de un usuario** directamente en la base de datos si es necesario

## 🔧 Cambiar rol de usuario manualmente

Si necesitas cambiar el rol de un usuario (por ejemplo, hacer admin a alguien):

```sql
USE ACEXAPI;
UPDATE Usuarios 
SET Rol = 'Administrador' 
WHERE Email = 'email@usuario.com';
```

Roles disponibles:
- `Administrador`
- `Coordinador`
- `Profesor`
- `Usuario`

## 🐛 Troubleshooting

### La API no responde

```powershell
# Verifica que esté corriendo
Get-Process | Where-Object {$_.ProcessName -like "*dotnet*"}

# Verifica el puerto
netstat -ano | findstr :7139
```

### Error de certificado SSL

El script ya incluye:
```powershell
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
```

### No puedo hacer login

1. Verifica que el usuario existe: `GET /api/dev/list-users`
2. Verifica que el email y password son correctos
3. Revisa los logs de la API en la consola
4. El email debe ser exactamente como lo registraste (case-sensitive)

## 📝 Ejemplo completo de uso

```powershell
# Terminal 1 - Iniciar API
cd G:\ProyectoFinalC#\ProyectoFinalDAM2\ACEXAPI
dotnet run

# Terminal 2 - Crear usuarios
cd G:\ProyectoFinalC#\ProyectoFinalDAM2
.\crear-usuarios.ps1

# Terminal 3 - Iniciar Flutter
cd G:\ProyectoFinalC#\ProyectoFinalDAM2\proyecto_santi
flutter run -d windows
```

Luego en la app:
1. Ingresa `admin@acexapi.com` / `admin123`
2. ✅ Login exitoso!
