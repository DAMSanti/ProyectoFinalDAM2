# Proyecto
# 🎓 Proyecto Final DAM2 - Sistema de Gestión de Actividades Extraescolares

Sistema completo de gestión de actividades extraescolares compuesto por:
- 🌐 **Backend API RESTful** (.NET 8)
- 📱 **Aplicación Frontend** (Flutter)
- 🗄️ **Base de Datos** (SQL Server)

---

## 🚀 INICIO RÁPIDO

### Opción 1: Script Automático (Recomendado)
```powershell
# Ejecutar el script de inicio automático
.\iniciar-proyecto.ps1
```

### Opción 2: Manual

**Terminal 1 - Backend:**
```powershell
cd ACEXAPI
dotnet run
```

**Terminal 2 - Frontend:**
```powershell
cd proyecto_santi
flutter run -d chrome
```

---

## 📋 ¿Qué necesito instalar?

### Requisitos Obligatorios

1. **[.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)**
   ```powershell
   dotnet --version  # Verificar instalación
   ```

2. **[SQL Server 2019+](https://www.microsoft.com/sql-server/sql-server-downloads)** o SQL Server Express (Gratis)
   - Alternativamente: Docker con SQL Server

3. **[Flutter SDK](https://docs.flutter.dev/get-started/install/windows)**
   ```powershell
   flutter --version  # Verificar instalación
   ```

### Herramientas Recomendadas
- **Visual Studio 2022** o **VS Code** (para .NET)
- **Android Studio** (para Flutter - incluye emulador)

---

## 📚 Documentación Completa

Para instrucciones detalladas de instalación y configuración:
👉 **[GUIA_INSTALACION.md](GUIA_INSTALACION.md)**

### Documentación del Backend (ACEXAPI/)
- 📖 [README.md](ACEXAPI/README.md) - Documentación completa de la API
- ⚡ [INICIO_RAPIDO.md](ACEXAPI/INICIO_RAPIDO.md) - Guía rápida
- ⚙️ [CONFIGURACION_COMPLETA.md](ACEXAPI/CONFIGURACION_COMPLETA.md) - Estado del sistema
- 🔐 [AUTENTICACION_CON_PASSWORD.md](ACEXAPI/AUTENTICACION_CON_PASSWORD.md) - Sistema de auth

### Documentación de la Base de Datos (DB/)
- 🗄️ [README.md](DB/README.md) - Estructura de la BD
- 📜 Scripts SQL en `ACEXAPI/Scripts/`

---

## 🏗️ Estructura del Proyecto

```
ProyectoFinalDAM2/
├── ACEXAPI/                    # Backend .NET 8 API
│   ├── Controllers/            # Controladores REST
│   ├── Models/                 # Modelos de datos
│   ├── Services/               # Lógica de negocio
│   ├── Data/                   # DbContext
│   ├── DTOs/                   # Data Transfer Objects
│   ├── Scripts/                # Scripts SQL
│   └── appsettings.json        # Configuración
│
├── proyecto_santi/             # Frontend Flutter
│   ├── lib/                    # Código Dart
│   ├── assets/                 # Recursos (imágenes, etc.)
│   └── pubspec.yaml            # Dependencias
│
├── DB/                         # Scripts de Base de Datos
│   └── databaseExport.sql
│
├── iniciar-proyecto.ps1        # 🚀 Script de inicio automático
└── GUIA_INSTALACION.md         # 📖 Guía completa de instalación
```

---

## 🎯 Características Principales

### Backend API (.NET 8)
- ✅ RESTful API con ASP.NET Core
- ✅ Autenticación JWT
- ✅ Entity Framework Core
- ✅ Swagger/OpenAPI
- ✅ CORS configurado
- ✅ Validación con FluentValidation
- ✅ Subida de archivos/imágenes

### Frontend (Flutter)
- ✅ Aplicación multiplataforma (Android, iOS, Web, Windows)
- ✅ Gestión de estado con Provider
- ✅ HTTP Client con Dio
- ✅ Calendario de actividades
- ✅ Mapas integrados
- ✅ Selección de imágenes

### Base de Datos (SQL Server)
- ✅ 13 tablas relacionales
- ✅ Integridad referencial
- ✅ Datos de prueba incluidos
- ✅ Scripts de migración

---

## 🔧 Configuración

### Backend API

El archivo `ACEXAPI/appsettings.json` ya está configurado:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=127.0.0.1,1433;Database=ACEXAPI;User Id=sa;Password=Semicrol_10;..."
  },
  "Jwt": {
    "Key": "SuperSecretKeyForJWTTokenGeneration...",
    "Issuer": "ACEXAPI",
    "Audience": "ACEXAPIUsers"
  }
}
```

### Base de Datos

Ya está creada y configurada según la documentación. Si necesitas recrearla:

```powershell
sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -i "ACEXAPI\Scripts\CreateDatabase.sql"
```

---

## 📡 Endpoints de la API

Una vez iniciado el backend, accede a:
- **Swagger UI:** `https://localhost:7xxx/swagger`

### Principales Endpoints:
- `POST /api/auth/login` - Iniciar sesión
- `GET /api/actividad` - Listar actividades
- `POST /api/actividad` - Crear actividad
- `GET /api/profesor` - Listar profesores
- `POST /api/foto/upload` - Subir fotos

---

## 🐛 Solución de Problemas

### Error: "No se puede conectar a SQL Server"
```powershell
# Verificar que SQL Server esté corriendo
Get-Service | Where-Object {$_.DisplayName -like "*SQL*"}

# Si usas Docker
docker start sqlserver
```

### Error: "dotnet: command not found"
Instalar [.NET 8 SDK](https://dotnet.microsoft.com/download)

### Error: "flutter: command not found"
Instalar [Flutter](https://docs.flutter.dev/get-started/install/windows) y añadir al PATH

### Más soluciones
Ver **[GUIA_INSTALACION.md](GUIA_INSTALACION.md)** sección "Solución de Problemas"

---

## 👥 Autores

- Miguel Ángel Calderon
- José David Casas
- Ángel García
- Victor Guardo

---

## 📄 Licencia

Este proyecto está bajo la licencia MIT.

---

## 🆘 ¿Necesitas Ayuda?

1. 📖 Lee la [GUIA_INSTALACION.md](GUIA_INSTALACION.md)
2. 📚 Revisa la documentación en `ACEXAPI/`
3. 🔍 Verifica los logs de la aplicación
4. 💬 Contacta al equipo de desarrollo

---

**¡Listo para empezar!** 🎉

Ejecuta `.\iniciar-proyecto.ps1` y comienza a desarrollar.
