import 'package:flutter/material.dart';
import 'package:proyecto_santi/components/app_bar.dart';
import 'package:proyecto_santi/components/desktop_shell.dart';
import 'package:proyecto_santi/models/chat/chat_message.dart';
import 'package:proyecto_santi/models/chat/message_type.dart';
import 'package:proyecto_santi/services/chat/firebase_chat_service.dart';
import 'package:proyecto_santi/services/chat/firebase_storage_service.dart';
import 'package:proyecto_santi/services/chat/presence_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import '../widgets/audio_recorder_widget.dart';
import '../widgets/audio_player_widget.dart';

class ChatView extends StatefulWidget {
  final String activityId;
  final String displayName;
  final String userId; // ID del usuario actual
  final VoidCallback onToggleTheme;
  final bool isDarkTheme;

  const ChatView({
    super.key,
    required this.activityId,
    required this.displayName,
    required this.userId,
    required this.onToggleTheme,
    required this.isDarkTheme,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final FirebaseChatService _chatService = FirebaseChatService();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final PresenceService? _presenceService = null; // Deshabilitado para Windows
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final ValueNotifier<bool> _hasTextNotifier = ValueNotifier<bool>(false);
  
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  bool _isRecordingAudio = false;

  @override
  void initState() {
    super.initState();
    // Configurar español para timeago
    timeago.setLocaleMessages('es', timeago.EsMessages());
    
    // Listener optimizado para cambiar botón de enviar/micrófono
    // Usa ValueNotifier para no reconstruir toda la vista
    _messageController.addListener(() {
      final hasText = _messageController.text.trim().isNotEmpty;
      if (hasText != _hasTextNotifier.value) {
        _hasTextNotifier.value = hasText;
      }
    });
    
    // PresenceService deshabilitado para Windows (Realtime Database no soportado)
    // En Android/iOS funcionará correctamente
    // _presenceService?.setUserOnline(widget.userId);
    
    // Marcar todos los mensajes como leídos al entrar
    _chatService.markAllAsRead(
      actividadId: widget.activityId,
      userId: widget.userId,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _hasTextNotifier.dispose();
    // _presenceService?.setUserOffline(widget.userId);
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    try {
      await _chatService.sendTextMessage(
        actividadId: widget.activityId,
        senderId: widget.userId,
        senderName: widget.displayName,
        message: messageText,
      );

      // Scroll al final
      _scrollToBottom();
    } catch (e) {
      _showError('Error al enviar mensaje: $e');
    }
  }

  void _sendImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      String imageUrl;
      
      if (kIsWeb) {
        // Web: usar bytes
        final bytes = await image.readAsBytes();
        imageUrl = await _storageService.uploadImage(
          actividadId: widget.activityId,
          userId: widget.userId,
          imageFile: bytes,
          fileName: image.name,
          onProgress: (progress) {
            setState(() => _uploadProgress = progress);
          },
        );
      } else {
        // Mobile/Desktop: usar File
        final file = File(image.path);
        imageUrl = await _storageService.uploadImage(
          actividadId: widget.activityId,
          userId: widget.userId,
          imageFile: file,
          fileName: image.name,
          onProgress: (progress) {
            setState(() => _uploadProgress = progress);
          },
        );
      }

      // Enviar mensaje con la imagen
      await _chatService.sendMediaMessage(
        actividadId: widget.activityId,
        senderId: widget.userId,
        senderName: widget.displayName,
        message: '📷 Imagen',
        type: MessageType.image,
        mediaUrl: imageUrl,
      );

      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
      _showError('Error al subir imagen: $e');
    }
  }

  void _startRecordingAudio() {
    setState(() => _isRecordingAudio = true);
  }

  void _cancelRecordingAudio() {
    setState(() => _isRecordingAudio = false);
  }

  void _sendAudio(String audioPath, int duration) async {
    setState(() => _isRecordingAudio = false);

    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      String audioUrl;
      
      if (kIsWeb) {
        // Web: leer bytes del archivo
        final file = File(audioPath);
        final bytes = await file.readAsBytes();
        audioUrl = await _storageService.uploadAudio(
          actividadId: widget.activityId,
          userId: widget.userId,
          audioFile: bytes,
          fileName: 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
          onProgress: (progress) {
            setState(() => _uploadProgress = progress);
          },
        );
      } else {
        // Mobile/Desktop: usar File
        final file = File(audioPath);
        audioUrl = await _storageService.uploadAudio(
          actividadId: widget.activityId,
          userId: widget.userId,
          audioFile: file,
          fileName: 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
          onProgress: (progress) {
            setState(() => _uploadProgress = progress);
          },
        );
      }

      // Enviar mensaje con el audio
      await _chatService.sendMediaMessage(
        actividadId: widget.activityId,
        senderId: widget.userId,
        senderName: widget.displayName,
        message: '🎵 Audio',
        type: MessageType.audio,
        mediaUrl: audioUrl,
        duration: duration,
      );

      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });

      _scrollToBottom();

      // Eliminar archivo temporal
      try {
        final file = File(audioPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Error al eliminar archivo temporal: $e');
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
      _showError('Error al subir audio: $e');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        navigateBackFromDetail(context, '/chat');
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: widget.isDarkTheme
                  ? [const Color(0xFF0A0E21), const Color(0xFF1A1F3A)]
                  : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 48), // Espacio para la flecha de volver
                  // Lista de mensajes
                  Expanded(
                child: StreamBuilder<List<ChatMessage>>(
                  stream: _chatService.getMessagesStream(widget.activityId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay mensajes aún',
                              style: TextStyle(
                                color: Colors.grey.withValues(alpha: 0.7),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '¡Envía el primer mensaje!',
                              style: TextStyle(
                                color: Colors.grey.withValues(alpha: 0.5),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final messages = snapshot.data!.reversed.toList();

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == widget.userId;

                        return _buildMessageBubble(message, isMe);
                      },
                    );
                  },
                ),
              ),

              // Indicador de subida
              if (_isUploading)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      Text('Subiendo... ${(_uploadProgress * 100).toInt()}%'),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(value: _uploadProgress),
                    ],
                  ),
                ),

              // Input de mensaje o grabador de audio
              _isRecordingAudio
                  ? AudioRecorderWidget(
                      onRecordingComplete: _sendAudio,
                      onCancel: _cancelRecordingAudio,
                    )
                  : Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: widget.isDarkTheme
                            ? const Color(0xFF1A1F3A)
                            : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Botón de imagen
                          IconButton(
                            icon: const Icon(Icons.image, color: Color(0xFF1976d2)),
                            onPressed: _isUploading ? null : _sendImage,
                            tooltip: 'Enviar imagen',
                          ),
                          // Campo de texto
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: 'Escribe un mensaje...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: widget.isDarkTheme
                                    ? const Color(0xFF2A2F4A)
                                    : const Color(0xFFF5F5F5),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                              textInputAction: TextInputAction.send,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Botón de micrófono o enviar - ValueListenableBuilder para evitar reconstruir toda la vista
                          ValueListenableBuilder<bool>(
                            valueListenable: _hasTextNotifier,
                            builder: (context, hasText, child) {
                              return hasText
                                  ? Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.send, color: Colors.white),
                                        onPressed: _sendMessage,
                                        tooltip: 'Enviar mensaje',
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.mic, color: Color(0xFF1976d2)),
                                      onPressed: _isUploading ? null : _startRecordingAudio,
                                      tooltip: 'Grabar audio',
                                    );
                            },
                          ),
                        ],
                      ),
                    ),
            ],
          ),
          // Flecha de volver (posicionada en la esquina superior izquierda)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              decoration: BoxDecoration(
                color: widget.isDarkTheme
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: widget.isDarkTheme ? Colors.white : const Color(0xFF1976d2),
                  size: 24,
                ),
                onPressed: () {
                  navigateBackFromDetail(context, '/chat');
                },
                tooltip: 'Volver',
              ),
            ),
          ),
        ],
      ),
    ),
  ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isMe
                ? [const Color(0xFF1976d2), const Color(0xFF1565c0)]
                : widget.isDarkTheme
                    ? [const Color(0xFF2A2F4A), const Color(0xFF1A1F3A)]
                    : [Colors.white, const Color(0xFFF5F5F5)],
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del remitente (siempre visible)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                message.senderName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isMe
                      ? Colors.white.withOpacity(0.9)
                      : const Color(0xFF1976d2),
                ),
              ),
            ),

            // Contenido del mensaje
            if (message.type == MessageType.image && message.mediaUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: message.mediaUrl!,
                  width: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                ),
              )
            else if (message.type == MessageType.audio && message.mediaUrl != null)
              AudioPlayerWidget(
                audioUrl: message.mediaUrl!,
                duration: message.duration ?? 0,
                isMine: isMe,
              )
            else
              Text(
                message.message,
                style: TextStyle(
                  color: isMe
                      ? Colors.white
                      : widget.isDarkTheme
                          ? Colors.white
                          : Colors.black87,
                  fontSize: 14,
                ),
              ),

            // Timestamp
            const SizedBox(height: 4),
            Text(
              timeago.format(message.timestamp, locale: 'es'),
              style: TextStyle(
                color: isMe
                    ? Colors.white70
                    : widget.isDarkTheme
                        ? Colors.white54
                        : Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
