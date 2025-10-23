# ACEX - Sistema de Gestión de Actividades Extraescolares

## 📱 Descripción

ACEX es una aplicación multiplataforma desarrollada en Flutter para la gestión de actividades extraescolares y complementarias en centros educativos. Permite a los profesores crear, visualizar y gestionar actividades, compartir fotos, comunicarse mediante chat y visualizar ubicaciones en mapas.

## 🚀 Características

- ✅ **Autenticación segura** de profesores
- 📅 **Gestión de actividades** (crear, editar, eliminar, visualizar)
- 📸 **Galería de fotos** por actividad
- 🗺️ **Visualización de ubicaciones** en mapa
- 💬 **Chat** integrado con Firebase
- 🎨 **Tema claro/oscuro**
- 📱 **Multiplataforma** (Web, Android, iOS, Windows, macOS, Linux)
- 🔐 **Almacenamiento seguro** de credenciales

## 🛠️ Tecnologías

### Frontend (Flutter)
- **Flutter SDK**: ^3.6.1
- **Dart**: ^3.9.2
- **Provider**: Gestión de estado
- **Dio**: Cliente HTTP
- **Firebase**: Chat y notificaciones
- **Google Maps**: Visualización de mapas
- **Flutter Secure Storage**: Almacenamiento seguro

### Backend (C# .NET 8.0 - ACEXAPI)
- **.NET 8.0**: Framework backend
- **ASP.NET Core**: Web API
- **Entity Framework Core**: ORM
- **SQL Server**: Base de datos
- **JWT Authentication**: Autenticación con tokens
- **Azure Blob Storage**: Almacenamiento de archivos (opcional)
- **FluentValidation**: Validación de datos
- **Swagger/OpenAPI**: Documentación de API

## 📋 Requisitos Previos

### Para desarrollo Flutter:
- Flutter SDK 3.6.1 o superior
- Dart 3.9.2 o superior
- VS Code o Android Studio
- Chrome (para desarrollo web)

### Para desarrollo Android:
- Android Studio con SDK
- JDK 11 o superior
- Android SDK Platform-Tools

### Para desarrollo Windows:
- Visual Studio 2019 o superior
- Desktop development with C++ workload
- Windows 10 SDK

### Para el backend (ACEXAPI):
- .NET 8.0 SDK o superior
- SQL Server 2022 (o SQL Server Express)
- Visual Studio 2022 o Visual Studio Code con extensión C#

## 🔧 Instalación

### 1. Clonar el repositorio
\`\`\`bash
git clone https://github.com/DAMSanti/ProyectoFinalDAM2.git
cd ProyectoFinalDAM2
\`\`\`

### 2. Configurar el backend (ACEXAPI - C# .NET)

```bash
cd ACEXAPI

# Editar appsettings.json con tus credenciales de SQL Server
# ConnectionStrings:DefaultConnection

# Ejecutar migraciones (si es necesario)
dotnet ef database update

# Compilar y ejecutar
dotnet run
```

La API estará disponible en: `http://localhost:5121`
Swagger UI en: `http://localhost:5121/swagger`

### 3. Configurar Flutter

\`\`\`bash
cd proyecto_santi

# Obtener dependencias
flutter pub get

# Ejecutar en Chrome
flutter run -d chrome

# Ejecutar en Windows
flutter run -d windows

# Ejecutar en Android (con emulador o dispositivo)
flutter run
\`\`\`

## 📁 Estructura del Proyecto

\`\`\`
proyecto_santi/
├── lib/
│   ├── components/          # Componentes reutilizables
│   │   ├── app_bar.dart
│   │   ├── marco_desktop.dart
│   │   └── menu.dart
│   ├── models/              # Modelos de datos
│   │   ├── actividad.dart
│   │   ├── auth.dart
│   │   ├── departamento.dart
│   │   ├── photo.dart
│   │   └── profesor.dart
│   ├── services/            # Servicios (API, etc.)
│   │   └── api_service.dart
│   ├── tema/                # Temas y estilos
│   │   ├── gradient_background.dart
│   │   └── theme.dart
│   ├── utils/               # Utilidades
│   │   ├── constants.dart
│   │   ├── date_formatter.dart
│   │   ├── dialog_utils.dart
│   │   └── validators.dart
│   ├── views/               # Vistas/Pantallas
│   │   ├── activities/
│   │   ├── activityDetail/
│   │   ├── chat/
│   │   ├── home/
│   │   ├── login/
│   │   └── map/
│   ├── config.dart          # Configuración de la app
│   ├── func.dart
│   └── main.dart            # Punto de entrada
├── assets/                  # Recursos (imágenes, etc.)
├── android/                 # Proyecto Android
├── ios/                     # Proyecto iOS
├── web/                     # Proyecto Web
├── windows/                 # Proyecto Windows
└── pubspec.yaml            # Dependencias
\`\`\`

## 🔑 Configuración

### API Base URL
Edita `lib/config.dart` para cambiar la URL de la API:

```dart
class AppConfig {
  // Para desarrollo local
  static const String apiBaseUrl = 'http://localhost:5121/api';
  static const String imagenesBaseUrl = 'http://localhost:5121/uploads';
  
  // Para producción o IP específica
  // static const String apiBaseUrl = 'http://TU_IP:5121/api';
  // static const String imagenesBaseUrl = 'http://TU_IP:5121/uploads';
}
```

### SQL Server
Edita `ACEXAPI/appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=127.0.0.1,1433;Database=ACEXAPI;User Id=sa;Password=TuPassword;..."
  },
  "Jwt": {
    "Key": "TuClaveSecretaMuyLargaYSegura...",
    "Issuer": "ACEXAPI",
    "Audience": "ACEXAPIUsers"
  }
}
```

### Firebase
Las credenciales de Firebase están en `lib/config.dart`. Para usar tu propio proyecto:

1. Crea un proyecto en [Firebase Console](https://console.firebase.google.com)
2. Actualiza las credenciales en `SecureStorageConfig.storeFirebaseConfig()`

## 🎯 Uso

### Autenticación
1. Abre la aplicación
2. Ingresa tu email
3. El sistema obtiene un JWT token de la API
4. Se verifica si eres profesor en la base de datos

### Gestión de Actividades
- **Ver actividades**: Pantalla principal muestra todas las actividades
- **Crear actividad**: Botón "+" en la barra inferior
- **Editar actividad**: Selecciona una actividad y edita los campos
- **Eliminar actividad**: Opción en el menú de la actividad

### Fotos
- Sube fotos desde la galería o cámara
- Las fotos se asocian a actividades específicas
- Se almacenan en el servidor

## 📡 API Endpoints (ACEXAPI C# .NET)

### Autenticación
- `POST /api/Auth/login` - Iniciar sesión y obtener JWT token

### Actividades
- `GET /api/Actividad` - Listar actividades (con paginación)
- `GET /api/Actividad/{id}` - Obtener una actividad
- `POST /api/Actividad` - Crear actividad (requiere JWT)
- `PUT /api/Actividad/{id}` - Actualizar actividad (requiere JWT)
- `DELETE /api/Actividad/{id}` - Eliminar actividad (requiere JWT)

### Profesores
- `GET /api/Profesor` - Listar profesores (requiere JWT)
- `GET /api/Profesor/{uuid}` - Obtener profesor por UUID
- `POST /api/Profesor` - Crear profesor (requiere JWT)
- `PUT /api/Profesor/{uuid}` - Actualizar profesor (requiere JWT)

### Fotos
- `GET /api/Foto` - Listar todas las fotos (requiere JWT)
- `GET /api/Foto/actividad/{id}` - Fotos de una actividad
- `POST /api/Foto/upload` - Subir fotos (requiere JWT, roles específicos)
- `DELETE /api/Foto/{id}` - Eliminar foto (requiere JWT)

### Catálogos
- `GET /api/Catalogos/departamentos` - Lista de departamentos
- `GET /api/Catalogos/cursos` - Lista de cursos
- `GET /api/Catalogos/grupos` - Lista de grupos

**Nota:** La mayoría de endpoints requieren autenticación JWT. Incluye el header:
```
Authorization: Bearer {tu_token_jwt}
```

## 🧪 Testing

\`\`\`bash
# Ejecutar tests
flutter test

# Análisis de código
flutter analyze

# Formatear código
flutter format .
\`\`\`

## 🎨 Personalización de Temas

Los temas están en `lib/tema/theme.dart`. Personaliza colores:

\`\`\`dart
// Tema claro
const Color colorFondoLight = Color.fromARGB(255, 213, 223, 235);
const Color colorTextoLight = Color.fromARGB(255, 108, 124, 136);

// Tema oscuro
const Color colorFondoDark = Color.fromARGB(255, 47, 67, 75);
const Color colorTextoDark = Color.fromARGB(255, 169, 231, 255);
\`\`\`

## 🐛 Solución de Problemas

### Error de conexión a la API
- Verifica que ACEXAPI esté ejecutándose (`dotnet run`)
- Comprueba la URL en `lib/config.dart` (debe ser `http://localhost:5121/api`)
- Verifica que el firewall permita la conexión
- Revisa los logs de la API en la consola

### Errores de autenticación (401 Unauthorized)
- Verifica que el JWT esté configurado correctamente en `appsettings.json`
- Asegúrate de que el token no haya expirado
- Revisa que el usuario esté en la base de datos SQL Server

### Errores de Firebase
- Verifica las credenciales en `config.dart`
- Comprueba que el proyecto de Firebase esté activo

### Problemas de build
\`\`\`bash
# Limpiar y reconstruir
flutter clean
flutter pub get
flutter run
\`\`\`

## 📝 Mejoras Implementadas

### ✅ Código Corregido
1. **Tipos corregidos**: `CardTheme` → `CardThemeData`, `DialogTheme` → `DialogThemeData`
2. **Imports limpiados**: Eliminados imports no utilizados
3. **Variables no usadas**: Eliminadas para código más limpio

### ✅ Nuevas Características
1. **ApiService mejorado**: 
   - Manejo de errores robusto
   - Interceptores para logging
   - Métodos CRUD completos
   - Excepciones personalizadas

2. **Configuración centralizada**:
   - `AppConfig` para URLs y configuración
   - `SecureStorageConfig` para almacenamiento seguro

3. **Utilidades**:
   - `Validators`: Validación de formularios
   - `DateFormatter`: Formateo de fechas
   - `DialogUtils`: Diálogos y mensajes
   - `AppConstants`: Constantes de la app

4. **Autenticación mejorada**:
   - Persistencia de sesión
   - Verificación automática al iniciar
   - Almacenamiento seguro de credenciales

## 👥 Contribuir

1. Fork el proyecto
2. Crea una rama (`git checkout -b feature/nueva-caracteristica`)
3. Commit tus cambios (`git commit -am 'Añade nueva característica'`)
4. Push a la rama (`git push origin feature/nueva-caracteristica`)
5. Crea un Pull Request

## 📄 Licencia

Este proyecto es parte de un Trabajo Final de DAM2.

## 👨‍💻 Autor

**DAMSanti**
- GitHub: [@DAMSanti](https://github.com/DAMSanti)

## 🙏 Agradecimientos

- Flutter Team por el excelente framework
- Comunidad de Flutter por los paquetes
- Profesores y compañeros por el apoyo

---

**¿Necesitas ayuda?** Abre un issue en GitHub o contacta al desarrollador.
