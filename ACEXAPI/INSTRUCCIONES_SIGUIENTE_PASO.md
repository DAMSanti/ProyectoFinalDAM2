# ✅ Base de Datos Actualizada con Columna Password

## 🎉 ¡Completado!

La base de datos SQL Server ha sido actualizada exitosamente con la columna `Password` en la tabla `Usuarios`.

---

## 📋 Lo que se hizo:

1. ✅ **Instaladas herramientas de Entity Framework** (`dotnet-ef`)
2. ✅ **Creado script SQL** para agregar columna Password
3. ✅ **Ejecutado script** en la base de datos ACEXAPI
4. ✅ **Verificada** la existencia de la columna

```sql
ALTER TABLE [dbo].[Usuarios]
ADD [Password] NVARCHAR(256) NOT NULL DEFAULT '';
```

---

## 🚀 Próximos Pasos

### Paso 1: Iniciar la API

Abre una terminal PowerShell:

```powershell
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\ACEXAPI
dotnet run
```

Espera a ver:
```
Now listening on: http://0.0.0.0:5000
```

### Paso 2: Crear Usuarios de Prueba

1. **Abre tu navegador** en: http://192.168.9.190:5000/swagger
   (O http://localhost:5000/swagger si lo haces desde la misma máquina)

2. Busca el grupo **`Dev`** (Development Controller)

3. Click en **`POST /api/Dev/seed-users`**

4. Click en **"Try it out"**

5. Click en **"Execute"**

**Resultado esperado:**
```json
{
  "message": "Usuarios de prueba creados exitosamente",
  "usuarios": [
    {
      "email": "admin@acexapi.com",
      "nombreCompleto": "Administrador ACEX",
      "rol": "Administrador",
      "passwordHint": "admin123"
    },
    {
      "email": "profesor@acexapi.com",
      "nombreCompleto": "Profesor Demo",
      "rol": "Profesor",
      "passwordHint": "profesor123"
    },
    // ... más usuarios
  ]
}
```

### Paso 3: Probar el Login

#### **Opción A: Desde Swagger**

1. Ve a **`Auth` → `POST /api/Auth/login`**
2. Click en **"Try it out"**
3. Ingresa:
```json
{
  "email": "admin@acexapi.com",
  "password": "admin123"
}
```
4. Click en **"Execute"**

**Resultado esperado (200 OK):**
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

#### **Opción B: Desde Flutter**

1. En otra terminal:
```powershell
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\proyecto_santi
flutter run -d chrome
```

2. En el formulario de login:
   - **Email:** `admin@acexapi.com`
   - **Password:** `admin123`
   - Click en **"Iniciar sesión"**

---

## 🔑 Credenciales de Prueba

| Email | Password | Rol |
|-------|----------|-----|
| `admin@acexapi.com` | `admin123` | Administrador |
| `profesor@acexapi.com` | `profesor123` | Profesor |
| `coordinador@acexapi.com` | `coord123` | Coordinador |
| `usuario@acexapi.com` | `usuario123` | Usuario |

---

## 🔧 Verificar que Todo Funciona

### 1. Verificar que la columna existe:

```powershell
sqlcmd -S 127.0.0.1,1433 -U sa -P Semicrol_10 -d ACEXAPI -Q "SELECT TOP 1 Email, Password, Rol FROM Usuarios"
```

### 2. Verificar que los usuarios fueron creados:

```powershell
sqlcmd -S 127.0.0.1,1433 -U sa -P Semicrol_10 -d ACEXAPI -Q "SELECT Email, NombreCompleto, Rol FROM Usuarios WHERE Email LIKE '%@acexapi.com'"
```

### 3. Verificar que las contraseñas están hasheadas:

Las contraseñas deben aparecer como hashes BCrypt (ej: `$2a$11$...`), **nunca en texto plano**.

---

## 📝 Estructura Actual de la Tabla Usuarios

```sql
CREATE TABLE [Usuarios] (
    [Id] UNIQUEIDENTIFIER PRIMARY KEY,
    [Email] NVARCHAR(256) NOT NULL,
    [NombreCompleto] NVARCHAR(200) NOT NULL,
    [Password] NVARCHAR(256) NOT NULL,  -- ✅ NUEVA COLUMNA
    [Rol] NVARCHAR(50) NOT NULL,
    [FechaCreacion] DATETIME2 NOT NULL,
    [Activo] BIT NOT NULL
);
```

---

## ❌ Solución de Problemas

### Error: "La API no inicia"

**Verifica que no haya otra instancia corriendo:**
```powershell
netstat -ano | findstr :5000
```

Si hay un proceso en el puerto 5000:
```powershell
taskkill /PID <numero-del-proceso> /F
```

### Error: "Invalid column name 'Password'"

**Significa que el script SQL no se ejecutó correctamente. Vuélvelo a ejecutar:**
```powershell
sqlcmd -S 127.0.0.1,1433 -U sa -P Semicrol_10 -d ACEXAPI -i C:\Users\santiagota\source\repos\ProyectoFinalDAM2\ACEXAPI\AddPasswordColumn.sql
```

### Error: "Credenciales inválidas" (pero estoy seguro que están bien)

**Asegúrate de que ejecutaste `/api/Dev/seed-users` para crear los usuarios.**

Verifica en la base de datos:
```powershell
sqlcmd -S 127.0.0.1,1433 -U sa -P Semicrol_10 -d ACEXAPI -Q "SELECT Email, Rol, LEN(Password) as PasswordLength FROM Usuarios"
```

Si `PasswordLength` es 0, los usuarios no tienen contraseña asignada. Ejecuta seed-users nuevamente.

---

## 🎯 Resumen

✅ Columna `Password` agregada a la tabla `Usuarios`  
✅ API lista para validar credenciales reales  
✅ Script SQL disponible en: `ACEXAPI/AddPasswordColumn.sql`  
✅ Endpoint `/api/Dev/seed-users` listo para crear usuarios de prueba  

**¡Todo listo para probar el login con contraseña! 🎉**
