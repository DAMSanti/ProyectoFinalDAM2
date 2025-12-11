# 📋 ANÁLISIS EXHAUSTIVO DEL PROYECTO ACEX

## Sistema de Gestión de Actividades Complementarias y Extraescolares

---

## 📑 ÍNDICE

1. [Resumen Ejecutivo](#1-resumen-ejecutivo)
2. [Arquitectura del Sistema](#2-arquitectura-del-sistema)
3. [Backend - API REST (.NET 8)](#3-backend---api-rest-net-8)
4. [Frontend - Aplicación Flutter](#4-frontend---aplicación-flutter)
5. [Base de Datos - SQL Server](#5-base-de-datos---sql-server)
6. [Servicios Firebase](#6-servicios-firebase)
7. [Infraestructura y Despliegue](#7-infraestructura-y-despliegue)
8. [Seguridad](#8-seguridad)
9. [Patrones de Diseño](#9-patrones-de-diseño)
10. [Dependencias y Librerías](#10-dependencias-y-librerías)
11. [Funcionalidades Detalladas](#11-funcionalidades-detalladas)
12. [Estructura de Archivos](#12-estructura-de-archivos)

---

## 1. RESUMEN EJECUTIVO

### 1.1 Descripción General
**ACEX** (Actividades Complementarias y Extraescolares) es una aplicación completa para la gestión integral de actividades educativas en centros escolares. El sistema permite planificar, organizar, aprobar y dar seguimiento a excursiones, visitas culturales, actividades deportivas y otros eventos extraescolares.

### 1.2 Stack Tecnológico

| Componente | Tecnología | Versión |
|------------|------------|---------|
| **Backend** | ASP.NET Core Web API | 8.0 |
| **Frontend** | Flutter/Dart | 3.6.1 |
| **Base de Datos** | SQL Server | 2019 |
| **Base de Datos Tiempo Real** | Firebase Firestore | Latest |
| **Almacenamiento** | Firebase Storage | Latest |
| **Notificaciones Push** | Firebase Cloud Messaging | Latest |
| **Servidor** | Ubuntu (DigitalOcean) | 22.04 LTS |
| **Proxy Inverso** | Nginx | Latest |

### 1.3 Plataformas Soportadas
- ✅ Windows (Desktop)
- ✅ Linux (Desktop)
- ✅ macOS (Desktop)
- ✅ Android (Móvil)
- ✅ iOS (Móvil)
- ✅ Web (PWA)

---

## 2. ARQUITECTURA DEL SISTEMA

### 2.1 Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                     CLIENTES FLUTTER                            │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌────────┐ │
│  │ Windows │  │  Linux  │  │  macOS  │  │ Android │  │  iOS   │ │
│  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘  └───┬────┘ │
└───────┼────────────┼────────────┼────────────┼───────────┼──────┘
        │            │            │            │           │
        └────────────┴─────┬──────┴────────────┴───────────┘
                           │
                    ┌──────▼──────┐
                    │    NGINX    │
                    │  (Reverse   │
                    │   Proxy)    │
                    └──────┬──────┘
                           │
        ┌──────────────────┴──────────────────┐
        │                                      │
┌───────▼───────┐                    ┌────────▼────────┐
│  ACEXAPI      │                    │    FIREBASE     │
│  (.NET 8.0)   │                    │                 │
│               │                    │  ┌───────────┐  │
│  • REST API   │                    │  │ Firestore │  │
│  • JWT Auth   │                    │  │  (Chat)   │  │
│  • EF Core    │                    │  └───────────┘  │
│               │                    │  ┌───────────┐  │
└───────┬───────┘                    │  │  Storage  │  │
        │                            │  │ (Media)   │  │
┌───────▼───────┐                    │  └───────────┘  │
│  SQL SERVER   │                    │  ┌───────────┐  │
│    2019       │                    │  │    FCM    │  │
│               │                    │  │  (Push)   │  │
│  18 Tablas    │                    │  └───────────┘  │
└───────────────┘                    └─────────────────┘
```

### 2.2 Patrón Arquitectónico
El proyecto implementa una **Arquitectura en 3 Capas (N-Tier)** con separación clara:

1. **Capa de Presentación**: Flutter (UI/UX)
2. **Capa de Lógica de Negocio**: ASP.NET Core (Services/Controllers)
3. **Capa de Datos**: SQL Server + Firebase

### 2.3 Comunicación Entre Capas

| Origen | Destino | Protocolo | Propósito |
|--------|---------|-----------|-----------|
| Flutter | .NET API | HTTPS/REST | CRUD operaciones |
| Flutter | Firestore | WebSocket | Chat tiempo real |
| Flutter | FCM | HTTPS | Notificaciones push |
| .NET API | SQL Server | TCP/TDS | Persistencia datos |
| .NET API | FCM | HTTPS | Envío notificaciones |

---

## 3. BACKEND - API REST (.NET 8)

### 3.1 Estructura del Proyecto

```
ACEXAPI/
├── Controllers/          # Endpoints REST (13 controladores)
│   ├── ActividadController.cs
│   ├── AlojamientoController.cs
│   ├── AuthController.cs
│   ├── CatalogosController.cs
│   ├── ChatController.cs
│   ├── ChatMediaController.cs
│   ├── ContratoController.cs
│   ├── DevController.cs
│   ├── FotoController.cs
│   ├── GastoPersonalizadoController.cs
│   ├── NotificationController.cs
│   ├── ProfesorController.cs
│   └── UsuariosController.cs
├── Services/             # Lógica de negocio (7 servicios)
│   ├── ActividadService.cs
│   ├── FileStorageService.cs
│   ├── JwtService.cs
│   ├── NotificationService.cs
│   ├── PasswordService.cs
│   └── INotificationService.cs
├── Models/               # Entidades del dominio (18 modelos)
│   ├── Actividad.cs
│   ├── ActividadLocalizacion.cs
│   ├── Alojamiento.cs
│   ├── Contrato.cs
│   ├── Curso.cs
│   ├── Departamento.cs
│   ├── EmpTransporte.cs
│   ├── EstadoActividad.cs
│   ├── FcmToken.cs
│   ├── Foto.cs
│   ├── GastoPersonalizado.cs
│   ├── Grupo.cs
│   ├── GrupoPartic.cs
│   ├── Localizacion.cs
│   ├── Profesor.cs
│   ├── ProfParticipante.cs
│   ├── ProfResponsable.cs
│   └── Usuario.cs
├── DTOs/                 # Objetos de transferencia (9 archivos)
│   ├── ActividadDto.cs
│   ├── AlojamientoDto.cs
│   ├── CatalogosDtos.cs
│   ├── CommonDto.cs
│   ├── ContratoDto.cs
│   ├── FotoDto.cs
│   ├── GastoPersonalizadoDto.cs
│   ├── NotificationDto.cs
│   └── ProfesorDto.cs
├── Data/                 # Contexto EF Core
│   └── ApplicationDbContext.cs
├── Middleware/           # Middleware personalizado
│   └── ErrorHandlingMiddleware.cs
├── ModelBinders/         # Binders personalizados
│   └── DecimalModelBinderProvider.cs
├── Validators/           # Validadores FluentValidation
│   ├── ActividadValidators.cs
│   └── ProfesorValidators.cs
├── Migrations/           # Migraciones EF Core
├── wwwroot/              # Archivos estáticos
├── Program.cs            # Punto de entrada
└── appsettings.*.json    # Configuraciones por entorno
```

### 3.2 Controladores Detallados

#### ActividadController (259 líneas)
Gestión completa del ciclo de vida de actividades.

| Endpoint | Método | Roles | Descripción |
|----------|--------|-------|-------------|
| `GET /api/actividad` | GET | Todos | Lista paginada con filtros |
| `GET /api/actividad/{id}` | GET | Todos | Detalle de actividad |
| `POST /api/actividad` | POST | Admin, Coord | Crear actividad |
| `PUT /api/actividad/{id}` | PUT | Admin, Coord | Actualizar actividad |
| `DELETE /api/actividad/{id}` | DELETE | Admin | Eliminar actividad |
| `GET /api/actividad/{id}/profesores-participantes` | GET | Todos | Listar profesores |
| `PUT /api/actividad/{id}/profesores-participantes` | PUT | Admin, Coord | Actualizar profesores |
| `GET /api/actividad/{id}/grupos-participantes` | GET | Todos | Listar grupos |
| `PUT /api/actividad/{id}/grupos-participantes` | PUT | Admin, Coord | Actualizar grupos |
| `POST /api/actividad/{id}/folleto` | POST | Admin, Coord | Subir folleto PDF |
| `DELETE /api/actividad/{id}/folleto` | DELETE | Admin, Coord | Eliminar folleto |
| `GET /api/actividad/{id}/localizaciones` | GET | Todos | Listar localizaciones |
| `POST /api/actividad/{id}/localizaciones/{locId}` | POST | Admin, Coord | Añadir localización |

#### AuthController (156 líneas)
Autenticación y gestión de sesiones.

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `POST /api/auth/login` | POST | Iniciar sesión (JWT) |
| `POST /api/auth/register` | POST | Registrar nuevo usuario |

#### ProfesorController
CRUD completo de profesores con soporte de fotos de perfil.

#### FotoController
Gestión de galería fotográfica con thumbnails automáticos.

#### NotificationController
Gestión de tokens FCM y envío de notificaciones push.

### 3.3 Servicios Principales

#### ActividadService (612 líneas)
```csharp
public interface IActividadService
{
    Task<PaginatedResult<ActividadListDto>> GetAllAsync(QueryParameters queryParams);
    Task<ActividadDto?> GetByIdAsync(int id);
    Task<ActividadDto> CreateAsync(ActividadCreateDto dto, IFormFile? folleto);
    Task<ActividadDto?> UpdateAsync(int id, ActividadUpdateDto dto, IFormFile? folleto);
    Task<bool> DeleteAsync(int id);
    Task<List<string>> GetProfesoresParticipantesAsync(int actividadId);
    Task<bool> UpdateProfesoresParticipantesAsync(int actividadId, List<string> profesoresIds);
    Task<List<GrupoParticipanteDto>> GetGruposParticipantesAsync(int actividadId);
    Task<bool> UpdateGruposParticipantesAsync(int actividadId, List<GrupoParticipanteUpdateDto> grupos);
    Task<string?> UpdateFolletoAsync(int actividadId, IFormFile folleto);
    Task<bool> DeleteFolletoAsync(int actividadId);
    Task<List<LocalizacionDto>> GetLocalizacionesAsync(int actividadId);
    Task<bool> AddLocalizacionAsync(...);
    Task<bool> RemoveLocalizacionAsync(...);
    Task<bool> UpdateLocalizacionAsync(...);
}
```

#### NotificationService (482 líneas)
Integración con Firebase Admin SDK para notificaciones push.
- Registro de tokens FCM por dispositivo
- Envío de notificaciones individuales y masivas
- Gestión de tópicos por actividad

#### JwtService
Generación y validación de tokens JWT con claims personalizados.

#### PasswordService
Hashing seguro de contraseñas con BCrypt.

### 3.4 Configuración y Middleware

#### Program.cs (273 líneas)
Configuraciones principales:

```csharp
// Autenticación JWT
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options => {
        options.TokenValidationParameters = new TokenValidationParameters {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(key),
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ClockSkew = TimeSpan.Zero
        };
    });

// CORS configurado por entorno
builder.Services.AddCors(options => {
    options.AddPolicy("AllowFlutterApp", policy => {
        if (builder.Environment.IsDevelopment()) {
            policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader();
        }
    });
});

// Entity Framework Core con SQL Server
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(dbConnectionString));

// Swagger con autenticación JWT
builder.Services.AddSwaggerGen(options => {
    options.AddSecurityDefinition("Bearer", ...);
});
```

### 3.5 Paquetes NuGet

| Paquete | Versión | Propósito |
|---------|---------|-----------|
| `Azure.Storage.Blobs` | 12.19.1 | Almacenamiento Azure (backup) |
| `BCrypt.Net-Next` | 4.0.3 | Hashing contraseñas |
| `FirebaseAdmin` | 3.4.0 | Firebase Admin SDK |
| `FluentValidation.AspNetCore` | 11.3.0 | Validación de modelos |
| `Microsoft.AspNetCore.Authentication.JwtBearer` | 8.0.0 | Autenticación JWT |
| `Microsoft.EntityFrameworkCore.SqlServer` | 8.0.0 | ORM SQL Server |
| `Microsoft.Extensions.Caching.Memory` | 8.0.1 | Caché en memoria |
| `SixLabors.ImageSharp` | 3.1.6 | Procesamiento imágenes |
| `Swashbuckle.AspNetCore` | 6.6.2 | Documentación Swagger |

---

## 4. FRONTEND - APLICACIÓN FLUTTER

### 4.1 Estructura del Proyecto

```
proyecto_santi/lib/
├── main.dart                 # Punto de entrada
├── config.dart               # Configuración API
├── firebase_options.dart     # Config Firebase autogenerada
├── func.dart                 # Funciones utilitarias
├── components/               # Componentes reutilizables
│   └── desktop_shell.dart    # Shell principal desktop
├── models/                   # Modelos de datos (14 archivos)
│   ├── actividad.dart
│   ├── alojamiento.dart
│   ├── auth.dart
│   ├── curso.dart
│   ├── departamento.dart
│   ├── empresa_transporte.dart
│   ├── gasto_personalizado.dart
│   ├── grupo.dart
│   ├── grupo_participante.dart
│   ├── localizacion.dart
│   ├── photo.dart
│   ├── profesor.dart
│   ├── usuario.dart
│   └── chat/                 # Modelos de chat
├── services/                 # Servicios (15 archivos)
│   ├── api_service.dart      # Cliente HTTP base
│   ├── actividad_service.dart
│   ├── auth_service.dart
│   ├── catalogo_service.dart
│   ├── gasto_personalizado_service.dart
│   ├── geocoding_service.dart
│   ├── holidays_service.dart
│   ├── lifecycle_manager.dart
│   ├── localizacion_service.dart
│   ├── notification_service.dart
│   ├── photo_service.dart
│   ├── profesor_service.dart
│   ├── usuario_service.dart
│   └── chat/                 # Servicios de chat
│       ├── backend_storage_service.dart
│       ├── firebase_chat_service.dart
│       ├── firebase_storage_service.dart
│       └── presence_service.dart
├── views/                    # Vistas (8 módulos)
│   ├── activities/           # Gestión actividades
│   ├── activityDetail/       # Detalle de actividad
│   ├── chat/                 # Sistema de chat
│   ├── estadisticas/         # Dashboard estadísticas
│   ├── gestion/              # Panel administración
│   ├── home/                 # Pantalla principal
│   ├── login/                # Autenticación
│   └── map/                  # Mapa interactivo
├── widgets/                  # Widgets personalizados
├── tema/                     # Temas claro/oscuro
│   └── theme.dart
├── shared/                   # Código compartido
└── utils/                    # Utilidades
```

### 4.2 Gestión de Estado

Se utiliza **Provider** como solución de gestión de estado:

```dart
// main.dart
runApp(
  ChangeNotifierProvider(
    create: (context) => Auth()..checkAuthStatus(),
    child: MyApp(),
  ),
);
```

### 4.3 Servicio API Base

```dart
class ApiService {
  late final Dio _dio;
  static String? _jwtToken;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectionTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Interceptor para JWT automático
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_jwtToken != null) {
          options.headers['Authorization'] = 'Bearer $_jwtToken';
        }
        return handler.next(options);
      },
    ));
  }

  // Métodos genéricos
  Future<Response> getData(String endpoint) async {...}
  Future<Response> postData(String endpoint, Map<String, dynamic> data) async {...}
  Future<Response> putData(String endpoint, Map<String, dynamic> data) async {...}
  Future<Response> deleteData(String endpoint) async {...}
}
```

### 4.4 Servicio de Chat Firebase

```dart
class FirebaseChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream de mensajes en tiempo real
  Stream<List<ChatMessage>> getMessagesStream(String actividadId, {int limit = 50}) {
    return _firestore
        .collection('actividades')
        .doc(actividadId)
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  /// Envío de mensajes multimedia
  Future<void> sendMediaMessage({
    required String actividadId,
    required String senderId,
    required String senderName,
    required MessageType type,
    required String mediaUrl,
    ...
  }) async {...}
}
```

### 4.5 Paquetes Dart/Flutter

| Paquete | Versión | Propósito |
|---------|---------|-----------|
| `provider` | 6.0.0 | Gestión de estado |
| `dio` | 5.8.0+1 | Cliente HTTP |
| `firebase_core` | 3.11.0 | Core Firebase |
| `cloud_firestore` | 5.6.3 | Base de datos tiempo real |
| `firebase_storage` | 12.3.9 | Almacenamiento archivos |
| `firebase_messaging` | 15.1.8 | Notificaciones push |
| `google_maps_flutter` | 2.10.0 | Mapas Google |
| `flutter_map` | 5.0.0 | Mapas OpenStreetMap |
| `flutter_secure_storage` | 9.2.4 | Almacenamiento seguro |
| `image_picker` | 1.1.2 | Selección imágenes |
| `video_player` | 2.9.2 | Reproducción video |
| `audioplayers` | 6.1.0 | Reproducción audio |
| `record` | 6.1.2 | Grabación audio |
| `syncfusion_flutter_calendar` | 28.1.38 | Calendario |
| `syncfusion_flutter_pdfviewer` | 28.1.38 | Visor PDF |
| `fl_chart` | 0.69.0 | Gráficos estadísticos |
| `cached_network_image` | 3.4.1 | Caché de imágenes |
| `emoji_picker_flutter` | 3.1.0 | Selector emojis |

### 4.6 Características por Plataforma

#### Desktop (Windows/Linux/macOS)
```dart
if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = WindowOptions(
    minimumSize: Size(1208, 720),
    title: 'ACEX'
  );
  windowManager.setAspectRatio(16 / 9);
}
```

#### Android
```dart
if (!kIsWeb && Platform.isAndroid) {
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [SystemUiOverlay.top],
  );
}
```

---

## 5. BASE DE DATOS - SQL SERVER

### 5.1 Diagrama Entidad-Relación

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│  DEPARTAMENTO   │1─────N│    PROFESOR     │1─────1│    USUARIO      │
├─────────────────┤       ├─────────────────┤       ├─────────────────┤
│ Id (PK)         │       │ Uuid (PK)       │       │ Id (PK)         │
│ Nombre          │       │ Dni             │       │ NombreUsuario   │
│ Descripcion     │       │ Nombre          │       │ Password        │
│ Codigo          │       │ Apellidos       │       │ Rol             │
└─────────────────┘       │ Correo          │       │ Activo          │
                          │ Telefono        │       │ ProfesorUuid(FK)│
                          │ FotoUrl         │       └─────────────────┘
                          │ DepartamentoId  │
                          └────────┬────────┘
                                   │
                          ┌────────┴────────┐
                          │                 │
              ┌───────────▼───┐    ┌────────▼────────┐
              │PROF_PARTICIPAN│    │ PROF_RESPONSABLE│
              │      TE       │    │                 │
              ├───────────────┤    ├─────────────────┤
              │ Id (PK)       │    │ Id (PK)         │
              │ ActividadId   │    │ ActividadId     │
              │ ProfesorUuid  │    │ ProfesorUuid    │
              │ FechaRegistro │    │ FechaAsignacion │
              └───────┬───────┘    └────────┬────────┘
                      │                     │
                      └──────────┬──────────┘
                                 │
                      ┌──────────▼──────────┐
                      │     ACTIVIDAD       │
                      ├─────────────────────┤
                      │ Id (PK)             │
                      │ Nombre              │
                      │ Descripcion         │
                      │ FechaInicio         │
                      │ FechaFin            │
                      │ Estado              │
                      │ Tipo                │
                      │ PresupuestoEstimado │
                      │ CostoReal           │
                      │ PrecioTransporte    │
                      │ PrecioAlojamiento   │
                      │ TransporteReq       │
                      │ AlojamientoReq      │
                      │ FolletoUrl          │
                      │ ResponsableId (FK)  │
                      │ LocalizacionId (FK) │
                      │ EmpTransporteId(FK) │
                      │ AlojamientoId (FK)  │
                      └──────────┬──────────┘
                                 │
       ┌─────────────────┬───────┼───────┬─────────────────┐
       │                 │       │       │                 │
┌──────▼──────┐  ┌───────▼─────┐ │ ┌─────▼─────┐  ┌────────▼────────┐
│    FOTO     │  │  CONTRATO   │ │ │GASTO_PERS.│  │ACTIVIDAD_LOCALIZ│
├─────────────┤  ├─────────────┤ │ ├───────────┤  ├─────────────────┤
│ Id (PK)     │  │ Id (PK)     │ │ │ Id (PK)   │  │ Id (PK)         │
│ Url         │  │ NombreProv. │ │ │ Concepto  │  │ ActividadId(FK) │
│ UrlThumbnail│  │ Descripcion │ │ │ Cantidad  │  │ LocalizacionId  │
│ Descripcion │  │ Monto       │ │ │ Fecha     │  │ EsPrincipal     │
│ FechaSubida │  │ FechaContra.│ │ │ Actividad │  │ Orden           │
│ TamanoBytes │  │ PresupUrl   │ │ └───────────┘  │ TipoLocalizacion│
│ ActividadId │  │ FacturaUrl  │ │                └─────────────────┘
└─────────────┘  │ ActividadId │ │                        │
                 └─────────────┘ │                        │
                                 │                ┌───────▼───────┐
                      ┌──────────▼──────────┐     │ LOCALIZACION  │
                      │    GRUPO_PARTIC     │     ├───────────────┤
                      ├─────────────────────┤     │ Id (PK)       │
                      │ Id (PK)             │     │ Nombre        │
                      │ NumeroParticipantes │     │ Direccion     │
                      │ ActividadId (FK)    │     │ Ciudad        │
                      │ GrupoId (FK)        │     │ Provincia     │
                      └──────────┬──────────┘     │ Latitud       │
                                 │                │ Longitud      │
                      ┌──────────▼──────────┐     └───────────────┘
                      │       GRUPO         │
                      ├─────────────────────┤
                      │ Id (PK)             │
                      │ Nombre              │
                      │ NumeroAlumnos       │
                      │ CursoId (FK)        │
                      └──────────┬──────────┘
                                 │
                      ┌──────────▼──────────┐
                      │       CURSO         │
                      ├─────────────────────┤
                      │ Id (PK)             │
                      │ Nombre              │
                      │ Nivel (ESO/BACH/FP) │
                      │ Activo              │
                      └─────────────────────┘
```

### 5.2 Tablas Completas (18 Tablas)

| Tabla | Descripción | Registros Est. |
|-------|-------------|----------------|
| `Actividades` | Actividades extraescolares | ~100-500 |
| `Profesores` | Personal docente | ~50-200 |
| `Usuarios` | Cuentas de acceso | ~50-200 |
| `Departamentos` | Departamentos académicos | ~10-20 |
| `Cursos` | Niveles educativos | ~10-30 |
| `Grupos` | Clases/grupos | ~50-100 |
| `Localizaciones` | Lugares de visita | ~50-200 |
| `ActividadLocalizaciones` | Relación N:M | Variable |
| `GrupoPartic` | Grupos participantes | Variable |
| `ProfParticipante` | Profesores participantes | Variable |
| `ProfResponsable` | Profesores responsables | Variable |
| `Fotos` | Galería fotográfica | ~500-5000 |
| `Contratos` | Contratos proveedores | ~50-200 |
| `GastosPersonalizados` | Gastos adicionales | Variable |
| `Alojamientos` | Hoteles/albergues | ~20-100 |
| `EmpTransportes` | Empresas transporte | ~10-50 |
| `FcmTokens` | Tokens notificaciones | Variable |

### 5.3 Tipos de Datos Especiales

```sql
-- Estados de Actividad
Estado NVARCHAR(20) -- 'Pendiente', 'Aprobada', 'Cancelada', 'Finalizada'

-- Tipos de Actividad
Tipo NVARCHAR(20) -- 'Complementaria', 'Extraescolar'

-- Niveles de Curso
Nivel NVARCHAR(10) -- 'ESO', 'BACH', 'FP'

-- Requerimientos (0=No, 1=Sí, 2=Por determinar)
TransporteReq INT
AlojamientoReq INT

-- Coordenadas geográficas
Latitud DECIMAL(10,8)
Longitud DECIMAL(11,8)
```

### 5.4 Índices y Restricciones

```csharp
// ApplicationDbContext.cs
modelBuilder.Entity<Profesor>()
    .HasIndex(p => p.Dni).IsUnique();

modelBuilder.Entity<Profesor>()
    .HasIndex(p => p.Correo).IsUnique();

modelBuilder.Entity<Usuario>()
    .HasIndex(u => u.NombreUsuario).IsUnique();

modelBuilder.Entity<ActividadLocalizacion>()
    .HasIndex(al => new { al.ActividadId, al.LocalizacionId }).IsUnique();
```

### 5.5 Relaciones y Cascadas

| Relación | Tipo | OnDelete |
|----------|------|----------|
| Departamento → Profesor | 1:N | SetNull |
| Profesor → Usuario | 1:1 | Cascade |
| Actividad → Fotos | 1:N | Cascade |
| Actividad → Contratos | 1:N | Cascade |
| Actividad → GrupoPartic | 1:N | Cascade |
| Actividad → ProfParticipante | 1:N | Cascade |
| Actividad → Localizaciones | N:M | Cascade |
| Curso → Grupos | 1:N | Cascade |

---

## 6. SERVICIOS FIREBASE

### 6.1 Firebase Firestore (Chat en Tiempo Real)

#### Estructura de Colecciones
```
actividades/
  └── {actividadId}/
      └── chats/
          └── {messageId}/
              ├── id: string
              ├── senderId: string
              ├── senderName: string
              ├── senderAvatar: string?
              ├── message: string
              ├── type: 'text'|'image'|'video'|'audio'|'file'
              ├── mediaUrl: string?
              ├── thumbnailUrl: string?
              ├── duration: number?
              ├── timestamp: Timestamp
              ├── replyToId: string?
              ├── isEdited: boolean
              └── isDeleted: boolean
```

### 6.2 Firebase Storage (Archivos Multimedia)

#### Estructura de Carpetas
```
chat_media/
  └── {actividadId}/
      ├── images/
      │   └── {uuid}.jpg
      ├── videos/
      │   └── {uuid}.mp4
      ├── audio/
      │   └── {uuid}.m4a
      └── files/
          └── {filename}
```

### 6.3 Firebase Cloud Messaging (Notificaciones Push)

#### Tipos de Notificaciones
- Nuevo mensaje de chat
- Cambio de estado de actividad
- Recordatorio de actividad próxima
- Asignación como participante/responsable

### 6.4 Reglas de Seguridad

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /actividades/{actividadId}/chats/{messageId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 7. INFRAESTRUCTURA Y DESPLIEGUE

### 7.1 Servidor de Producción

| Componente | Especificación |
|------------|----------------|
| Proveedor | DigitalOcean |
| Sistema Operativo | Ubuntu 22.04 LTS |
| vCPUs | 2 |
| RAM | 4 GB |
| Almacenamiento | 80 GB SSD |
| Transferencia | 4 TB/mes |

### 7.2 Configuración Nginx

```nginx
# nginx-config
server {
    listen 80;
    server_name api.acex.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### 7.3 Servicio Systemd

```ini
# acexapi.service
[Unit]
Description=ACEX API .NET Application
After=network.target

[Service]
WorkingDirectory=/var/www/acexapi
ExecStart=/usr/bin/dotnet /var/www/acexapi/ACEXAPI.dll
Restart=always
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=acexapi
User=www-data
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false

[Install]
WantedBy=multi-user.target
```

### 7.4 Scripts de Despliegue

| Script | Propósito |
|--------|-----------|
| `install_server.sh` | Instalación inicial del servidor |
| `deploy_api.sh` | Despliegue de la API |
| `quick_deploy.ps1` | Despliegue rápido desde Windows |
| `export_database.ps1` | Backup de base de datos |
| `restore_database.sh` | Restauración de base de datos |

---

## 8. SEGURIDAD

### 8.1 Autenticación JWT

```csharp
// Generación de token
public string GenerateToken(string username, string role, Guid userId)
{
    var claims = new[]
    {
        new Claim(ClaimTypes.Name, username),
        new Claim(ClaimTypes.Role, role),
        new Claim("UserId", userId.ToString())
    };

    var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_secretKey));
    var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

    var token = new JwtSecurityToken(
        issuer: _issuer,
        audience: _audience,
        claims: claims,
        expires: DateTime.UtcNow.AddHours(24),
        signingCredentials: creds
    );

    return new JwtSecurityTokenHandler().WriteToken(token);
}
```

### 8.2 Hashing de Contraseñas

```csharp
// BCrypt con salt automático
public string HashPassword(string password)
{
    return BCrypt.Net.BCrypt.HashPassword(password, BCrypt.Net.BCrypt.GenerateSalt(12));
}

public bool VerifyPassword(string password, string hash)
{
    return BCrypt.Net.BCrypt.Verify(password, hash);
}
```

### 8.3 Roles y Permisos

| Rol | Permisos |
|-----|----------|
| **Administrador** | Acceso total, CRUD completo, gestión usuarios |
| **Coordinador** | Crear/editar actividades, aprobar solicitudes |
| **Profesor** | Ver actividades, participar, chat |
| **Usuario** | Solo lectura (consultas básicas) |

### 8.4 Almacenamiento Seguro (Flutter)

```dart
// flutter_secure_storage para tokens
final storage = FlutterSecureStorage();
await storage.write(key: 'jwt_token', value: token);
String? token = await storage.read(key: 'jwt_token');
```

---

## 9. PATRONES DE DISEÑO

### 9.1 Repository Pattern (Implícito via EF Core)
Entity Framework Core actúa como capa de abstracción de datos.

### 9.2 Service Layer Pattern
```csharp
// Separación clara entre Controllers y lógica de negocio
public class ActividadController : ControllerBase
{
    private readonly IActividadService _actividadService;
    
    public async Task<ActionResult> GetAll([FromQuery] QueryParameters queryParams)
    {
        var result = await _actividadService.GetAllAsync(queryParams);
        return Ok(result);
    }
}
```

### 9.3 Dependency Injection
```csharp
// Program.cs - Registro de servicios
builder.Services.AddScoped<IActividadService, ActividadService>();
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddScoped<IJwtService, JwtService>();
```

### 9.4 DTO Pattern
Separación entre modelos de dominio y objetos de transferencia.

### 9.5 Observer Pattern (Flutter)
```dart
// Provider para notificación de cambios
class Auth extends ChangeNotifier {
  bool _isAuthenticated = false;
  
  void login(String token) {
    _isAuthenticated = true;
    notifyListeners(); // Notifica a todos los widgets suscritos
  }
}
```

### 9.6 Factory Pattern (Flutter)
```dart
// fromJson factories en modelos
factory Actividad.fromJson(Map<String, dynamic> json) {
    return Actividad(
        id: json['id'],
        titulo: json['nombre'] ?? '',
        ...
    );
}
```

### 9.7 Singleton Pattern
```dart
// ApiService con token compartido
class ApiService {
    static String? _jwtToken; // Token compartido entre instancias
}
```

### 9.8 Strategy Pattern (Middleware)
```csharp
// Diferentes estrategias de manejo de errores
public class ErrorHandlingMiddleware
{
    public async Task InvokeAsync(HttpContext context)
    {
        try {
            await _next(context);
        }
        catch (ValidationException ex) { /* Estrategia 400 */ }
        catch (NotFoundException ex) { /* Estrategia 404 */ }
        catch (Exception ex) { /* Estrategia 500 */ }
    }
}
```

---

## 10. DEPENDENCIAS Y LIBRERÍAS

### 10.1 Backend (.NET)

```xml
<ItemGroup>
  <!-- Almacenamiento -->
  <PackageReference Include="Azure.Storage.Blobs" Version="12.19.1" />
  
  <!-- Seguridad -->
  <PackageReference Include="BCrypt.Net-Next" Version="4.0.3" />
  <PackageReference Include="Microsoft.AspNetCore.Authentication.JwtBearer" Version="8.0.0" />
  
  <!-- Firebase -->
  <PackageReference Include="FirebaseAdmin" Version="3.4.0" />
  
  <!-- Validación -->
  <PackageReference Include="FluentValidation.AspNetCore" Version="11.3.0" />
  
  <!-- Base de datos -->
  <PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="8.0.0" />
  <PackageReference Include="Microsoft.EntityFrameworkCore.Design" Version="8.0.0" />
  
  <!-- Caché -->
  <PackageReference Include="Microsoft.Extensions.Caching.Memory" Version="8.0.1" />
  
  <!-- Procesamiento de imágenes -->
  <PackageReference Include="SixLabors.ImageSharp" Version="3.1.6" />
  
  <!-- Documentación API -->
  <PackageReference Include="Swashbuckle.AspNetCore" Version="6.6.2" />
</ItemGroup>
```

### 10.2 Frontend (Flutter)

```yaml
dependencies:
  # Estado
  provider: ^6.0.0
  
  # HTTP
  dio: ^5.8.0+1
  http: ^1.2.2
  retrofit: ^4.4.2
  
  # Firebase
  firebase_core: ^3.11.0
  cloud_firestore: ^5.6.3
  firebase_storage: ^12.3.9
  firebase_messaging: ^15.1.8
  firebase_auth: ^5.3.3
  firebase_database: ^11.2.1
  
  # Mapas
  google_maps_flutter: ^2.10.0
  flutter_map: ^5.0.0
  latlong2: ^0.9.0
  geocoding: ^3.0.0
  
  # UI/UX
  table_calendar: ^3.1.3
  syncfusion_flutter_calendar: ^28.1.38
  fl_chart: ^0.69.0
  font_awesome_flutter: ^10.1.0
  flutter_screenutil: ^5.0.0+2
  cached_network_image: ^3.4.1
  emoji_picker_flutter: ^3.1.0
  photo_view: ^0.15.0
  
  # Multimedia
  image_picker: ^1.1.2
  file_picker: ^8.1.6
  video_player: ^2.9.2
  chewie: ^1.8.5
  audioplayers: ^6.1.0
  record: ^6.1.2
  
  # PDF
  syncfusion_flutter_pdfviewer: ^28.1.38
  pdf: ^3.11.1
  printing: ^5.13.3
  
  # Almacenamiento
  flutter_secure_storage: ^9.2.4
  shared_preferences: ^2.3.3
  path_provider: ^2.1.5
  
  # Utilidades
  intl: 0.19.0
  uuid: ^4.5.1
  mime: ^2.0.0
  timeago: ^3.7.0
  flutter_linkify: ^6.0.0
  visibility_detector: ^0.4.0+2
  
  # Desktop
  window_manager: ^0.4.3
  
  # Notificaciones
  flutter_local_notifications: ^18.0.1
```

---

## 11. FUNCIONALIDADES DETALLADAS

### 11.1 Módulo de Actividades

| Funcionalidad | Descripción |
|---------------|-------------|
| Listado con paginación | Scroll infinito, búsqueda, filtros |
| Creación de actividad | Formulario completo con validación |
| Edición de actividad | Actualización de todos los campos |
| Gestión de participantes | Profesores y grupos |
| Múltiples localizaciones | Mapa interactivo |
| Galería de fotos | Subida, thumbnails, visualización |
| Documentos adjuntos | Folletos PDF |
| Estados y workflow | Pendiente → Aprobada → Finalizada |

### 11.2 Módulo de Chat

| Funcionalidad | Descripción |
|---------------|-------------|
| Mensajes de texto | Tiempo real con Firebase |
| Imágenes | Captura y galería |
| Videos | Grabación y selección |
| Audios | Grabación y reproducción |
| Archivos | Cualquier tipo de documento |
| Responder mensajes | Reply con referencia |
| Editar mensajes | Modificación con historial |
| Eliminar mensajes | Soft delete |
| Emojis | Selector completo |
| Scroll infinito | Carga de mensajes antiguos |

### 11.3 Módulo de Mapas

| Funcionalidad | Descripción |
|---------------|-------------|
| Visualización | OpenStreetMap / Google Maps |
| Marcadores | Localizaciones de actividad |
| Geocodificación | Búsqueda de direcciones |
| Rutas | Itinerario de visita |
| Múltiples puntos | Orden personalizable |

### 11.4 Módulo de Estadísticas

| Funcionalidad | Descripción |
|---------------|-------------|
| Dashboard | Métricas principales |
| Gráficos | fl_chart |
| Filtros temporales | Por período |
| Exportación | PDF y Excel |

### 11.5 Módulo de Gestión

| Funcionalidad | Descripción |
|---------------|-------------|
| Usuarios | CRUD completo |
| Profesores | Gestión de personal |
| Departamentos | Organización |
| Cursos y Grupos | Estructura académica |
| Catálogos | Alojamientos, transportes |

### 11.6 Notificaciones Push

| Evento | Destinatarios |
|--------|---------------|
| Nuevo mensaje | Participantes actividad |
| Cambio estado | Responsable y coordinadores |
| Recordatorio | Participantes próximos 24h |
| Asignación | Profesor asignado |

---

## 12. ESTRUCTURA DE ARCHIVOS

### 12.1 Resumen de Archivos

| Directorio | Archivos | Descripción |
|------------|----------|-------------|
| `/ACEXAPI/Controllers` | 13 | Endpoints REST |
| `/ACEXAPI/Services` | 7 | Lógica de negocio |
| `/ACEXAPI/Models` | 18 | Entidades |
| `/ACEXAPI/DTOs` | 9 | Transferencia datos |
| `/proyecto_santi/lib/views` | 8 módulos | Vistas UI |
| `/proyecto_santi/lib/services` | 15 | Servicios cliente |
| `/proyecto_santi/lib/models` | 14 | Modelos Dart |
| `/DB` | 50+ | Scripts SQL, migraciones |
| `/deploy` | 11 | Scripts despliegue |

### 12.2 Líneas de Código Estimadas

| Componente | LOC Estimado |
|------------|--------------|
| Backend C# | ~5,000 |
| Frontend Dart | ~15,000 |
| SQL Scripts | ~2,000 |
| Configuración | ~500 |
| **Total** | **~22,500** |

---

## 📊 MÉTRICAS DEL PROYECTO

| Métrica | Valor |
|---------|-------|
| **Controladores API** | 13 |
| **Endpoints REST** | ~50 |
| **Modelos de dominio** | 18 |
| **Tablas SQL** | 18 |
| **Servicios backend** | 7 |
| **Servicios frontend** | 15 |
| **Vistas Flutter** | 8 módulos |
| **Paquetes NuGet** | 11 |
| **Paquetes Dart** | 45+ |
| **Plataformas soportadas** | 6 |

---

*Documento generado automáticamente - ACEX Project Analysis*
*Última actualización: Diciembre 2025*
