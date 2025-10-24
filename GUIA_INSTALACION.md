# 🚀 GUÍA DE INSTALACIÓN - Proyecto Final DAM2

## 📋 Tabla de Contenidos
1. [Requisitos Previos](#requisitos-previos)
2. [Instalación del Backend (.NET API)](#instalación-del-backend-net-api)
3. [Instalación del Frontend (Flutter)](#instalación-del-frontend-flutter)
4. [Configuración de la Base de Datos](#configuración-de-la-base-de-datos)
5. [Ejecutar el Proyecto Completo](#ejecutar-el-proyecto-completo)
6. [Verificación](#verificación)
7. [Solución de Problemas](#solución-de-problemas)

---

## ✅ Requisitos Previos

### 1. **SDK y Herramientas**

#### .NET (Backend API)
- ✅ **.NET 8 SDK** - [Descargar aquí](https://dotnet.microsoft.com/download/dotnet/8.0)
  ```powershell
  # Verificar instalación
  dotnet --version
  # Debe mostrar 8.0.x o superior
  ```

#### Flutter (Frontend Mobile/Web)
- ✅ **Flutter SDK** - [Guía de instalación](https://docs.flutter.dev/get-started/install/windows)
  ```powershell
  # Verificar instalación
  flutter --version
  # Debe mostrar Flutter 3.x o superior
  ```

#### Base de Datos
- ✅ **SQL Server 2019+** o **SQL Server Express/LocalDB**
  - [SQL Server Express](https://www.microsoft.com/sql-server/sql-server-downloads) (Gratis)
  - O usar Docker (ver más abajo)

#### Editores (Opcional pero recomendado)
- ✅ **Visual Studio 2022** (Para .NET) o **VS Code**
- ✅ **Android Studio** (Para Flutter - incluye emulador Android)

### 2. **SQL Server con Docker (Alternativa)**

Si prefieres usar Docker:
```powershell
# Descargar e instalar Docker Desktop
# Luego ejecutar SQL Server en container:
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=Semicrol_10" -p 1433:1433 --name sqlserver -d mcr.microsoft.com/mssql/server:2022-latest
```

---

## 🔧 Instalación del Backend (.NET API)

### Paso 1: Navegar al proyecto
```powershell
cd "g:\ProyectoFinalC#\ProyectoFinalDAM2\ACEXAPI"
```

### Paso 2: Restaurar paquetes NuGet
```powershell
dotnet restore
```

### Paso 3: Compilar el proyecto
```powershell
dotnet build
```

Si sale algún error, instala los paquetes manualmente:
```powershell
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add package FluentValidation.AspNetCore
dotnet add package SixLabors.ImageSharp
```

### Paso 4: Verificar configuración
El archivo `appsettings.json` ya está configurado con:
- ✅ Connection String a SQL Server (127.0.0.1,1433)
- ✅ JWT configurado
- ✅ CORS para Flutter

---

## 🗄️ Configuración de la Base de Datos

### Opción A: Base de Datos YA existe (Recomendado)
Según tu documentación, la BD ya está creada. Solo verifica:

```powershell
# Verificar conexión
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -Q "SELECT name FROM sys.databases WHERE name = 'ACEXAPI'"
```

Si muestra "ACEXAPI", **¡ya está lista!** Pasa al siguiente paso.

### Opción B: Crear Base de Datos desde cero

Si no existe, ejecuta el script de creación:
```powershell
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -i "g:\ProyectoFinalC#\ProyectoFinalDAM2\ACEXAPI\Scripts\CreateDatabase.sql"
```

O desde SQL Server Management Studio (SSMS):
1. Conectar a `127.0.0.1,1433` con usuario `sa`
2. Abrir archivo `Scripts\CreateDatabase.sql`
3. Ejecutar (F5)

### Opción C: Usar Entity Framework Migrations (Si prefieres)
```powershell
# Crear migración inicial
dotnet ef migrations add InitialCreate

# Aplicar a la base de datos
dotnet ef database update
```

---

## 📱 Instalación del Frontend (Flutter)

### Paso 1: Navegar al proyecto Flutter
```powershell
cd "g:\ProyectoFinalC#\ProyectoFinalDAM2\proyecto_santi"
```

### Paso 2: Obtener dependencias
```powershell
flutter pub get
```

Este comando descarga todas las dependencias listadas en `pubspec.yaml`:
- dio (HTTP client)
- provider (State management)
- image_picker (Selección de imágenes)
- flutter_map (Mapas)
- Y otras...

### Paso 3: Verificar dispositivos disponibles
```powershell
flutter devices
```

Deberías ver:
- Chrome/Edge (para web)
- Windows (si estás en Windows)
- Emulador Android (si está instalado)

### Paso 4: Configurar Firebase (si usas Firestore)

Si usas Cloud Firestore, necesitas configurar Firebase:
```powershell
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase (sigue el asistente)
flutterfire configure
```

---

## 🚀 Ejecutar el Proyecto Completo

### 1️⃣ Iniciar el Backend API

#### Opción A: Desde Visual Studio
1. Abre `ACEXAPI.sln` con Visual Studio
2. Presiona **F5** o clic en **▶ Start**
3. Se abrirá Swagger automáticamente en el navegador

#### Opción B: Desde línea de comandos
```powershell
cd "g:\ProyectoFinalC#\ProyectoFinalDAM2\ACEXAPI"
dotnet run
```

La API estará disponible en:
- **HTTPS:** `https://localhost:7xxx`
- **HTTP:** `http://localhost:5xxx`
- **Swagger UI:** `https://localhost:7xxx/swagger`

> ⚠️ **Anota el puerto** que muestra la consola, lo necesitarás para Flutter.

### 2️⃣ Iniciar el Frontend Flutter

En otra terminal PowerShell:

#### Para Windows Desktop:
```powershell
cd "g:\ProyectoFinalC#\ProyectoFinalDAM2\proyecto_santi"
flutter run -d windows
```

#### Para Web (Chrome):
```powershell
flutter run -d chrome
```

#### Para Android (Emulador):
```powershell
flutter run
```

### 3️⃣ Configurar la URL de la API en Flutter

Busca el archivo de configuración de la API en Flutter (probablemente en `lib/services/` o `lib/config/`):

```dart
// Ejemplo: lib/services/api_service.dart
class ApiService {
  static const String baseUrl = 'https://localhost:7xxx/api'; // Cambia el puerto
  // ...
}
```

O si usas Dio con Retrofit:
```dart
const String baseUrl = 'https://localhost:7xxx';
```

---

## ✅ Verificación

### 1. Verificar Backend
Abre en tu navegador: `https://localhost:7xxx/swagger`

Deberías ver:
- ✅ Swagger UI con todos los endpoints
- ✅ Endpoints de Actividades, Profesores, Fotos, Auth, etc.

Prueba un endpoint simple:
```
GET /api/catalogos/departamentos
```

Debe devolver:
```json
[
  { "id": 1, "nombre": "Informática" },
  { "id": 2, "nombre": "Matemáticas" },
  { "id": 3, "nombre": "Lengua" }
]
```

### 2. Verificar Frontend
- ✅ La app Flutter debe compilar sin errores
- ✅ Debe mostrarse la pantalla de inicio
- ✅ No debe haber errores de conexión HTTP (si la API está corriendo)

### 3. Verificar Base de Datos
```powershell
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -d ACEXAPI -Q "SELECT COUNT(*) AS Total FROM Actividades"
```

---

## 🔍 Solución de Problemas

### ❌ Error: "No se puede conectar a SQL Server"

**Problema:** La conexión a la base de datos falla.

**Soluciones:**
1. Verificar que SQL Server esté corriendo:
   ```powershell
   # Ver servicios de SQL Server
   Get-Service | Where-Object {$_.DisplayName -like "*SQL*"}
   ```

2. Iniciar SQL Server si está detenido:
   ```powershell
   # Si usas Docker
   docker start sqlserver
   
   # Si es SQL Server local
   Start-Service MSSQLSERVER
   ```

3. Verificar firewall en puerto 1433

### ❌ Error: "dotnet: command not found"

**Solución:** Instalar .NET 8 SDK desde [aquí](https://dotnet.microsoft.com/download).

### ❌ Error: "flutter: command not found"

**Solución:**
1. Instalar Flutter desde [aquí](https://docs.flutter.dev/get-started/install/windows)
2. Añadir Flutter al PATH de Windows
3. Ejecutar `flutter doctor` para verificar

### ❌ Error de CORS en Flutter Web

**Problema:** Error "CORS policy" al llamar a la API.

**Solución:** Ya está configurado en `appsettings.json`, pero verifica que el puerto de Flutter esté en la lista:
```json
"Cors": {
  "AllowedOrigins": [
    "http://localhost:58080",  // Flutter web típicamente usa estos puertos
    "http://localhost:58081"
  ]
}
```

### ❌ Error: "Certificate error" en Flutter

**Problema:** Flutter no confía en el certificado HTTPS local.

**Soluciones:**
1. Usar HTTP en desarrollo (menos seguro):
   ```dart
   const String baseUrl = 'http://localhost:5xxx/api';
   ```

2. O deshabilitar validación SSL (solo desarrollo):
   ```dart
   // En tu configuración de Dio
   dio.httpClientAdapter = IOHttpClientAdapter(
     createHttpClient: () {
       final client = HttpClient();
       client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
       return client;
     },
   );
   ```

### ❌ Flutter no encuentra dependencias

**Solución:**
```powershell
flutter clean
flutter pub get
flutter pub upgrade
```

---

## 🎯 Resumen Rápido

### Comandos para arrancar TODO:

```powershell
# Terminal 1 - Backend API
cd "g:\ProyectoFinalC#\ProyectoFinalDAM2\ACEXAPI"
dotnet run

# Terminal 2 - Frontend Flutter
cd "g:\ProyectoFinalC#\ProyectoFinalDAM2\proyecto_santi"
flutter run -d chrome
```

### URLs importantes:
- 📡 **API Swagger:** `https://localhost:7xxx/swagger`
- 🌐 **Flutter Web:** `http://localhost:58080` (o el puerto que asigne)
- 🗄️ **SQL Server:** `127.0.0.1,1433`

---

## 📚 Documentación Adicional

- **INICIO_RAPIDO.md** - Guía rápida del backend
- **CONFIGURACION_COMPLETA.md** - Estado completo del sistema
- **Scripts/README_DatabaseSetup.md** - Configuración de BD
- **AUTENTICACION_CON_PASSWORD.md** - Sistema de autenticación

---

## 🆘 ¿Necesitas Ayuda?

1. Revisa los logs en la consola
2. Verifica que todos los servicios estén corriendo
3. Consulta la documentación específica en las carpetas del proyecto

**¡Ahora estás listo para desarrollar!** 🎉
