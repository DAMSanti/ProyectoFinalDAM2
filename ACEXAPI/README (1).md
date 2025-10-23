# ApiEquipoA1DAM

## Realizado
- Miguel Ángel Calderon
- José David Casas
- Ángel García
- Victor Guardo

## Indice

1. [Introducción](#introducción)
2. [Configuración](#configuración)
3. [Tecnologías Utilizadas](#tecnologías-utilizadas)  
4. [Estructura](#estructura)
5. [Modelos](#modelos)
6. [Repositorios (Repositories)](#repositorios-repositories)
7. [Controladores (EndPoints)](#controladores-endpoints)
8. [Seguridad](#seguridad)

## Introducción

Este proyecto consiste en la creacion de una API para la gestión de las actividades extraescolares del centro debido a la necesidad
del departamento para su gestión, con el objetivo de ser capaz de tener una mayor organización en cuanto a todo lo que tiene que ver con las actividades, es decir,
control de presupuestos, transportes, dias, profesores organizadores y facilitar también a los que se quedan en el centro a la hora de actividades fuera del mismo.

## Tecnologías Utilizadas

- **Java 17** (o versión superior)  
- **Spring Boot** (versión 2.x o 3.x, según el POM)  
- **Maven** o **Gradle** (dependiendo del gestor de dependencias configurado)  
- **Azure Active Directory** para la autenticación y autorización  
- **Base de datos en Azure** (Azure SQL Database)  
- **IntelliJ IDEA** como entorno de desarrollo  
- **Swagger / OpenAPI** para la generación de la documentación interactiva de los endpoints  
- **REST** para la comunicación y diseño de la API  

---

## Configuración

```properties
# Configuración del servidor
server.port=8080

# Configuración de la base de datos
spring.datasource.url=jdbc:mysql://localhost:3307/proyecto?allowPublicKeyRetrieval=true&useSSL=false&serverTimezone=UTC
spring.datasource.username=root
spring.datasource.password=mysql
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver


# Configuración de JPA / Hibernate
spring.jpa.hibernate.ddl-auto=none
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL8Dialect
spring.jackson.serialization.FAIL_ON_EMPTY_BEANS=false

# Configuración de logs
logging.level.org.springframework=INFO
logging.level.org.hibernate.SQL=DEBUG
```
## Estructura

Este proyecto sigue una estructura organizada en paquetes que representan las capas principales de la arquitectura ademas de un paquete en el que se hace la gestión de los ficheros.

### Estructura

```plaintext
src/main/java
└── com.proyectos.proyectosapi
    ├── controllers      # Controladores
    ├── models           # Modelos
    ├── repositories     # Repositorios
    ├── services         # Servicios
    ├── security         # Seguridad
    └── swagger          # Swagger
```


## Modelos

1. **Actividad**: Representa a una actividad registrada en el sistema.
2. **Contrato**: Representa el contrato ciclo formativo con sus características.
3. **Curso**: Representa los cursos del centro.
4. **Departamento**: Representa cada departamento del centro.
5. **EmpTransporte**: Representa a las empresas de transporte.
6. **Foto**: Representa cada fotos de una actividad.
7. **Profesor**: Representa a cada uno de los profesores del centro.
8. **Grupo**: Representa cada uno de los grupos de un centro.
9. **GrupoPartic**: Relación entre grupos y actividades.
10. **Localizacion**: Representa cada localización de una actividad.
11. **ProfParticipante**: Relación entre profesores y actividad que son participantes de la misma.
12. **ProfResponsable**: Relación entre profesores y actividad que son responsabkes de la misma

## Repositorios (Repositories)

Los repositorios en esta API representan la capa de acceso a datos. 

| Repositorio            | Entidad asociada | 
|------------------------|------------------|
| `ActividadRepository`     | `Actividad`         |
| `ContratoRepository`      | `Contrato`          | 
| `CursoRepository`   | `Curso`       |
| `ProfesorRepository`   | `Profesor`       |
| `FotoRepository`    | `Foto`        |
| `GrupoRepository`     | `Grupo`         |
| `DepartamentoRepository`     | `Departamento`         |
| `GrupoParticRepository`     | `GrupoPartic`         |
| `LocalizacionRepository`     | `Localizacion`         |
| `ProfParticipanteRepository`     | `ProfParticipante`         |
| `ProfResponsableRepository`     | `ProfResponsable`         |
| `EmpTransporteRepository`     | `EmpTransporte`         |

---

### Ejemplo de Repositorio: `ProfesorRepository`

- `findProfesoresByDni(String dni)`: Obtiene profesor por su dni.
- `findProfesorsByCorreo(String correo);`: Busca un profesor por su correo.

# Controladores (EndPoints)

A continuación, se describe el controlador `AlumnoController`, presentando un resumen  de todos los endpoints disponibles en este controlador.

# Endpoints de ActividadController

| **Método HTTP** | **Endpoint**              | **Descripción**                                      | **Respuesta Exitosa** | **Código de Estado** | **Parámetros**                       |
|-----------------|---------------------------|------------------------------------------------------|-----------------------|----------------------|--------------------------------------|
| `GET`           | `/api/actividad`                | Obtiene todas las actividades.                          | Lista de actividades       | `200 OK`             | Ninguno                              |
| `GET`           | `/api/actividad/{id}`      | Obtiene una actividad por su id.                        | Detalles del actividad    | `200 OK`             | `id` (int)                       |
| `POST`          | `/api/actividad`                | Crea una nueva actividad.                                | Detalles del alumno creado | `201 Created`       | Cuerpo JSON con los datos de la actividad, folleto (MultipartFile) |
| `PUT`           | `/api/actividad/{id}`     | Actualiza un actividad existente.                       | Alumno actualizado     | `200 OK`             | `id` (int), Cuerpo JSON con los datos a actualizar, folleto (MultipartFile) |
| `DELETE`        | `/api/actividad/{id}`     | Elimina un actividad por su ID. | | | `id` (int) |
| `GET`           | `/api/actividad/authorization/{id}` | Crea una autorización con los datos de la actividad | Autorización rellena | `200 OK`    | `id`(int) |
| `GET`           | `/api/actividad/documentos | Recibe el pdf del folleto | PDF | `200 OK` | `id` (int) | 

# Endpoints de ContratosController

| **Método HTTP** | **Endpoint**              | **Descripción**                                      | **Respuesta Exitosa** | **Código de Estado** | **Parámetros**                       |
|-----------------|---------------------------|------------------------------------------------------|-----------------------|----------------------|--------------------------------------|
| `GET`           | `/api/contrato`                | Obtiene todos los contratos.                          | Lista de contratos       | `200 OK`             | Ninguno                              |
| `GET`           | `/api/contrato/{id}`      | Obtiene un contrato por su id.                        | Detalles del contrato    | `200 OK`             | `id` (int)                       |
| `POST`          | `/api/contrato`                | Crea un nuevo contrato.                                | Detalles del contrato creado | `201 Created`       | Cuerpo JSON con los datos del contrato, presupuesto (MultipartFile), factura (MultipartFile) |
| `PUT`           | `/api/contrato/{id}`     | Actualiza un actividad existente.                       | Contrato actualizado     | `200 OK`             | `id` (int), Cuerpo JSON con los datos a actualizar, presupuesto (MultipartFile), factura (MultipartFile) |
| `DELETE`        | `/api/contrato/{id}`     | Elimina un actividad por su ID. | | | `id` (int) |

# Endpoints de ProfesorController

| **Método HTTP** | **Endpoint**              | **Descripción**                                      | **Respuesta Exitosa** | **Código de Estado** | **Parámetros**                       |
|-----------------|---------------------------|------------------------------------------------------|-----------------------|----------------------|--------------------------------------|
| `GET`           | `/api/profesor`                | Obtiene todos los contratos.                          | Lista de profesores       | `200 OK`             | Ninguno                              |
| `GET`           | `/api/profesor/{uuid}`      | Obtiene un profesor por su uuid.                        | Detalles del profesor    | `200 OK`             | `uuid` (String)                       |
| `GET`           | `/api/profesor/dni/{dni}`      | Obtiene un profesor por su dni.                        | Detalles del profesor    | `200 OK`             | `dni` (String)                       |
| `POST`          | `/api/profesor`                | Crea un nuevo profesor.                                | Detalles del profesor creado | `201 Created`       | Cuerpo JSON con los datos del profesor|
| `GET`           | `/api/profesor/foto`     | Recoge la foto de un profesor.                       | Foto del profesor     | `200 OK`             | `correo` (String) |
| `PUT`        | `/api/profesor/{uuid}`     | Modifica un profesor por su uuid. | Detalles del profesor editado | `200 OK` | `uuid` (String), Cuerpo JSON con los datos del profesor |
| `DELETE`        | `/api/profesor/{uuid}`     | Elimina un profesor por su uuid. | | | `uuid` (String) |

# Endpoints de ProfParticipanteController

| **Método HTTP** | **Endpoint**              | **Descripción**                                      | **Respuesta Exitosa** | **Código de Estado** | **Parámetros**                       |
|-----------------|---------------------------|------------------------------------------------------|-----------------------|----------------------|--------------------------------------|
| `GET`           | `/api/profParticipante`                | Obtiene todos los Profesores Participantes.                          | Lista de Profesores Participantes       | `200 OK`             | Ninguno                              |
| `GET`           | `/api/profParticipante/{id}`      | Obtiene un Profesor Participante por su id.                        | Detalles del Profesor Participante    | `200 OK`             | `id` (int)                       |
| `GET`           | `/api/profParticipante/actividad/{id}`      | Obtiene un Profesor Participante por el id de la actividad.                        | Detalles del Profesor Participante de la actividad    | `200 OK`             | `id` (int)                       |
| `PUT`           | `/api/profParticipante/{id}`     | Actualiza un Profesor Participante.                       | Profesor Participante actualizado     | `200 OK`             | `id` (int), Cuerpo JSON con los datos a actualizar |
| `DELETE`        | `/api/profParticipante/{id}`     | Elimina un Profesor Participante por su ID. | | | `id` (int) |
| `POST`          | `/api/profParticipante` | Sube un Profesor Participante. | | `200 OK` | `id` (int) |

# Endpoints de ProfResponsableController

| **Método HTTP** | **Endpoint**              | **Descripción**                                      | **Respuesta Exitosa** | **Código de Estado** | **Parámetros**                       |
|-----------------|---------------------------|------------------------------------------------------|-----------------------|----------------------|--------------------------------------|
| `GET`           | `/api/profResponsable`                | Obtiene todos los Profesores Responsables.                          | Lista de Profesores Responsables       | `200 OK`             | Ninguno                              |
| `GET`           | `/api/profResponsable/{id}`      | Obtiene un Profesor Responsable por su id.                        | Detalles del Profesor Responsable    | `200 OK`             | `id` (int)                       |                |
| `PUT`           | `/api/profResponsable/{id}`     | Actualiza un Profesor Responsable.                       | Profesor Responsable actualizado     | `200 OK`             | `id` (int), Cuerpo JSON con los datos a actualizar |
| `DELETE`        | `/api/profResponsable/{id}`     | Elimina un Profesor Responsable por su ID. | | | `id` (int) |
| `POST`          | `/api/profResponsable` | Sube un Profesor Responsable. | | `200 OK` | `id` (int) |

# Endpoints de FotoController

| **Método HTTP** | **Endpoint**              | **Descripción**                                      | **Respuesta Exitosa** | **Código de Estado** | **Parámetros**                       |
|-----------------|---------------------------|------------------------------------------------------|-----------------------|----------------------|--------------------------------------|
| `GET`           | `/api/foto`                | Obtiene todas las fotos.                          | Lista de fotos       | `200 OK`             | Ninguno                              |
| `GET`           | `/api/foto/{id}`      | Obtiene una foto por su id.                        | Detalles de la foto    | `200 OK`             | `id` (int)                       |
| `PUT`           | `/api/foto/{id}`     | Actualiza una foto existente.                       | Foto actualizado     | `200 OK`             | `id` (int), Cuerpo JSON con los datos a actualizar |
| `GET`           | `/api/foto/poractividad` | Recibe una lista de fotos por el id de la actividad | Lista de fotos de la actividad | `200 OK` | `id` (int) |
| `DELETE`        | `/api/foto/{id}`     | Elimina un actividad por su ID. | | | `id` (int) |
| `POST`          | `/api/foto/upload` | Sube una lista de fotos. | | `200 OK` | `fotos` MultipartFile[], `idActividad` (int), `descripcion` (String) |

# Endpoints de CursoController

| **Método HTTP** | **Endpoint**              | **Descripción**                                      | **Respuesta Exitosa** | **Código de Estado** | **Parámetros**                       |
|-----------------|---------------------------|------------------------------------------------------|-----------------------|----------------------|--------------------------------------|
| `GET`           | `/api/cursos`                | Obtiene todos los cursos.                          | Lista de cursos       | `200 OK`             | Ninguno                              |
| `GET`           | `/api/cursos/{id}`      | Obtiene una curso por su id.                        | Detalles del curso    | `200 OK`             | `id` (int)                       |
| `PUT`           | `/api/cursos/{id}`     | Actualiza un curso existente.                       | Curso actualizado     | `200 OK`             | `id` (int), Cuerpo JSON con los datos a actualizar |
| `DELETE`        | `/api/cursos/{id}`     | Elimina un actividad por su ID. | | | `id` (int) |
| `POST`          | `/api/cursos` | Sube un curso. | | `200 OK` | `id` (int) |

# Endpoints de DepartamentoController

| **Método HTTP** | **Endpoint**              | **Descripción**                                      | **Respuesta Exitosa** | **Código de Estado** | **Parámetros**                       |
|-----------------|---------------------------|------------------------------------------------------|-----------------------|----------------------|--------------------------------------|
| `GET`           | `/api/departamento`                | Obtiene todos los departamentos.                          | Lista de departamentos       | `200 OK`             | Ninguno                              |
| `GET`           | `/api/departamento/{id}`      | Obtiene una departamento por su id.                        | Detalles del departamento    | `200 OK`             | `id` (int)                       |
| `PUT`           | `/api/departamento/{id}`     | Actualiza un departamento existente.                       | Departamento actualizado     | `200 OK`             | `id` (int), Cuerpo JSON con los datos a actualizar |
| `DELETE`        | `/api/departamento/{id}`     | Elimina un actividad por su ID. | | | `id` (int) |
| `POST`          | `/api/departamento` | Sube un departamento. | | `200 OK` | `id` (int) |

# Endpoints de DepartamentoController

| **Método HTTP** | **Endpoint**              | **Descripción**                                      | **Respuesta Exitosa** | **Código de Estado** | **Parámetros**                       |
|-----------------|---------------------------|------------------------------------------------------|-----------------------|----------------------|--------------------------------------|
| `GET`           | `/api/departamento`                | Obtiene todos los departamentos.                          | Lista de departamentos       | `200 OK`             | Ninguno                              |
| `GET`           | `/api/departamento/{id}`      | Obtiene una departamento por su id.                        | Detalles del departamento    | `200 OK`             | `id` (int)                       |
| `PUT`           | `/api/departamento/{id}`     | Actualiza un departamento existente.                       | Departamento actualizado     | `200 OK`             | `id` (int), Cuerpo JSON con los datos a actualizar |
| `DELETE`        | `/api/departamento/{id}`     | Elimina un actividad por su ID. | | | `id` (int) |
| `POST`          | `/api/departamento` | Sube un departamento. | | `200 OK` | `id` (int) |

# Endpoints de EmpTransporteController

| **Método HTTP** | **Endpoint**              | **Descripción**                                      | **Respuesta Exitosa** | **Código de Estado** | **Parámetros**                       |
|-----------------|---------------------------|------------------------------------------------------|-----------------------|----------------------|--------------------------------------|
| `GET`           | `/api/empTransporte`                | Obtiene todas las empresas de transporte.                          | Lista de las empresas de transporte       | `200 OK`             | Ninguno                              |
| `GET`           | `/api/empTransporte/{id}`      | Obtiene una empresa de transporte por su id.                        | Detalles del departamento    | `200 OK`             | `id` (int)                       |
| `PUT`           | `/api/empTransporte/{id}`     | Actualiza un empresa de transporte existente.                       | Empresa de Transporte actualizada     | `200 OK`             | `id` (int), Cuerpo JSON con los datos a actualizar |
| `DELETE`        | `/api/empTransporte/{id}`     | Elimina una empresa de transporte por su ID. | | | `id` (int) |
| `POST`          | `/api/empTransporte` | Sube una empresa de transporte. | | `200 OK` | `id` (int) |

# Endpoints de GrupoController

| **Método HTTP** | **Endpoint**              | **Descripción**                                      | **Respuesta Exitosa** | **Código de Estado** | **Parámetros**                       |
|-----------------|---------------------------|------------------------------------------------------|-----------------------|----------------------|--------------------------------------|
| `GET`           | `/api/grupo`                | Obtiene todos los grupos.                          | Lista de grupos       | `200 OK`             | Ninguno                              |
| `GET`           | `/api/grupo/{id}`      | Obtiene un grupo por su id.                        | Detalles del grupo    | `200 OK`             | `id` (int)                       |
| `PUT`           | `/api/grupo/{id}`     | Actualiza un grupo.                       | Grupo actualizado     | `200 OK`             | `id` (int), Cuerpo JSON con los datos a actualizar |
| `DELETE`        | `/api/grupo/{id}`     | Elimina un grupo por su ID. | | | `id` (int) |
| `POST`          | `/api/grupo` | Sube un grupo. | | `200 OK` | `id` (int) |

# Endpoints de GrupoParticipanteController

| **Método HTTP** | **Endpoint**              | **Descripción**                                      | **Respuesta Exitosa** | **Código de Estado** | **Parámetros**                       |
|-----------------|---------------------------|------------------------------------------------------|-----------------------|----------------------|--------------------------------------|
| `GET`           | `/api/grupoParticipante`                | Obtiene todos los grupoParticipantes.                          | Lista de grupos       | `200 OK`             | Ninguno                              |
| `GET`           | `/api/grupoParticipante/{id}`      | Obtiene un grupoParticipante por su id.                        | Detalles del grupoParticipante    | `200 OK`             | `id` (int)                       |
| `PUT`           | `/api/grupo/{id}`     | Actualiza un grupoParticipante.                       | grupoParticipantes actualizado     | `200 OK`             | `id` (int), Cuerpo JSON con los datos a actualizar |
| `DELETE`        | `/api/grupoParticipantes/{id}`     | Elimina un grupoParticipantes por su ID. | | | `id` (int) |
| `POST`          | `/api/grupoParticipantes` | Sube un grupoParticipantes. | | `200 OK` | `id` (int) |

# Endpoints de LocalizacionController

| **Método HTTP** | **Endpoint**              | **Descripción**                                      | **Respuesta Exitosa** | **Código de Estado** | **Parámetros**                       |
|-----------------|---------------------------|------------------------------------------------------|-----------------------|----------------------|--------------------------------------|
| `GET`           | `/api/localizacion`                | Obtiene todas las localizaciones.                          | Lista de localizaciones       | `200 OK`             | Ninguno                              |
| `GET`           | `/api/localizacion/{id}`      | Obtiene un localización por su id.                        | Detalles del localización    | `200 OK`             | `id` (int)                       |
| `PUT`           | `/api/localizacion/{id}`     | Actualiza una localización.                       | Localización actualizado     | `200 OK`             | `id` (int), Cuerpo JSON con los datos a actualizar |
| `DELETE`        | `/api/localizacion/{id}`     | Elimina un localización por su ID. | | | `id` (int) |
| `POST`          | `/api/localizacion` | Sube un localización. | | `200 OK` | `id` (int) |


# Seguridad
Con la finalidad de obtener un nivel de seguridad muy alto sin gastar un tiempo excesivo implementándola, nos hemos decantado por aprovecharnos de la seguridad de Microsoft, usando las cuentas del mismo y los tokens que el propio Microsoft gestiona para dar acceso o no a la api. Para ello, hemos tenido que conectar la api a Azure y añadirla a las aplicaciones gestionadas por el mismo para que se le proporcione acceso a los servidores de validación de tokens.

Las rutas que NO estan protegidas por la seguridad para una futura implementación de endpoints publicos son:
- /public/**
- /swagger-ui/**
- /v3/**
  
## Gestión de los tokens
```java
    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        return http
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/public/**").permitAll()
                        .requestMatchers("/swagger-ui/**").permitAll()
                        .requestMatchers("/v3/**").permitAll()
                        .anyRequest().authenticated()
                )
                // En lugar de oauth2.jwt() directo, usamos el Customizer
                .oauth2ResourceServer(oauth2 -> oauth2
                        .jwt(Customizer.withDefaults())
                )
                .build();
    }

    @Bean
    public JwtDecoder jwtDecoder() {
        // Define el URI de la JWK Set de Azure
        String jwkSetUri = "https://login.microsoftonline.com/common/discovery/v2.0/keys";

        // Construye el decoder
        NimbusJwtDecoder jwtDecoder = NimbusJwtDecoder.withJwkSetUri(jwkSetUri).build();

        // Validador predeterminado que valida exp y nbf
        OAuth2TokenValidator<Jwt> defaultValidators = JwtValidators.createDefault();

        // Validador personalizado para omitir la validación de 'iss'
        OAuth2TokenValidator<Jwt> withoutIssuerValidator = jwt -> OAuth2TokenValidatorResult.success();

        // Combina los validadores usando DelegatingOAuth2TokenValidator
        OAuth2TokenValidator<Jwt> combinedValidators =
                new DelegatingOAuth2TokenValidator<>(defaultValidators, withoutIssuerValidator);

        // Establece los validadores combinados
        jwtDecoder.setJwtValidator(combinedValidators);

        return jwtDecoder;
    }
```
  
