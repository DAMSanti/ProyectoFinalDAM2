# 6. DISEÑO DEL SISTEMA - ACEX

## 6.1 ARQUITECTURA GENERAL DEL PROYECTO

### Descripción General
El sistema ACEX (Actividades Complementarias y Extraescolares) está construido con una arquitectura Cliente-Servidor de 3 capas, utilizando tecnologías modernas y siguiendo principios de desarrollo escalable y mantenible.

### Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CAPA DE PRESENTACIÓN                         │
│                         (Flutter Multi-Plataforma)                   │
├──────────────┬──────────────┬──────────────┬──────────────┬─────────┤
│   Android    │     iOS      │     Web      │   Windows    │  Linux  │
│   (Móvil)    │   (Móvil)    │  (Navegador) │  (Desktop)   │(Desktop)│
└──────────────┴──────────────┴──────────────┴──────────────┴─────────┘
                                    │
                                    │ HTTPS/REST API
                                    │ WebSocket (Chat)
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      CAPA DE APLICACIÓN                              │
│                    ASP.NET Core 8.0 Web API                          │
├─────────────────────────────────────────────────────────────────────┤
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐          │
│  │ Controllers   │  │   Services    │  │  Middleware   │          │
│  │ (Endpoints)   │  │  (Lógica)     │  │  (Auth/JWT)   │          │
│  └───────────────┘  └───────────────┘  └───────────────┘          │
│                                                                      │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐          │
│  │  DTOs         │  │  Validators   │  │ ModelBinders  │          │
│  │ (Transfer)    │  │ (FluentVal.)  │  │               │          │
│  └───────────────┘  └───────────────┘  └───────────────┘          │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
                    ▼               ▼               ▼
┌──────────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│   CAPA DE DATOS      │  │  SERVICIOS CLOUD │  │  ALMACENAMIENTO  │
│   SQL Server         │  │    Firebase      │  │   ARCHIVOS       │
├──────────────────────┤  ├──────────────────┤  ├──────────────────┤
│ • Actividades        │  │ • Authentication │  │ • Folletos PDF   │
│ • Profesores         │  │ • Cloud Firestore│  │ • Imágenes       │
│ • Grupos             │  │   (Chat)         │  │ • Thumbnails     │
│ • Localizaciones     │  │ • FCM (Push)     │  │                  │
│ • Departamentos      │  │ • Storage (Media)│  │ /wwwroot/uploads/│
│ • Usuarios           │  │                  │  │                  │
│ • Fotos              │  │                  │  │                  │
│ • Contratos          │  │                  │  │                  │
└──────────────────────┘  └──────────────────┘  └──────────────────┘
```

### Descripción de Componentes

#### **CAPA DE PRESENTACIÓN (Flutter)**
- **Tecnología**: Flutter SDK 3.x, Dart 3.x
- **Función**: Interfaz de usuario multiplataforma
- **Características**:
  - Responsive design adaptable a diferentes tamaños de pantalla
  - Navegación fluida con rutas nominadas
  - Gestión de estado con Provider
  - Temas claro/oscuro
  - Internacionalización (español)

#### **CAPA DE APLICACIÓN (ASP.NET Core)**
- **Tecnología**: .NET 8.0, C#
- **Función**: Lógica de negocio y API REST
- **Componentes**:
  - **Controllers**: Endpoints HTTP (GET, POST, PUT, DELETE)
  - **Services**: Lógica de negocio encapsulada
  - **Middleware**: Autenticación JWT, manejo de errores, CORS
  - **DTOs**: Objetos de transferencia de datos
  - **Validators**: Validaciones con FluentValidation

#### **CAPA DE DATOS**
- **Base de Datos**: SQL Server
  - Entity Framework Core para ORM
  - Migraciones automáticas
  - Relaciones 1:N y N:M
  
- **Firebase Cloud Services**:
  - **Firestore**: Base de datos en tiempo real para chat
  - **Cloud Messaging**: Notificaciones push
  - **Storage**: Almacenamiento de media en chat
  
- **Sistema de Archivos**:
  - Almacenamiento local en servidor
  - Gestión de folletos PDF
  - Gestión de imágenes con thumbnails

---

## 6.2 DIAGRAMA ENTIDAD-RELACIÓN (BASE DE DATOS)

### Diagrama E/R Completo

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│  Departamento   │         │    Profesor     │         │    Usuario      │
├─────────────────┤    1:N  ├─────────────────┤   1:1   ├─────────────────┤
│ *Id (PK)        │◄────────│ *Uuid (PK)      │◄────────│ *Id (PK)        │
│  Nombre         │         │  Nombre         │         │  NombreUsuario  │
│  Descripcion    │         │  Apellidos      │         │  Password       │
└─────────────────┘         │  Email          │         │  Rol            │
                            │  Telefono       │         │  Activo         │
                            │  FotoUrl        │         │  FechaCreacion  │
                            │  Activo         │         │  ProfesorUuid(FK)│
                            │ *DepartamentoId │         └─────────────────┘
                            └─────────────────┘
                                     │
                        ┌────────────┼────────────┐
                        │            │            │
                   Responsable  Participante  Responsable
                        │            │            │
                        ▼            ▼            ▼
            ┌─────────────────────────────────────────────┐
            │              Actividad                      │
            ├─────────────────────────────────────────────┤
            │ *Id (PK)                                    │
            │  Nombre                                     │
            │  Descripcion                                │
            │  FechaInicio                                │
            │  FechaFin                                   │
            │  Estado (Pendiente/Aprobada/Cancelada)      │
            │  Tipo (Complementaria/Extraescolar)         │
            │  PresupuestoEstimado                        │
            │  CostoReal                                  │
            │  FolletoUrl                                 │
            │  PrecioTransporte                           │
            │  PrecioAlojamiento                          │
            │  TransporteReq                              │
            │  AlojamientoReq                             │
            │  FechaCreacion                              │
            │ *ResponsableId (FK → Profesor)              │
            │ *LocalizacionId (FK → Localizacion)         │
            │ *EmpTransporteId (FK → EmpTransporte)       │
            │ *AlojamientoId (FK → Alojamiento)           │
            └─────────────────────────────────────────────┘
                     │           │           │
        ┌────────────┼───────────┼───────────┼────────────┐
        │            │           │           │            │
        │            │           │           │            │
        ▼            ▼           ▼           ▼            ▼
┌───────────┐  ┌──────────┐  ┌──────┐  ┌──────────┐  ┌─────────────┐
│  Foto     │  │Contrato  │  │Gasto │  │GrupoPar. │  │ProfPart.    │
├───────────┤  ├──────────┤  │Person│  ├──────────┤  ├─────────────┤
│*Id (PK)   │  │*Id (PK)  │  │├─────┤  │*Id (PK)  │  │*Id (PK)     │
│ Url       │  │ Nombre   │  │*Id   │  │ Num.Part.│  │ Obs.        │
│ Thumb     │  │ Proveedor│  │ Conc.│  │*ActId(FK)│  │*ActId (FK)  │
│ Descrip.  │  │ Descrip. │  │ Cant.│  │*GrupoId  │  │*ProfUuid(FK)│
│ FechaSub. │  │ Monto    │  │ Fecha│  └──────────┘  └─────────────┘
│ Tamaño    │  │ FechaCon.│  └──────┘       │
│*ActId(FK) │  │ Presup.  │                 ▼
└───────────┘  │ Factura  │          ┌─────────────┐
               │*ActId(FK)│          │   Grupo     │
               └──────────┘          ├─────────────┤
                                     │*Id (PK)     │
┌──────────────┐                     │ Nombre      │
│ Localizacion │                     │ NumAlumnos  │
├──────────────┤                     │*CursoId(FK) │
│*Id (PK)      │                     └─────────────┘
│ Nombre       │                            │
│ Direccion    │                            ▼
│ Ciudad       │                     ┌─────────────┐
│ CP           │                     │   Curso     │
│ Provincia    │                     ├─────────────┤
│ Pais         │                     │*Id (PK)     │
│ Latitud      │                     │ Nombre      │
│ Longitud     │                     │ Nivel       │
│ Descripcion  │                     │ Activo      │
└──────────────┘                     └─────────────┘
       ▲
       │ N:M
       │
┌────────────────────┐
│ActividadLocalizac. │
├────────────────────┤
│*Id (PK)            │
│ EsPrincipal        │
│ Orden              │
│ TipoLocalizacion   │
│ Descripcion        │
│ FechaAsignacion    │
│*ActividadId (FK)   │
│*LocalizacionId (FK)│
└────────────────────┘

┌──────────────┐         ┌──────────────┐
│EmpTransporte │         │ Alojamiento  │
├──────────────┤         ├──────────────┤
│*Id (PK)      │         │*Id (PK)      │
│ Nombre       │         │ Nombre       │
│ CIF          │         │ Direccion    │
│ Telefono     │         │ Ciudad       │
│ Email        │         │ CP           │
│ Direccion    │         │ Provincia    │
└──────────────┘         │ Telefono     │
                         │ Email        │
                         │ Web          │
                         │ TipoAlojam.  │
                         │ NumHabit.    │
                         │ CapacidadTot.│
                         │ Activo       │
                         └──────────────┘

┌──────────────┐
│  FcmToken    │
├──────────────┤
│*Id (PK)      │
│ UsuarioId    │
│ Token        │
│ DeviceId     │
│ DeviceType   │
│ Activo       │
│ FechaCreac.  │
│ UltActualiz. │
└──────────────┘
```

---

## 6.3 DESCRIPCIÓN DETALLADA DE TABLAS

### **1. Actividades** (Tabla principal)
**Propósito**: Almacena la información completa de las actividades escolares.

| Campo | Tipo | Descripción | PK/FK |
|-------|------|-------------|-------|
| Id | int | Identificador único | PK |
| Nombre | nvarchar(200) | Nombre de la actividad | |
| Descripcion | nvarchar(1000) | Descripción detallada | |
| FechaInicio | datetime2 | Fecha y hora de inicio | |
| FechaFin | datetime2 | Fecha y hora de finalización | |
| Estado | nvarchar(20) | Pendiente/Aprobada/Cancelada | |
| Tipo | nvarchar(20) | Complementaria/Extraescolar | |
| PresupuestoEstimado | decimal(18,2) | Presupuesto previsto | |
| CostoReal | decimal(18,2) | Costo final real | |
| FolletoUrl | nvarchar(max) | Ruta del folleto PDF | |
| PrecioTransporte | decimal(18,2) | Precio del transporte | |
| PrecioAlojamiento | decimal(18,2) | Precio del alojamiento | |
| TransporteReq | int | 0=No, 1=Sí, 2=A determinar | |
| AlojamientoReq | int | 0=No, 1=Sí, 2=A determinar | |
| FechaCreacion | datetime2 | Fecha de creación del registro | |
| ResponsableId | uniqueidentifier | Profesor responsable | FK → Profesores |
| LocalizacionId | int | Localización principal | FK → Localizaciones |
| EmpTransporteId | int | Empresa de transporte | FK → EmpTransportes |
| AlojamientoId | int | Alojamiento seleccionado | FK → Alojamientos |

**Relaciones**:
- 1:N con Fotos (una actividad puede tener múltiples fotos)
- 1:N con Contratos (una actividad puede tener múltiples contratos)
- 1:N con GastosPersonalizados
- N:M con Profesores (través de ProfParticipantes)
- N:M con Grupos (través de GrupoPartics)
- N:M con Localizaciones (través de ActividadLocalizaciones)

---

### **2. Profesores**
**Propósito**: Información de los profesores del centro.

| Campo | Tipo | Descripción | PK/FK |
|-------|------|-------------|-------|
| Uuid | uniqueidentifier | Identificador único UUID | PK |
| Nombre | nvarchar(100) | Nombre del profesor | |
| Apellidos | nvarchar(200) | Apellidos | |
| Email | nvarchar(200) | Correo electrónico único | |
| Telefono | nvarchar(20) | Teléfono de contacto | |
| FotoUrl | nvarchar(max) | URL de la foto de perfil | |
| Activo | bit | Estado activo/inactivo | |
| DepartamentoId | int | Departamento al que pertenece | FK → Departamentos |

**Relaciones**:
- N:1 con Departamentos
- 1:N con Actividades (como responsable)
- N:M con Actividades (como participante)
- 1:1 con Usuarios

---

### **3. Usuarios**
**Propósito**: Credenciales y datos de autenticación.

| Campo | Tipo | Descripción | PK/FK |
|-------|------|-------------|-------|
| Id | uniqueidentifier | Identificador único | PK |
| NombreUsuario | nvarchar(200) | Nombre de usuario único | |
| Password | nvarchar(256) | Contraseña hasheada (BCrypt) | |
| Rol | nvarchar(50) | Admin/Profesor/Usuario | |
| Activo | bit | Estado de la cuenta | |
| FechaCreacion | datetime2 | Fecha de creación | |
| ProfesorUuid | uniqueidentifier | Relación con profesor | FK → Profesores |

**Relaciones**:
- 1:1 con Profesores (un usuario puede estar vinculado a un profesor)

---

### **4. Departamentos**
**Propósito**: Departamentos académicos del centro.

| Campo | Tipo | Descripción | PK/FK |
|-------|------|-------------|-------|
| Id | int | Identificador único | PK |
| Nombre | nvarchar(200) | Nombre del departamento | |
| Descripcion | nvarchar(500) | Descripción del departamento | |

**Relaciones**:
- 1:N con Profesores

---

### **5. Localizaciones**
**Propósito**: Lugares relacionados con las actividades.

| Campo | Tipo | Descripción | PK/FK |
|-------|------|-------------|-------|
| Id | int | Identificador único | PK |
| Nombre | nvarchar(200) | Nombre del lugar | |
| Direccion | nvarchar(500) | Dirección completa | |
| Ciudad | nvarchar(100) | Ciudad | |
| CodigoPostal | nvarchar(20) | Código postal | |
| Provincia | nvarchar(100) | Provincia | |
| Pais | nvarchar(100) | País | |
| Latitud | decimal(10,8) | Coordenada latitud | |
| Longitud | decimal(11,8) | Coordenada longitud | |
| Descripcion | nvarchar(max) | Descripción del lugar | |

**Relaciones**:
- N:M con Actividades (através de ActividadLocalizaciones)

---

### **6. ActividadLocalizaciones** (Tabla intermedia N:M)
**Propósito**: Relación muchos a muchos entre actividades y localizaciones.

| Campo | Tipo | Descripción | PK/FK |
|-------|------|-------------|-------|
| Id | int | Identificador único | PK |
| ActividadId | int | Referencia a actividad | FK → Actividades |
| LocalizacionId | int | Referencia a localización | FK → Localizaciones |
| EsPrincipal | bit | Marca si es la localización principal | |
| Orden | int | Orden de visita (0, 1, 2...) | |
| TipoLocalizacion | nvarchar(50) | Destino/Encuentro/Parada/etc. | |
| Descripcion | nvarchar(500) | Descripción específica | |
| FechaAsignacion | datetime2 | Cuándo se asignó | |

**Constraint Único**: (ActividadId, LocalizacionId)

---

### **7. Grupos**
**Propósito**: Grupos de estudiantes del centro.

| Campo | Tipo | Descripción | PK/FK |
|-------|------|-------------|-------|
| Id | int | Identificador único | PK |
| Nombre | nvarchar(100) | Nombre del grupo (ej: 2º ESO A) | |
| NumeroAlumnos | int | Total de alumnos en el grupo | |
| CursoId | int | Curso al que pertenece | FK → Cursos |

**Relaciones**:
- N:1 con Cursos
- N:M con Actividades (através de GrupoPartics)

---

### **8. Cursos**
**Propósito**: Cursos académicos (ESO, Bachillerato, etc.).

| Campo | Tipo | Descripción | PK/FK |
|-------|------|-------------|-------|
| Id | int | Identificador único | PK |
| Nombre | nvarchar(100) | Nombre del curso (ej: 1º ESO) | |
| Nivel | nvarchar(10) | ESO/BACH/FP | |
| Activo | bit | Si está activo actualmente | |

**Relaciones**:
- 1:N con Grupos

---

### **9. GrupoPartics** (Tabla intermedia N:M)
**Propósito**: Relación muchos a muchos entre actividades y grupos, con participantes.

| Campo | Tipo | Descripción | PK/FK |
|-------|------|-------------|-------|
| Id | int | Identificador único | PK |
| ActividadId | int | Referencia a actividad | FK → Actividades |
| GrupoId | int | Referencia a grupo | FK → Grupos |
| NumeroParticipantes | int | Cuántos alumnos del grupo participan | |
| FechaRegistro | datetime2 | Fecha de registro | |

---

### **10. ProfParticipantes** (Tabla intermedia N:M)
**Propósito**: Profesores que participan en actividades (no como responsables).

| Campo | Tipo | Descripción | PK/FK |
|-------|------|-------------|-------|
| Id | int | Identificador único | PK |
| ActividadId | int | Referencia a actividad | FK → Actividades |
| ProfesorUuid | uniqueidentifier | Referencia a profesor | FK → Profesores |
| FechaRegistro | datetime2 | Fecha de registro | |
| Observaciones | nvarchar(500) | Observaciones adicionales | |

---

### **11. Fotos**
**Propósito**: Imágenes asociadas a actividades.

| Campo | Tipo | Descripción | PK/FK |
|-------|------|-------------|-------|
| Id | int | Identificador único | PK |
| ActividadId | int | Actividad a la que pertenece | FK → Actividades |
| Url | nvarchar(max) | Ruta de la imagen | |
| UrlThumbnail | nvarchar(max) | Ruta del thumbnail | |
| Descripcion | nvarchar(500) | Descripción de la foto | |
| FechaSubida | datetime2 | Fecha de carga | |
| TamanoBytes | bigint | Tamaño del archivo | |

**Relaciones**:
- N:1 con Actividades (una actividad puede tener múltiples fotos)

---

### **12. Contratos**
**Propósito**: Contratos y documentos financieros de actividades.

| Campo | Tipo | Descripción | PK/FK |
|-------|------|-------------|-------|
| Id | int | Identificador único | PK |
| ActividadId | int | Actividad relacionada | FK → Actividades |
| NombreProveedor | nvarchar(200) | Nombre del proveedor | |
| Descripcion | nvarchar(1000) | Descripción del contrato | |
| Monto | decimal(18,2) | Monto del contrato | |
| FechaContrato | datetime2 | Fecha del contrato | |
| PresupuestoUrl | nvarchar(max) | URL del presupuesto | |
| FacturaUrl | nvarchar(max) | URL de la factura | |
| FechaCreacion | datetime2 | Fecha de creación | |

---

### **13. GastosPersonalizados**
**Propósito**: Gastos adicionales personalizados de actividades.

| Campo | Tipo | Descripción | PK/FK |
|-------|------|-------------|-------|
| Id | int | Identificador único | PK |
| ActividadId | int | Actividad relacionada | FK → Actividades |
| Concepto | nvarchar(200) | Descripción del gasto | |
| Cantidad | decimal(18,2) | Monto del gasto | |
| FechaCreacion | datetime2 | Fecha de creación | |

---

### **14. EmpTransportes**
**Propósito**: Empresas de transporte disponibles.

| Campo | Tipo | Descripción | PK/FK |
|-------|------|-------------|-------|
| Id | int | Identificador único | PK |
| Nombre | nvarchar(200) | Nombre de la empresa | |
| Cif | nvarchar(50) | CIF de la empresa | |
| Telefono | nvarchar(20) | Teléfono de contacto | |
| Email | nvarchar(200) | Email de contacto | |
| Direccion | nvarchar(500) | Dirección de la empresa | |

---

### **15. Alojamientos**
**Propósito**: Alojamientos disponibles para actividades.

| Campo | Tipo | Descripción | PK/FK |
|-------|------|-------------|-------|
| Id | int | Identificador único | PK |
| Nombre | nvarchar(200) | Nombre del alojamiento | |
| Direccion | nvarchar(300) | Dirección completa | |
| Ciudad | nvarchar(100) | Ciudad | |
| CodigoPostal | nvarchar(20) | Código postal | |
| Provincia | nvarchar(100) | Provincia | |
| Telefono | nvarchar(20) | Teléfono de contacto | |
| Email | nvarchar(200) | Email de contacto | |
| Web | nvarchar(max) | Sitio web | |
| TipoAlojamiento | nvarchar(50) | Hotel/Hostal/Albergue/etc. | |
| NumeroHabitaciones | int | Número de habitaciones | |
| CapacidadTotal | int | Capacidad total de personas | |
| Activo | bit | Si está disponible | |

---

### **16. FcmTokens**
**Propósito**: Tokens de Firebase Cloud Messaging para notificaciones push.

| Campo | Tipo | Descripción | PK/FK |
|-------|------|-------------|-------|
| Id | int | Identificador único | PK |
| UsuarioId | nvarchar(450) | ID del usuario (UUID) | |
| Token | nvarchar(500) | Token FCM del dispositivo | |
| DeviceId | nvarchar(200) | ID del dispositivo | |
| DeviceType | nvarchar(50) | Android/iOS/Web | |
| Activo | bit | Si el token está activo | |
| FechaCreacion | datetime2 | Fecha de registro | |
| UltimaActualizacion | datetime2 | Última actualización | |

---

## 6.4 DIAGRAMA DE CLASES (Backend - C#)

### Diagrama de Clases Principal

```
┌──────────────────────────────────────────────┐
│           <<abstract>>                        │
│         ControllerBase                        │
└──────────────────────────────────────────────┘
                    △
                    │
       ┌────────────┼────────────┐
       │            │            │
┌──────────────┐┌──────────────┐┌──────────────┐
│ Actividad    ││  Profesor    ││   Catalogo   │
│ Controller   ││  Controller  ││   Controller │
├──────────────┤├──────────────┤├──────────────┤
│- service     ││- service     ││- service     │
├──────────────┤├──────────────┤├──────────────┤
│+ GetAll()    ││+ GetAll()    ││+ GetDept()   │
│+ GetById()   ││+ GetById()   ││+ GetCursos() │
│+ Create()    ││+ Create()    ││+ GetGrupos() │
│+ Update()    ││+ Update()    ││+ GetEmpresas()│
│+ Delete()    ││+ Delete()    ││              │
│+ UploadFoll()││              ││              │
└──────────────┘└──────────────┘└──────────────┘
       │              │                │
       ▼              ▼                ▼
┌──────────────┐┌──────────────┐┌──────────────┐
│ Actividad    ││  Profesor    ││   Catalogo   │
│  Service     ││   Service    ││    Service   │
├──────────────┤├──────────────┤├──────────────┤
│- context     ││- context     ││- context     │
│- fileStorage ││- logger      ││- logger      │
│- logger      ││              ││              │
├──────────────┤├──────────────┤├──────────────┤
│+ GetAllAsync()│+ GetAllAsync()│+ GetDept()  │
│+ CreateAsync()│+ CreateAsync()│+ GetCursos()│
│+ UpdateAsync()│+ UpdateAsync()│+ GetGrupos()│
│+ DeleteAsync()│+ DeleteAsync()│              │
└──────────────┘└──────────────┘└──────────────┘
       │              │
       ▼              ▼
┌──────────────────────────────────────────────┐
│      ApplicationDbContext                     │
│      (DbContext)                             │
├──────────────────────────────────────────────┤
│+ DbSet<Actividad> Actividades               │
│+ DbSet<Profesor> Profesores                 │
│+ DbSet<Usuario> Usuarios                    │
│+ DbSet<Departamento> Departamentos          │
│+ DbSet<Grupo> Grupos                        │
│+ DbSet<Curso> Cursos                        │
│+ DbSet<Localizacion> Localizaciones         │
│+ DbSet<Foto> Fotos                          │
│+ DbSet<Contrato> Contratos                  │
│+ DbSet<EmpTransporte> EmpTransportes        │
│+ DbSet<Alojamiento> Alojamientos            │
├──────────────────────────────────────────────┤
│+ OnModelCreating(ModelBuilder)              │
└──────────────────────────────────────────────┘


┌────────────────── MODELOS ──────────────────┐

┌──────────────┐      ┌──────────────┐
│  Actividad   │  1:N │   Foto       │
├──────────────┤◄─────├──────────────┤
│+ Id          │      │+ Id          │
│+ Nombre      │      │+ Url         │
│+ Descripcion │      │+ UrlThumbnail│
│+ FechaInicio │      │+ Descripcion │
│+ FechaFin    │      │+ FechaSubida │
│+ Estado      │      │+ TamanoBytes │
│+ Tipo        │      │+ ActividadId │
│+ Presupuesto │      └──────────────┘
│+ CostoReal   │
│+ FolletoUrl  │      ┌──────────────┐
│+ Responsable │  1:N │  Contrato    │
│+ Fotos       │◄─────├──────────────┤
│+ Contratos   │      │+ Id          │
│+ Grupos      │      │+ Nombre      │
│+ Profesores  │      │+ Proveedor   │
│+ Localizacn. │      │+ Monto       │
└──────────────┘      │+ FechaContr. │
      │               │+ ActividadId │
      │               └──────────────┘
      │ N:M
      ▼
┌──────────────┐      ┌──────────────┐
│ActividadLoc. │  N:1 │ Localizacion │
├──────────────┤─────►├──────────────┤
│+ Id          │      │+ Id          │
│+ EsPrincipal │      │+ Nombre      │
│+ Orden       │      │+ Direccion   │
│+ TipoLocaliz.│      │+ Ciudad      │
│+ ActividadId │      │+ Latitud     │
│+ Localiz.Id  │      │+ Longitud    │
└──────────────┘      └──────────────┘


┌──────────────┐      ┌──────────────┐
│  Profesor    │  N:1 │ Departamento │
├──────────────┤─────►├──────────────┤
│+ Uuid        │      │+ Id          │
│+ Nombre      │      │+ Nombre      │
│+ Apellidos   │      │+ Descripcion │
│+ Email       │      └──────────────┘
│+ Telefono    │
│+ FotoUrl     │      ┌──────────────┐
│+ Activo      │  1:1 │   Usuario    │
│+ Departamnto │◄─────├──────────────┤
└──────────────┘      │+ Id          │
      │               │+ NombreUser  │
      │ N:M           │+ Password    │
      ▼               │+ Rol         │
┌──────────────┐      │+ Activo      │
│ProfParticipt.│      │+ ProfesorUuid│
├──────────────┤      └──────────────┘
│+ Id          │
│+ ActividadId │
│+ ProfesorUuid│
│+ FechaReg.   │
│+ Observac.   │
└──────────────┘


┌──────────────┐      ┌──────────────┐
│    Grupo     │  N:1 │    Curso     │
├──────────────┤─────►├──────────────┤
│+ Id          │      │+ Id          │
│+ Nombre      │      │+ Nombre      │
│+ NumAlumnos  │      │+ Nivel       │
│+ CursoId     │      │+ Activo      │
└──────────────┘      └──────────────┘
      │
      │ N:M
      ▼
┌──────────────┐
│ GrupoPartic. │
├──────────────┤
│+ Id          │
│+ ActividadId │
│+ GrupoId     │
│+ NumPart.    │
│+ FechaReg.   │
└──────────────┘


┌──────────────────── DTOs ─────────────────────┐

┌──────────────┐      ┌──────────────┐
│ActividadDto  │      │ActividadCreate│
├──────────────┤      │     Dto       │
│+ Id          │      ├──────────────┤
│+ Nombre      │      │+ Nombre      │
│+ Descripcion │      │+ Descripcion │
│+ FechaInicio │      │+ FechaInicio │
│+ Estado      │      │+ Responsable │
│+ Responsable │      │+ Localizacn. │
│+ Localizac.  │      └──────────────┘
│+ Fotos       │
│+ Participan. │      ┌──────────────┐
└──────────────┘      │ActividadUpdate│
                      │     Dto       │
┌──────────────┐      ├──────────────┤
│ProfesorDto   │      │+ Nombre      │
├──────────────┤      │+ Descripcion │
│+ Uuid        │      │+ FechaInicio │
│+ Nombre      │      │+ Estado      │
│+ Apellidos   │      │+ Presupuesto │
│+ Email       │      └──────────────┘
│+ FotoUrl     │
│+ Departamnto │
└──────────────┘
```

### Descripción de Clases Principales

#### **Controllers**
- **ActividadController**: Maneja endpoints para operaciones CRUD de actividades
  - Métodos: GetAll, GetById, Create, Update, Delete, UploadFolleto, DeleteFolleto
  - Inyección: ActividadService, FileStorageService
  
- **ProfesorController**: Gestiona profesores
  - Métodos: GetAll, GetById, Create, Update, Delete, UpdateFoto
  
- **CatalogoController**: Proporciona datos de catálogos
  - Métodos: GetDepartamentos, GetCursos, GetGrupos, GetEmpresas, GetAlojamientos

#### **Services**
- **ActividadService**: Lógica de negocio de actividades
  - Gestiona relaciones con participantes, fotos, contratos
  - Manejo de folletos y archivos
  
- **ProfesorService**: Lógica de profesores
  - Validaciones, gestión de departamentos
  
- **FileStorageService**: Gestión de archivos
  - Subida, descarga, eliminación de archivos
  - Generación de thumbnails

#### **Models** (Entidades)
- Clases que mapean directamente a tablas de la base de datos
- Anotaciones Data Annotations para validación
- Navegation Properties para relaciones EF Core

#### **DTOs** (Data Transfer Objects)
- **ActividadDto**: Representa actividad completa para lectura
- **ActividadCreateDto**: Datos necesarios para crear actividad
- **ActividadUpdateDto**: Datos actualizables de actividad
- Similar para Profesor, Localizacion, etc.

---

## 6.5 DIAGRAMA DE CLASES (Frontend - Flutter/Dart)

```
┌────────────── VISTAS ──────────────┐

┌──────────────┐
│   MyApp      │
├──────────────┤
│+ build()     │
└──────────────┘
      │
      ▼
┌──────────────┐      ┌──────────────┐
│DesktopShell  │◄─────│  LoginView   │
├──────────────┤      ├──────────────┤
│+ drawer      │      │- emailCtrl   │
│+ appBar      │      │- passCtrl    │
│+ body        │      │+ login()     │
└──────────────┘      └──────────────┘
      │
      ├───────────┬───────────┬───────────┐
      │           │           │           │
      ▼           ▼           ▼           ▼
┌──────────┐┌──────────┐┌──────────┐┌──────────┐
│HomeView  ││Activities││Activity  ││ChatList  │
│          ││View      ││Detail    ││View      │
├──────────┤├──────────┤├──────────┤├──────────┤
│+ build() ││+ build() ││+ build() ││+ build() │
└──────────┘└──────────┘└──────────┘└──────────┘


┌────────────── MODELOS ──────────────┐

┌──────────────┐      ┌──────────────┐
│  Actividad   │  1:N │   Photo      │
├──────────────┤◄─────├──────────────┤
│+ id          │      │+ id          │
│+ titulo      │      │+ url         │
│+ descripcion │      │+ descripcion │
│+ fini        │      │+ actividadId │
│+ ffin        │      └──────────────┘
│+ estado      │
│+ tipo        │      ┌──────────────┐
│+ urlFolleto  │  N:1 │ Localizacion │
│+ responsable │◄─────├──────────────┤
│+ localizacn. │      │+ id          │
│+ fotos       │      │+ nombre      │
│+ participan. │      │+ direccion   │
├──────────────┤      │+ latitud     │
│+ fromJson()  │      │+ longitud    │
│+ toJson()    │      ├──────────────┤
└──────────────┘      │+ fromJson()  │
                      │+ toJson()    │
┌──────────────┐      └──────────────┘
│  Profesor    │
├──────────────┤
│+ uuid        │      ┌──────────────┐
│+ nombre      │  N:1 │ Departamento │
│+ apellidos   │◄─────├──────────────┤
│+ email       │      │+ id          │
│+ fotoUrl     │      │+ nombre      │
│+ departamnto │      │+ descripcion │
├──────────────┤      ├──────────────┤
│+ fromJson()  │      │+ fromJson()  │
│+ toJson()    │      │+ toJson()    │
└──────────────┘      └──────────────┘


┌────────────── SERVICIOS ──────────────┐

┌──────────────┐
│  ApiService  │
├──────────────┤
│- dio: Dio    │
│- baseUrl     │
├──────────────┤
│+ get()       │
│+ post()      │
│+ put()       │
│+ delete()    │
│+ upload()    │
└──────────────┘
      △
      │
      ├───────────┬───────────┬───────────┐
      │           │           │           │
┌──────────────┐┌──────────────┐┌──────────────┐
│ Actividad    ││   Profesor   ││   Photo      │
│  Service     ││   Service    ││   Service    │
├──────────────┤├──────────────┤├──────────────┤
│- apiService  ││- apiService  ││- apiService  │
├──────────────┤├──────────────┤├──────────────┤
│+ fetchAll()  ││+ fetchAll()  ││+ upload()    │
│+ fetchById() ││+ fetchById() ││+ update()    │
│+ create()    ││+ create()    ││+ delete()    │
│+ update()    ││+ update()    ││              │
│+ delete()    ││+ delete()    ││              │
│+ uploadFoll()││+ uploadFoto()││              │
└──────────────┘└──────────────┘└──────────────┘


┌──────────────────────────────────────────────┐
│     FirebaseChatService                       │
├──────────────────────────────────────────────┤
│- firestore: FirebaseFirestore               │
│- storage: FirebaseStorage                   │
│- messaging: FirebaseMessaging               │
├──────────────────────────────────────────────┤
│+ sendMessage(chatId, message, userId)       │
│+ getMessages(chatId): Stream<Messages>      │
│+ uploadMedia(file): Future<String>          │
│+ markAsRead(chatId, messageId, userId)      │
│+ getUnreadCount(chatId, userId): int        │
└──────────────────────────────────────────────┘


┌────────────── PROVIDERS ──────────────┐

┌──────────────────────────────────────┐
│         Auth (ChangeNotifier)         │
├──────────────────────────────────────┤
│- _isAuthenticated: bool              │
│- _currentUser: Usuario?              │
│- _token: String?                     │
├──────────────────────────────────────┤
│+ login(email, password)              │
│+ logout()                            │
│+ checkAuthStatus()                   │
│+ get isAuthenticated: bool           │
│+ get currentUser: Usuario?           │
│+ notifyListeners()                   │
└──────────────────────────────────────┘


┌────────────── WIDGETS ──────────────┐

┌──────────────┐      ┌──────────────┐
│ActivityCard  │      │FolletoCard  │
├──────────────┤      ├──────────────┤
│+ actividad   │      │+ folletoUrl  │
│+ onTap       │      │+ onSelect    │
├──────────────┤      │+ onDelete    │
│+ build()     │      ├──────────────┤
└──────────────┘      │+ build()     │
                      └──────────────┘
┌──────────────┐
│ProfesorCard  │      ┌──────────────┐
├──────────────┤      │ ImageGallery │
│+ profesor    │      ├──────────────┤
│+ showDelete  │      │+ images      │
│+ onDelete    │      │+ onDelete    │
├──────────────┤      │+ onAdd       │
│+ build()     │      ├──────────────┤
└──────────────┘      │+ build()     │
                      └──────────────┘
```

### Descripción de Clases Flutter

#### **Vistas (StatefulWidget)**
- **LoginView**: Autenticación de usuarios
  - Controllers para email y password
  - Validación de formulario
  - Integración con Auth provider
  
- **HomeView**: Pantalla principal con lista de actividades
  - FutureBuilder para cargar datos
  - Navegación a detalles
  
- **ActivityDetailView**: Detalles completos de una actividad
  - Gestión de estado local
  - Manejo de cambios pendientes
  - Secciones: Info, Presupuesto, Participantes, Imágenes

#### **Modelos**
- **Actividad**: Representa una actividad escolar
  - `fromJson()`: Deserializa JSON de API
  - `toJson()`: Serializa para enviar a API
  
- **Profesor**, **Localizacion**, **Photo**: Similar estructura
  - Propiedades finales inmutables
  - Métodos de serialización

#### **Servicios**
- **ApiService**: Servicio base HTTP con Dio
  - Configuración de headers, timeouts
  - Interceptors para logging y errores
  
- **ActividadService**: Operaciones específicas de actividades
  - Wraps ApiService
  - Manejo de respuestas y errores específicos
  
- **FirebaseChatService**: Integración con Firestore
  - Streams para mensajes en tiempo real
  - Subida de archivos multimedia

#### **Providers (State Management)**
- **Auth**: Estado de autenticación global
  - ChangeNotifier para notificar cambios
  - Métodos login/logout
  - Persistencia de token JWT

#### **Widgets Reutilizables**
- **ActivityCard**: Tarjeta de actividad en lista
- **FolletoCard**: Widget para gestión de folleto PDF
- **ProfesorCard**: Tarjeta de profesor
- **ImageGallery**: Galería de imágenes con funcionalidad CRUD

---

## 6.6 DIAGRAMAS DE INTERFACES Y PROTOTIPOS

### 6.6.1 Mapa de Navegación General

```
                    ┌─────────────┐
                    │   INICIO    │
                    │ (LoginView) │
                    └──────┬──────┘
                           │
                    [Autenticación]
                           │
                           ▼
              ┌────────────────────────┐
              │   SHELL PRINCIPAL      │
              │  (DesktopShell)        │
              ├────────────────────────┤
              │ • AppBar (Superior)    │
              │ • Drawer (Lateral)     │
              │ • Body (Contenido)     │
              └────────────────────────┘
                           │
          ┌────────────────┼────────────────┬────────────────┐
          │                │                │                │
          ▼                ▼                ▼                ▼
    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
    │   HOME   │    │ACTIVIDA- │    │  CHAT    │    │  MAPA    │
    │  Vista   │    │  DES     │    │  Lista   │    │  Global  │
    │Principal │    │  Lista   │    │Mensajes  │    │Localiza. │
    └────┬─────┘    └────┬─────┘    └────┬─────┘    └──────────┘
         │               │               │
         │               │               │
         └───────┬───────┴───────┬───────┘
                 │               │
                 ▼               ▼
        ┌─────────────┐   ┌─────────────┐
        │  ACTIVIDAD  │   │   CHAT      │
        │   DETALLE   │   │  Conversac. │
        └─────┬───────┘   └─────────────┘
              │
    ┌─────────┼─────────┬─────────┐
    │         │         │         │
    ▼         ▼         ▼         ▼
┌────────┐┌────────┐┌────────┐┌────────┐
│Editar  ││Añadir  ││Gestión ││Gestión │
│Activ.  ││Partici.││Imágenes││Folleto │
└────────┘└────────┘└────────┘└────────┘
```

---

### 6.6.2 Pantallas Principales

#### **PANTALLA 1: Login (Inicio de Sesión)**

**Propósito**: Autenticar usuarios en el sistema.

**Elementos visuales**:
```
┌─────────────────────────────────────┐
│            🎓 ACEX                  │
│   Actividades Extraescolares        │
├─────────────────────────────────────┤
│                                     │
│   ┌───────────────────────────┐    │
│   │ 📧 Email                  │    │
│   └───────────────────────────┘    │
│                                     │
│   ┌───────────────────────────┐    │
│   │ 🔒 Contraseña             │    │
│   └───────────────────────────┘    │
│                                     │
│   ┌─────────────────────────────┐  │
│   │      INICIAR SESIÓN         │  │
│   └─────────────────────────────┘  │
│                                     │
│   [¿Olvidaste tu contraseña?]      │
│                                     │
└─────────────────────────────────────┘
```

**Datos recogidos**:
- Email del usuario (validación de formato)
- Contraseña (campo oculto)

**Funcionalidad**:
- Validación de campos obligatorios
- Envío de credenciales a API
- Recepción de token JWT
- Navegación a HomeView tras éxito
- Mensajes de error en caso de fallo

---

#### **PANTALLA 2: Home (Vista Principal)**

**Propósito**: Mostrar lista de actividades futuras y acceso rápido.

**Elementos visuales**:
```
┌────────────────────────────────────────────────────────┐
│ ☰  ACEX                      🌓 🔔 👤                  │
├────────────────────────────────────────────────────────┤
│                                                        │
│  🔍 Buscar actividades...        [+ Nueva]            │
│                                                        │
│  Filtros: [Todas] [Complementaria] [Extraescolar]     │
│                                                        │
│  ┌──────────────────────────────────────────────┐    │
│  │ 📅 Excursión al Museo de Ciencias           │    │
│  │ 📍 Madrid • 15/11/2025                       │    │
│  │ 👤 María García • Estado: Aprobada           │    │
│  │ 💰 500€ • 👥 45 participantes                │    │
│  └──────────────────────────────────────────────┘    │
│                                                        │
│  ┌──────────────────────────────────────────────┐    │
│  │ 🎨 Taller de Robótica                        │    │
│  │ 📍 Centro • 20/11/2025                       │    │
│  │ 👤 Juan Martínez • Estado: Pendiente         │    │
│  │ 💰 800€ • 👥 30 participantes                │    │
│  └──────────────────────────────────────────────┘    │
│                                                        │
└────────────────────────────────────────────────────────┘
```

**Datos mostrados**:
- Lista de actividades con información resumida
- Nombre, fecha, lugar, responsable
- Estado (Pendiente/Aprobada/Cancelada)
- Presupuesto y número de participantes

**Funcionalidad**:
- Scroll infinito de actividades
- Filtrado por tipo de actividad
- Búsqueda por nombre
- Click en tarjeta → Navegar a detalle
- Botón flotante para crear nueva actividad

---

#### **PANTALLA 3: Detalle de Actividad**

**Propósito**: Mostrar información completa y gestionar una actividad.

**Elementos visuales** (Vista en pestañas):
```
┌────────────────────────────────────────────────────────┐
│ ← ACEX                    💾 Guardar  🔄 Revertir      │
├────────────────────────────────────────────────────────┤
│                                                        │
│  ┌────────────────────────────────────────────────┐  │
│  │ 📅 EXCURSIÓN AL MUSEO DE CIENCIAS              │  │
│  │ Tipo: Complementaria • Estado: Aprobada         │  │
│  │ 📍 Museo de Ciencias, Madrid                    │  │
│  │ 📅 15/11/2025 9:00 - 18:00                      │  │
│  │ 👤 María García (Informática)                   │  │
│  │ 📄 [Ver Folleto PDF]                            │  │
│  └────────────────────────────────────────────────┘  │
│                                                        │
│  [Info] [Presupuesto] [Participantes] [Localiz.] [...] │
│  ════════════════════════════════════════════════      │
│                                                        │
│  INFORMACIÓN GENERAL                                   │
│  ┌────────────────────────────────────────────────┐  │
│  │ Descripción:                                    │  │
│  │ Visita educativa al Museo de Ciencias...       │  │
│  │                                                 │  │
│  │ 🚌 Transporte: Sí - AutosNorte (350€)          │  │
│  │ 🏨 Alojamiento: No requerido                    │  │
│  │                                                 │  │
│  │ Comentarios:                                    │  │
│  │ Traer almuerzo. Salida a las 8:30h             │  │
│  └────────────────────────────────────────────────┘  │
│                                                        │
└────────────────────────────────────────────────────────┘
```

**Pestañas disponibles**:
1. **Info**: Datos generales, transporte, alojamiento
2. **Presupuesto**: Costes, gastos personalizados
3. **Participantes**: Profesores y grupos de alumnos
4. **Localizaciones**: Mapa con múltiples destinos
5. **Imágenes**: Galería de fotos

**Datos recogidos/mostrados**:
- Información completa de la actividad
- Gestión de participantes
- Control de presupuesto
- Folleto PDF
- Galería de imágenes

**Funcionalidad**:
- Edición inline de campos (si es admin/responsable)
- Detección de cambios no guardados
- Botones guardar/revertir contextuales
- Navegación entre pestañas
- Subida de archivos (folleto, imágenes)

---

#### **PANTALLA 4: Sección de Presupuesto**

**Propósito**: Gestionar presupuesto estimado, costes reales y gastos.

**Elementos visuales**:
```
┌────────────────────────────────────────────────────────┐
│  PRESUPUESTO                                           │
│  ════════════════════════════════════════════════      │
│                                                        │
│  📊 RESUMEN                                            │
│  ┌────────────────────────────────────────────────┐  │
│  │ Presupuesto Estimado:    1.200,00 €            │  │
│  │ Costo Real:                850,00 €            │  │
│  │ Diferencia:               +350,00 € 💚         │  │
│  └────────────────────────────────────────────────┘  │
│                                                        │
│  🚌 TRANSPORTE                                         │
│  ┌────────────────────────────────────────────────┐  │
│  │ Empresa: AutosNorte                             │  │
│  │ Precio: 350,00 €                                │  │
│  │ Comentario: Autobús de 50 plazas               │  │
│  └────────────────────────────────────────────────┘  │
│                                                        │
│  🏨 ALOJAMIENTO                                        │
│  ┌────────────────────────────────────────────────┐  │
│  │ No requerido                                    │  │
│  └────────────────────────────────────────────────┘  │
│                                                        │
│  💰 GASTOS PERSONALIZADOS          [+ Añadir Gasto]   │
│  ┌────────────────────────────────────────────────┐  │
│  │ • Entradas museo        250,00 € [✏️] [🗑️]     │  │
│  │ • Material didáctico    150,00 € [✏️] [🗑️]     │  │
│  │ • Seguro de viaje       100,00 € [✏️] [🗑️]     │  │
│  └────────────────────────────────────────────────┘  │
│                                                        │
└────────────────────────────────────────────────────────┘
```

**Datos recogidos**:
- Presupuesto estimado (manual)
- Precio de transporte
- Precio de alojamiento
- Gastos personalizados (concepto + cantidad)

**Funcionalidad**:
- Cálculo automático de totales
- Comparación presupuesto vs real
- Añadir/editar/eliminar gastos personalizados
- Validación de cantidades numéricas

---

#### **PANTALLA 5: Sección de Participantes**

**Propósito**: Gestionar profesores y grupos de alumnos participantes.

**Elementos visuales**:
```
┌────────────────────────────────────────────────────────┐
│  PARTICIPANTES                                         │
│  ════════════════════════════════════════════════      │
│                                                        │
│  👥 PROFESORES PARTICIPANTES       [+ Añadir Profesor] │
│  ┌────────────────────────────────────────────────┐  │
│  │ 👤 María García (Informática)        [🗑️]      │  │
│  │    Responsable de la actividad                  │  │
│  ├────────────────────────────────────────────────┤  │
│  │ 👤 Juan Martínez (Matemáticas)      [🗑️]      │  │
│  │    Acompañante                                  │  │
│  ├────────────────────────────────────────────────┤  │
│  │ 👤 Ana Fernández (Lengua)           [🗑️]      │  │
│  │    Acompañante                                  │  │
│  └────────────────────────────────────────────────┘  │
│                                                        │
│  🎓 GRUPOS PARTICIPANTES              [+ Añadir Grupo] │
│  ┌────────────────────────────────────────────────┐  │
│  │ 📚 2º ESO A                         [✏️] [🗑️]  │  │
│  │    Participantes: 25 de 28 alumnos             │  │
│  ├────────────────────────────────────────────────┤  │
│  │ 📚 2º ESO B                         [✏️] [🗑️]  │  │
│  │    Participantes: 20 de 26 alumnos             │  │
│  └────────────────────────────────────────────────┘  │
│                                                        │
│  📊 Total: 45 alumnos + 3 profesores = 48 personas    │
│                                                        │
└────────────────────────────────────────────────────────┘
```

**Datos recogidos**:
- Profesores participantes (selección múltiple)
- Grupos de alumnos (selección múltiple)
- Número específico de participantes por grupo

**Funcionalidad**:
- Búsqueda de profesores
- Búsqueda de grupos por curso
- Edición de número de participantes
- Cálculo automático del total
- Validación de números

---

#### **PANTALLA 6: Sección de Localizaciones**

**Propósito**: Gestionar múltiples localizaciones y visualizarlas en mapa.

**Elementos visuales**:
```
┌────────────────────────────────────────────────────────┐
│  LOCALIZACIONES                                        │
│  ════════════════════════════════════════════════      │
│                                                        │
│  🗺️ MAPA INTERACTIVO                                  │
│  ┌────────────────────────────────────────────────┐  │
│  │         [Mapa con marcadores]                   │  │
│  │  📍 Centro Educativo (Punto de encuentro)       │  │
│  │  📍 Museo de Ciencias (Destino principal)       │  │
│  │  📍 Restaurante (Parada para comer)             │  │
│  │                                                 │  │
│  │         [Zoom +/-] [Centrar]                    │  │
│  └────────────────────────────────────────────────┘  │
│                                                        │
│  📍 LISTADO DE LOCALIZACIONES     [+ Añadir Localiz.]  │
│  ┌────────────────────────────────────────────────┐  │
│  │ 1️⃣ Centro Educativo               [✏️] [🗑️]    │  │
│  │    Tipo: Punto de encuentro                     │  │
│  │    📍 Calle Principal 123, Madrid               │  │
│  │    🕐 Hora: 08:30                               │  │
│  ├────────────────────────────────────────────────┤  │
│  │ 2️⃣ Museo de Ciencias             [✏️] [🗑️]    │  │
│  │    Tipo: Destino principal ⭐                   │  │
│  │    📍 Av. Ciencia 45, Madrid                    │  │
│  │    🕐 Hora: 10:00 - 14:00                       │  │
│  ├────────────────────────────────────────────────┤  │
│  │ 3️⃣ Restaurante El Buen Yantar    [✏️] [🗑️]    │  │
│  │    Tipo: Parada intermedia                      │  │
│  │    📍 Plaza Mayor 7, Madrid                     │  │
│  │    🕐 Hora: 14:30                               │  │
│  └────────────────────────────────────────────────┘  │
│                                                        │
└────────────────────────────────────────────────────────┘
```

**Datos recogidos**:
- Nombre de la localización
- Dirección completa
- Coordenadas (latitud/longitud)
- Tipo (Destino/Encuentro/Parada/Alojamiento/Interés)
- Orden de visita
- Hora estimada
- Descripción adicional

**Funcionalidad**:
- Mapa interactivo con marcadores
- Añadir localización (autocompletado de direcciones)
- Editar localización existente
- Eliminar localización
- Reordenar localizaciones (drag & drop)
- Marcar localización principal
- Geocodificación automática de direcciones

---

#### **PANTALLA 7: Sección de Imágenes**

**Propósito**: Galería de fotos de la actividad con gestión completa.

**Elementos visuales**:
```
┌────────────────────────────────────────────────────────┐
│  GALERÍA DE IMÁGENES                                   │
│  ════════════════════════════════════════════════      │
│                                                        │
│  [📷 Añadir Imágenes]                    🔍 Buscar    │
│                                                        │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐│
│  │[Imagen 1]│ │[Imagen 2]│ │[Imagen 3]│ │[Imagen 4]││
│  │          │ │          │ │          │ │          ││
│  │  Vista   │ │ Entrada  │ │ Grupo en │ │Experimen.││
│  │ general  │ │  museo   │ │ sala     │ │  ciencia ││
│  │          │ │          │ │          │ │          ││
│  │[✏️] [🗑️] │ │[✏️] [🗑️] │ │[✏️] [🗑️] │ │[✏️] [🗑️] ││
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘│
│                                                        │
│  ┌──────────┐ ┌──────────┐                            │
│  │[Imagen 5]│ │[Imagen 6]│                            │
│  │          │ │          │                            │
│  │Actividad │ │ Salida   │                            │
│  │práctica  │ │del museo │                            │
│  │          │ │          │                            │
│  │[✏️] [🗑️] │ │[✏️] [🗑️] │                            │
│  └──────────┘ └──────────┘                            │
│                                                        │
│  Total: 6 imágenes                                     │
│                                                        │
└────────────────────────────────────────────────────────┘
```

**Datos recogidos**:
- Imágenes (JPG, PNG)
- Descripción de cada imagen
- Fecha de subida automática
- Tamaño del archivo

**Funcionalidad**:
- Subida múltiple de imágenes
- Vista previa en miniatura
- Click para ver imagen completa
- Editar descripción de imagen
- Eliminar imagen (con confirmación)
- Generación automática de thumbnails
- Compresión de imágenes antes de subir

---

#### **PANTALLA 8: Chat de Actividad**

**Propósito**: Comunicación en tiempo real entre participantes de la actividad.

**Elementos visuales**:
```
┌────────────────────────────────────────────────────────┐
│ ← Chat: Excursión Museo de Ciencias                   │
├────────────────────────────────────────────────────────┤
│                                                        │
│  ┌────────────────────────────────┐                   │
│  │ 👤 María García (09:15)        │                   │
│  │ Buenos días! Recordad traer    │                   │
│  │ el almuerzo. Salimos a las 8:30│                   │
│  └────────────────────────────────┘                   │
│                                                        │
│               ┌────────────────────────────────┐      │
│               │ 👤 Juan Martínez (09:20)      │      │
│               │ Perfecto. ¿Hay algún cambio   │      │
│               │ en el horario?                 │      │
│               └────────────────────────────────┘      │
│                                                        │
│  ┌────────────────────────────────┐                   │
│  │ 👤 María García (09:22)        │                   │
│  │ No, todo según lo planeado     │                   │
│  │ [📷 imagen_museo.jpg]          │                   │
│  └────────────────────────────────┘                   │
│                                                        │
│               ┌────────────────────────────────┐      │
│               │ 👤 Ana Fernández (09:25)      │      │
│               │ ¿Necesitamos llevar algo      │      │
│               │ especial?                      │      │
│               └────────────────────────────────┘      │
│                                                        │
├────────────────────────────────────────────────────────┤
│ 📎  [Escribe un mensaje...]              [Enviar] 📤  │
└────────────────────────────────────────────────────────┘
```

**Datos recogidos**:
- Mensajes de texto
- Archivos multimedia (imágenes, videos, documentos)
- Marca de tiempo
- Estado de lectura

**Funcionalidad**:
- Mensajes en tiempo real (Firebase Firestore)
- Envío de texto
- Envío de imágenes desde galería o cámara
- Envío de videos
- Envío de archivos PDF
- Indicadores de estado (enviando/enviado/leído)
- Notificaciones push para nuevos mensajes
- Contador de mensajes no leídos
- Scroll automático a nuevos mensajes
- Vista previa de multimedia
- Descarga de archivos adjuntos

---

### 6.6.3 Diálogos y Modales

#### **Diálogo: Editar Actividad**
```
┌─────────────────────────────────────┐
│  ✏️ EDITAR ACTIVIDAD                │
├─────────────────────────────────────┤
│  Nombre:                            │
│  [Excursión al Museo de Ciencias]  │
│                                     │
│  Tipo:                              │
│  (•) Complementaria  ( ) Extra.     │
│                                     │
│  Fecha Inicio:       Hora:          │
│  [15/11/2025]       [09:00]         │
│                                     │
│  Fecha Fin:          Hora:          │
│  [15/11/2025]       [18:00]         │
│                                     │
│  Estado:                            │
│  [▼ Aprobada]                       │
│                                     │
│  Descripción:                       │
│  [Visita educativa al museo...]     │
│                                     │
├─────────────────────────────────────┤
│  [Cancelar]         [Guardar]       │
└─────────────────────────────────────┘
```

#### **Diálogo: Confirmar Eliminación**
```
┌─────────────────────────────────────┐
│  ⚠️ CONFIRMAR ELIMINACIÓN           │
├─────────────────────────────────────┤
│                                     │
│  🗑️                                 │
│                                     │
│  ¿Estás seguro de que deseas        │
│  eliminar este elemento?            │
│                                     │
│  Esta acción no se puede deshacer.  │
│                                     │
├─────────────────────────────────────┤
│  [Cancelar]         [Eliminar]      │
└─────────────────────────────────────┘
```

#### **Diálogo: Seleccionar Profesor**
```
┌─────────────────────────────────────┐
│  👤 AÑADIR PROFESOR                 │
├─────────────────────────────────────┤
│  🔍 Buscar por nombre...            │
│                                     │
│  ☑️ María García (Informática)      │
│  ☐ Juan Martínez (Matemáticas)     │
│  ☑️ Ana Fernández (Lengua)          │
│  ☐ Pedro López (Historia)           │
│  ☐ Laura Sánchez (Inglés)           │
│                                     │
│  Seleccionados: 2                   │
│                                     │
├─────────────────────────────────────┤
│  [Cancelar]         [Añadir (2)]    │
└─────────────────────────────────────┘
```

---

## 6.7 GUÍA DE ESTILOS

### 6.7.1 Logotipo e Identidad

**Nombre de la Aplicación**: **ACEX**
- Acrónimo de: **A**ctividades **C**omplementarias y **EX**traescolares

**Logotipo**: 
- Icono: 🎓 (Birrete académico) + 📅 (Calendario)
- Tipografía: Sans-serif moderna, bold
- Concepto: Educación + Organización

**Eslogan**: "Gestión eficiente de actividades educativas"

---

### 6.7.2 Paleta de Colores

#### **Colores Principales**

| Color | Código Hex | RGB | Uso |
|-------|------------|-----|-----|
| **Azul Principal** | `#1976D2` | rgb(25, 118, 210) | Botones primarios, headers, enlaces |
| **Azul Oscuro** | `#1565C0` | rgb(21, 101, 192) | Gradientes, hover states |
| **Azul Claro** | `#42A5F5` | rgb(66, 165, 245) | Acentos, destacados |

#### **Colores de Estado**

| Estado | Color | Código | Uso |
|--------|-------|--------|-----|
| **Pendiente** | Naranja | `#FF9800` | Actividades en espera |
| **Aprobada** | Verde | `#4CAF50` | Actividades confirmadas |
| **Cancelada** | Rojo | `#F44336` | Actividades rechazadas |

#### **Colores de Tipo de Actividad**

| Tipo | Color | Código | Uso |
|------|-------|--------|-----|
| **Complementaria** | Morado | `#9C27B0` | Badge, indicador |
| **Extraescolar** | Azul | `#1976D2` | Badge, indicador |

#### **Colores Semánticos**

| Acción | Color | Código | Uso |
|--------|-------|--------|-----|
| **Eliminar** | Rojo | `#D32F2F` | Botones de eliminación |
| **Editar** | Azul | `#1976D2` | Botones de edición |
| **Guardar** | Verde | `#43A047` | Botones de confirmación |
| **Cancelar** | Gris | `#757575` | Botones de cancelación |

#### **Colores de Tema**

**Tema Claro**:
```
- Fondo principal:     #BBDEF7 (Azul muy claro)
- Fondo tarjetas:      #E3F2FD (Azul pastel)
- Texto principal:     #6C7C88 (Gris azulado)
- Texto secundario:    #90A4AE (Gris claro)
```

**Tema Oscuro**:
```
- Fondo principal:     #2F434B (Gris azulado oscuro)
- Fondo tarjetas:      #203847 (Azul muy oscuro)
- Texto principal:     #A9E7FF (Azul claro)
- Texto secundario:    #B0BEC5 (Gris azulado)
```

#### **Gradientes Utilizados**

1. **Gradiente Principal** (Botones, Headers):
   ```
   Linear: [#1976D2, #1565C0]
   Dirección: Diagonal (topLeft → bottomRight)
   ```

2. **Gradiente Fondo Claro**:
   ```
   Linear: [#BBDEF7, #90CAF9]
   Dirección: Vertical (top → bottom)
   ```

3. **Gradiente Fondo Oscuro**:
   ```
   Linear: [#2F434B, #1A2933]
   Dirección: Vertical (top → bottom)
   ```

4. **Gradiente Advertencia**:
   ```
   Linear: [#D32F2F, #C62828]
   Dirección: Horizontal
   ```

---

### 6.7.3 Tipografía

**Familia de Fuentes**: **System Default** (Roboto en Android, San Francisco en iOS)

**Escalas de Tamaño**:

| Elemento | Tamaño | Peso | Uso |
|----------|---------|------|-----|
| **H1 (Display Large)** | 32px | Bold | Títulos principales |
| **H2 (Headline Large)** | 24px | Bold | Títulos de sección |
| **H3 (Headline Medium)** | 20px | SemiBold | Subtítulos |
| **Body Large** | 16px | Regular | Texto principal |
| **Body Medium** | 14px | Regular | Texto secundario |
| **Caption** | 12px | Regular | Etiquetas, notas |
| **Button** | 16px | Bold | Texto de botones |

**Interlineado**: 1.5 (150% del tamaño de fuente)

**Espaciado de Letras**: 
- Títulos: 0.5px
- Cuerpo: 0px (default)
- Botones: 1px (uppercase)

---

### 6.7.4 Iconografía

**Set de Iconos**: Material Icons (Google)

**Iconos Principales**:

| Icono | Nombre | Uso |
|-------|--------|-----|
| 📅 `event` | Calendario | Fechas, actividades |
| 👤 `person` | Persona | Usuarios, profesores |
| 👥 `group` | Grupo | Grupos de alumnos |
| 📍 `place` | Localización | Lugares, destinos |
| 💰 `attach_money` | Dinero | Presupuesto, costes |
| 🚌 `directions_bus` | Transporte | Empresas de transporte |
| 🏨 `hotel` | Alojamiento | Hoteles, albergues |
| 📄 `description` | Documento | Folletos, archivos |
| 📷 `photo_camera` | Cámara | Galería de fotos |
| 💬 `chat` | Chat | Mensajes |
| 🔍 `search` | Búsqueda | Buscadores |
| ✏️ `edit` | Editar | Edición |
| 🗑️ `delete` | Eliminar | Borrado |
| 💾 `save` | Guardar | Guardar cambios |
| 🔄 `refresh` | Revertir | Deshacer cambios |
| ⚠️ `warning` | Advertencia | Alertas |
| ✓ `check` | Correcto | Confirmación |
| ✕ `close` | Cerrar | Cancelar |

**Tamaños de Iconos**:
- **Pequeño**: 16px (inline con texto)
- **Mediano**: 24px (botones, listas)
- **Grande**: 48px (headers, destacados)
- **Extra Grande**: 64px (estados vacíos, errores)

---

### 6.7.5 Espaciado y Márgenes

**Sistema de Espaciado** (múltiplos de 4px):

| Variable | Valor | Uso |
|----------|-------|-----|
| `xs` | 4px | Espaciado mínimo |
| `sm` | 8px | Espaciado pequeño |
| `md` | 12px | Espaciado medio |
| `lg` | 16px | Espaciado estándar |
| `xl` | 24px | Espaciado grande |
| `xxl` | 32px | Espaciado extra grande |

**Padding de Contenedores**:
- Móvil: 12px
- Tablet: 16px
- Desktop: 24px

**Márgenes entre Elementos**:
- Entre secciones: 16-24px
- Entre tarjetas: 12px
- Entre campos de formulario: 12px
- Entre botones: 8px

---

### 6.7.6 Bordes y Sombras

**Bordes Redondeados**:
- **Botones**: 8px
- **Tarjetas**: 12px
- **Diálogos**: 16px
- **Campos de texto**: 8px

**Sombras (Elevación)**:

```css
/* Nivel 1 - Tarjetas */
box-shadow: 0 2px 4px rgba(0,0,0,0.1);

/* Nivel 2 - Botones elevados */
box-shadow: 0 4px 8px rgba(0,0,0,0.15);

/* Nivel 3 - Diálogos */
box-shadow: 0 8px 16px rgba(0,0,0,0.2);

/* Nivel 4 - Menús flotantes */
box-shadow: 0 12px 24px rgba(0,0,0,0.25);
```

**Bordes**:
- Grosor estándar: 1px
- Color claro: rgba(0,0,0,0.1)
- Color oscuro: rgba(255,255,255,0.1)

---

### 6.7.7 Animaciones y Transiciones

**Duraciones**:
- **Rápida**: 150ms (hover, focus)
- **Normal**: 300ms (transiciones estándar)
- **Lenta**: 500ms (cambios de página)

**Curvas de Animación**:
- **Ease-in-out**: Transiciones suaves
- **Ease-out**: Entrada de elementos
- **Ease-in**: Salida de elementos

**Animaciones Específicas**:
- Hover en botones: `scale(1.02)` en 150ms
- Abrir diálogo: Fade-in + Scale-up en 300ms
- Cambio de página: Slide lateral en 300ms
- Loading spinner: Rotación continua

---

### 6.7.8 Responsive Design

**Breakpoints**:

| Dispositivo | Ancho | Layout |
|-------------|-------|--------|
| **Móvil Portrait** | < 600px | 1 columna |
| **Móvil Landscape** | 600-960px | 2 columnas adaptable |
| **Tablet** | 960-1280px | 2-3 columnas |
| **Desktop** | > 1280px | 3+ columnas + sidebar |

**Adaptaciones**:
- **Móvil**: Navegación inferior, menú hamburguesa
- **Tablet**: Navegación lateral colapsable
- **Desktop**: Navegación lateral fija, múltiples paneles

---

## 6.8 DISEÑO DE PROCEDIMIENTOS Y ALGORITMOS

### 6.8.1 Flujo de Autenticación

**Descripción**: Proceso completo de inicio de sesión con validación JWT.

```
┌─────────────┐
│   INICIO    │
│ LoginView   │
└──────┬──────┘
       │
       ▼
┌─────────────────────────┐
│ Usuario ingresa:        │
│ - Email                 │
│ - Password              │
└──────┬──────────────────┘
       │
       ▼
┌─────────────────────────┐
│ validateForm()          │
│ ¿Campos completos?      │
└──────┬────┬─────────────┘
       │    │ NO
       │    └──────────────────┐
       │ SÍ                    │
       ▼                       ▼
┌─────────────────────┐  ┌──────────────┐
│ apiService.login()  │  │ Mostrar error│
│ POST /api/auth/login│  │ de validación│
└──────┬──────────────┘  └──────────────┘
       │
       ▼
┌─────────────────────────┐
│ Backend verifica:       │
│ 1. Usuario existe       │
│ 2. Password correcto    │
│ 3. Usuario activo       │
└──────┬────┬─────────────┘
       │    │ ERROR
       │    └──────────────────┐
       │ OK                    │
       ▼                       ▼
┌─────────────────────┐  ┌──────────────┐
│ Generar JWT Token   │  │ HTTP 401     │
│ - Payload: userId   │  │ Credenciales │
│ - Expiry: 24h       │  │ inválidas    │
└──────┬──────────────┘  └──────┬───────┘
       │                        │
       ▼                        ▼
┌─────────────────────┐  ┌──────────────┐
│ Guardar en Storage: │  │ Mostrar error│
│ - Token JWT         │  │ al usuario   │
│ - User Info         │  └──────────────┘
│ - Expiry Date       │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ auth.setAuth(true)  │
│ Notificar listeners │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ Navigator.push()    │
│ → HomeView          │
└─────────────────────┘
       │
       ▼
┌─────────────┐
│   FIN       │
│  Dashboard  │
└─────────────┘
```

**Resumen por Bloque**:
1. **Entrada de datos**: Captura email y password del usuario
2. **Validación local**: Verifica que los campos no estén vacíos y el email sea válido
3. **Petición HTTP**: Envía credenciales al backend via POST
4. **Verificación backend**: Comprueba usuario, password hasheado y estado
5. **Generación token**: Crea JWT con información del usuario y expiración
6. **Almacenamiento seguro**: Guarda token en FlutterSecureStorage
7. **Actualización estado**: Notifica al Provider Auth del cambio
8. **Navegación**: Redirige a la pantalla principal

---

### 6.8.2 Flujo de Guardado de Actividad

**Descripción**: Proceso de guardar cambios en una actividad con validación y actualización de relaciones.

```
┌─────────────┐
│   INICIO    │
│ [Guardar]   │
└──────┬──────┘
       │
       ▼
┌────────────────────────┐
│ _datosEditados?        │
│ ¿Hay cambios?          │
└──────┬────┬────────────┘
       │    │ NO
       │    └───────────────────┐
       │ SÍ                     │
       ▼                        ▼
┌────────────────────────┐ ┌─────────────┐
│ validateFields()       │ │ Mostrar     │
│ ¿Todos válidos?        │ │ "Sin cambios"│
└──────┬────┬────────────┘ └─────────────┘
       │    │ INVÁLIDO
       │    └───────────────────┐
       │ VÁLIDO                 │
       ▼                        ▼
┌────────────────────────┐ ┌─────────────┐
│ Mostrar loading        │ │ Mostrar     │
│ "Guardando..."         │ │ errores     │
└──────┬─────────────────┘ └─────────────┘
       │
       ▼
┌────────────────────────┐
│ SaveHandler.save()     │
│ Orquesta todas las     │
│ operaciones            │
└──────┬─────────────────┘
       │
       ├──────────────────┐
       │                  │
       ▼                  ▼
┌─────────────┐    ┌──────────────┐
│ 1. Guardar  │    │ 2. Subir     │
│ actividad   │    │ folleto      │
│ PUT /api/.. │    │ (si cambió)  │
└──────┬──────┘    └──────┬───────┘
       │                  │
       ├──────────────────┤
       │
       ├──────────────────┬──────────────────┐
       │                  │                  │
       ▼                  ▼                  ▼
┌─────────────┐    ┌─────────────┐   ┌─────────────┐
│ 3. Guardar  │    │ 4. Guardar  │   │ 5. Guardar  │
│ profesores  │    │ grupos      │   │ localizac.  │
│ participant.│    │ participant.│   │             │
└──────┬──────┘    └──────┬──────┘   └──────┬──────┘
       │                  │                  │
       ├──────────────────┼──────────────────┤
       │
       ├──────────────────┬──────────────────┐
       │                  │                  │
       ▼                  ▼                  ▼
┌─────────────┐    ┌─────────────┐   ┌─────────────┐
│ 6. Guardar  │    │ 7. Eliminar │   │ 8. Subir    │
│ descrip.    │    │ imágenes    │   │ nuevas      │
│ fotos       │    │ marcadas    │   │ imágenes    │
└──────┬──────┘    └──────┬──────┘   └──────┬──────┘
       │                  │                  │
       └──────────────────┴──────────────────┘
                          │
                          ▼
                   ┌─────────────────┐
                   │ ¿Todos OK?      │
                   └──────┬────┬─────┘
                          │    │ ERROR
                          │    └────────────────┐
                          │ OK                  │
                          ▼                     ▼
                   ┌─────────────────┐   ┌─────────────┐
                   │ Limpiar         │   │ Rollback    │
                   │ _datosEditados  │   │ Mostrar     │
                   │                 │   │ error       │
                   └──────┬──────────┘   └─────────────┘
                          │
                          ▼
                   ┌─────────────────┐
                   │ _loadActivity() │
                   │ Recargar datos  │
                   └──────┬──────────┘
                          │
                          ▼
                   ┌─────────────────┐
                   │ Ocultar loading │
                   │ Mostrar success │
                   └──────┬──────────┘
                          │
                          ▼
                   ┌─────────────────┐
                   │   FIN           │
                   │ Datos guardados │
                   └─────────────────┘
```

**Resumen por Bloque**:
1. **Verificación de cambios**: Comprueba si hay datos en `_datosEditados`
2. **Validación**: Valida que todos los campos cumplan las reglas (fechas, presupuesto, etc.)
3. **Inicio guardado**: Muestra indicador de carga y inicia proceso
4. **Guardar actividad base**: PUT a `/api/Actividad/{id}` con datos principales
5. **Subir folleto**: Si hay nuevo folleto, POST a `/api/Actividad/{id}/folleto`
6. **Guardar participantes**: PUT a endpoints de profesores y grupos participantes
7. **Guardar localizaciones**: POST/PUT/DELETE de localizaciones modificadas
8. **Gestión de imágenes**: Actualiza descripciones, elimina marcadas, sube nuevas
9. **Verificación final**: Comprueba que todas las operaciones fueron exitosas
10. **Recarga**: Obtiene datos actualizados desde el servidor
11. **Notificación**: Muestra mensaje de éxito y oculta loading

**Manejo de Errores**:
- Si alguna operación falla, se muestra el error específico
- Las operaciones ya completadas no se revierten (idempotencia)
- El usuario puede reintentar el guardado

---

### 6.8.3 Flujo de Envío de Mensaje en Chat

**Descripción**: Proceso de enviar un mensaje con multimedia a través de Firebase.

```
┌─────────────┐
│   INICIO    │
│ [Enviar] 📤 │
└──────┬──────┘
       │
       ▼
┌────────────────────────┐
│ ¿Hay texto o archivo?  │
└──────┬────┬────────────┘
       │    │ NO
       │    └───────────────────┐
       │ SÍ                     │
       ▼                        ▼
┌────────────────────────┐ ┌─────────────┐
│ Generar mensaje local  │ │ Ignorar     │
│ - ID temporal          │ │ (botón      │
│ - Estado: "sending"    │ │ deshabilitado)│
│ - Timestamp            │ └─────────────┘
└──────┬─────────────────┘
       │
       ▼
┌────────────────────────┐
│ Añadir a UI            │
│ (optimistic update)    │
└──────┬─────────────────┘
       │
       ▼
┌────────────────────────┐
│ ¿Hay archivo adjunto?  │
└──────┬────┬────────────┘
       │    │ NO
       │    └───────────────────┐
       │ SÍ                     │
       ▼                        │
┌────────────────────────┐      │
│ firebaseStorage        │      │
│ .uploadFile()          │      │
│ - Compresión si imagen │      │
│ - Genera thumbnail     │      │
│ - Obtiene URL pública  │      │
└──────┬─────────────────┘      │
       │                        │
       │ ┌──────────────────────┘
       │ │
       ▼ ▼
┌────────────────────────┐
│ Crear documento en     │
│ Firestore:             │
│ /chats/{id}/messages/  │
│ - messageId            │
│ - senderId             │
│ - text                 │
│ - mediaUrl (opcional)  │
│ - mediaType (opcional) │
│ - timestamp            │
│ - readBy: []           │
└──────┬─────────────────┘
       │
       ▼
┌────────────────────────┐
│ ¿Escritura OK?         │
└──────┬────┬────────────┘
       │    │ ERROR
       │    └────────────────────┐
       │ OK                      │
       ▼                         ▼
┌────────────────────────┐ ┌──────────────┐
│ Actualizar mensaje UI  │ │ Marcar msg   │
│ Estado: "sent"         │ │ como error   │
│ ID real de Firestore   │ │ Mostrar retry│
└──────┬─────────────────┘ └──────────────┘
       │
       ▼
┌────────────────────────┐
│ Actualizar último      │
│ mensaje del chat       │
│ /chats/{id}            │
│ - lastMessage          │
│ - lastMessageTime      │
│ - unreadCount          │
└──────┬─────────────────┘
       │
       ▼
┌────────────────────────┐
│ Enviar notificación    │
│ FCM a participantes    │
│ (excepto remitente)    │
└──────┬─────────────────┘
       │
       ▼
┌────────────────────────┐
│   FIN                  │
│ Mensaje enviado        │
└────────────────────────┘
```

**Resumen por Bloque**:
1. **Validación inicial**: Verifica que haya texto o archivo para enviar
2. **Mensaje optimista**: Crea mensaje local y lo muestra inmediatamente en UI
3. **Subida de archivo**: Si hay multimedia, sube a Firebase Storage
4. **Compresión**: Las imágenes se comprimen automáticamente
5. **Generación thumbnail**: Se crea miniatura para imágenes/videos
6. **Escritura Firestore**: Guarda el mensaje en la colección del chat
7. **Actualización UI**: Cambia estado de "enviando" a "enviado"
8. **Actualización chat**: Actualiza último mensaje y contador de no leídos
9. **Notificación push**: Envía notificación FCM a otros participantes
10. **Finalización**: Mensaje visible para todos en tiempo real

**Stream de Mensajes**:
- Los mensajes se reciben en tiempo real via Stream de Firestore
- Ordenados por timestamp descendente
- Filtrados por chatId
- Actualizaciones automáticas sin polling

---

### 6.8.4 Flujo de Detección de Cambios no Guardados

**Descripción**: Sistema de detección y prevención de pérdida de datos.

```
┌─────────────┐
│   INICIO    │
│ EditField   │
└──────┬──────┘
       │
       ▼
┌────────────────────────┐
│ onChanged() evento     │
│ Usuario modifica campo │
└──────┬─────────────────┘
       │
       ▼
┌────────────────────────┐
│ _datosEditados[key]    │
│ = nuevoValor           │
└──────┬─────────────────┘
       │
       ▼
┌────────────────────────┐
│ _notifyChanges()       │
│ Notificar al padre     │
└──────┬─────────────────┘
       │
       ▼
┌────────────────────────┐
│ setState()             │
│ _hasUnsavedChanges     │
│ = true                 │
└──────┬─────────────────┘
       │
       ▼
┌────────────────────────┐
│ Mostrar botones:       │
│ [Guardar] [Revertir]   │
└────────────────────────┘
       │
       │ [Usuario intenta salir]
       ▼
┌────────────────────────┐
│ WillPopScope()         │
│ Intercepta navegación  │
└──────┬─────────────────┘
       │
       ▼
┌────────────────────────┐
│ ¿Hay cambios sin       │
│ guardar?               │
└──────┬────┬────────────┘
       │    │ NO
       │    └───────────────────┐
       │ SÍ                     │
       ▼                        ▼
┌────────────────────────┐ ┌─────────────┐
│ Mostrar diálogo:       │ │ Permitir    │
│ "Tienes cambios sin    │ │ navegación  │
│ guardar. ¿Deseas       │ └─────────────┘
│ salir de todos modos?" │
└──────┬────┬────────────┘
       │    │ [Cancelar]
       │    └───────────────────┐
       │ [Salir]                │
       ▼                        ▼
┌────────────────────────┐ ┌─────────────┐
│ Descartar cambios      │ │ Permanecer  │
│ Permitir navegación    │ │ en pantalla │
└────────────────────────┘ └─────────────┘
       │
       ▼
┌─────────────┐
│   FIN       │
└─────────────┘
```

**Resumen por Bloque**:
1. **Captura de cambio**: Campo de texto notifica cambio via `onChanged`
2. **Almacenamiento**: Guarda nuevo valor en mapa `_datosEditados`
3. **Notificación**: Llama a callback `_notifyChanges()` del padre
4. **Actualización estado**: Marca `_hasUnsavedChanges = true`
5. **UI actualizada**: Muestra botones de guardar y revertir
6. **Interceptación**: `WillPopScope` captura intento de salir
7. **Verificación**: Comprueba si hay cambios pendientes
8. **Diálogo confirmación**: Pregunta al usuario si desea descartar
9. **Decisión usuario**: Puede cancelar o confirmar salida
10. **Acción final**: Descarta cambios o permanece en pantalla

**Casos Especiales**:
- Si el usuario guarda, `_datosEditados` se limpia automáticamente
- Si revierte, se restauran valores originales desde `widget.actividad`
- Los cambios en listas (participantes, fotos) también se detectan

---

Esta documentación proporciona una visión completa del diseño del sistema ACEX, desde la arquitectura hasta los detalles de implementación de interfaces y flujos lógicos.

---
---

# 7. PLANIFICACIÓN DEL PROYECTO

## 7.1 DEFINICIÓN DE ACTIVIDADES Y TAREAS

### 7.1.1 Estructura Jerárquica del Proyecto (WBS)

```
ACEX - SISTEMA DE GESTIÓN DE ACTIVIDADES EXTRAESCOLARES
│
├─ 1. ANÁLISIS Y DISEÑO
│  ├─ 1.1 Análisis de requisitos
│  │  ├─ 1.1.1 Reuniones con stakeholders
│  │  ├─ 1.1.2 Documentación de requisitos funcionales
│  │  ├─ 1.1.3 Documentación de requisitos no funcionales
│  │  └─ 1.1.4 Casos de uso y escenarios
│  │
│  ├─ 1.2 Diseño de base de datos
│  │  ├─ 1.2.1 Modelo Entidad-Relación
│  │  ├─ 1.2.2 Normalización y optimización
│  │  ├─ 1.2.3 Scripts de creación
│  │  └─ 1.2.4 Scripts de datos iniciales
│  │
│  └─ 1.3 Diseño de arquitectura
│     ├─ 1.3.1 Arquitectura del sistema
│     ├─ 1.3.2 Diagramas de clases
│     ├─ 1.3.3 Diseño de APIs REST
│     └─ 1.3.4 Diseño de interfaces de usuario
│
├─ 2. DESARROLLO BACKEND
│  ├─ 2.1 Configuración inicial
│  │  ├─ 2.1.1 Creación proyecto ASP.NET Core
│  │  ├─ 2.1.2 Configuración Entity Framework
│  │  ├─ 2.1.3 Configuración autenticación JWT
│  │  └─ 2.1.4 Configuración CORS y middleware
│  │
│  ├─ 2.2 Modelos y repositorios
│  │  ├─ 2.2.1 Creación de modelos de datos
│  │  ├─ 2.2.2 Migraciones de base de datos
│  │  ├─ 2.2.3 Repositorios y DbContext
│  │  └─ 2.2.4 DTOs y mapeos
│  │
│  ├─ 2.3 Servicios de negocio
│  │  ├─ 2.3.1 Servicio de actividades
│  │  ├─ 2.3.2 Servicio de profesores
│  │  ├─ 2.3.3 Servicio de autenticación
│  │  ├─ 2.3.4 Servicio de almacenamiento (Firebase)
│  │  └─ 2.3.5 Servicio de notificaciones (FCM)
│  │
│  ├─ 2.4 Controladores API
│  │  ├─ 2.4.1 ActividadController
│  │  ├─ 2.4.2 ProfesorController
│  │  ├─ 2.4.3 CatalogoController
│  │  ├─ 2.4.4 AuthController
│  │  └─ 2.4.5 NotificationController
│  │
│  └─ 2.5 Testing backend
│     ├─ 2.5.1 Unit tests de servicios
│     ├─ 2.5.2 Integration tests de API
│     └─ 2.5.3 Tests de autenticación
│
├─ 3. INTEGRACIÓN FIREBASE
│  ├─ 3.1 Configuración Firebase
│  │  ├─ 3.1.1 Creación proyecto Firebase
│  │  ├─ 3.1.2 Configuración Firestore
│  │  ├─ 3.1.3 Configuración Storage
│  │  └─ 3.1.4 Configuración Cloud Messaging
│  │
│  ├─ 3.2 Chat en tiempo real
│  │  ├─ 3.2.1 Estructura de colecciones Firestore
│  │  ├─ 3.2.2 Reglas de seguridad Firestore
│  │  ├─ 3.2.3 Servicio de chat backend
│  │  └─ 3.2.4 Testing de mensajería
│  │
│  └─ 3.3 Notificaciones push
│     ├─ 3.3.1 Gestión de tokens FCM
│     ├─ 3.3.2 Servicio de envío de notificaciones
│     └─ 3.3.3 Testing de notificaciones
│
├─ 4. DESARROLLO FRONTEND
│  ├─ 4.1 Configuración inicial Flutter
│  │  ├─ 4.1.1 Creación proyecto Flutter
│  │  ├─ 4.1.2 Configuración dependencias
│  │  ├─ 4.1.3 Estructura de carpetas
│  │  └─ 4.1.4 Configuración multiplataforma
│  │
│  ├─ 4.2 Sistema de diseño
│  │  ├─ 4.2.1 Definición de colores y temas
│  │  ├─ 4.2.2 Widgets reutilizables
│  │  ├─ 4.2.3 Responsive design
│  │  └─ 4.2.4 Animaciones y transiciones
│  │
│  ├─ 4.3 Gestión de estado
│  │  ├─ 4.3.1 Providers (ChangeNotifier)
│  │  ├─ 4.3.2 Modelos de datos
│  │  └─ 4.3.3 Servicios API client
│  │
│  ├─ 4.4 Pantallas principales
│  │  ├─ 4.4.1 Login y autenticación
│  │  ├─ 4.4.2 Home y lista de actividades
│  │  ├─ 4.4.3 Detalle de actividad (5 pestañas)
│  │  ├─ 4.4.4 Formulario de edición
│  │  ├─ 4.4.5 Chat de actividad
│  │  ├─ 4.4.6 Mapa de localizaciones
│  │  └─ 4.4.7 Galería de imágenes
│  │
│  ├─ 4.5 Funcionalidades avanzadas
│  │  ├─ 4.5.1 Persistencia de sesión
│  │  ├─ 4.5.2 Subida de archivos
│  │  ├─ 4.5.3 Gestión de folletos PDF
│  │  ├─ 4.5.4 Detección de cambios no guardados
│  │  └─ 4.5.5 Notificaciones locales
│  │
│  └─ 4.6 Testing frontend
│     ├─ 4.6.1 Unit tests de servicios
│     ├─ 4.6.2 Widget tests
│     └─ 4.6.3 Integration tests
│
├─ 5. DESPLIEGUE E INFRAESTRUCTURA
│  ├─ 5.1 Configuración servidores
│  │  ├─ 5.1.1 Servidor SQL Server (Azure/local)
│  │  ├─ 5.1.2 Servidor API ASP.NET Core
│  │  └─ 5.1.3 Configuración Firebase producción
│  │
│  ├─ 5.2 Compilación aplicaciones
│  │  ├─ 5.2.1 Build Android APK/AAB
│  │  ├─ 5.2.2 Build iOS IPA
│  │  ├─ 5.2.3 Build Web
│  │  └─ 5.2.4 Build Windows/macOS/Linux
│  │
│  └─ 5.3 Publicación
│     ├─ 5.3.1 Deploy API a servidor
│     ├─ 5.3.2 Publicación Google Play Store
│     ├─ 5.3.3 Publicación Apple App Store
│     └─ 5.3.4 Hosting aplicación web
│
└─ 6. DOCUMENTACIÓN Y CIERRE
   ├─ 6.1 Documentación técnica
   │  ├─ 6.1.1 Manual de instalación
   │  ├─ 6.1.2 Documentación de APIs
   │  ├─ 6.1.3 Guía de arquitectura
   │  └─ 6.1.4 Documentación de código
   │
   ├─ 6.2 Documentación de usuario
   │  ├─ 6.2.1 Manual de usuario
   │  ├─ 6.2.2 Tutoriales y guías
   │  └─ 6.2.3 FAQs y solución de problemas
   │
   └─ 6.3 Entrega final
      ├─ 6.3.1 Presentación del proyecto
      ├─ 6.3.2 Memoria técnica
      └─ 6.3.3 Entrega de código fuente
```

---

## 7.2 DIAGRAMA DE GANTT (CRONOGRAMA)

### 7.2.1 Planificación Temporal del Proyecto

**Duración total estimada**: 16 semanas (4 meses)

**Periodo**: Septiembre 2024 - Diciembre 2024

#### **Diagrama de Gantt Detallado**

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ ID │ ACTIVIDAD                          │ DUR │ SEP 2025  │ OCT 2025  │ NOV 2025  │ DIC 2025  │                                      │
│    │                                    │(sem)│ 1 2 3 4   │ 1 2 3 4   │ 1 2 3 4   │ 1 2 3 4   │                                      │
├────┼────────────────────────────────────┼─────┼───────────┼───────────┼───────────┼───────────┤                                      │
│ 1  │ ■ ANÁLISIS Y DISEÑO                │  3  │███████████│           │           │           │ HITO 1: Diseño completado            │
│    │                                    │     │           │           │           │           │                                      │
│1.1 │   Análisis de requisitos           │  1  │███        │           │           │           │                                      │
│1.2 │   Diseño de base de datos          │  1  │   ███     │           │           │           │                                      │
│1.3 │   Diseño de arquitectura           │  1  │      ███  │           │           │           │                                      │
│    │                                    │     │         ▼ │           │           │           │                                      │
├────┼────────────────────────────────────┼─────┼───────────┼───────────┼───────────┼───────────┤                                      │
│ 2  │ ■ DESARROLLO BACKEND               │  5  │      █████│███████████│███        │           │ HITO 2: Backend funcional            │
│    │                                    │     │           │           │           │           │                                      │
│2.1 │   Configuración inicial            │  1  │      ███  │           │           │           │                                      │
│2.2 │   Modelos y repositorios           │  1  │         ██│█          │           │           │                                      │
│2.3 │   Servicios de negocio             │  2  │           │ ██████    │           │           │                                      │
│2.4 │   Controladores API                │  1  │           │      ███  │           │           │                                      │
│2.5 │   Testing backend                  │  1  │           │         ██│█          │           │                                      │
│    │                                    │     │           │           │ ▼         │           │                                      │
├────┼────────────────────────────────────┼─────┼───────────┼───────────┼───────────┼───────────┤                                      │
│ 3  │ ■ INTEGRACIÓN FIREBASE             │  2  │           │      █████│███        │           │ HITO 3: Chat y notif. operativos     │
│    │                                    │     │           │           │           │           │                                      │
│3.1 │   Configuración Firebase           │  1  │           │      ███  │           │           │                                      │
│3.2 │   Chat en tiempo real              │  1  │           │         ██│█          │           │                                      │
│3.3 │   Notificaciones push              │  1  │           │           │ ███       │           │                                      │
│    │                                    │     │           │           │   ▼       │           │                                      │
├────┼────────────────────────────────────┼─────┼───────────┼───────────┼───────────┼───────────┤                                      │
│ 4  │ ■ DESARROLLO FRONTEND              │  6  │           │   ████████│███████████│███        │ HITO 4: App completa                 │
│    │                                    │     │           │           │           │           │                                      │
│4.1 │   Configuración inicial Flutter    │  1  │           │   ███     │           │           │                                      │
│4.2 │   Sistema de diseño                │  1  │           │      ███  │           │           │                                      │
│4.3 │   Gestión de estado                │  1  │           │         ██│█          │           │                                      │
│4.4 │   Pantallas principales            │  2  │           │           │ ██████    │           │                                      │
│4.5 │   Funcionalidades avanzadas        │  1  │           │           │      ███  │           │                                      │
│4.6 │   Testing frontend                 │  1  │           │           │         ██│█          │                                      │
│    │                                    │     │           │           │           │ ▼         │                                      │
├────┼────────────────────────────────────┼─────┼───────────┼───────────┼───────────┼───────────┤                                      │
│ 5  │ ■ DESPLIEGUE E INFRAESTRUCTURA     │  2  │           │           │           │ ██████    │ HITO 5: Sistema en producción        │
│    │                                    │     │           │           │           │           │                                      │
│5.1 │   Configuración servidores         │  1  │           │           │           │ ███       │                                      │
│5.2 │   Compilación aplicaciones         │  1  │           │           │           │    ███    │                                      │
│5.3 │   Publicación                      │  1  │           │           │           │      ███  │                                      │
│    │                                    │     │           │           │           │        ▼  │                                      │
├────┼────────────────────────────────────┼─────┼───────────┼───────────┼───────────┼───────────┤                                      │
│ 6  │ ■ DOCUMENTACIÓN Y CIERRE           │  2  │           │           │           │    ███████│ HITO 6: Proyecto finalizado          │
│    │                                    │     │           │           │           │           │                                      │
│6.1 │   Documentación técnica            │  1  │           │           │           │    ███    │                                      │
│6.2 │   Documentación de usuario         │  1  │           │           │           │       ███ │                                      │
│6.3 │   Entrega final                    │  1  │           │           │           │         ██│█                                     │
│    │                                    │     │           │           │           │           │▼ ENTREGA                             │
└────┴────────────────────────────────────┴─────┴───────────┴───────────┴───────────┴───────────┴──────────────────────────────────────┘

LEYENDA:
███ Trabajo en progreso
 ▼  Hito alcanzado
 █  Reserva/margen de tiempo
```

---

### 7.2.2 Tabla Detallada de Actividades

| ID | Actividad | Inicio | Fin | Duración | Predecesoras | Recursos |
|----|-----------|--------|-----|----------|--------------|----------|
| **1** | **ANÁLISIS Y DISEÑO** | **01/09** | **22/09** | **3 sem** | - | **Analista/Arquitecto** |
| 1.1 | Análisis de requisitos | 01/09 | 08/09 | 1 sem | - | Analista + Cliente |
| 1.2 | Diseño de base de datos | 08/09 | 15/09 | 1 sem | 1.1 | Arquitecto BD |
| 1.3 | Diseño de arquitectura | 15/09 | 22/09 | 1 sem | 1.2 | Arquitecto Software |
| **2** | **DESARROLLO BACKEND** | **15/09** | **27/10** | **5 sem** | **1.2** | **Dev. Backend (2)** |
| 2.1 | Configuración inicial | 15/09 | 22/09 | 1 sem | 1.2 | Dev. Backend Senior |
| 2.2 | Modelos y repositorios | 22/09 | 29/09 | 1 sem | 2.1 | Dev. Backend (2) |
| 2.3 | Servicios de negocio | 29/09 | 13/10 | 2 sem | 2.2 | Dev. Backend (2) |
| 2.4 | Controladores API | 13/10 | 20/10 | 1 sem | 2.3 | Dev. Backend Senior |
| 2.5 | Testing backend | 20/10 | 27/10 | 1 sem | 2.4 | Dev. Backend + Tester |
| **3** | **INTEGRACIÓN FIREBASE** | **06/10** | **03/11** | **2 sem** | **2.3** | **Dev. Backend + Cloud** |
| 3.1 | Configuración Firebase | 06/10 | 13/10 | 1 sem | 2.3 | Dev. Cloud |
| 3.2 | Chat en tiempo real | 13/10 | 20/10 | 1 sem | 3.1 | Dev. Backend |
| 3.3 | Notificaciones push | 27/10 | 03/11 | 1 sem | 3.2 | Dev. Backend |
| **4** | **DESARROLLO FRONTEND** | **29/09** | **17/11** | **6 sem** | **2.1** | **Dev. Frontend (2)** |
| 4.1 | Configuración Flutter | 29/09 | 06/10 | 1 sem | 2.1 | Dev. Frontend Senior |
| 4.2 | Sistema de diseño | 06/10 | 13/10 | 1 sem | 4.1 | Dev. Frontend + Designer |
| 4.3 | Gestión de estado | 13/10 | 20/10 | 1 sem | 4.2 | Dev. Frontend (2) |
| 4.4 | Pantallas principales | 20/10 | 03/11 | 2 sem | 4.3, 2.4 | Dev. Frontend (2) |
| 4.5 | Funcionalidades avanzadas | 03/11 | 10/11 | 1 sem | 4.4, 3.3 | Dev. Frontend (2) |
| 4.6 | Testing frontend | 10/11 | 17/11 | 1 sem | 4.5 | Dev. Frontend + Tester |
| **5** | **DESPLIEGUE** | **17/11** | **01/12** | **2 sem** | **4.6** | **DevOps + Equipo** |
| 5.1 | Configuración servidores | 17/11 | 24/11 | 1 sem | 4.6, 2.5 | DevOps |
| 5.2 | Compilación aplicaciones | 24/11 | 28/11 | 0.5 sem | 5.1 | Dev. Frontend |
| 5.3 | Publicación | 28/11 | 01/12 | 0.5 sem | 5.2 | DevOps + Project Mgr |
| **6** | **DOCUMENTACIÓN** | **24/11** | **22/12** | **2 sem** | **5.1** | **Tech Writer + Equipo** |
| 6.1 | Documentación técnica | 24/11 | 01/12 | 1 sem | 5.1 | Tech Writer + Devs |
| 6.2 | Documentación usuario | 01/12 | 08/12 | 1 sem | 6.1 | Tech Writer |
| 6.3 | Entrega final | 15/12 | 22/12 | 1 sem | 6.2 | Project Manager |

---

### 7.2.3 Hitos del Proyecto

| Hito | Descripción | Fecha | Entregables |
|------|-------------|-------|-------------|
| **H1** | Diseño Completado | 22/09/2024 | • Documento de requisitos<br>• Diagramas E/R<br>• Diagramas de arquitectura<br>• Mockups de UI |
| **H2** | Backend Funcional | 27/10/2024 | • API REST operativa<br>• Endpoints documentados<br>• Tests unitarios pasando<br>• Base de datos poblada |
| **H3** | Firebase Integrado | 03/11/2024 | • Chat en tiempo real funcionando<br>• Notificaciones push operativas<br>• Storage configurado |
| **H4** | Aplicación Completa | 17/11/2024 | • App Flutter compilando<br>• Todas las pantallas implementadas<br>• Tests de integración pasando |
| **H5** | Sistema en Producción | 01/12/2024 | • API desplegada en servidor<br>• Apps publicadas (Android/iOS)<br>• Web hosting activo |
| **H6** | Proyecto Finalizado | 22/12/2024 | • Documentación completa<br>• Manuales de usuario<br>• Presentación final<br>• Código fuente entregado |

---

## 7.3 RECURSOS Y LOGÍSTICA

### 7.3.1 Recursos Humanos

| Rol | Cantidad | Dedicación | Periodo | Responsabilidades |
|-----|----------|------------|---------|-------------------|
| **Project Manager** | 1 | Tiempo parcial (25%) | Todo el proyecto | • Coordinación general<br>• Seguimiento de plazos<br>• Gestión de riesgos<br>• Comunicación con stakeholders |
| **Analista/Arquitecto** | 1 | Tiempo completo | Semanas 1-3 | • Análisis de requisitos<br>• Diseño de arquitectura<br>• Diseño de base de datos<br>• Documentación técnica |
| **Dev. Backend Senior** | 1 | Tiempo completo | Semanas 3-11 | • Configuración inicial<br>• Desarrollo de APIs<br>• Integración Firebase<br>• Revisión de código<br>• Mentoring |
| **Dev. Backend Junior** | 1 | Tiempo completo | Semanas 4-11 | • Desarrollo de servicios<br>• Creación de DTOs<br>• Testing unitario<br>• Documentación de código |
| **Dev. Frontend Senior** | 1 | Tiempo completo | Semanas 4-14 | • Configuración Flutter<br>• Arquitectura del código<br>• Pantallas complejas<br>• Revisión de código |
| **Dev. Frontend Junior** | 1 | Tiempo completo | Semanas 5-14 | • Sistema de diseño<br>• Widgets reutilizables<br>• Pantallas secundarias<br>• Testing de UI |
| **QA/Tester** | 1 | Tiempo parcial (50%) | Semanas 11-14 | • Tests de integración<br>• Tests E2E<br>• Reporte de bugs<br>• Validación de requisitos |
| **DevOps Engineer** | 1 | Tiempo parcial (50%) | Semanas 14-16 | • Configuración servidores<br>• CI/CD pipelines<br>• Despliegue aplicaciones<br>• Monitoreo |
| **UI/UX Designer** | 1 | Tiempo parcial (25%) | Semanas 1-6 | • Diseño de mockups<br>• Guía de estilos<br>• Validación de usabilidad<br>• Diseño de iconos |
| **Technical Writer** | 1 | Tiempo parcial (50%) | Semanas 14-17 | • Documentación técnica<br>• Manuales de usuario<br>• Tutoriales<br>• FAQs |

**Total personas involucradas**: 10 profesionales

---

### 7.3.2 Recursos Técnicos (Hardware)

| Recurso | Cantidad | Uso | Coste Unitario | Coste Total |
|---------|----------|-----|----------------|-------------|
| **Portátil Dev (Windows)** | 4 | Desarrollo backend/frontend | 1.200 € | 4.800 € |
| **Portátil Dev (MacBook Pro)** | 2 | Desarrollo iOS | 2.500 € | 5.000 € |
| **Servidor local desarrollo** | 1 | Testing y pruebas | 1.500 € | 1.500 € |
| **iPhone (testing iOS)** | 1 | Testing aplicación iOS | 800 € | 800 € |
| **Android devices (varios)** | 3 | Testing aplicación Android | 300 € | 900 € |
| **Tablet Android** | 1 | Testing UI responsive | 400 € | 400 € |
| **Monitor adicional** | 6 | Mejora productividad | 200 € | 1.200 € |
| **Almacenamiento NAS** | 1 | Backup y compartir archivos | 600 € | 600 € |

**Total Hardware**: **15.200 €**

---

### 7.3.3 Recursos Técnicos (Software y Servicios)

| Recurso | Tipo | Uso | Coste Mensual | Coste Total (4 meses) |
|---------|------|-----|---------------|----------------------|
| **Visual Studio Professional** | Licencia | IDE backend | 45 € × 2 dev | 360 € |
| **JetBrains IntelliJ/Rider** | Licencia | IDE alternativo | 24 € × 2 dev | 192 € |
| **GitHub Pro** | Suscripción | Control de versiones | 4 € × 10 users | 160 € |
| **Azure SQL Database** | Cloud | Base de datos desarrollo | 50 € | 200 € |
| **Azure App Service** | Cloud | Hosting API desarrollo | 40 € | 160 € |
| **Firebase Blaze Plan** | Cloud | Firestore + Storage + FCM | 30 € | 120 € |
| **Google Play Console** | Pago único | Publicación Android | - | 25 € |
| **Apple Developer Program** | Anual | Publicación iOS | 99 € | 99 € |
| **Figma Pro** | Suscripción | Diseño UI/UX | 12 € | 48 € |
| **Postman Team** | Suscripción | Testing APIs | 24 € | 96 € |
| **Jira Software** | Suscripción | Gestión de proyecto | 10 € × 10 users | 400 € |
| **Slack Pro** | Suscripción | Comunicación equipo | 6 € × 10 users | 240 € |
| **Office 365 Business** | Suscripción | Documentación | 10 € × 10 users | 400 € |

**Total Software y Servicios**: **2.500 €**

---

### 7.3.4 Infraestructura de Producción

| Recurso | Proveedor | Especificaciones | Coste Mensual | Coste Anual |
|---------|-----------|------------------|---------------|-------------|
| **SQL Server Database** | Azure | Standard S2 (50 DTUs) | 75 € | 900 € |
| **App Service (API)** | Azure | Premium P1V2 | 140 € | 1.680 € |
| **Firebase Hosting** | Google | Blaze Plan (uso moderado) | 50 € | 600 € |
| **CDN (imágenes)** | Cloudflare | Pro Plan | 20 € | 240 € |
| **Dominio .com** | GoDaddy | Registro anual | - | 12 € |
| **SSL Certificate** | Let's Encrypt | Gratuito | 0 € | 0 € |
| **Backup Storage** | Azure Blob | 100 GB redundante | 5 € | 60 € |
| **Monitoring (App Insights)** | Azure | Uso básico | 15 € | 180 € |

**Total Infraestructura (primer año)**: **3.672 €**

---

### 7.3.5 Espacios y Logística

| Recurso | Tipo | Cantidad | Coste Mensual | Coste Total (4 meses) |
|---------|------|----------|---------------|----------------------|
| **Espacio de oficina** | Alquiler | 50 m² | 800 € | 3.200 € |
| **Internet de alta velocidad** | Servicio | 1 línea 600 Mbps | 60 € | 240 € |
| **Electricidad y servicios** | Servicios | - | 150 € | 600 € |
| **Mobiliario (mesas, sillas)** | Compra | Para 10 personas | - | 2.500 € |
| **Material de oficina** | Consumibles | - | 50 € | 200 € |
| **Café y snacks** | Beneficios | - | 100 € | 400 € |

**Total Espacios y Logística**: **7.140 €**

---

## 7.4 PROCEDIMIENTOS DE CADA ACTIVIDAD

### 7.4.1 Análisis de Requisitos

**Objetivo**: Comprender y documentar las necesidades del sistema.

**Procedimiento**:
1. **Reunión inicial con stakeholders** (Director, profesores, administración)
   - Presentación del proyecto
   - Identificación de usuarios principales
   - Recopilación de necesidades primarias

2. **Entrevistas individuales** (2-3 sesiones de 1h)
   - Profesores: flujo de creación de actividades
   - Administración: gestión de presupuestos
   - Dirección: reportes y aprobaciones

3. **Análisis de sistemas actuales**
   - Revisar procesos manuales existentes
   - Identificar puntos de dolor
   - Documentar flujos de trabajo

4. **Documentación de requisitos**
   - Requisitos funcionales (numerados)
   - Requisitos no funcionales (rendimiento, seguridad)
   - Casos de uso detallados
   - User stories con criterios de aceptación

5. **Validación con cliente**
   - Presentación de documento de requisitos
   - Revisión y ajustes
   - Firma de aprobación

**Entregables**:
- Documento de Requisitos Funcionales
- Documento de Requisitos No Funcionales
- Casos de Uso Detallados
- User Stories

---

### 7.4.2 Diseño de Base de Datos

**Objetivo**: Crear estructura de datos eficiente y normalizada.

**Procedimiento**:
1. **Identificación de entidades**
   - Listar entidades principales (Actividad, Profesor, etc.)
   - Definir atributos de cada entidad
   - Identificar claves primarias

2. **Definición de relaciones**
   - Mapear relaciones entre entidades (1:N, N:M)
   - Crear tablas intermedias para N:M
   - Definir claves foráneas

3. **Normalización**
   - Aplicar 3FN (Tercera Forma Normal)
   - Eliminar redundancias
   - Optimizar estructura

4. **Creación de diagrama E/R**
   - Dibujar diagrama completo
   - Documentar cardinalidades
   - Añadir restricciones

5. **Scripts SQL**
   - Crear scripts de creación de tablas
   - Definir índices y constraints
   - Preparar datos de prueba

6. **Revisión y ajustes**
   - Validación con arquitecto
   - Ajustes de rendimiento
   - Aprobación final

**Entregables**:
- Diagrama Entidad-Relación
- Scripts CREATE TABLE
- Scripts de datos iniciales
- Documentación de tablas

---

### 7.4.3 Desarrollo de Servicios Backend

**Objetivo**: Implementar lógica de negocio del sistema.

**Procedimiento**:
1. **Análisis de requisitos del servicio**
   - Leer user stories asignadas
   - Identificar operaciones CRUD necesarias
   - Definir DTOs de entrada/salida

2. **Creación de interfaces**
   - Definir interfaz `IActividadService`
   - Declarar métodos públicos
   - Documentar parámetros y retornos

3. **Implementación de la clase**
   - Inyección de dependencias (DbContext, otros servicios)
   - Implementar métodos uno por uno
   - Aplicar principios SOLID

4. **Manejo de errores**
   - Validaciones de entrada
   - Try-catch de excepciones
   - Logs de errores

5. **Testing unitario**
   - Crear clase de test `ActividadServiceTests`
   - Mockear dependencias
   - Tests para casos exitosos y errores
   - Verificar cobertura > 80%

6. **Code review**
   - Pull request en GitHub
   - Revisión por desarrollador senior
   - Corrección de comentarios

7. **Merge a rama principal**
   - Verificar que tests pasan
   - Merge aprobado
   - Eliminar rama feature

**Entregables**:
- Código del servicio implementado
- Tests unitarios
- Documentación XML en código

---

### 7.4.4 Desarrollo de Pantallas Frontend

**Objetivo**: Crear interfaz de usuario funcional y responsive.

**Procedimiento**:
1. **Análisis del diseño**
   - Revisar mockup en Figma
   - Identificar widgets necesarios
   - Planificar estructura de widgets

2. **Creación del StatefulWidget**
   - Crear archivo `activity_detail_view.dart`
   - Definir clase con estado
   - Inicializar variables

3. **Implementación del layout**
   - Estructura con Scaffold
   - AppBar con título y acciones
   - Body con Column/ListView

4. **Conexión con Provider**
   - `Consumer<ActividadProvider>`
   - Escuchar cambios de estado
   - Actualizar UI automáticamente

5. **Llamadas a API**
   - Método `_loadData()` en `initState`
   - Mostrar loading mientras carga
   - Manejo de errores con SnackBar

6. **Interacciones de usuario**
   - Botones con `onPressed`
   - Formularios con validación
   - Navegación entre pantallas

7. **Testing de widget**
   - Widget tests para componentes
   - Verificar que renderiza correctamente
   - Simular interacciones de usuario

8. **Testing en dispositivos reales**
   - Probar en Android (3 dispositivos)
   - Probar en iOS (iPhone)
   - Probar en web (Chrome/Firefox)
   - Verificar responsive design

**Entregables**:
- Código de la pantalla
- Widget tests
- Capturas de pantalla

---

### 7.4.5 Integración de Chat con Firebase

**Objetivo**: Implementar mensajería en tiempo real.

**Procedimiento**:
1. **Configuración de Firebase**
   - Crear proyecto en Firebase Console
   - Añadir app Android con `google-services.json`
   - Añadir app iOS con `GoogleService-Info.plist`
   - Añadir app Web con configuración JS

2. **Estructura de Firestore**
   - Colección `chats`
   - Subcolección `messages`
   - Campos: senderId, text, timestamp, mediaUrl

3. **Reglas de seguridad**
   ```
   match /chats/{chatId} {
     allow read, write: if request.auth != null 
                        && exists(/databases/$(database)/documents/chats/$(chatId)/participants/$(request.auth.uid));
   }
   ```

4. **Servicio de Chat (Flutter)**
   - Clase `ChatService`
   - Método `sendMessage(chatId, message)`
   - Stream `getMessages(chatId)`
   - Método `uploadMedia(file)`

5. **Pantalla de Chat**
   - ListView con StreamBuilder
   - Burbuja de mensaje (izq/der según sender)
   - Campo de texto para escribir
   - Botón de envío

6. **Subida de archivos**
   - Firebase Storage para imágenes/videos
   - Compresión de imágenes antes de subir
   - URL público en mensaje

7. **Notificaciones push**
   - Cloud Functions para trigger
   - Envío de FCM al resto de participantes
   - Payload con chatId y texto

8. **Testing**
   - Enviar mensajes entre 2 usuarios
   - Verificar recepción en tiempo real
   - Probar envío de imágenes
   - Verificar notificaciones

**Entregables**:
- Estructura Firestore configurada
- Reglas de seguridad
- Código ChatService
- Pantalla de chat funcional

---

## 7.5 IDENTIFICACIÓN DE RIESGOS Y PLAN DE PREVENCIÓN

### 7.5.1 Matriz de Riesgos

| ID | Riesgo | Probabilidad | Impacto | Severidad | Mitigación | Contingencia |
|----|--------|--------------|---------|-----------|------------|--------------|
| **R1** | Retraso en análisis de requisitos | Media | Alto | **ALTO** | • Reuniones agendadas con antelación<br>• Buffer de 3 días | • Priorizar requisitos críticos<br>• Desarrollo iterativo |
| **R2** | Cambios en requisitos durante desarrollo | Alta | Alto | **CRÍTICO** | • Validación temprana con cliente<br>• Documentación detallada<br>• Reuniones de seguimiento semanales | • Proceso de change management<br>• Evaluación de impacto antes de aceptar |
| **R3** | Problemas de rendimiento de BD | Media | Medio | **MEDIO** | • Diseño normalizado<br>• Índices en columnas clave<br>• Tests de carga | • Optimización de queries<br>• Caché de datos frecuentes |
| **R4** | Incompatibilidad entre backend y frontend | Baja | Alto | **MEDIO** | • Contrato de APIs documentado<br>• DTOs versionados<br>• Tests de integración | • Reuniones diarias de sincronización<br>• Mock servers para desarrollo |
| **R5** | Fallos en integración con Firebase | Media | Alto | **ALTO** | • Documentación oficial de Firebase<br>• Desarrollo incremental<br>• Tests unitarios | • Soporte técnico de Google<br>• Implementación alternativa (WebSockets) |
| **R6** | Problemas de seguridad (autenticación) | Baja | Crítico | **ALTO** | • JWT con expiración<br>• HTTPS obligatorio<br>• Validación en backend<br>• Auditoría de seguridad | • Parche inmediato si se detecta fallo<br>• Rotación de secrets |
| **R7** | Bugs críticos en producción | Media | Alto | **ALTO** | • Testing exhaustivo (unit, integration, E2E)<br>• Code reviews obligatorios<br>• QA dedicado | • Rollback inmediato<br>• Hotfix prioritario<br>• Comunicación a usuarios |
| **R8** | Sobrecostes en infraestructura cloud | Media | Medio | **MEDIO** | • Monitoreo de costes en Azure/Firebase<br>• Alertas de presupuesto<br>• Plan Blaze con límites | • Optimización de queries<br>• Reducción de features no críticas |
| **R9** | Abandono de miembro del equipo | Baja | Alto | **MEDIO** | • Documentación continua del código<br>• Pair programming<br>• Knowledge sharing | • Redistribución de tareas<br>• Contratación de reemplazo |
| **R10** | Retrasos en aprobación de Apple/Google | Media | Medio | **MEDIO** | • Seguir guidelines al pie de la letra<br>• Testing previo exhaustivo<br>• Envío con 2 semanas de margen | • Corrección rápida de observaciones<br>• Plan B sin stores (APK directo, web) |
| **R11** | Problemas de conectividad en demo final | Baja | Alto | **MEDIO** | • Presentación con datos locales<br>• Video de demostración grabado<br>• Backup de conexión 4G | • Usar video pregrabado<br>• Demo offline |
| **R12** | Pérdida de datos por fallo de servidor | Baja | Crítico | **ALTO** | • Backups automáticos diarios<br>• Redundancia en Azure<br>• Versionado de BD | • Restauración desde backup<br>• Plan de recuperación ante desastres |

**Clasificación de Severidad**:
- **CRÍTICO**: Puede detener el proyecto
- **ALTO**: Impacto significativo en plazos o calidad
- **MEDIO**: Impacto moderado, gestionable
- **BAJO**: Impacto mínimo

---

### 7.5.2 Plan de Prevención Detallado

#### **R1: Retraso en Análisis de Requisitos**

**Medidas preventivas**:
1. Agendar todas las reuniones con stakeholders en semana 1
2. Preparar cuestionarios previos a las entrevistas
3. Grabar (con permiso) las reuniones para revisión
4. Validar requisitos progresivamente, no al final
5. Tener plantillas de documentación preparadas

**Indicadores de alerta**:
- Dificultad para agendar reuniones
- Respuestas vagas o contradictorias
- Falta de disponibilidad de stakeholders clave

**Plan de acción si ocurre**:
1. Priorizar requisitos críticos (login, CRUD actividades)
2. Documentar decisiones tomadas por el equipo con justificación
3. Iterar sobre requisitos secundarios en sprints posteriores

---

#### **R5: Fallos en Integración con Firebase**

**Medidas preventivas**:
1. **Desarrollo incremental**:
   - Semana 1: Solo autenticación básica
   - Semana 2: Firestore con operaciones simples
   - Semana 3: Storage para archivos
   - Semana 4: Cloud Messaging

2. **Documentación y ejemplos**:
   - Seguir tutoriales oficiales de Firebase
   - Revisar proyectos open-source similares
   - Consultar Stack Overflow para problemas comunes

3. **Entorno de pruebas**:
   - Proyecto Firebase separado para desarrollo
   - Datos de prueba, no datos reales
   - Reglas de seguridad más permisivas en dev

4. **Testing continuo**:
   - Tests unitarios para cada función
   - Tests de integración con emuladores de Firebase
   - Monitoreo de logs en Firebase Console

**Indicadores de alerta**:
- Errores frecuentes en logs de Firebase
- Lentitud en operaciones de Firestore
- Mensajes push no llegando

**Plan de acción si ocurre**:
1. **Fase de diagnóstico** (4 horas):
   - Revisar logs de error detalladamente
   - Probar componentes aisladamente
   - Consultar status de Firebase (downtime)

2. **Fase de solución** (8-16 horas):
   - Contactar soporte de Firebase
   - Buscar implementación alternativa
   - Ajustar arquitectura si es necesario

3. **Plan B** (si falla completamente):
   - Chat: Implementar con SignalR (WebSockets) en backend propio
   - Storage: Usar Azure Blob Storage
   - Notificaciones: OneSignal como alternativa a FCM

---

#### **R7: Bugs Críticos en Producción**

**Medidas preventivas**:
1. **Testing riguroso**:
   - Cobertura de tests > 80%
   - Tests E2E de flujos completos
   - Testing en dispositivos reales (no solo emuladores)

2. **Code reviews obligatorios**:
   - Mínimo 1 revisor por pull request
   - Checklist de review (seguridad, rendimiento, estilo)
   - No permitir merge sin aprobación

3. **Despliegue gradual**:
   - Beta testing con grupo reducido de usuarios
   - Monitoreo de logs y errores en tiempo real
   - Rollback automático si tasa de error > 5%

4. **Documentación de bugs**:
   - Registro en Jira de todos los bugs encontrados
   - Clasificación por severidad
   - Asignación de prioridad

**Indicadores de alerta**:
- Aumento súbito de errores en logs
- Quejas de usuarios en reviews o soporte
- Caídas del servidor

**Plan de acción si ocurre**:
1. **Severidad Crítica** (app no usable):
   - Rollback inmediato a versión anterior (15 minutos)
   - Comunicado a usuarios vía notificación push
   - Hotfix prioritario con equipo completo

2. **Severidad Alta** (funcionalidad clave afectada):
   - Hotfix en 24 horas
   - Deploy fuera de horas pico
   - Testing acelerado pero exhaustivo

3. **Severidad Media/Baja**:
   - Incluir en siguiente release planificado
   - Workaround temporal si es posible

---

## 7.6 CÁLCULO DE COSTES

### 7.6.1 Costes de Personal

| Rol | Tarifa/Hora | Horas/Semana | Semanas | Total Horas | Coste Total |
|-----|-------------|--------------|---------|-------------|-------------|
| **Project Manager** | 50 €/h | 10h (25%) | 16 | 160h | 8.000 € |
| **Analista/Arquitecto** | 55 €/h | 40h (100%) | 3 | 120h | 6.600 € |
| **Dev. Backend Senior** | 45 €/h | 40h (100%) | 8 | 320h | 14.400 € |
| **Dev. Backend Junior** | 30 €/h | 40h (100%) | 7 | 280h | 8.400 € |
| **Dev. Frontend Senior** | 45 €/h | 40h (100%) | 10 | 400h | 18.000 € |
| **Dev. Frontend Junior** | 30 €/h | 40h (100%) | 9 | 360h | 10.800 € |
| **QA/Tester** | 35 €/h | 20h (50%) | 3 | 60h | 2.100 € |
| **DevOps Engineer** | 50 €/h | 20h (50%) | 2 | 40h | 2.000 € |
| **UI/UX Designer** | 40 €/h | 10h (25%) | 5 | 50h | 2.000 € |
| **Technical Writer** | 35 €/h | 20h (50%) | 3 | 60h | 2.100 € |

**Subtotal Personal**: **74.400 €**

---

### 7.6.2 Costes de Recursos Técnicos

| Categoría | Detalle | Coste |
|-----------|---------|-------|
| **Hardware** | Portátiles, dispositivos, servidores (ver 7.3.2) | 15.200 € |
| **Software y Servicios** | Licencias, cloud services (4 meses) (ver 7.3.3) | 2.500 € |
| **Infraestructura Producción** | Azure, Firebase (primer año) (ver 7.3.4) | 3.672 € |
| **Espacios y Logística** | Oficina, internet, servicios (4 meses) (ver 7.3.5) | 7.140 € |

**Subtotal Recursos Técnicos**: **28.512 €**

---

### 7.6.3 Otros Costes

| Concepto | Descripción | Coste |
|----------|-------------|-------|
| **Formación** | Cursos Firebase, Flutter avanzado | 1.500 € |
| **Viajes y dietas** | Reuniones con cliente (si aplica) | 800 € |
| **Marketing inicial** | Assets para stores, landing page | 600 € |
| **Contingencia (10%)** | Reserva para imprevistos | 10.581 € |
| **Seguros y legales** | Seguro de responsabilidad, contratos | 1.200 € |

**Subtotal Otros Costes**: **14.681 €**

---

### 7.6.4 Resumen Total de Costes

| Categoría | Coste |
|-----------|-------|
| **Personal** | 74.400 € |
| **Recursos Técnicos** | 28.512 € |
| **Otros Costes** | 14.681 € |
| **TOTAL PROYECTO** | **117.593 €** |

---

### 7.6.5 Distribución de Costes por Fase

| Fase | Duración | % Proyecto | Coste Estimado |
|------|----------|------------|----------------|
| **1. Análisis y Diseño** | 3 semanas | 15% | 17.639 € |
| **2. Desarrollo Backend** | 5 semanas | 25% | 29.398 € |
| **3. Integración Firebase** | 2 semanas | 10% | 11.759 € |
| **4. Desarrollo Frontend** | 6 semanas | 30% | 35.278 € |
| **5. Despliegue e Infraestructura** | 2 semanas | 10% | 11.759 € |
| **6. Documentación y Cierre** | 2 semanas | 10% | 11.759 € |

**Total**: **117.593 €**

---

### 7.6.6 Análisis de ROI (Retorno de Inversión)

**Beneficios esperados**:

| Beneficio | Descripción | Ahorro Anual Estimado |
|-----------|-------------|----------------------|
| **Reducción de tiempo administrativo** | Automatización de procesos manuales | 15.000 € |
| **Reducción de errores** | Menos errores en presupuestos y datos | 5.000 € |
| **Mejora en comunicación** | Chat integrado reduce emails y llamadas | 3.000 € |
| **Centralización de información** | Acceso rápido a datos históricos | 4.000 € |
| **Mejor control presupuestario** | Prevención de sobrecostes | 8.000 € |

**Total Beneficios Anuales**: **35.000 €**

**Cálculo de ROI**:
- **Inversión inicial**: 117.593 €
- **Beneficios año 1**: 35.000 €
- **Costes operacionales año 1**: 3.672 € (infraestructura) + 2.000 € (mantenimiento) = 5.672 €
- **Beneficio neto año 1**: 35.000 - 5.672 = **29.328 €**

**Periodo de recuperación**: 117.593 / 29.328 = **4 años**

**ROI a 5 años**: (29.328 × 5 - 117.593) / 117.593 × 100 = **24,8%**

---

### 7.6.7 Análisis de Sensibilidad

**Escenario Optimista** (15% reducción de costes):
- Coste total: 99.954 €
- ROI a 5 años: 46,8%

**Escenario Realista** (actual):
- Coste total: 117.593 €
- ROI a 5 años: 24,8%

**Escenario Pesimista** (20% aumento de costes):
- Coste total: 141.112 €
- ROI a 5 años: 3,9%

**Conclusión**: El proyecto es viable financieramente incluso en escenario pesimista, con beneficios tangibles a partir del segundo año.


