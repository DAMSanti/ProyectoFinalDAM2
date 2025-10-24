# ⚡ COMANDOS RÁPIDOS - Proyecto Final DAM2

Referencia rápida de comandos más utilizados.

---

## 🚀 INICIO RÁPIDO

### Script Automático (Más Fácil)
```powershell
.\iniciar-proyecto.ps1
```

### Manual - Ambos Servicios

**Terminal 1 - Backend:**
```powershell
cd ACEXAPI ; dotnet run
```

**Terminal 2 - Frontend:**
```powershell
cd proyecto_santi ; flutter run -d chrome
```

---

## 🌐 BACKEND (.NET API)

### Navegación
```powershell
cd "g:\ProyectoFinalC#\ProyectoFinalDAM2\ACEXAPI"
```

### Comandos Básicos
```powershell
# Restaurar paquetes
dotnet restore

# Compilar
dotnet build

# Ejecutar
dotnet run

# Limpiar build
dotnet clean

# Ver información del proyecto
dotnet --info
```

### Entity Framework
```powershell
# Crear migración
dotnet ef migrations add NombreMigracion

# Aplicar migraciones
dotnet ef database update

# Revertir última migración
dotnet ef migrations remove

# Ver migraciones
dotnet ef migrations list

# Ver SQL de migración
dotnet ef migrations script
```

### Compilación Específica
```powershell
# Release
dotnet build -c Release

# Debug
dotnet build -c Debug

# Publicar
dotnet publish -c Release -o ./publish
```

---

## 📱 FRONTEND (Flutter)

### Navegación
```powershell
cd "g:\ProyectoFinalC#\ProyectoFinalDAM2\proyecto_santi"
```

### Comandos Básicos
```powershell
# Obtener dependencias
flutter pub get

# Actualizar dependencias
flutter pub upgrade

# Limpiar build
flutter clean

# Analizar código
flutter analyze

# Formatear código
flutter format .
```

### Ejecución
```powershell
# Web (Chrome)
flutter run -d chrome

# Windows Desktop
flutter run -d windows

# Android
flutter run

# Con hot reload
flutter run --hot

# Sin hot reload
flutter run --no-hot
```

### Dispositivos
```powershell
# Ver dispositivos disponibles
flutter devices

# Ver emuladores
flutter emulators

# Lanzar emulador
flutter emulators --launch <emulator_id>
```

### Build
```powershell
# Build para web
flutter build web

# Build para Windows
flutter build windows

# Build APK Android
flutter build apk

# Build release APK
flutter build apk --release
```

### Debugging
```powershell
# Ver logs
flutter logs

# Doctor (verificar instalación)
flutter doctor

# Doctor verbose
flutter doctor -v
```

---

## 🗄️ BASE DE DATOS (SQL Server)

### Conexión
```powershell
# Conectar a SQL Server
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10"

# Conectar a base de datos específica
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -d ACEXAPI

# Ejecutar consulta directa
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -d ACEXAPI -Q "SELECT * FROM Departamentos"

# Ejecutar script SQL
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -i "ruta\al\script.sql"
```

### Consultas Rápidas
```powershell
# Ver todas las bases de datos
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -Q "SELECT name FROM sys.databases"

# Ver tablas de ACEXAPI
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -d ACEXAPI -Q "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'"

# Contar registros en tabla
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -d ACEXAPI -Q "SELECT COUNT(*) FROM Actividades"

# Ver departamentos
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -d ACEXAPI -Q "SELECT * FROM Departamentos"

# Ver cursos
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -d ACEXAPI -Q "SELECT * FROM Cursos"
```

### Scripts Disponibles
```powershell
# Crear base de datos completa
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -i "ACEXAPI\Scripts\CreateDatabase.sql"

# Verificar base de datos
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -i "ACEXAPI\Scripts\VerifyDatabase.sql"

# Corregir tabla Usuarios
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -i "ACEXAPI\Scripts\FixUsuariosTable.sql"
```

### Docker (Si usas SQL Server en Docker)
```powershell
# Iniciar container
docker start sqlserver

# Detener container
docker stop sqlserver

# Ver status
docker ps

# Ver logs
docker logs sqlserver

# Ejecutar comando SQL en container
docker exec -it sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "Semicrol_10" -Q "SELECT @@VERSION"
```

---

## 🔧 GIT

### Comandos Básicos
```powershell
# Ver estado
git status

# Ver cambios
git diff

# Añadir cambios
git add .
git add archivo.txt

# Commit
git commit -m "Mensaje descriptivo"

# Push
git push origin main

# Pull
git pull origin main

# Ver log
git log --oneline
```

### Ramas
```powershell
# Ver ramas
git branch

# Crear rama
git branch nombre-rama

# Cambiar a rama
git checkout nombre-rama

# Crear y cambiar a rama
git checkout -b nombre-rama

# Mergear rama
git merge nombre-rama
```

---

## 🔍 VERIFICACIÓN Y DIAGNÓSTICO

### Verificar Instalaciones
```powershell
# .NET
dotnet --version
dotnet --info

# Flutter
flutter --version
flutter doctor
flutter doctor -v

# SQL Server
sqlcmd -?
Get-Service | Where-Object {$_.DisplayName -like "*SQL*"}

# Git
git --version

# PowerShell
$PSVersionTable
```

### Verificar Servicios Corriendo
```powershell
# SQL Server services
Get-Service | Where-Object {$_.DisplayName -like "*SQL*"}

# Procesos de .NET
Get-Process | Where-Object {$_.ProcessName -like "*dotnet*"}

# Procesos de Flutter
Get-Process | Where-Object {$_.ProcessName -like "*flutter*"}
```

### Verificar Puertos
```powershell
# Ver qué está usando el puerto 1433 (SQL Server)
netstat -ano | findstr :1433

# Ver qué está usando el puerto 5000 o 7000 (.NET)
netstat -ano | findstr :5000
netstat -ano | findstr :7000

# Ver todos los puertos en uso
netstat -ano
```

---

## 🧹 LIMPIEZA

### Backend
```powershell
cd ACEXAPI

# Limpiar build
dotnet clean

# Eliminar carpetas bin y obj
Remove-Item -Recurse -Force bin, obj

# Restaurar y rebuild
dotnet restore ; dotnet build
```

### Frontend
```powershell
cd proyecto_santi

# Limpiar Flutter
flutter clean

# Eliminar pubspec.lock y reinstalar
Remove-Item pubspec.lock
flutter pub get
```

### Base de Datos
```sql
-- Eliminar y recrear base de datos
USE master;
GO
DROP DATABASE IF EXISTS ACEXAPI;
GO
-- Luego ejecutar CreateDatabase.sql
```

---

## 🐛 SOLUCIÓN RÁPIDA DE PROBLEMAS

### Backend no compila
```powershell
dotnet clean ; dotnet restore ; dotnet build
```

### Frontend no compila
```powershell
flutter clean ; flutter pub get
```

### SQL Server no responde
```powershell
# Si es servicio
Restart-Service MSSQLSERVER

# Si es Docker
docker restart sqlserver
```

### Puerto ocupado
```powershell
# Ver qué proceso usa el puerto (ejemplo: 5000)
netstat -ano | findstr :5000

# Matar proceso por PID (reemplazar XXXX con el PID)
taskkill /PID XXXX /F
```

---

## 📊 TESTING

### Backend
```powershell
# Ejecutar tests
dotnet test

# Con cobertura
dotnet test /p:CollectCoverage=true
```

### Frontend
```powershell
# Ejecutar tests
flutter test

# Con cobertura
flutter test --coverage
```

---

## 📝 URLS IMPORTANTES

Una vez todo esté corriendo:

- **Swagger UI:** `https://localhost:7xxx/swagger`
- **API Base:** `https://localhost:7xxx/api`
- **Flutter Web:** `http://localhost:58080` (o puerto asignado)

---

## 💡 TIPS

### Alias de PowerShell (Opcional)
Añade al perfil de PowerShell para comandos más cortos:

```powershell
# Ver/Editar perfil
notepad $PROFILE

# Añadir estos alias:
function Start-Backend { cd "g:\ProyectoFinalC#\ProyectoFinalDAM2\ACEXAPI" ; dotnet run }
function Start-Frontend { cd "g:\ProyectoFinalC#\ProyectoFinalDAM2\proyecto_santi" ; flutter run -d chrome }

Set-Alias backend Start-Backend
Set-Alias frontend Start-Frontend
```

Luego solo escribe `backend` o `frontend` en PowerShell.

---

**¡Guarda este archivo para referencia rápida!** 📌
