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


