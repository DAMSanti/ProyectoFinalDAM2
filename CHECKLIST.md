# ✅ CHECKLIST DE VERIFICACIÓN - Proyecto Final DAM2

Usa este checklist para asegurarte de que todo está instalado y configurado correctamente.

---

## 📋 Antes de Empezar

### Instalaciones Requeridas

- [ ] **.NET 8 SDK** instalado
  ```powershell
  dotnet --version
  # Debe mostrar: 8.0.x o superior
  ```

- [ ] **Flutter SDK** instalado
  ```powershell
  flutter --version
  # Debe mostrar: Flutter 3.x o superior
  ```

- [ ] **SQL Server** instalado y corriendo
  - [ ] SQL Server 2019+ o SQL Server Express
  - [ ] O Docker con SQL Server
  ```powershell
  # Verificar conexión
  sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -Q "SELECT @@VERSION"
  ```

### Herramientas Opcionales (Recomendadas)

- [ ] **Visual Studio 2022** o **VS Code**
- [ ] **SQL Server Management Studio (SSMS)**
- [ ] **Android Studio** (para emulador Android)
- [ ] **Git** para control de versiones

---

## 🔧 Configuración del Backend

### Verificar Proyecto .NET

- [ ] Navegar a la carpeta ACEXAPI
  ```powershell
  cd "g:\ProyectoFinalC#\ProyectoFinalDAM2\ACEXAPI"
  ```

- [ ] Restaurar paquetes NuGet
  ```powershell
  dotnet restore
  ```
  ✅ Resultado esperado: "Restore succeeded"

- [ ] Compilar el proyecto
  ```powershell
  dotnet build
  ```
  ✅ Resultado esperado: "Build succeeded. 0 Warning(s). 0 Error(s)"

### Verificar Configuración

- [ ] Archivo `appsettings.json` existe
- [ ] Connection string está configurado:
  ```json
  "DefaultConnection": "Server=127.0.0.1,1433;Database=ACEXAPI;..."
  ```
- [ ] JWT Key está configurado (mínimo 32 caracteres)
- [ ] CORS está configurado para los puertos de Flutter

---

## 🗄️ Configuración de Base de Datos

### Verificar SQL Server

- [ ] SQL Server está corriendo
  ```powershell
  Get-Service | Where-Object {$_.DisplayName -like "*SQL*"}
  ```
  ✅ Status debe ser "Running"

- [ ] Conexión funciona
  ```powershell
  sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -Q "SELECT 1"
  ```
  ✅ Debe devolver: "(1 rows affected)"

### Verificar Base de Datos ACEXAPI

- [ ] Base de datos existe
  ```powershell
  sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -Q "SELECT name FROM sys.databases WHERE name = 'ACEXAPI'"
  ```
  ✅ Debe mostrar: "ACEXAPI"

- [ ] Tablas creadas (13 tablas)
  ```powershell
  sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -d ACEXAPI -Q "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'"
  ```
  ✅ Debe mostrar: "13"

- [ ] Datos iniciales existen
  ```powershell
  # Verificar departamentos
  sqlcmd -S "127.0.0.1,1433" -U sa -P "Semicrol_10" -d ACEXAPI -Q "SELECT COUNT(*) FROM Departamentos"
  ```
  ✅ Debe mostrar: "3" (Informática, Matemáticas, Lengua)

---

## 📱 Configuración del Frontend

### Verificar Proyecto Flutter

- [ ] Navegar a la carpeta proyecto_santi
  ```powershell
  cd "g:\ProyectoFinalC#\ProyectoFinalDAM2\proyecto_santi"
  ```

- [ ] Obtener dependencias
  ```powershell
  flutter pub get
  ```
  ✅ Resultado esperado: "Got dependencies!"

- [ ] Verificar que no hay errores
  ```powershell
  flutter analyze
  ```
  ✅ Resultado esperado: "No issues found!"

### Verificar Dispositivos Disponibles

- [ ] Listar dispositivos
  ```powershell
  flutter devices
  ```
  ✅ Debe mostrar al menos uno de:
  - Chrome (web)
  - Windows (desktop)
  - Emulador Android
  - Dispositivo físico

---

## 🚀 Prueba de Ejecución

### Probar Backend API

- [ ] Iniciar la API
  ```powershell
  cd "g:\ProyectoFinalC#\ProyectoFinalDAM2\ACEXAPI"
  dotnet run
  ```

- [ ] Swagger UI se abre automáticamente
  - URL: `https://localhost:7xxx/swagger`
  - ✅ Debe mostrar la documentación de la API

- [ ] Probar endpoint de prueba
  - En Swagger, probar: `GET /api/catalogos/departamentos`
  - ✅ Debe devolver 3 departamentos

- [ ] API responde sin errores
  - ✅ No hay excepciones en la consola
  - ✅ Swagger UI es completamente navegable

### Probar Frontend Flutter

- [ ] Iniciar Flutter (en otra terminal)
  ```powershell
  cd "g:\ProyectoFinalC#\ProyectoFinalDAM2\proyecto_santi"
  flutter run -d chrome
  ```

- [ ] La aplicación compila sin errores
  - ✅ No hay errores de compilación
  - ✅ La app se abre en el navegador/emulador

- [ ] La UI se muestra correctamente
  - ✅ Pantalla de inicio visible
  - ✅ No hay errores de widgets

### Verificar Comunicación Backend-Frontend

- [ ] Configurar URL de API en Flutter
  - Buscar archivo de configuración (ej: `lib/services/api_service.dart`)
  - Verificar que apunta al puerto correcto del backend

- [ ] Probar una petición desde Flutter
  - ✅ Flutter puede conectarse a la API
  - ✅ No hay errores de CORS
  - ✅ No hay errores de certificado SSL

---

## 🎯 Checklist Final

### Todo Funcionando ✅

- [ ] ✅ Backend API corriendo sin errores
- [ ] ✅ Frontend Flutter corriendo sin errores
- [ ] ✅ SQL Server conectado y respondiendo
- [ ] ✅ Base de datos con datos de prueba
- [ ] ✅ Swagger UI accesible
- [ ] ✅ Flutter puede hacer peticiones a la API
- [ ] ✅ No hay errores de CORS
- [ ] ✅ No hay errores de autenticación

---

## 🐛 Si Algo No Funciona...

### Backend no compila
```powershell
# Limpiar y reconstruir
dotnet clean
dotnet restore
dotnet build
```

### Flutter no compila
```powershell
# Limpiar y reconstruir
flutter clean
flutter pub get
flutter pub upgrade
```

### SQL Server no conecta
```powershell
# Si usas Docker
docker start sqlserver
docker ps  # Verificar que está corriendo

# Si es servicio Windows
Start-Service MSSQLSERVER
```

### Error de CORS
- Verificar que el puerto de Flutter está en `appsettings.json` > `Cors.AllowedOrigins`
- Reiniciar el backend después de cambiar la configuración

### Error de certificado SSL en Flutter
- Usar HTTP en lugar de HTTPS en desarrollo
- O configurar Dio para aceptar certificados auto-firmados

---

## 📚 Recursos Útiles

- **[GUIA_INSTALACION.md](GUIA_INSTALACION.md)** - Guía completa de instalación
- **[ACEXAPI/README.md](ACEXAPI/README.md)** - Documentación de la API
- **[ACEXAPI/INICIO_RAPIDO.md](ACEXAPI/INICIO_RAPIDO.md)** - Guía rápida del backend

---

## ✅ ¡Todo Listo!

Si has marcado todas las casillas, tu proyecto está **100% listo** para desarrollar.

**Siguiente paso:** Ejecuta `.\iniciar-proyecto.ps1` y comienza a codificar! 🎉
