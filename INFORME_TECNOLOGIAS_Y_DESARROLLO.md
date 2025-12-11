# INFORME TÉCNICO: TECNOLOGÍAS Y ASPECTOS DE DESARROLLO
## Sistema ACEX - Gestión de Actividades Complementarias y Extraescolares

---

## 1. ENTORNOS DE DESARROLLO (IDEs)

El proyecto ha sido desarrollado utilizando múltiples entornos de desarrollo especializados según la tecnología:

### **Visual Studio Code**
- **Versión**: Última estable
- **Uso principal**: Desarrollo del backend ASP.NET Core y frontend Flutter
- **Extensiones clave**:
  - C# Dev Kit para desarrollo .NET
  - Flutter y Dart para desarrollo móvil/multiplataforma
  - REST Client para testing de endpoints
  - GitLens para control de versiones
  - Database Client para gestión SQL Server

### **Visual Studio 2022 Community** (Opcional)
- **Uso**: Desarrollo avanzado del backend .NET, debugging complejo
- **Características utilizadas**: SQL Server Management Tools integrado, perfilado de rendimiento

El uso de VS Code como IDE principal demuestra una elección moderna y eficiente, compatible con desarrollo multiplataforma y altamente extensible.

---

## 2. PLATAFORMAS DE IMPLEMENTACIÓN Y DESPLIEGUE

### **2.1 Servidor de Producción**

**DigitalOcean Droplet**
- **Sistema Operativo**: Ubuntu 22.04 LTS (Linux)
- **Especificaciones**: Servidor VPS con IP pública (64.226.85.100)
- **Componentes instalados**:
  - .NET 8.0 Runtime y SDK
  - SQL Server 2019 for Linux (Developer Edition)
  - Nginx como reverse proxy
  - Systemd para gestión de servicios

**Características del despliegue**:
```bash
# Servicio systemd configurado
/etc/systemd/system/acexapi.service
- Autostart en boot
- Restart automático en caso de fallo
- Logging centralizado con journalctl
```

**Nginx como Reverse Proxy**:
- Redirección HTTP → API .NET en puerto 5000
- Configuración de headers (X-Forwarded-For, Host)
- Preparado para futuro certificado SSL/HTTPS

### **2.2 Base de Datos**

**Microsoft SQL Server**
- **Versión**: SQL Server 2019 (Linux)
- **Configuración**:
  - Puerto: 1433 (acceso remoto habilitado)
  - Autenticación SQL Server (usuario SA)
  - Encriptación TLS habilitada
  - Multiple Active Result Sets (MARS) activado
- **Gestión**:
  - Backups regulares en formato .bak
  - Scripts de migración versionados en carpeta `/DB`
  - Sistema de migraciones con Entity Framework Core

### **2.3 Servicios en la Nube**

**Firebase (Google Cloud Platform)**
- **Firebase Cloud Firestore**: Base de datos NoSQL en tiempo real para chat
- **Firebase Cloud Messaging (FCM)**: Notificaciones push multiplataforma
- **Firebase Storage**: Almacenamiento de archivos multimedia del chat (imágenes, videos, audios)
- **Firebase Authentication**: Sincronización de usuarios entre .NET y Firebase

**Azure Blob Storage** (Configurado pero no en uso actualmente)
- Sistema de almacenamiento alternativo para archivos
- Implementación mediante patrón Strategy (intercambiable con almacenamiento local)

### **2.4 Sistema de Archivos Local**

**wwwroot/uploads/** (Almacenamiento actual)
- Folletos PDF de actividades
- Imágenes de actividades (con thumbnails automáticos)
- Fotos de profesores
- Archivos multimedia del chat (`wwwroot/chat_media/`)

---

## 3. LENGUAJES DE PROGRAMACIÓN

### **3.1 Backend: C#**
- **Versión**: C# 11 (con .NET 8.0)
- **Paradigma**: Orientado a objetos, programación asíncrona moderna
- **Características utilizadas**:
  - Nullable reference types habilitado (`<Nullable>enable</Nullable>`)
  - Implicit usings para reducir boilerplate
  - Pattern matching
  - Records para DTOs inmutables (donde aplica)
  - Async/await para operaciones I/O
  - LINQ para consultas a base de datos

**Ejemplo de código significativo - Manejo asíncrono**:
```csharp
public async Task<ActividadDto?> GetByIdAsync(int id)
{
    var actividad = await _context.Actividades
        .Include(a => a.Responsable)
        .Include(a => a.Alojamiento)
        .Include(a => a.Localizacion)
        .FirstOrDefaultAsync(a => a.Id == id);
    
    return actividad == null ? null : MapToDto(actividad);
}
```

### **3.2 Frontend: Dart**
- **Versión**: Dart 3.6.1
- **Paradigma**: Orientado a objetos con soporte funcional
- **Características utilizadas**:
  - Null safety completo
  - Async/await para operaciones asíncronas
  - Extension methods
  - Mixins para reutilización de código
  - Programación reactiva con Streams

### **3.3 Scripting: PowerShell**
- **Uso**: Scripts de automatización (generación de hashes BCrypt, despliegue, migraciones)
- **Ejemplos**: `generate_bcrypt_hash.ps1`, `execute_migration_remote.ps1`

### **3.4 SQL (T-SQL)**
- **Uso**: Scripts de migración, procedimientos almacenados, mantenimiento de BD
- **Archivos**: Todos los scripts en carpeta `/DB` (más de 30 archivos)

---

## 4. FRAMEWORKS Y LIBRERÍAS

### **4.1 Backend (.NET)**

**Framework Principal: ASP.NET Core 8.0**
- Web API RESTful moderna
- Inyección de dependencias nativa
- Middleware pipeline configurable
- Soporte multiplataforma (Windows, Linux, macOS)

**Librerías NuGet clave**:

| Librería | Versión | Propósito |
|----------|---------|-----------|
| `Microsoft.EntityFrameworkCore.SqlServer` | 8.0.0 | ORM para acceso a datos |
| `Microsoft.AspNetCore.Authentication.JwtBearer` | 8.0.0 | Autenticación JWT |
| `FluentValidation.AspNetCore` | 11.3.0 | Validación de modelos |
| `BCrypt.Net-Next` | 4.0.3 | Hashing seguro de contraseñas |
| `FirebaseAdmin` | 3.4.0 | Integración con Firebase |
| `Azure.Storage.Blobs` | 12.19.1 | Almacenamiento en la nube |
| `SixLabors.ImageSharp` | 3.1.6 | Procesamiento de imágenes |
| `Swashbuckle.AspNetCore` | 6.6.2 | Documentación Swagger/OpenAPI |
| `Microsoft.Extensions.Caching.Memory` | 8.0.1 | Sistema de caché en memoria |

**Código significativo - Configuración JWT**:
```csharp
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ValidateIssuer = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidateAudience = true,
        ValidAudience = builder.Configuration["Jwt:Audience"],
        ValidateLifetime = true,
        ClockSkew = TimeSpan.Zero
    };
});
```

### **4.2 Frontend (Flutter)**

**Framework Principal: Flutter SDK 3.6.x**
- UI multiplataforma (Android, iOS, Web, Windows, Linux, macOS)
- Hot reload para desarrollo ágil
- Material Design 3 y Cupertino (iOS)

**Librerías Dart/Flutter clave**:

| Librería | Versión | Propósito |
|----------|---------|-----------|
| `provider` | 6.0.0 | Gestión de estado |
| `dio` | 5.8.0 | Cliente HTTP avanzado |
| `flutter_secure_storage` | 9.2.4 | Almacenamiento seguro de credenciales |
| `firebase_core` | 3.11.0 | Integración Firebase |
| `firebase_messaging` | 15.1.8 | Notificaciones push |
| `cloud_firestore` | 5.6.3 | Base de datos NoSQL en tiempo real |
| `firebase_storage` | 12.3.9 | Almacenamiento de archivos |
| `google_maps_flutter` | 2.10.0 | Mapas interactivos |
| `flutter_map` | 5.0.0 | Mapas alternativos (OpenStreetMap) |
| `table_calendar` | 3.1.3 | Calendario interactivo |
| `syncfusion_flutter_calendar` | 28.1.38 | Calendario avanzado |
| `syncfusion_flutter_pdfviewer` | 28.1.38 | Visor de PDF |
| `fl_chart` | 0.69.0 | Gráficos estadísticos |
| `image_picker` | 1.1.2 | Captura de imágenes |
| `file_picker` | 8.1.6 | Selección de archivos |
| `video_player` / `chewie` | 2.9.2 / 1.8.5 | Reproducción de video |
| `audioplayers` | 6.1.0 | Reproducción de audio |
| `record` | 6.1.2 | Grabación de audio |
| `cached_network_image` | 3.4.1 | Caché de imágenes |
| `photo_view` | 0.15.0 | Visor de imágenes zoom |
| `emoji_picker_flutter` | 3.1.0 | Selector de emojis |
| `flutter_linkify` | 6.0.0 | Detección de enlaces |
| `timeago` | 3.7.0 | Fechas relativas |
| `intl` | 0.19.0 | Internacionalización |
| `flutter_screenutil` | 5.0.0 | Diseño responsivo |

---

## 5. BASE DE DATOS

### **5.1 Diseño Relacional**

**SQL Server 2019** con modelo normalizado (3FN - Tercera Forma Normal)

**Tablas principales** (18 tablas):
- `Actividades`: Entidad central del sistema
- `Profesores`: Usuarios docentes
- `Usuarios`: Credenciales de acceso
- `Departamentos`: Departamentos académicos
- `Cursos`, `Grupos`: Estructura educativa
- `Localizaciones`: Lugares de actividades
- `Alojamientos`: Hoteles/alojamientos
- `EmpTransportes`: Empresas de transporte
- `Fotos`: Galería de imágenes por actividad
- `Contratos`: Documentos legales
- `GrupoPartics`: Relación N:M Actividades-Grupos
- `ProfParticipantes`, `ProfResponsables`: Relaciones Actividades-Profesores
- `ActividadLocalizaciones`: Relación N:M Actividades-Localizaciones
- `GastosPersonalizados`: Gastos adicionales de actividades
- `FcmTokens`: Tokens de notificaciones push

**Relaciones clave**:
- 1:N → Departamento-Profesores, Actividad-Fotos, Actividad-Contratos
- N:M → Actividades-Grupos, Actividades-Localizaciones, Actividades-Profesores

### **5.2 Base de Datos NoSQL**

**Firebase Cloud Firestore**

**Colecciones**:
- `chats/`: Salas de chat por actividad
  - `messages/`: Mensajes del chat (tiempo real)
  - `typing/`: Indicadores de escritura
  - `presence/`: Estado online/offline
- `users/`: Datos de usuarios sincronizados

**Ventajas**:
- Sincronización en tiempo real (WebSocket)
- Escalabilidad automática
- Offline persistence
- Listeners reactivos

---

## 6. CONTROL DE VERSIONES

**Git + GitHub**

**Repositorio**: `DAMSanti/ProyectoFinalDAM2`
- **Rama principal**: `main`
- **Estrategia**: Feature branches con merge a main
- **Hosting**: GitHub (https://github.com/DAMSanti/ProyectoFinalDAM2)

**Gestión de código**:
- Commits descriptivos en español
- `.gitignore` configurado para .NET y Flutter
- Documentación README.md en múltiples carpetas
- Scripts de migración versionados

**Buenas prácticas observadas**:
- Separación de configuraciones (appsettings por entorno)
- Backups de base de datos versionados
- Documentación de cambios en archivos MIGRATION_README.md

---

## 7. PATRONES DE DISEÑO

### **7.1 Patrones Arquitectónicos**

**1. Repository Pattern (Implícito con Entity Framework)**
```csharp
public class ApplicationDbContext : DbContext
{
    public DbSet<Actividad> Actividades { get; set; }
    public DbSet<Profesor> Profesores { get; set; }
    // ... acceso encapsulado a datos
}
```

**2. Service Layer Pattern**
```csharp
public interface IActividadService
{
    Task<ActividadDto?> GetByIdAsync(int id);
    Task<ActividadDto> CreateAsync(ActividadCreateDto dto, IFormFile? folleto);
    // ... lógica de negocio separada de controladores
}
```

**3. Dependency Injection (DI)**
```csharp
// Program.cs
builder.Services.AddScoped<IActividadService, ActividadService>();
builder.Services.AddScoped<IJwtService, JwtService>();
builder.Services.AddScoped<IFileStorageService, LocalFileStorageService>();
```

**4. Strategy Pattern**
```csharp
// Intercambiable según configuración
if (builder.Configuration.GetValue<bool>("Azure:BlobStorage:Enabled"))
{
    builder.Services.AddScoped<IFileStorageService, AzureBlobStorageService>();
}
else
{
    builder.Services.AddScoped<IFileStorageService, LocalFileStorageService>();
}
```

### **7.2 Patrones Creacionales**

**Singleton Pattern**
- Usado para `BlobServiceClient`, `MemoryCache`
- Provider pattern en Flutter para estado global (Auth, Notificaciones)

### **7.3 Patrones Estructurales**

**DTO Pattern (Data Transfer Objects)**
```csharp
public class ActividadDto          // Lectura
public class ActividadCreateDto    // Creación
public class ActividadUpdateDto    // Actualización
```

**Middleware Pattern**
```csharp
app.UseErrorHandling();     // Middleware personalizado
app.UseAuthentication();    // Middleware framework
app.UseAuthorization();
app.UseCors("AllowFlutterApp");
```

**Facade Pattern**
- Servicios como `ActividadService` que encapsulan operaciones complejas de múltiples entidades

### **7.4 Patrones Comportamentales**

**Observer Pattern**
- Implementado con `Provider` en Flutter
- Listeners de Firestore para chat en tiempo real
- Notificaciones push con FCM

**Chain of Responsibility**
- Middleware pipeline de ASP.NET Core

---

## 8. ARQUITECTURA DEL SISTEMA

### **8.1 Arquitectura General**

**Arquitectura Cliente-Servidor de 3 Capas**

```
┌─────────────────────────────────────┐
│   CAPA DE PRESENTACIÓN              │
│   Flutter (Multi-plataforma)        │
│   - Android, iOS, Web, Desktop      │
└──────────────┬──────────────────────┘
               │ REST API (HTTPS/JSON)
               │ WebSocket (Chat)
               ▼
┌─────────────────────────────────────┐
│   CAPA DE APLICACIÓN                │
│   ASP.NET Core 8.0 Web API          │
│   - Controllers                     │
│   - Services (Lógica de negocio)    │
│   - Middleware (Auth, CORS, Error)  │
│   - DTOs, Validators                │
└──────────────┬──────────────────────┘
               │ EF Core ORM
               ▼
┌─────────────────────────────────────┐
│   CAPA DE DATOS                     │
│   - SQL Server (Datos relacionales) │
│   - Firebase Firestore (Chat)       │
│   - File System (Archivos)          │
└─────────────────────────────────────┘
```

### **8.2 Arquitectura del Backend (.NET)**

**Patrón: Clean Architecture / N-Layer Architecture**

```
Controllers/        → Endpoints HTTP (presentación)
    ├── ActividadController.cs
    ├── ProfesorController.cs
    ├── AuthController.cs
    └── ...
    
Services/           → Lógica de negocio
    ├── ActividadService.cs
    ├── JwtService.cs
    ├── PasswordService.cs
    └── FileStorageService.cs
    
Data/               → Acceso a datos
    └── ApplicationDbContext.cs
    
Models/             → Entidades de dominio
    ├── Actividad.cs
    ├── Profesor.cs
    └── ...
    
DTOs/               → Objetos de transferencia
    ├── ActividadDto.cs
    ├── ProfesorDto.cs
    └── ...
    
Validators/         → Validaciones
    ├── ActividadValidators.cs
    └── ProfesorValidators.cs
    
Middleware/         → Componentes transversales
    └── ErrorHandlingMiddleware.cs
```

**Flujo de una petición**:
1. Cliente → HTTP Request
2. Middleware (CORS, Auth) → Validación
3. Controller → Recibe request
4. Validator (FluentValidation) → Valida datos
5. Service → Ejecuta lógica de negocio
6. Repository/DbContext → Acceso a BD
7. Service → Mapea entidad a DTO
8. Controller → HTTP Response (JSON)

### **8.3 Arquitectura del Frontend (Flutter)**

**Patrón: MVVM + Service Layer + Provider**

```
lib/
├── main.dart                      → Entry point
├── config.dart                    → Configuración global
├── models/                        → Modelos de datos
│   ├── actividad.dart
│   ├── profesor.dart
│   └── auth.dart (ChangeNotifier)
│
├── services/                      → Lógica de negocio
│   ├── api_service.dart          → Cliente HTTP base
│   ├── actividad_service.dart
│   ├── profesor_service.dart
│   ├── auth_service.dart
│   ├── notification_service.dart
│   └── chat/
│       ├── firebase_chat_service.dart
│       └── firebase_storage_service.dart
│
├── views/                         → Pantallas (UI)
│   ├── login/
│   ├── home/
│   ├── actividades/
│   ├── profesores/
│   └── chat/
│
├── widgets/                       → Componentes reutilizables
├── components/                    → Componentes complejos
└── tema/                          → Temas y estilos
```

**Gestión de Estado**: Provider pattern
```dart
ChangeNotifierProvider(
  create: (context) => Auth()..checkAuthStatus(),
  child: MyApp(),
)
```

### **8.4 Comunicación entre capas**

**REST API**:
- HTTP Methods: GET, POST, PUT, DELETE
- Content-Type: application/json, multipart/form-data
- Autenticación: Bearer Token (JWT)

**WebSocket** (Firebase):
- Chat en tiempo real
- Presencia de usuarios
- Notificaciones

---

## 9. CÓDIGO SIGNIFICATIVO

### **9.1 Sistema de Autenticación JWT**

```csharp
// Generación de token con claims
public string GenerateToken(string email, string role, Guid userId)
{
    var claims = new[]
    {
        new Claim(ClaimTypes.Email, email),
        new Claim(ClaimTypes.Role, role),
        new Claim(ClaimTypes.NameIdentifier, userId.ToString()),
        new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
    };

    var token = new JwtSecurityToken(
        issuer: _configuration["Jwt:Issuer"],
        audience: _configuration["Jwt:Audience"],
        claims: claims,
        expires: DateTime.UtcNow.AddHours(24),
        signingCredentials: credentials
    );

    return new JwtSecurityTokenHandler().WriteToken(token);
}
```

### **9.2 Middleware de Manejo de Errores Global**

```csharp
public async Task InvokeAsync(HttpContext context)
{
    try
    {
        await _next(context);
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Error no controlado: {Message}", ex.Message);
        await HandleExceptionAsync(context, ex);
    }
}

private static Task HandleExceptionAsync(HttpContext context, Exception exception)
{
    var code = exception switch
    {
        KeyNotFoundException => HttpStatusCode.NotFound,
        UnauthorizedAccessException => HttpStatusCode.Unauthorized,
        ArgumentException => HttpStatusCode.BadRequest,
        _ => HttpStatusCode.InternalServerError
    };
    
    context.Response.ContentType = "application/json";
    context.Response.StatusCode = (int)code;
    return context.Response.WriteAsync(JsonSerializer.Serialize(new { message = "..." }));
}
```

### **9.3 Validación con FluentValidation**

```csharp
public class ActividadCreateDtoValidator : AbstractValidator<ActividadCreateDto>
{
    public ActividadCreateDtoValidator()
    {
        RuleFor(x => x.Nombre)
            .NotEmpty().WithMessage("El nombre es requerido")
            .MaximumLength(200).WithMessage("El nombre no puede exceder 200 caracteres");

        RuleFor(x => x.FechaInicio)
            .NotEmpty().WithMessage("La fecha de inicio es requerida")
            .GreaterThanOrEqualTo(DateTime.Today.AddDays(-30))
            .WithMessage("La fecha de inicio no puede ser anterior a 30 días");

        RuleFor(x => x.FechaFin)
            .GreaterThanOrEqualTo(x => x.FechaInicio)
            .When(x => x.FechaFin.HasValue)
            .WithMessage("La fecha de fin debe ser posterior a la fecha de inicio");
    }
}
```

### **9.4 Procesamiento de Imágenes con Thumbnails**

```csharp
public async Task<(string url, string? thumbnailUrl, long size)> UploadImageAsync(
    IFormFile file, string containerName)
{
    // Optimizar imagen principal (máx 1920x1080, calidad 85%)
    using (var image = await Image.LoadAsync(file.OpenReadStream()))
    {
        if (image.Width > 1920 || image.Height > 1080)
        {
            image.Mutate(x => x.Resize(new ResizeOptions
            {
                Mode = ResizeMode.Max,
                Size = new Size(1920, 1080)
            }));
        }
        await image.SaveAsync(filePath, new JpegEncoder { Quality = 85 });
    }

    // Crear thumbnail (300x300, calidad 75%)
    using (var thumbnailImage = await Image.LoadAsync(file.OpenReadStream()))
    {
        thumbnailImage.Mutate(x => x.Resize(new ResizeOptions
        {
            Mode = ResizeMode.Max,
            Size = new Size(300, 300)
        }));
        await thumbnailImage.SaveAsync(thumbnailPath, new JpegEncoder { Quality = 75 });
    }
    
    return (url, thumbnailUrl, fileInfo.Length);
}
```

### **9.5 Model Binder Personalizado para Decimales**

```csharp
// Solución al problema de cultura regional en decimales (punto vs coma)
public class DecimalModelBinder : IModelBinder
{
    public Task BindModelAsync(ModelBindingContext bindingContext)
    {
        var valueProviderResult = bindingContext.ValueProvider.GetValue(bindingContext.ModelName);
        
        if (valueProviderResult == ValueProviderResult.None)
            return Task.CompletedTask;

        var value = valueProviderResult.FirstValue;

        if (string.IsNullOrEmpty(value))
            return Task.CompletedTask;

        // Usar SIEMPRE InvariantCulture (punto como separador decimal)
        if (decimal.TryParse(value, NumberStyles.Any, CultureInfo.InvariantCulture, out var decimalValue))
        {
            bindingContext.Result = ModelBindingResult.Success(decimalValue);
        }
        
        return Task.CompletedTask;
    }
}
```

### **9.6 Chat en Tiempo Real con Firebase (Flutter)**

```dart
class FirebaseChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Stream reactivo de mensajes
  Stream<List<ChatMessage>> getMessages(int actividadId) {
    return _firestore
        .collection('chats')
        .doc(actividadId.toString())
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }
  
  // Enviar mensaje
  Future<void> sendMessage(int actividadId, ChatMessage message) async {
    await _firestore
        .collection('chats')
        .doc(actividadId.toString())
        .collection('messages')
        .add(message.toMap());
  }
}
```

---

## 10. CONVENCIONES DE CODIFICACIÓN Y ESTÁNDARES

### **10.1 Backend (C# / .NET)**

**Nomenclatura**:
- **Clases**: PascalCase (`ActividadService`, `ProfesorController`)
- **Métodos**: PascalCase (`GetByIdAsync`, `CreateAsync`)
- **Propiedades**: PascalCase (`Nombre`, `FechaInicio`)
- **Variables locales**: camelCase (`actividad`, `profesor`)
- **Constantes**: PascalCase (`DefaultExpirationMinutes`)
- **Interfaces**: I + PascalCase (`IActividadService`, `IJwtService`)

**Estándares de código**:
- **Async suffix**: Todos los métodos asíncronos terminan en `Async`
- **Nullable reference types**: Habilitado (`string?` para valores opcionales)
- **Documentación XML**: Comentarios `///` en controladores
  ```csharp
  /// <summary>
  /// Obtiene una actividad por su ID
  /// </summary>
  ```
- **Inyección de dependencias**: Por constructor
- **Separación de concerns**: Controllers → Services → Data
- **DTOs**: Separados de entidades para proteger modelo de dominio

**Configuración**:
```xml
<PropertyGroup>
  <Nullable>enable</Nullable>
  <ImplicitUsings>enable</ImplicitUsings>
</PropertyGroup>
```

### **10.2 Frontend (Dart / Flutter)**

**Nomenclatura**:
- **Clases**: PascalCase (`ActividadService`, `LoginView`)
- **Archivos**: snake_case (`actividad_service.dart`, `login_view.dart`)
- **Métodos/Variables**: camelCase (`fetchActividades`, `isLoading`)
- **Constantes**: camelCase con const (`apiBaseUrl`, `connectionTimeout`)
- **Widgets privados**: _PascalCase (`_HomeState`)

**Estándares de código**:
- **Null safety**: Obligatorio (`String?`, `int?`)
- **Async/await**: Para operaciones asíncronas
- **Separación por features**: Carpetas por funcionalidad (views, services, models)
- **Comentarios**: En español para lógica compleja
  ```dart
  // ✅ NUEVO: Guardar token JWT
  ```

**Configuración**:
```yaml
environment:
  sdk: ^3.6.1  # Null safety obligatorio
```

### **10.3 Base de Datos**

**SQL**:
- **Tablas**: PascalCase (`Actividades`, `Profesores`)
- **Columnas**: PascalCase (`Id`, `FechaInicio`)
- **Constraints**: Descriptivos (`FK_Actividades_Profesores`)
- **Índices**: `IX_NombreTabla_NombreColumna`

**Convenciones Entity Framework**:
- Atributo `[Table("Actividades")]` para mapeo explícito
- Atributo `[Column("precio_transporte")]` para nombres snake_case en BD legacy
- Navigation properties en plural (`GruposParticipantes`, `Fotos`)

### **10.4 Documentación**

**README.md** en múltiples carpetas:
- `/DB/README.md`: Instrucciones de base de datos
- `/DB/MIGRATION_README.md`: Historial de migraciones
- `/deploy/README.md`: Guía de despliegue completa
- `/ACEXAPI/Scripts/README_DatabaseSetup.md`: Setup inicial

**Comentarios en código**:
- Español en backend y frontend
- Explicaciones de "por qué", no "qué"
- Comentarios de advertencia: `// IMPORTANTE:`, `// ⚠️ CUIDADO:`

---

## 11. OTROS ASPECTOS TECNOLÓGICOS

### **11.1 Seguridad**

**Autenticación y Autorización**:
- JWT (JSON Web Tokens) con expiración de 24 horas
- Hashing de contraseñas con BCrypt (factor 12)
- Roles: Administrador, Coordinador, Profesor
- Atributos `[Authorize(Roles = "...")]` en endpoints sensibles

**Protección de datos**:
- HTTPS/TLS en producción
- Secure Storage en Flutter para tokens
- SQL Injection protegido por Entity Framework (queries parametrizadas)
- XSS protegido por serialización JSON automática

**CORS configurado**:
```csharp
policy.WithOrigins(allowedOrigins)
      .AllowAnyMethod()
      .AllowAnyHeader()
      .AllowCredentials();
```

### **11.2 Performance**

**Caché en memoria**:
```csharp
builder.Services.AddMemoryCache();
builder.Services.AddResponseCaching();
```

**Eager Loading** para evitar N+1 queries:
```csharp
var actividad = await _context.Actividades
    .Include(a => a.Responsable)
    .Include(a => a.Alojamiento)
    .Include(a => a.Localizacion)
    .FirstOrDefaultAsync(a => a.Id == id);
```

**Paginación**:
```csharp
var actividades = await query
    .Skip((pageNumber - 1) * pageSize)
    .Take(pageSize)
    .ToListAsync();
```

**Optimización de imágenes**:
- Redimensionamiento automático (máx 1920x1080)
- Compresión JPEG (calidad 85%)
- Generación de thumbnails (300x300, calidad 75%)
- Caché de imágenes en Flutter (`cached_network_image`)

### **11.3 Logging y Monitoreo**

**ASP.NET Core Logging**:
```csharp
"Logging": {
  "LogLevel": {
    "Default": "Information",
    "Microsoft.AspNetCore": "Warning",
    "Microsoft.EntityFrameworkCore": "Information"
  }
}
```

**Systemd journaling** en producción:
```bash
sudo journalctl -u acexapi -f
```

### **11.4 Configuración Multi-Ambiente**

**Archivos de configuración**:
- `appsettings.json` (base)
- `appsettings.Development.json` (desarrollo local)
- `appsettings.Production.json` (servidor producción)
- `appsettings.Casa.json` (desarrollo remoto)
- `appsettings.Trabajo.json` (desarrollo trabajo)

**Detección automática de entorno**:
```csharp
var environment = builder.Environment.EnvironmentName;
// Development, Production, Casa, Trabajo
```

**Flutter**:
```dart
static const bool useProductionServer = true;
static String get apiBaseUrl {
  return useProductionServer ? productionUrl : localUrl;
}
```

### **11.5 Internacionalización**

**Backend**: UTF-8 configurado
```csharp
options.JsonSerializerOptions.Encoder = 
    System.Text.Encodings.Web.JavaScriptEncoder.UnsafeRelaxedJsonEscaping;
```

**Frontend**: Locale español
```dart
await initializeDateFormatting('es_ES', null);

MaterialApp(
  locale: Locale('es', 'ES'),
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
)
```

### **11.6 Testing y Calidad**

**Herramientas configuradas**:
- Swagger UI para testing manual de API
- FluentValidation para validación automática
- Flutter DevTools para debugging

**Estrategias de testing**:
- Testing manual con Swagger
- Testing de endpoints con archivos `.http`
- Hot reload en Flutter para testing de UI

### **11.7 DevOps y CI/CD**

**Deployment manual** (documentado):
1. Compilación: `dotnet publish -c Release`
2. Compresión: `Compress-Archive`
3. Transfer: `scp` al servidor
4. Extracción y reinicio: `systemctl restart acexapi`

**Scripts de automatización**:
- PowerShell para tareas Windows
- Bash para servidor Linux
- SQL scripts para migraciones de BD

---

## 12. CONCLUSIONES TÉCNICAS

El proyecto ACEX demuestra una arquitectura moderna y profesional que combina las mejores prácticas de desarrollo full-stack:

**Fortalezas técnicas**:
1. **Arquitectura limpia** con separación clara de responsabilidades (Controllers → Services → Data)
2. **Seguridad robusta** con JWT, BCrypt, y validaciones en múltiples capas
3. **Escalabilidad** mediante servicios stateless, caché, y base de datos optimizada
4. **Multiplataforma** real con Flutter (6 plataformas soportadas)
5. **Integración cloud** moderna con Firebase y preparación para Azure
6. **Documentación exhaustiva** con README.md, comentarios, y Swagger
7. **Configuración multi-ambiente** para desarrollo ágil
8. **Patrones de diseño** aplicados correctamente (Strategy, Service Layer, DTO, DI)

**Stack tecnológico maduro**:
- **.NET 8.0**: Framework empresarial estable y performante
- **Flutter 3.x**: Mejor framework para desarrollo multiplataforma
- **SQL Server**: Base de datos robusta y escalable
- **Firebase**: Servicios cloud de Google para features en tiempo real
- **Linux deployment**: Reducción de costos con tecnologías open source

Este informe documenta un sistema completo de gestión educativa con estándares profesionales, listo para entornos de producción y con capacidad de crecimiento futuro.

---

**Fecha del informe**: Noviembre 2025  
**Proyecto**: ACEX - Sistema de Gestión de Actividades Complementarias y Extraescolares  
**Tecnologías principales**: ASP.NET Core 8.0, Flutter 3.6, SQL Server 2019, Firebase  
**Palabras totales**: ~3,500 palabras
