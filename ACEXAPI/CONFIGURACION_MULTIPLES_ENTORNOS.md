# 🏠🏢 CONFIGURACIÓN MÚLTIPLES ENTORNOS - CASA Y TRABAJO

## 📋 Configuración actual de la API

Tu API se conecta a la base de datos usando el archivo `appsettings.json`:

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=ACEXAPI;User Id=sa;Password=Semicrol_10;..."
}
```

## ✅ Archivos creados para ti:

1. **`appsettings.Casa.json`** - Configuración para casa (localhost)
2. **`appsettings.Trabajo.json`** - Configuración para trabajo (debes editarla)
3. **`start-api-casa.ps1`** - Script para iniciar en casa
4. **`start-api-trabajo.ps1`** - Script para iniciar en trabajo

---

## 🔧 PASO 1: Configurar el entorno de TRABAJO

Edita el archivo `ACEXAPI/appsettings.Trabajo.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=TU_SERVIDOR\\SQLEXPRESS;Database=ACEXAPI;User Id=sa;Password=TU_PASSWORD;MultipleActiveResultSets=true;TrustServerCertificate=True;Encrypt=False"
  }
}
```

**Reemplaza:**
- `TU_SERVIDOR` con el nombre de tu servidor en el trabajo (ejemplo: `DESKTOP-TRABAJO`, `192.168.1.100`, etc.)
- `TU_PASSWORD` con la contraseña de SQL Server del trabajo

---

## 🚀 PASO 2: Iniciar la API

### 🏠 Para iniciar en CASA:

```powershell
cd G:\ProyectoFinalCSharp\ProyectoFinalDAM2\ACEXAPI
.\start-api-casa.ps1
```

### 🏢 Para iniciar en TRABAJO:

```powershell
cd G:\ProyectoFinalCSharp\ProyectoFinalDAM2\ACEXAPI
.\start-api-trabajo.ps1
```

---

## 📱 PASO 3: Iniciar la aplicación Flutter

**En otra terminal PowerShell:**

```powershell
cd G:\ProyectoFinalCSharp\ProyectoFinalDAM2\proyecto_santi

# Para Windows
flutter run -d windows

# Para Web
flutter run -d chrome

# Para Android
flutter run
```

---

## 🎯 FORMA ALTERNATIVA: Usar variables de entorno manualmente

### En CASA:

```powershell
cd G:\ProyectoFinalCSharp\ProyectoFinalDAM2\ACEXAPI
$env:ASPNETCORE_ENVIRONMENT = "Casa"
dotnet run
```

### En TRABAJO:

```powershell
cd G:\ProyectoFinalCSharp\ProyectoFinalDAM2\ACEXAPI
$env:ASPNETCORE_ENVIRONMENT = "Trabajo"
dotnet run
```

---

## 🔍 Verificar qué base de datos estás usando

Cuando inicies la API, verás en la consola:

```
Now listening on: https://localhost:7139
```

Y en los logs iniciales verás la cadena de conexión que está usando.

---

## 💡 TIP: Crear un alias rápido

Puedes crear aliases en tu perfil de PowerShell:

```powershell
# Editar perfil
notepad $PROFILE

# Añadir estas líneas:
function Start-ApiCasa { 
    cd "G:\ProyectoFinalCSharp\ProyectoFinalDAM2\ACEXAPI"
    .\start-api-casa.ps1 
}

function Start-ApiTrabajo { 
    cd "G:\ProyectoFinalCSharp\ProyectoFinalDAM2\ACEXAPI"
    .\start-api-trabajo.ps1 
}

# Guardar y reiniciar PowerShell
# Ahora puedes ejecutar:
Start-ApiCasa
# o
Start-ApiTrabajo
```

---

## 📝 RESUMEN DE COMANDOS RÁPIDOS

| Acción | Comando Casa | Comando Trabajo |
|--------|--------------|-----------------|
| **Iniciar API** | `.\start-api-casa.ps1` | `.\start-api-trabajo.ps1` |
| **Base de datos** | `localhost\SQLEXPRESS` | Tu servidor trabajo |
| **Password** | `Semicrol_10` | Tu password trabajo |

---

## ⚙️ Cómo funciona internamente

ASP.NET Core lee los archivos `appsettings` en este orden:

1. `appsettings.json` (base)
2. `appsettings.{ASPNETCORE_ENVIRONMENT}.json` (sobrescribe)

Cuando ejecutas con `$env:ASPNETCORE_ENVIRONMENT = "Casa"`:
- Lee `appsettings.json`
- Luego lee `appsettings.Casa.json` y sobrescribe los valores

---

## 🆘 Solución de problemas

### Error: "Cannot connect to SQL Server"

**En CASA:**
```powershell
# Verificar que SQL Server está corriendo
Get-Service MSSQL$SQLEXPRESS

# Iniciarlo si está detenido
Start-Service MSSQL$SQLEXPRESS
```

**En TRABAJO:**
- Verifica el nombre del servidor
- Verifica que el puerto 1433 esté abierto
- Verifica usuario y contraseña

### Error: "Login failed for user 'sa'"

Verifica la contraseña en el archivo `appsettings.{Entorno}.json`

---

## 📌 IMPORTANTE

- **NO subas** `appsettings.Trabajo.json` a Git si tiene credenciales reales
- Añádelo al `.gitignore`:

```
appsettings.Trabajo.json
```

¡Listo! Ahora puedes trabajar fácilmente en casa y en el trabajo sin cambiar configuraciones manualmente. 🎉
