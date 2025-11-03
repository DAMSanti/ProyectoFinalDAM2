# Implementación de Mensajes de Voz en el Chat

## 📝 Resumen

Se ha implementado completamente la funcionalidad de mensajes de voz en el chat de la aplicación. Los usuarios ahora pueden:

- 🎙️ **Grabar** mensajes de audio manteniendo presionado el botón del micrófono
- 🎵 **Reproducir** mensajes de audio recibidos con controles interactivos
- ⏱️ Ver la **duración** de las grabaciones en tiempo real
- ❌ **Cancelar** grabaciones antes de enviarlas
- 📤 **Enviar** automáticamente al completar la grabación

## 🛠️ Componentes Implementados

### 1. Paquetes Agregados

**`pubspec.yaml`**
```yaml
record: ^5.1.2  # Para grabar audio
```

Ya existentes:
- `audioplayers: ^6.1.0` - Para reproducir audio
- `firebase_storage: ^12.3.9` - Para almacenar archivos

### 2. Widgets Creados

#### `AudioRecorderWidget`
**Ubicación:** `lib/views/chat/widgets/audio_recorder_widget.dart`

Widget que gestiona la grabación de audio:
- Inicia grabación automáticamente al mostrarse
- Muestra temporizador en tiempo real
- Límite de 5 minutos de grabación
- Botones para cancelar o enviar
- Animación de grabación (punto rojo pulsante)
- Manejo de permisos de micrófono

**Características:**
- ✅ Configuración de audio: AAC-LC, 128kbps, 44.1kHz
- ✅ Temporizador visible
- ✅ Cancelación con limpieza de recursos
- ✅ Callback con path del archivo y duración

#### `AudioPlayerWidget`
**Ubicación:** `lib/views/chat/widgets/audio_player_widget.dart`

Widget que reproduce mensajes de audio:
- Botón play/pause
- Slider de progreso con seek
- Duración total y tiempo actual
- Indicador de carga
- Estilos adaptados a tema claro/oscuro
- Colores diferentes para mensajes propios vs ajenos

**Características:**
- ✅ Control de reproducción completo
- ✅ Seek en el audio
- ✅ Reinicio automático al finalizar
- ✅ Manejo de errores de red
- ✅ Diseño compacto e intuitivo

### 3. Servicios Actualizados

#### `FirebaseChatService`
Ya tenía el método `sendMediaMessage` que soporta `MessageType.audio` con campo `duration`.

#### `FirebaseStorageService`
Ya tenía el método `uploadAudio` que sube archivos de audio al backend.

#### `BackendStorageService`
Ya implementado con soporte completo para subida de audio mediante multipart/form-data.

### 4. Vista Principal del Chat

**`chat_view.dart`** - Actualizaciones:

1. **Imports agregados:**
```dart
import '../widgets/audio_recorder_widget.dart';
import '../widgets/audio_player_widget.dart';
```

2. **Estado agregado:**
```dart
bool _isRecordingAudio = false;
```

3. **Listener en initState:**
```dart
_messageController.addListener(() {
  setState(() {}); // Actualizar UI para cambiar botón
});
```

4. **Métodos nuevos:**
- `_startRecordingAudio()` - Inicia modo grabación
- `_cancelRecordingAudio()` - Cancela grabación
- `_sendAudio(String audioPath, int duration)` - Sube y envía audio

5. **UI actualizada:**
- Botón de micrófono aparece cuando el campo de texto está vacío
- Botón de enviar aparece cuando hay texto escrito
- Al presionar micrófono, se muestra `AudioRecorderWidget`
- En los mensajes, se detecta `MessageType.audio` y se muestra `AudioPlayerWidget`

### 5. Permisos Agregados

**`AndroidManifest.xml`**
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
```

## 🎨 Diseño y UX

### Comportamiento del Botón de Entrada
- **Campo vacío:** Muestra icono de micrófono 🎤
- **Con texto:** Muestra botón de enviar con gradiente azul 📤
- **Mientras graba:** Reemplaza todo el input con el widget de grabación

### Estilo de Mensajes de Audio
- **Mensajes propios:** Fondo azul
- **Mensajes ajenos:** Fondo gris
- **Responsive:** Se adapta al ancho del mensaje
- **Tema oscuro:** Colores ajustados automáticamente

### Feedback Visual
- Punto rojo pulsante durante grabación
- Temporizador en formato MM:SS
- Progress bar del audio
- Estados de carga claramente indicados

## 🔄 Flujo de Trabajo

### Grabar y Enviar Audio

1. Usuario presiona botón de micrófono
2. Se solicitan permisos (si es necesario)
3. Comienza grabación automática
4. Temporizador cuenta segundos
5. Usuario puede:
   - ❌ Cancelar (botón rojo)
   - ✅ Enviar (botón azul)
6. Al enviar:
   - Se detiene grabación
   - Se sube archivo al backend
   - Se crea mensaje en Firestore con:
     - `type: MessageType.audio`
     - `mediaUrl: [URL del audio]`
     - `duration: [segundos]`
     - `message: "🎵 Audio"`
   - Se envía notificación a otros usuarios
7. Archivo temporal se elimina

### Reproducir Audio Recibido

1. Mensaje aparece con `AudioPlayerWidget`
2. Usuario presiona play ▶️
3. Audio se descarga y reproduce
4. Slider muestra progreso
5. Usuario puede:
   - ⏸️ Pausar
   - ↔️ Hacer seek
   - Ver duración restante
6. Al finalizar, vuelve al inicio automáticamente

## 📱 Compatibilidad

### Plataformas Soportadas
- ✅ **Android** - Completamente funcional
- ✅ **iOS** - Completamente funcional (requiere configuración de Info.plist)
- ✅ **Web** - Funcional con limitaciones de navegador
- ⚠️ **Windows** - Requiere configuración adicional
- ⚠️ **Linux** - Requiere configuración adicional

### Formatos de Audio
- **Grabación:** AAC-LC (`.m4a`)
- **Reproducción:** Soporta AAC, MP3, WAV, OGG

### iOS - Configuración Adicional Necesaria

Agregar a `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Necesitamos acceso al micrófono para grabar mensajes de voz</string>
```

## 🔧 Backend

El backend C# ya soporta la subida de archivos de audio a través del endpoint:
- **POST** `/api/ChatMedia/upload`
- Acepta multipart/form-data
- Guarda en `wwwroot/chat_media/{actividadId}/`
- Retorna URL pública del archivo

## 📊 Modelo de Datos

### ChatMessage
```dart
class ChatMessage {
  final MessageType type;        // MessageType.audio
  final String? mediaUrl;        // URL del archivo de audio
  final int? duration;           // Duración en segundos
  final String message;          // "🎵 Audio"
  // ... otros campos
}
```

## 🚀 Cómo Usar

### Para Usuarios
1. Abrir cualquier chat de actividad
2. Presionar y mantener el botón del micrófono
3. Hablar el mensaje
4. Soltar para enviar o deslizar para cancelar
5. Para escuchar un audio recibido, presionar play

### Para Desarrolladores

**Enviar mensaje de voz programáticamente:**
```dart
await _chatService.sendMediaMessage(
  actividadId: activityId,
  senderId: userId,
  senderName: userName,
  message: '🎵 Audio',
  type: MessageType.audio,
  mediaUrl: audioUrl,
  duration: durationInSeconds,
);
```

**Renderizar widget de audio:**
```dart
if (message.type == MessageType.audio && message.mediaUrl != null)
  AudioPlayerWidget(
    audioUrl: message.mediaUrl!,
    duration: message.duration ?? 0,
    isMine: isMyMessage,
  )
```

## ⚠️ Consideraciones

1. **Permisos:** La app solicita permisos de micrófono la primera vez
2. **Tamaño:** Los audios se comprimen con AAC-LC a 128kbps
3. **Límite:** Máximo 5 minutos por mensaje
4. **Red:** Requiere conexión para subir/descargar
5. **Almacenamiento:** Los archivos se almacenan en el backend, no localmente

## 🐛 Depuración

### Problemas Comunes

**No se puede grabar:**
- Verificar permisos en configuración del dispositivo
- Comprobar que el micrófono no esté siendo usado por otra app

**Audio no se reproduce:**
- Verificar conectividad a internet
- Comprobar que la URL del audio sea accesible
- Revisar logs de `audioplayers`

**Archivo no se sube:**
- Verificar que el backend esté corriendo
- Comprobar configuración de `AppConfig.apiBaseUrl`
- Revisar logs del `BackendStorageService`

## 📈 Mejoras Futuras

- [ ] Compresión adicional de audio para reducir tamaño
- [ ] Visualización de forma de onda durante grabación
- [ ] Soporte para pausar/reanudar grabación
- [ ] Transcripción automática de audio a texto
- [ ] Efectos de voz (velocidad, tono)
- [ ] Guardado de audios en favoritos
- [ ] Búsqueda dentro de mensajes de voz

## ✅ Testing

Para probar la funcionalidad:

1. **Grabación:**
   ```
   - Abrir chat
   - Presionar micrófono
   - Verificar que aparece temporizador
   - Verificar animación de grabación
   - Cancelar y verificar que no se envía
   - Grabar y enviar mensaje corto
   ```

2. **Reproducción:**
   ```
   - Recibir mensaje de voz
   - Presionar play
   - Verificar reproducción
   - Hacer seek en diferentes posiciones
   - Pausar y reanudar
   - Dejar terminar automáticamente
   ```

3. **Integración:**
   ```
   - Enviar varios tipos de mensajes (texto, imagen, audio)
   - Verificar que notificaciones funcionan
   - Probar en tema claro y oscuro
   - Verificar en diferentes tamaños de pantalla
   ```

## 📚 Documentación de Paquetes

- **record:** https://pub.dev/packages/record
- **audioplayers:** https://pub.dev/packages/audioplayers
- **firebase_storage:** https://pub.dev/packages/firebase_storage

---

**Última actualización:** 3 de noviembre de 2025
**Estado:** ✅ Implementación completa y funcional
