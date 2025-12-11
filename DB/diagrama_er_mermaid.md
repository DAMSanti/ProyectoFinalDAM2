# Diagrama E/R Sistema ACEX - Código Mermaid

## Instrucciones
1. Copia el código de abajo
2. Ve a: https://mermaid.live/
3. Pega el código en el editor
4. Exporta como PNG o SVG

## Código Mermaid

```mermaid
erDiagram
    DEPARTAMENTO ||--o{ PROFESOR : pertenece
    PROFESOR ||--o{ USUARIO : tiene
    PROFESOR ||--o{ ACTIVIDAD : responsable
    PROFESOR ||--o{ PROF_PARTICIPANTE : participa
    
    ACTIVIDAD ||--o{ FOTO : contiene
    ACTIVIDAD ||--o{ CONTRATO : tiene
    ACTIVIDAD ||--o{ GASTO_PERSONALIZADO : genera
    ACTIVIDAD ||--o{ GRUPO_PARTIC : incluye
    ACTIVIDAD ||--o{ PROF_PARTICIPANTE : incluye
    ACTIVIDAD ||--o{ ACTIVIDAD_LOCALIZACION : visita
    ACTIVIDAD }o--|| ALOJAMIENTO : usa
    ACTIVIDAD }o--|| EMP_TRANSPORTE : contrata
    ACTIVIDAD }o--|| LOCALIZACION : principal
    
    LOCALIZACION ||--o{ ACTIVIDAD_LOCALIZACION : es_visitada
    
    GRUPO ||--o{ GRUPO_PARTIC : participa
    CURSO ||--o{ GRUPO : contiene
    
    DEPARTAMENTO {
        int Id PK
        string Nombre
        string Descripcion
    }
    
    PROFESOR {
        uuid Uuid PK
        string Nombre
        string Apellidos
        string Email UK
        string Telefono
        string FotoUrl
        bool Activo
        int DepartamentoId FK
    }
    
    USUARIO {
        uuid Id PK
        string NombreUsuario UK
        string Password
        string Rol
        bool Activo
        datetime FechaCreacion
        uuid ProfesorUuid FK
    }
    
    ACTIVIDAD {
        int Id PK
        string Nombre
        string Descripcion
        datetime FechaInicio
        datetime FechaFin
        string Estado
        string Tipo
        decimal PresupuestoEstimado
        decimal CostoReal
        string FolletoUrl
        decimal PrecioTransporte
        decimal PrecioAlojamiento
        int TransporteReq
        int AlojamientoReq
        datetime FechaCreacion
        uuid ResponsableId FK
        int LocalizacionId FK
        int EmpTransporteId FK
        int AlojamientoId FK
    }
    
    FOTO {
        int Id PK
        string Url
        string UrlThumbnail
        string Descripcion
        datetime FechaSubida
        bigint TamanoBytes
        int ActividadId FK
    }
    
    CONTRATO {
        int Id PK
        string NombreProveedor
        string Descripcion
        decimal Monto
        datetime FechaContrato
        string PresupuestoUrl
        string FacturaUrl
        datetime FechaCreacion
        int ActividadId FK
    }
    
    GASTO_PERSONALIZADO {
        int Id PK
        string Concepto
        decimal Cantidad
        datetime FechaCreacion
        int ActividadId FK
    }
    
    LOCALIZACION {
        int Id PK
        string Nombre
        string Direccion
        string Ciudad
        string CodigoPostal
        string Provincia
        string Pais
        decimal Latitud
        decimal Longitud
        string Descripcion
    }
    
    ACTIVIDAD_LOCALIZACION {
        int Id PK
        bool EsPrincipal
        int Orden
        string TipoLocalizacion
        string Descripcion
        datetime FechaAsignacion
        int ActividadId FK
        int LocalizacionId FK
    }
    
    GRUPO {
        int Id PK
        string Nombre
        int NumeroAlumnos
        int CursoId FK
    }
    
    CURSO {
        int Id PK
        string Nombre
        string Nivel
        bool Activo
    }
    
    GRUPO_PARTIC {
        int Id PK
        int NumeroParticipantes
        datetime FechaRegistro
        int ActividadId FK
        int GrupoId FK
    }
    
    PROF_PARTICIPANTE {
        int Id PK
        datetime FechaRegistro
        string Observaciones
        int ActividadId FK
        uuid ProfesorUuid FK
    }
    
    EMP_TRANSPORTE {
        int Id PK
        string Nombre
        string CIF
        string Telefono
        string Email
        string Direccion
    }
    
    ALOJAMIENTO {
        int Id PK
        string Nombre
        string Direccion
        string Ciudad
        string CodigoPostal
        string Provincia
        string Telefono
        string Email
        string Web
        string TipoAlojamiento
        int NumeroHabitaciones
        int CapacidadTotal
        bool Activo
    }
    
    FCM_TOKEN {
        int Id PK
        string UsuarioId
        string Token
        string DeviceId
        string DeviceType
        bool Activo
        datetime FechaCreacion
        datetime UltimaActualizacion
    }
```

## Alternativa: Versión Simplificada (más legible)

```mermaid
erDiagram
    DEPARTAMENTO ||--o{ PROFESOR : "1:N"
    PROFESOR ||--|| USUARIO : "1:1"
    PROFESOR ||--o{ ACTIVIDAD : "responsable"
    
    ACTIVIDAD ||--o{ FOTO : "1:N"
    ACTIVIDAD ||--o{ CONTRATO : "1:N"
    ACTIVIDAD }o--o{ PROFESOR : "N:M participante"
    ACTIVIDAD }o--o{ GRUPO : "N:M"
    ACTIVIDAD }o--o{ LOCALIZACION : "N:M"
    
    CURSO ||--o{ GRUPO : "1:N"
    
    DEPARTAMENTO {
        int id
        string nombre
    }
    
    PROFESOR {
        uuid uuid
        string nombre
        string email
    }
    
    ACTIVIDAD {
        int id
        string nombre
        datetime fecha_inicio
        string estado
        decimal presupuesto
    }
```
