# ACEX API - Gestión de Actividades Extraescolares

API RESTful desarrollada en .NET 8 para la gestión integral de actividades extraescolares en centros educativos.

## ?? Tabla de Contenidos

- [Características](#características)
- [Tecnologías](#tecnologías)
- [Requisitos](#requisitos)
- [Instalación](#instalación)
- [Configuración](#configuración)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Endpoints](#endpoints)
- [Autenticación y Autorización](#autenticación-y-autorización)
- [Almacenamiento de Archivos](#almacenamiento-de-archivos)
- [Despliegue](#despliegue)

## ? Características

- ? **Autenticación JWT** - Sistema seguro de autenticación basado en tokens
- ? **Autorización por roles** - Control de acceso granular (Administrador, Coordinador, Profesor, Usuario)
- ? **CRUD completo** - Gestión de actividades, profesores, departamentos, fotos, contratos
- ? **Subida de archivos** - Optimización automática de imágenes y almacenamiento configurable
- ? **Paginación y filtrado** - Endpoints optimizados con soporte para búsqueda y ordenamiento
- ? **Validación de datos** - FluentValidation para validación robusta
- ? **Documentación Swagger** - API completamente documentada con OpenAPI
- ? **CORS configurado** - Listo para aplicaciones Flutter/React/Angular
- ? **Caché en memoria** - Optimización de rendimiento
- ? **Almacenamiento flexible** - Soporte para Azure Blob Storage o almacenamiento local

## ?? Tecnologías

- **.NET 8** - Framework principal
- **Entity Framework Core 8** - ORM para acceso a datos
- **SQL Server** - Base de datos relacional
- **JWT Bearer** - Autenticación
- **FluentValidation** - Validación de modelos
- **SixLabors.ImageSharp** - Procesamiento de imágenes
- **Azure Blob Storage** - Almacenamiento en la nube (opcional)
- **Swagger/OpenAPI** - Documentación de API

## ?? Requisitos

- .NET 8 SDK
- SQL Server 2019+ o LocalDB
- Visual Studio 2022 / VS Code / Rider
- Azure Storage Account (opcional, para producción)

## ?? Instalación

1. **Clonar el repositorio**
```bash
git clone https://github.com/tu-usuario/acexapi.git
cd acexapi
```

2. **Restaurar paquetes**
```bash
dotnet restore
```

3. **Configurar la base de datos**

Editar `appsettings.json` con tu cadena de conexión:
```json
"ConnectionStrings": {
  "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=ACEXAPI;Trusted_Connection=true;MultipleActiveResultSets=true;TrustServerCertificate=True"
}
```

4. **Aplicar migraciones**
```bash
dotnet ef migrations add InitialCreate
dotnet ef database update
```

5. **Ejecutar la aplicación**
```bash
dotnet run
```

La API estará disponible en `https://localhost:7xxx` y Swagger en `https://localhost:7xxx`

## ? Configuración

### appsettings.json

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "tu-connection-string"
  },
  "Jwt": {
    "Key": "tu-clave-secreta-de-al-menos-32-caracteres",
    "Issuer": "ACEXAPI",
    "Audience": "ACEXAPIUsers"
  },
  "Azure": {
    "BlobStorage": {
      "ConnectionString": "tu-azure-storage-connection-string",
      "Enabled": false
    }
  },
  "Cors": {
    "AllowedOrigins": [
      "http://localhost:3000",
      "https://tu-dominio.com"
    ]
  }
}
```

### Variables de Entorno (Producción)

Configura las siguientes variables:
- `ConnectionStrings__DefaultConnection`
- `Jwt__Key`
- `Azure__BlobStorage__ConnectionString`
- `Azure__BlobStorage__Enabled`

## ?? Estructura del Proyecto

```
ACEXAPI/
??? Controllers/          # Controladores de la API
?   ??? ActividadController.cs
?   ??? ProfesorController.cs
?   ??? FotoController.cs
?   ??? AuthController.cs
??? Data/                # Contexto de base de datos
?   ??? ApplicationDbContext.cs
??? DTOs/                # Data Transfer Objects
?   ??? ActividadDto.cs
?   ??? ProfesorDto.cs
?   ??? CommonDto.cs
??? Models/              # Modelos de dominio
?   ??? Actividad.cs
?   ??? Profesor.cs
?   ??? Departamento.cs
?   ??? ...
??? Services/            # Lógica de negocio
?   ??? ActividadService.cs
?   ??? FileStorageService.cs
?   ??? JwtService.cs
??? Validators/          # Validadores FluentValidation
?   ??? ActividadValidators.cs
?   ??? ProfesorValidators.cs
??? Middleware/          # Middleware personalizado
?   ??? ErrorHandlingMiddleware.cs
??? Program.cs           # Configuración de la aplicación
??? appsettings.json     # Configuración
```

## ?? Endpoints

### Autenticación

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/auth/login` | Iniciar sesión |
| POST | `/api/auth/register` | Registrar usuario |

### Actividades

| Método | Endpoint | Descripción | Roles |
|--------|----------|-------------|-------|
| GET | `/api/actividad` | Listar actividades (paginado) | Todos |
| GET | `/api/actividad/{id}` | Obtener actividad | Todos |
| POST | `/api/actividad` | Crear actividad | Admin, Coord |
| PUT | `/api/actividad/{id}` | Actualizar actividad | Admin, Coord |
| DELETE | `/api/actividad/{id}` | Eliminar actividad | Admin |

**Parámetros de consulta:**
- `page` (int): Número de página
- `pageSize` (int): Elementos por página
- `search` (string): Búsqueda por nombre/descripción
- `orderBy` (string): Campo de ordenamiento
- `descending` (bool): Orden descendente

### Profesores

| Método | Endpoint | Descripción | Roles |
|--------|----------|-------------|-------|
| GET | `/api/profesor` | Listar profesores | Todos |
| GET | `/api/profesor/{uuid}` | Obtener profesor por UUID | Todos |
| GET | `/api/profesor/dni/{dni}` | Obtener profesor por DNI | Todos |
| POST | `/api/profesor` | Crear profesor | Admin |
| PUT | `/api/profesor/{uuid}` | Actualizar profesor | Admin |
| DELETE | `/api/profesor/{uuid}` | Eliminar profesor | Admin |

### Fotos

| Método | Endpoint | Descripción | Roles |
|--------|----------|-------------|-------|
| GET | `/api/foto` | Listar todas las fotos | Todos |
| GET | `/api/foto/{id}` | Obtener foto | Todos |
| GET | `/api/foto/actividad/{id}` | Fotos de una actividad | Todos |
| POST | `/api/foto/upload` | Subir fotos | Admin, Coord, Prof |
| DELETE | `/api/foto/{id}` | Eliminar foto | Admin, Coord |

## ?? Autenticación y Autorización

### Roles del sistema

- **Administrador**: Acceso completo
- **Coordinador**: Gestión de actividades y fotos
- **Profesor**: Visualización y participación
- **Usuario**: Solo lectura

### Uso del token JWT

1. **Login:**
```bash
POST /api/auth/login
{
  "email": "usuario@example.com",
  "nombreCompleto": "Usuario Ejemplo"
}
```

Respuesta:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "usuario": {
    "id": "guid",
    "email": "usuario@example.com",
    "nombreCompleto": "Usuario Ejemplo",
    "rol": "Usuario"
  }
}
```

2. **Usar el token:**
```bash
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

## ?? Almacenamiento de Archivos

### Almacenamiento Local (Desarrollo)

Las imágenes se almacenan en `wwwroot/uploads/` y se sirven estáticamente.

### Azure Blob Storage (Producción)

1. Configurar `appsettings.json`:
```json
"Azure": {
  "BlobStorage": {
    "ConnectionString": "DefaultEndpointsProtocol=https;AccountName=...",
    "Enabled": true
  }
}
```

2. Las imágenes se optimizan automáticamente:
   - Redimensionadas a máximo 1920x1080
   - Compresión JPEG al 85%
   - Thumbnails de 300x300 al 75%

## ?? CORS

Configurado para aplicaciones Flutter, React, Angular:

```json
"Cors": {
  "AllowedOrigins": [
    "http://localhost:3000",
    "http://localhost:4200",
    "http://localhost:5173"
  ]
}
```

## ?? Caché

Implementado con `IMemoryCache` para mejorar el rendimiento:
- Tiempo de expiración configurable
- Invalidación automática en actualizaciones

## ?? Despliegue

### Azure App Service

1. Publicar desde Visual Studio o CLI:
```bash
dotnet publish -c Release
```

2. Configurar variables de entorno en Azure Portal

3. Habilitar HTTPS

### Docker

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["ACEXAPI.csproj", "./"]
RUN dotnet restore
COPY . .
RUN dotnet build -c Release -o /app/build

FROM build AS publish
RUN dotnet publish -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ACEXAPI.dll"]
```

## ?? Licencia

Este proyecto está bajo la licencia MIT.

## ?? Autores

- Miguel Ángel Calderon
- José David Casas
- Ángel García
- Victor Guardo

## ?? Contribuir

Las contribuciones son bienvenidas. Por favor, abre un issue primero para discutir los cambios.
