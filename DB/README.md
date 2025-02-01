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
5. [Modelos (Entities)](#modelos-entities)
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

## Application.properties

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

# Controladores

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

# Endpoints de FotoController

| **Método HTTP** | **Endpoint**              | **Descripción**                                      | **Respuesta Exitosa** | **Código de Estado** | **Parámetros**                       |
|-----------------|---------------------------|------------------------------------------------------|-----------------------|----------------------|--------------------------------------|
| `GET`           | `/api/foto`                | Obtiene todas las fotos.                          | Lista de fotos       | `200 OK`             | Ninguno                              |
| `GET`           | `/api/foto/{id}`      | Obtiene una foto por su id.                        | Detalles de la foto    | `200 OK`             | `id` (int)                       |
| `PUT`           | `/api/foto/{id}`     | Actualiza una foto existente.                       | Foto actualizado     | `200 OK`             | `id` (int), Cuerpo JSON con los datos a actualizar |
| `GET`           | `/api/foto/poractividad` | Recibe una lista de fotos por el id de la actividad | Lista de fotos de la actividad | `200 OK` | `id` (int) |
| `DELETE`        | `/api/foto/{id}`     | Elimina un actividad por su ID. | | | `id` (int) |
| `POST`          | `/api/foto/upload` | Sube una lista de fotos. | | `200 OK` | `fotos` MultipartFile[], `idActividad` (int), `descripcion` (String) |
