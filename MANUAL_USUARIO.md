# Manual de Usuario - ACEX
## Aplicación de Gestión de Actividades Extraescolares y Complementarias

---

## Índice

1. [Introducción](#1-introducción)
2. [Requisitos del Sistema](#2-requisitos-del-sistema)
3. [Acceso a la Aplicación](#3-acceso-a-la-aplicación)
4. [Pantalla Principal (Home)](#4-pantalla-principal-home)
5. [Gestión de Actividades](#5-gestión-de-actividades)
6. [Detalle de Actividad](#6-detalle-de-actividad)
7. [Mapa de Localizaciones](#7-mapa-de-localizaciones)
8. [Sistema de Chat](#8-sistema-de-chat)
9. [Estadísticas](#9-estadísticas)
10. [Panel de Gestión (Administración)](#10-panel-de-gestión-administración)
11. [Preguntas Frecuentes](#11-preguntas-frecuentes)

---

## 1. Introducción

### 1.1 ¿Qué es ACEX?

ACEX (Actividades Complementarias y Extraescolares) es una aplicación diseñada para facilitar la gestión integral de actividades extraescolares y complementarias en centros educativos. Permite a profesores, coordinadores y administradores:

- **Crear y gestionar actividades** extraescolares y complementarias
- **Coordinar profesores participantes** y grupos de alumnos
- **Gestionar presupuestos** incluyendo transporte, alojamiento y gastos adicionales
- **Visualizar localizaciones** en mapas interactivos
- **Comunicarse en tiempo real** mediante chat integrado
- **Analizar estadísticas** de participación y costes

### 1.2 Roles de Usuario

La aplicación distingue entre diferentes roles con distintos niveles de acceso:

| Rol | Descripción | Permisos |
|-----|-------------|----------|
| **Administrador** | Control total del sistema | Acceso completo a todas las funciones y panel de gestión |
| **Coordinador** | Coordinador de departamento | Gestión de actividades de su departamento, estadísticas |
| **Profesor** | Profesor del centro | Ver y gestionar actividades propias, participar en chats |

### 1.3 Plataformas Soportadas

ACEX está disponible en múltiples plataformas:

- **Windows** (aplicación de escritorio)
- **Web** (navegador)
- **Android** (móvil y tablet)
- **iOS** (iPhone y iPad)
- **macOS** (aplicación de escritorio)
- **Linux** (aplicación de escritorio)

---

## 2. Requisitos del Sistema

### 2.1 Requisitos Mínimos

**Para dispositivos móviles:**
- Android 6.0 (API 23) o superior
- iOS 12.0 o superior
- 100 MB de espacio libre
- Conexión a Internet

**Para escritorio:**
- Windows 10 o superior / macOS 10.14 o superior / Linux (Ubuntu 18.04+)
- 4 GB de RAM
- 200 MB de espacio libre
- Conexión a Internet

**Para navegador web:**
- Chrome 80+, Firefox 75+, Safari 13+, Edge 80+
- JavaScript habilitado
- Conexión a Internet

### 2.2 Conexión a Internet

La aplicación requiere conexión a Internet para:
- Iniciar sesión
- Sincronizar actividades
- Enviar y recibir mensajes de chat
- Cargar mapas y localizaciones
- Subir y descargar imágenes

---

## 3. Acceso a la Aplicación

### 3.1 Pantalla de Inicio de Sesión

Al abrir la aplicación, se muestra la pantalla de inicio de sesión con los siguientes elementos:

![Login](./docs/images/login.png)

**Elementos de la pantalla:**

1. **Campo de Usuario**: Introduce tu nombre de usuario proporcionado por el administrador
2. **Campo de Contraseña**: Introduce tu contraseña (los caracteres se ocultan por seguridad)
3. **Botón Iniciar Sesión**: Pulsa para acceder a la aplicación
4. **Indicador de carga**: Aparece mientras se verifica tus credenciales

### 3.2 Proceso de Inicio de Sesión

**Paso 1:** Introduce tu nombre de usuario en el campo correspondiente.

**Paso 2:** Introduce tu contraseña.

**Paso 3:** Pulsa el botón "Iniciar Sesión".

**Paso 4:** Espera mientras se verifican tus credenciales.

**Resultado exitoso:** Serás redirigido a la pantalla principal (Home).

**Error de credenciales:** Si los datos son incorrectos, aparecerá un mensaje de error indicando que el usuario o la contraseña no son válidos.

### 3.3 Cambio de Tema (Claro/Oscuro)

La aplicación soporta dos temas visuales:

- **Tema Claro**: Fondo blanco con texto oscuro (ideal para uso diurno)
- **Tema Oscuro**: Fondo oscuro con texto claro (ideal para uso nocturno o ambientes con poca luz)

Para cambiar el tema:
1. Busca el icono de sol/luna en la barra superior
2. Pulsa sobre él para alternar entre temas
3. El cambio se aplica inmediatamente

### 3.4 Cierre de Sesión

Para cerrar sesión de forma segura:

1. Accede al menú lateral (en móvil) o menú de usuario (en escritorio)
2. Selecciona la opción "Cerrar Sesión"
3. Confirma la acción cuando se te solicite
4. Serás redirigido a la pantalla de inicio de sesión

---

## 4. Pantalla Principal (Home)

### 4.1 Descripción General

La pantalla principal muestra un resumen de las próximas actividades y proporciona acceso rápido a las funciones más utilizadas.

### 4.2 Elementos de la Interfaz

**Barra de Navegación Lateral (Desktop/Web):**

En la versión de escritorio y web, encontrarás una barra lateral con las siguientes opciones:

| Icono | Nombre | Descripción |
|-------|--------|-------------|
| 🏠 | Home | Pantalla principal con actividades próximas |
| 📋 | Actividades | Lista completa de actividades |
| 🗺️ | Mapa | Mapa interactivo con localizaciones |
| 💬 | Chat | Sistema de mensajería por actividad |
| 📊 | Estadísticas | Gráficos y análisis de datos |
| ⚙️ | Gestión | Panel de administración (solo administradores) |

**Menú Hamburguesa (Móvil):**

En dispositivos móviles, el menú se accede pulsando el icono de tres líneas horizontales (☰) en la esquina superior izquierda.

### 4.3 Calendario de Actividades

La pantalla principal incluye un calendario interactivo que muestra las actividades programadas:

**Navegación del calendario:**
- **Flechas izquierda/derecha**: Cambiar de mes
- **Puntos de colores**: Indican días con actividades programadas
- **Tap en un día**: Muestra las actividades de ese día

**Colores de los indicadores:**
- 🟢 **Verde**: Actividad aprobada
- 🟡 **Amarillo/Naranja**: Actividad pendiente de aprobación
- 🔵 **Azul**: Actividad en curso
- 🟣 **Púrpura**: Actividad finalizada
- 🔴 **Rojo**: Actividad cancelada o rechazada

### 4.4 Tarjetas de Actividades Próximas

Debajo del calendario se muestran tarjetas con las actividades más próximas:

**Información mostrada en cada tarjeta:**
- Título de la actividad
- Fecha y hora de inicio
- Estado (chip de color)
- Departamento organizador
- Número de participantes

**Acciones disponibles:**
- **Tap en la tarjeta**: Abre el detalle de la actividad
- **Deslizar** (en móvil): Puede revelar acciones rápidas

### 4.5 Filtrado de Actividades por Rol

El sistema filtra automáticamente las actividades según tu rol:

- **Administradores y Coordinadores**: Ven todas las actividades del sistema
- **Profesores**: Solo ven actividades donde son responsables o participantes

---

## 5. Gestión de Actividades

### 5.1 Vista de Lista de Actividades

La vista de actividades muestra todas las actividades del sistema organizadas en dos secciones principales.

**Acceso a la vista:**
1. Pulsa en "Actividades" en el menú lateral
2. O navega desde la pantalla principal

### 5.2 Secciones de la Vista

**Sección "Todas las Actividades":**
- Muestra todas las actividades futuras del sistema
- Incluye actividades de todos los departamentos
- Permite ver actividades aunque no participes en ellas

**Sección "Tus Actividades":**
- Muestra únicamente las actividades donde eres responsable o participante
- Acceso rápido a tus tareas pendientes
- Filtrado automático según tu perfil

### 5.3 Búsqueda y Filtrado

**Barra de búsqueda:**
1. Pulsa en el icono de lupa o el campo de búsqueda
2. Escribe el término a buscar (título, descripción, departamento)
3. Los resultados se filtran en tiempo real mientras escribes
4. Pulsa la X para limpiar la búsqueda

**Filtros disponibles:**

| Filtro | Descripción |
|--------|-------------|
| Por estado | Borrador, Pendiente, Aprobada, En curso, Finalizada, Cancelada |
| Por tipo | Extraescolar, Complementaria |
| Por departamento | Selecciona uno o varios departamentos |
| Por fecha | Rango de fechas específico |

### 5.4 Crear Nueva Actividad

**Requisitos:** Debes tener rol de Administrador, Coordinador o Profesor.

**Pasos para crear una actividad:**

**Paso 1:** Pulsa el botón "+" o "Nueva Actividad" (generalmente un botón flotante en la esquina inferior derecha).

**Paso 2:** Completa el formulario con la información básica:

| Campo | Obligatorio | Descripción |
|-------|-------------|-------------|
| Título | ✅ Sí | Nombre descriptivo de la actividad |
| Descripción | ❌ No | Detalles adicionales sobre la actividad |
| Tipo | ✅ Sí | Extraescolar o Complementaria |
| Departamento | ✅ Sí | Departamento organizador |
| Fecha inicio | ✅ Sí | Cuándo comienza la actividad |
| Fecha fin | ✅ Sí | Cuándo termina la actividad |
| Responsable | ✅ Sí | Profesor responsable (por defecto, tú) |

**Paso 3:** Configura opciones adicionales:
- **Requiere transporte**: Activa si necesitas contratar transporte
- **Requiere alojamiento**: Activa si la actividad incluye pernocta
- **Pernocta**: Indica si los participantes dormirán fuera

**Paso 4:** Pulsa "Guardar" o "Crear" para crear la actividad.

**Resultado:** La actividad se crea en estado "Borrador" y puedes seguir editándola.

### 5.5 Estados de una Actividad

Las actividades pasan por diferentes estados durante su ciclo de vida:

```
Borrador → Pendiente → Aprobada → En Curso → Finalizada
                 ↓
              Rechazada
                 ↓
              Cancelada
```

**Descripción de estados:**

| Estado | Color | Descripción |
|--------|-------|-------------|
| **Borrador** | Gris | Actividad en preparación, no visible públicamente |
| **Pendiente** | Naranja | Enviada para aprobación, esperando revisión |
| **Aprobada** | Verde | Aprobada por coordinador/administrador |
| **Rechazada** | Rojo | No aprobada, requiere modificaciones |
| **En Curso** | Azul | La actividad está realizándose actualmente |
| **Finalizada** | Púrpura | La actividad ha concluido |
| **Cancelada** | Gris oscuro | La actividad fue cancelada |

### 5.6 Flujo de Aprobación

**Para el profesor (solicitante):**

1. Crea la actividad y completa todos los campos necesarios
2. Revisa que toda la información sea correcta
3. Cambia el estado de "Borrador" a "Pendiente"
4. Espera la revisión del coordinador o administrador
5. Recibirás notificación cuando sea aprobada o rechazada

**Para el coordinador/administrador (aprobador):**

1. Revisa las actividades en estado "Pendiente"
2. Verifica la información, presupuesto y logística
3. Aprueba la actividad (cambia a "Aprobada") o recházala indicando el motivo
4. El profesor recibirá notificación del resultado

### 5.7 Tarjeta de Actividad

Cada actividad se muestra como una tarjeta con la siguiente información:

**Cabecera:**
- Título de la actividad
- Chip con el estado actual (color según estado)
- Icono del tipo de actividad

**Cuerpo:**
- Fechas: Desde - Hasta
- Departamento organizador
- Profesor responsable

**Pie:**
- Número de grupos participantes
- Número de profesores acompañantes
- Indicadores: 🚌 (transporte) 🏨 (alojamiento)

**Acciones:**
- Tap en la tarjeta → Abre el detalle
- Menú contextual (⋮) → Editar, Duplicar, Eliminar

---

## 6. Detalle de Actividad

### 6.1 Acceso al Detalle

Para ver el detalle completo de una actividad:
1. Pulsa sobre cualquier tarjeta de actividad
2. O selecciona "Ver detalle" en el menú contextual

### 6.2 Estructura de la Vista

La vista de detalle se organiza en pestañas para facilitar la navegación:

| Pestaña | Contenido |
|---------|-----------|
| **Información** | Datos generales de la actividad |
| **Presupuesto** | Gestión económica y gastos |
| **Imágenes** | Galería de fotos de la actividad |
| **Ubicaciones** | Mapa con las localizaciones |
| **Participantes** | Grupos y profesores asignados |

### 6.3 Pestaña Información

**Sección Datos Generales:**
- Título de la actividad
- Descripción completa
- Tipo (Extraescolar/Complementaria)
- Departamento organizador
- Profesor responsable

**Sección Fechas y Horarios:**
- Fecha y hora de inicio
- Fecha y hora de fin
- Duración total (días)
- Indicador de pernocta

**Sección Transporte:**
- ¿Requiere transporte? (Sí/No)
- Empresa de transporte seleccionada
- Coste estimado del transporte

**Sección Alojamiento:**
- ¿Requiere alojamiento? (Sí/No)
- Alojamiento seleccionado
- Dirección del alojamiento
- Precio por noche
- Número de noches

**Sección Observaciones:**
- Comentarios adicionales
- Notas internas
- Comentarios del coordinador (si aplica)

### 6.4 Pestaña Presupuesto

**Resumen Económico:**

```
┌─────────────────────────────────────┐
│ COSTE TOTAL ESTIMADO:    1.250,00 € │
│ Número de participantes:        45  │
│ COSTE POR ALUMNO:           27,78 € │
└─────────────────────────────────────┘
```

**Desglose de Gastos:**

| Concepto | Importe |
|----------|---------|
| Transporte | 450,00 € |
| Alojamiento (2 noches x 35€) | 630,00 € |
| Entradas/Actividades | 120,00 € |
| Gastos varios | 50,00 € |
| **TOTAL** | **1.250,00 €** |

**Añadir Gasto Personalizado:**

1. Pulsa el botón "+ Añadir Gasto"
2. Introduce el nombre del gasto
3. Introduce el importe
4. Opcionalmente añade una descripción
5. Pulsa "Guardar"

El gasto se añade a la lista y el total se recalcula automáticamente.

### 6.5 Pestaña Imágenes

**Galería de Imágenes:**
- Muestra todas las fotos asociadas a la actividad
- Las imágenes se muestran en formato cuadrícula (grid)
- Tap en una imagen para verla a pantalla completa

**Añadir Imágenes (si tienes permisos):**

1. Pulsa el botón "+" o el icono de cámara
2. Selecciona el origen:
   - **Cámara**: Tomar foto nueva
   - **Galería**: Seleccionar imagen existente
3. Opcionalmente añade una descripción
4. La imagen se sube automáticamente

**Visor de Imágenes a Pantalla Completa:**
- Desliza horizontalmente para navegar entre imágenes
- Pellizca para hacer zoom
- Pulsa X o desliza hacia abajo para cerrar

**Eliminar Imágenes (si tienes permisos):**
1. Abre la imagen a pantalla completa
2. Pulsa el icono de papelera
3. Confirma la eliminación

### 6.6 Pestaña Ubicaciones

**Mapa Integrado:**
- Muestra un mapa con todas las localizaciones de la actividad
- Utiliza OpenStreetMap para la cartografía

**Tipos de Localizaciones:**

| Tipo | Icono | Descripción |
|------|-------|-------------|
| Punto de encuentro | 🟢 | Lugar donde se reúne el grupo |
| Destino principal | 🔴 | Objetivo principal de la actividad |
| Parada intermedia | 🟠 | Paradas durante el recorrido |

**Interacción con el Mapa:**
- Arrastra para desplazarte
- Pellizca para zoom
- Tap en un marcador para ver detalles

**Añadir Localización (si tienes permisos):**

1. Pulsa el botón "+ Añadir Ubicación"
2. Busca la dirección o pulsa en el mapa
3. Selecciona el tipo de localización
4. Añade nombre y descripción
5. Pulsa "Guardar"

### 6.7 Pestaña Participantes

**Sección Grupos:**

Muestra los grupos de alumnos que participarán:

```
┌─────────────────────────────────────┐
│ 📚 1º DAM A                    25 👥 │
│ 📚 1º DAM B                    23 👥 │
│ 📚 2º DAM A                    22 👥 │
├─────────────────────────────────────┤
│ TOTAL ALUMNOS:                 70 👥 │
└─────────────────────────────────────┘
```

**Añadir Grupos:**
1. Pulsa "+ Añadir Grupo"
2. Selecciona los grupos de la lista
3. Pulsa "Confirmar"

**Sección Profesores Acompañantes:**

Muestra los profesores que acompañarán la actividad:

```
┌─────────────────────────────────────┐
│ ⭐ Juan García (Responsable)        │
│    📧 juan.garcia@centro.edu        │
│                                     │
│ 👤 María López                      │
│    📧 maria.lopez@centro.edu        │
│                                     │
│ 👤 Pedro Sánchez                    │
│    📧 pedro.sanchez@centro.edu      │
└─────────────────────────────────────┘
```

**Añadir Profesores:**
1. Pulsa "+ Añadir Profesor"
2. Selecciona profesores de la lista
3. Pulsa "Confirmar"

### 6.8 Modo Edición

**Activar Edición:**
- Solo disponible si eres el responsable o administrador
- Pulsa el icono de lápiz (✏️) en la barra superior

**En Modo Edición:**
- Los campos se vuelven editables
- Aparece una barra con botones "Guardar" y "Cancelar"
- Los cambios se resaltan visualmente

**Guardar Cambios:**
1. Realiza las modificaciones necesarias
2. Pulsa "Guardar"
3. Espera la confirmación
4. Los cambios se aplican inmediatamente

**Cancelar Cambios:**
1. Pulsa "Cancelar"
2. Confirma que deseas descartar los cambios
3. Se restauran los valores originales

### 6.9 Permisos de Edición

| Rol | Puede Editar |
|-----|--------------|
| Administrador | ✅ Todas las actividades |
| Coordinador | ✅ Actividades de su departamento |
| Profesor Responsable | ✅ Solo sus actividades |
| Profesor Participante | ❌ Solo lectura |

---

## 7. Mapa de Localizaciones

### 7.1 Descripción General

El mapa interactivo muestra todas las localizaciones de las actividades programadas, permitiendo visualizar geográficamente dónde se realizarán las diferentes actividades.

**Acceso:**
1. Pulsa "Mapa" en el menú lateral
2. O accede desde la pestaña "Ubicaciones" de una actividad específica

### 7.2 Interfaz del Mapa

**Componentes principales:**

```
┌─────────────────────────────────────────┐
│ 🔍 Buscar actividad...            [X]  │
├─────────────────────────────────────────┤
│                                         │
│          [MAPA OPENSTREETMAP]           │
│                                         │
│     🔴          🟢                      │
│            🟠        🔴                 │
│                                         │
│                           [+]           │
│                           [-]           │
│                           [📍]          │
├─────────────────────────────────────────┤
│ 📋 3 actividades en el mapa             │
└─────────────────────────────────────────┘
```

### 7.3 Controles del Mapa

**Botones de zoom:**
- **[+]**: Acercar (más detalle)
- **[-]**: Alejar (vista más amplia)

**Botón de ubicación [📍]:**
- Centra el mapa en tu ubicación actual
- Requiere permiso de ubicación en el dispositivo

**Gestos táctiles:**
- **Arrastrar**: Mover el mapa
- **Pellizcar**: Zoom in/out
- **Doble tap**: Zoom in rápido
- **Tap con dos dedos**: Zoom out

### 7.4 Marcadores en el Mapa

Los marcadores indican las localizaciones de las actividades:

**Colores según estado de la actividad:**

| Color | Estado |
|-------|--------|
| 🟢 Verde | Actividad aprobada |
| 🟠 Naranja | Actividad pendiente |
| 🔵 Azul | Actividad en curso |
| 🟣 Púrpura | Actividad finalizada |
| ⚫ Gris | Actividad en borrador |

**Tipos de marcadores:**

| Icono | Tipo |
|-------|------|
| 🏁 | Punto de encuentro |
| 📍 | Destino principal |
| ⭕ | Parada intermedia |

### 7.5 Búsqueda de Actividades

**Usar el buscador:**

1. Pulsa en el campo de búsqueda
2. Escribe el nombre de la actividad o localización
3. Se muestran resultados mientras escribes
4. Tap en un resultado para centrar el mapa

**Resultados de búsqueda:**
- Muestra título de la actividad
- Fecha de la actividad
- Distancia aproximada (si la ubicación está activa)

### 7.6 Información de Marcadores

**Al pulsar un marcador:**

Aparece un popup con información resumida:
```
┌─────────────────────────────────┐
│ 📍 Museo del Prado              │
│ Excursión Cultural Madrid       │
│ 📅 15 Dic 2025                  │
│                                 │
│ [Ver Detalle]                   │
└─────────────────────────────────┘
```

**Acciones disponibles:**
- **Ver Detalle**: Abre la vista de detalle de la actividad
- **Cómo llegar**: Abre la navegación en Google Maps/Apple Maps

### 7.7 Modo Detalle de Actividad

Cuando accedes al mapa desde el detalle de una actividad específica:

- Solo se muestran las localizaciones de esa actividad
- Se traza una línea conectando los puntos en orden
- El zoom se ajusta automáticamente para mostrar todo el recorrido

**Navegación entre puntos:**
- Usa las flechas ← → para ir al punto anterior/siguiente
- El mapa se centra automáticamente en cada punto

### 7.8 Clustering de Marcadores

Cuando hay muchas localizaciones cercanas:
- Se agrupan en un círculo con un número
- El número indica cuántas localizaciones hay en esa zona
- Haz zoom para separar los marcadores agrupados
- Tap en el cluster para hacer zoom automático

---

## 8. Sistema de Chat

### 8.1 Descripción General

El sistema de chat permite la comunicación en tiempo real entre los participantes de cada actividad. Cada actividad tiene su propio chat grupal.

**Características principales:**
- Mensajería en tiempo real (Firebase)
- Envío de imágenes y archivos
- Notificaciones push
- Historial de conversaciones

### 8.2 Lista de Chats

**Acceso:**
1. Pulsa "Chat" en el menú lateral

**Vista de lista:**
```
┌─────────────────────────────────────────┐
│ 💬 Chats                                │
├─────────────────────────────────────────┤
│ 🔍 Buscar conversación...               │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ 🎭 Excursión Teatro Madrid          │ │
│ │ Juan: ¿A qué hora quedamos?    14:32│ │
│ │                              🔴 3   │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │ 🏛️ Visita Museo Arqueológico        │ │
│ │ Tú: Perfecto, nos vemos allí  Ayer │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │ ⛷️ Semana Blanca 2025               │ │
│ │ María: Recordad llevar...     Lun  │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

**Elementos de cada chat:**
- Icono/imagen de la actividad
- Nombre de la actividad
- Preview del último mensaje
- Hora/fecha del último mensaje
- Badge con mensajes no leídos (🔴)

### 8.3 Filtrado de Chats

Los chats se filtran según tu rol:

- **Administradores/Coordinadores**: Ven chats de todas las actividades
- **Profesores**: Solo ven chats de actividades donde participan

**Búsqueda de chats:**
1. Escribe en el campo de búsqueda
2. Se filtran por nombre de actividad
3. Se filtran por contenido de mensajes

### 8.4 Conversación Individual

**Interfaz del chat:**
```
┌─────────────────────────────────────────┐
│ ← Excursión Teatro Madrid         ℹ️    │
├─────────────────────────────────────────┤
│         ── 15 de Diciembre ──           │
│                                         │
│     ┌─────────────────────────┐         │
│     │ Buenas tardes a todos,  │         │
│     │ recordad traer el DNI   │         │
│     │                   10:30 │         │
│     └─────────────────────────┘         │
│                                         │
│ ┌─────────────────────────┐             │
│ │ Juan García:            │             │
│ │ ¿A qué hora quedamos    │             │
│ │ mañana?           14:32 │             │
│ └─────────────────────────┘             │
│                                         │
│     ┌─────────────────────────┐         │
│     │ A las 8:00 en la puerta │         │
│     │ principal          14:35│         │
│     │                    ✓✓  │         │
│     └─────────────────────────┘         │
│                                         │
├─────────────────────────────────────────┤
│ [📎] Escribe un mensaje...      [📷][➤]│
└─────────────────────────────────────────┘
```

**Elementos:**
- Mensajes propios a la derecha (fondo azul)
- Mensajes de otros a la izquierda (fondo gris)
- Nombre del remitente en mensajes de otros
- Hora de cada mensaje
- Indicadores de estado: ✓ enviado, ✓✓ entregado, ✓✓ leído (azul)

### 8.5 Enviar Mensajes

**Mensaje de texto:**
1. Escribe en el campo de texto
2. Pulsa el botón de enviar (➤)
3. El mensaje aparece inmediatamente

**Enviar imagen:**
1. Pulsa el icono de cámara (📷)
2. Selecciona:
   - **Cámara**: Tomar foto nueva
   - **Galería**: Seleccionar imagen existente
3. Opcionalmente añade un texto
4. Pulsa enviar

**Enviar archivo:**
1. Pulsa el icono de clip (📎)
2. Selecciona el archivo
3. Espera mientras se sube
4. El archivo se envía al completarse

### 8.6 Acciones sobre Mensajes

**Mantener pulsado un mensaje:**

Opciones disponibles:
- **Copiar**: Copia el texto al portapapeles
- **Responder**: Cita el mensaje y responde
- **Reenviar**: Envía a otro chat
- **Eliminar** (solo mensajes propios): Borra el mensaje

### 8.7 Información del Chat

**Pulsar el icono ℹ️:**

Muestra información de la actividad:
- Nombre de la actividad
- Fecha de la actividad
- Lista de participantes
- Acceso rápido al detalle de la actividad

### 8.8 Notificaciones

**Configuración de notificaciones:**
- Las notificaciones push se envían cuando recibes mensajes nuevos
- No recibes notificación si ya estás en ese chat
- Puedes silenciar chats específicos

**Silenciar un chat:**
1. Abre el chat
2. Pulsa el icono ℹ️
3. Activa "Silenciar notificaciones"
4. Selecciona duración: 1 hora, 8 horas, 1 día, siempre

---

## 9. Estadísticas

### 9.1 Descripción General

La vista de estadísticas proporciona gráficos y análisis de las actividades del centro, permitiendo visualizar tendencias, costes y participación.

**Acceso:**
1. Pulsa "Estadísticas" en el menú lateral

**Requisitos:** Solo disponible para Administradores y Coordinadores.

### 9.2 Panel de Estadísticas

**Estructura de la vista:**
```
┌─────────────────────────────────────────┐
│ 📊 Estadísticas                         │
├─────────────────────────────────────────┤
│ [Este mes ▼] [Filtros] [📥 Exportar]    │
├─────────────────────────────────────────┤
│                                         │
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐        │
│ │ 47  │ │ 38  │ │ 856 │ │12.5k│        │
│ │Total│ │Aprob│ │Alumn│ │ €   │        │
│ └─────┘ └─────┘ └─────┘ └─────┘        │
│                                         │
│ [Gráfico de barras por mes]            │
│                                         │
│ [Gráfico circular por estado]          │
│                                         │
│ [Gráfico por departamento]             │
│                                         │
└─────────────────────────────────────────┘
```

### 9.3 Tarjetas de Resumen (KPIs)

En la parte superior se muestran las métricas principales:

| Tarjeta | Descripción |
|---------|-------------|
| **Total Actividades** | Número total de actividades en el período |
| **Aprobadas** | Actividades con estado aprobado |
| **Participantes** | Total de alumnos que han participado |
| **Coste Total** | Suma de presupuestos de todas las actividades |

**Indicadores de tendencia:**
- ▲ Verde: Aumento respecto al período anterior
- ▼ Rojo: Disminución respecto al período anterior
- ─ Gris: Sin cambio significativo

### 9.4 Filtros de Período

**Períodos predefinidos:**

| Opción | Descripción |
|--------|-------------|
| Este mes | Mes actual |
| Últimos 30 días | Últimos 30 días naturales |
| Este trimestre | Trimestre actual |
| Año académico | Septiembre a Junio del curso actual |
| Año natural | Enero a Diciembre del año actual |
| Personalizado | Rango de fechas a elegir |

**Seleccionar período personalizado:**
1. Pulsa "Personalizado"
2. Selecciona fecha de inicio
3. Selecciona fecha de fin
4. Pulsa "Aplicar"

### 9.5 Gráficos Disponibles

**Gráfico de Tendencias (Líneas):**
- Muestra la evolución de actividades a lo largo del tiempo
- Eje X: Semanas o meses
- Eje Y: Número de actividades
- Línea de tendencia punteada

**Gráfico de Actividades por Estado (Circular):**
- Distribución de actividades según su estado
- Muestra porcentajes
- Colores según el estado
- Centro muestra el total

**Gráfico de Actividades por Departamento (Barras Horizontales):**
- Ordenado de mayor a menor
- Muestra el nombre del departamento
- Valor numérico al final de cada barra

**Gráfico de Actividades por Mes (Barras Verticales):**
- Agrupado por meses
- Barras apiladas o agrupadas por estado
- Útil para ver estacionalidad

**Gráfico Presupuesto vs Coste (Líneas):**
- Compara presupuesto estimado con coste real
- Identifica desviaciones
- Muestra ahorro o sobrecosto

### 9.6 Interacción con Gráficos

**Tooltip al pulsar:**
- Muestra el valor exacto del dato
- Información contextual adicional
- Desglose si aplica

**Zoom en gráficos temporales:**
- Pellizca para hacer zoom
- Arrastra para desplazarte en el tiempo

### 9.7 Exportar a PDF

**Generar informe:**

1. Pulsa el botón "Exportar" o icono 📥
2. Selecciona las secciones a incluir:
   - ☑️ Resumen ejecutivo
   - ☑️ Gráfico de tendencias
   - ☑️ Distribución por estado
   - ☑️ Actividades por departamento
   - ☑️ Tabla de actividades
3. Pulsa "Generar PDF"
4. Espera mientras se genera
5. Selecciona dónde guardar o compartir

**Contenido del PDF:**
- Portada con logo y período
- Resumen de KPIs
- Gráficos como imágenes
- Tablas de datos detallados
- Pie de página con fecha de generación

---

## 10. Panel de Gestión (Administración)

### 10.1 Descripción General

El Panel de Gestión permite administrar todas las entidades del sistema: usuarios, profesores, departamentos, grupos, cursos, alojamientos y empresas de transporte.

**Acceso:**
1. Pulsa "Gestión" en el menú lateral

**Requisitos:** Solo disponible para **Administradores**.

### 10.2 Vista Principal

**Grid de entidades:**
```
┌─────────────────────────────────────────┐
│ ⚙️ Panel de Gestión                     │
│ Administra todas las entidades          │
├─────────────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐ ┌─────────┐    │
│ │ 👤      │ │ 👨‍🏫      │ │ 🏢      │    │
│ │Usuarios │ │Profesores│ │Deptos   │    │
│ │   24    │ │    45    │ │   10    │    │
│ └─────────┘ └─────────┘ └─────────┘    │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐    │
│ │ 👥      │ │ 📚      │ │ 🏨      │    │
│ │ Grupos  │ │ Cursos  │ │Alojamien│    │
│ │   35    │ │   12    │ │   15    │    │
│ └─────────┘ └─────────┘ └─────────┘    │
│ ┌─────────┐                             │
│ │ 🚌      │                             │
│ │Transport│                             │
│ │    8    │                             │
│ └─────────┘                             │
└─────────────────────────────────────────┘
```

### 10.3 Gestión de Usuarios

**Acceso:** Pulsa la tarjeta "Usuarios"

**Lista de usuarios:**
- Avatar o iniciales
- Nombre de usuario
- Email
- Rol (Admin, Coordinador, Profesor)
- Estado (Activo/Inactivo)

**Crear usuario:**
1. Pulsa el botón "+"
2. Completa los campos:
   - Nombre de usuario (obligatorio, único)
   - Email (obligatorio, único)
   - Contraseña (mínimo 8 caracteres)
   - Confirmar contraseña
   - Rol (seleccionar de lista)
   - Profesor asociado (opcional)
3. Pulsa "Guardar"

**Editar usuario:**
1. Pulsa sobre el usuario en la lista
2. Modifica los campos necesarios
3. Pulsa "Guardar"

**Cambiar contraseña:**
1. Edita el usuario
2. Introduce nueva contraseña
3. Confirma la contraseña
4. Pulsa "Guardar"

**Desactivar usuario:**
1. Edita el usuario
2. Cambia el estado a "Inactivo"
3. El usuario no podrá iniciar sesión

### 10.4 Gestión de Profesores

**Acceso:** Pulsa la tarjeta "Profesores"

**Lista de profesores:**
- Foto o avatar
- Nombre completo
- Email
- Departamento
- Indicador de coordinador

**Campos del formulario:**

| Campo | Obligatorio | Descripción |
|-------|-------------|-------------|
| Nombre | ✅ | Nombre del profesor |
| Apellidos | ✅ | Apellidos del profesor |
| Email | ✅ | Email de contacto (único) |
| Teléfono | ❌ | Teléfono de contacto |
| Departamento | ✅ | Departamento al que pertenece |
| Es Coordinador | ❌ | ¿Es coordinador del departamento? |

### 10.5 Gestión de Departamentos

**Acceso:** Pulsa la tarjeta "Departamentos"

**Campos del formulario:**

| Campo | Obligatorio | Descripción |
|-------|-------------|-------------|
| Nombre | ✅ | Nombre del departamento |
| Código | ✅ | Código abreviado (ej: "INF", "MAT") |
| Descripción | ❌ | Descripción del departamento |
| Coordinador | ❌ | Profesor coordinador |

### 10.6 Gestión de Grupos

**Acceso:** Pulsa la tarjeta "Grupos"

**Campos del formulario:**

| Campo | Obligatorio | Descripción |
|-------|-------------|-------------|
| Nombre | ✅ | Nombre del grupo (ej: "1º DAM A") |
| Curso | ✅ | Curso al que pertenece |
| Número de alumnos | ✅ | Cantidad de alumnos en el grupo |
| Tutor | ❌ | Profesor tutor del grupo |

### 10.7 Gestión de Cursos

**Acceso:** Pulsa la tarjeta "Cursos"

**Campos del formulario:**

| Campo | Obligatorio | Descripción |
|-------|-------------|-------------|
| Nombre | ✅ | Nombre del curso (ej: "1º DAM") |
| Nivel | ✅ | ESO, Bachillerato, FP, etc. |
| Año | ✅ | 1º, 2º, 3º, 4º |

### 10.8 Gestión de Alojamientos

**Acceso:** Pulsa la tarjeta "Alojamientos"

**Campos del formulario:**

| Campo | Obligatorio | Descripción |
|-------|-------------|-------------|
| Nombre | ✅ | Nombre del alojamiento |
| Tipo | ✅ | Hotel, Hostal, Albergue, etc. |
| Dirección | ✅ | Dirección completa |
| Ciudad | ✅ | Ciudad |
| Teléfono | ❌ | Teléfono de contacto |
| Email | ❌ | Email de contacto |
| Precio/noche | ❌ | Precio por noche |
| Capacidad | ❌ | Número máximo de personas |

### 10.9 Gestión de Empresas de Transporte

**Acceso:** Pulsa la tarjeta "Transporte"

**Campos del formulario:**

| Campo | Obligatorio | Descripción |
|-------|-------------|-------------|
| Nombre | ✅ | Nombre de la empresa |
| Tipo | ✅ | Autobús, Tren, Avión, etc. |
| Teléfono | ✅ | Teléfono de contacto |
| Email | ❌ | Email de contacto |
| Persona contacto | ❌ | Nombre de contacto |
| Precio base | ❌ | Precio base por servicio |

### 10.10 Operaciones Comunes (CRUD)

**Crear nuevo registro:**
1. Pulsa el botón "+" (FAB)
2. Completa el formulario
3. Pulsa "Guardar"
4. El registro aparece en la lista

**Editar registro:**
1. Pulsa sobre el registro en la lista
2. Modifica los campos
3. Pulsa "Guardar"

**Eliminar registro:**
1. Pulsa el icono de papelera o desliza
2. Confirma la eliminación
3. El registro se elimina

**Buscar registros:**
1. Usa la barra de búsqueda
2. Escribe el término
3. Los resultados se filtran en tiempo real

---

## 11. Preguntas Frecuentes

### 11.1 Problemas de Acceso

**P: No puedo iniciar sesión, ¿qué hago?**

R: Verifica lo siguiente:
1. Comprueba que el nombre de usuario esté escrito correctamente
2. Verifica que la contraseña sea correcta (mayúsculas/minúsculas)
3. Asegúrate de tener conexión a Internet
4. Si persiste, contacta con el administrador

**P: He olvidado mi contraseña**

R: Contacta con el administrador del sistema para que te genere una nueva contraseña.

### 11.2 Actividades

**P: No veo ninguna actividad en la pantalla principal**

R: Esto puede deberse a:
1. No hay actividades futuras programadas
2. No participas en ninguna actividad (si eres profesor)
3. Prueba a ir a "Actividades" para ver todas

**P: No puedo editar una actividad**

R: Solo puedes editar actividades si:
1. Eres el profesor responsable de la actividad
2. Eres administrador o coordinador
3. La actividad no está en estado "Finalizada" o "Cancelada"

**P: ¿Cómo cambio el estado de una actividad?**

R: En el detalle de la actividad, pulsa el chip de estado y selecciona el nuevo estado. Solo puedes cambiar a estados permitidos según el flujo.

### 11.3 Chat

**P: No recibo notificaciones de chat**

R: Verifica:
1. Las notificaciones están habilitadas en la app
2. El chat no está silenciado
3. Las notificaciones del dispositivo están activadas

**P: No puedo enviar imágenes**

R: Asegúrate de:
1. Tener permiso de acceso a la cámara/galería
2. Tener conexión a Internet estable
3. El archivo no supera el tamaño máximo

### 11.4 Mapa

**P: El mapa no carga**

R: Verifica tu conexión a Internet. Los mapas requieren conexión para cargar los tiles.

**P: No veo mi ubicación**

R: Debes conceder permiso de ubicación a la aplicación en la configuración del dispositivo.

### 11.5 General

**P: La aplicación va muy lenta**

R: Prueba a:
1. Cerrar y volver a abrir la aplicación
2. Verificar tu conexión a Internet
3. Actualizar a la última versión

**P: ¿Cómo actualizo la aplicación?**

R: 
- **Android**: Google Play Store
- **iOS**: App Store
- **Windows/Mac/Linux**: Descarga la última versión
- **Web**: Actualización automática

---

## Contacto y Soporte

Para soporte técnico o consultas:

- **Email**: soporte@acex.edu
- **Teléfono**: +34 XXX XXX XXX
- **Horario**: Lunes a Viernes, 9:00 - 14:00

---

*Manual de Usuario ACEX v1.0*
*Última actualización: Diciembre 2025*

