import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_santi/models/chat/chat_message.dart';
import 'package:proyecto_santi/models/chat/message_type.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/config.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';

/// Servicio para manejar operaciones de chat con Firebase Firestore
class FirebaseChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  final ApiService _apiService = ApiService();

  /// Stream de mensajes de una actividad en tiempo real
  /// Los mensajes se ordenan por timestamp (más recientes primero)
  Stream<List<ChatMessage>> getMessagesStream(String actividadId, {int limit = 50}) {
    return _firestore
        .collection('actividades')
        .doc(actividadId)
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();
    });
  }

  /// Carga mensajes más antiguos para scroll infinito
  Future<List<ChatMessage>> loadMoreMessages(
    String actividadId, {
    required DateTime beforeTimestamp,
    int limit = 20,
  }) async {
    final snapshot = await _firestore
        .collection('actividades')
        .doc(actividadId)
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .where('timestamp', isLessThan: Timestamp.fromDate(beforeTimestamp))
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ChatMessage.fromFirestore(doc))
        .toList();
  }

  /// Envía un mensaje de texto
  Future<void> sendTextMessage({
    required String actividadId,
    required String senderId,
    required String senderName,
    String? senderAvatar,
    required String message,
    String? replyToId,
  }) async {
    final messageId = _uuid.v4();
    final chatMessage = ChatMessage(
      id: messageId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      message: message,
      type: MessageType.text,
      timestamp: DateTime.now(),
      replyToId: replyToId,
    );

    await _firestore
        .collection('actividades')
        .doc(actividadId)
        .collection('chats')
        .doc(messageId)
        .set(chatMessage.toFirestore());

    // Enviar notificación a través del backend
    await _sendNotification(
      actividadId: actividadId,
      senderName: senderName,
      messagePreview: message.length > 50 ? '${message.substring(0, 50)}...' : message,
    );
  }

  /// Envía un mensaje con multimedia (imagen, video, audio, archivo)
  Future<void> sendMediaMessage({
    required String actividadId,
    required String senderId,
    required String senderName,
    String? senderAvatar,
    required String message,
    required MessageType type,
    required String mediaUrl,
    String? thumbnailUrl,
    int? duration,
    String? replyToId,
  }) async {
    final messageId = _uuid.v4();
    final chatMessage = ChatMessage(
      id: messageId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      message: message,
      type: type,
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      duration: duration,
      timestamp: DateTime.now(),
      replyToId: replyToId,
    );

    await _firestore
        .collection('actividades')
        .doc(actividadId)
        .collection('chats')
        .doc(messageId)
        .set(chatMessage.toFirestore());

    // Enviar notificación con descripción según el tipo de media
    String mediaDescription;
    switch (type) {
      case MessageType.image:
        mediaDescription = '📷 Envió una imagen';
        break;
      case MessageType.video:
        mediaDescription = '🎥 Envió un video';
        break;
      case MessageType.audio:
        mediaDescription = '🎵 Envió un audio';
        break;
      case MessageType.file:
        mediaDescription = '📎 Envió un archivo';
        break;
      default:
        mediaDescription = message;
    }

    await _sendNotification(
      actividadId: actividadId,
      senderName: senderName,
      messagePreview: mediaDescription,
    );
  }

  /// Edita un mensaje existente
  Future<void> editMessage({
    required String actividadId,
    required String messageId,
    required String newMessage,
  }) async {
    await _firestore
        .collection('actividades')
        .doc(actividadId)
        .collection('chats')
        .doc(messageId)
        .update({
      'message': newMessage,
      'edited': true,
      'editedAt': Timestamp.now(),
    });
  }

  /// Elimina un mensaje
  Future<void> deleteMessage({
    required String actividadId,
    required String messageId,
  }) async {
    await _firestore
        .collection('actividades')
        .doc(actividadId)
        .collection('chats')
        .doc(messageId)
        .delete();
  }

  /// Añade o actualiza una reacción a un mensaje
  Future<void> addReaction({
    required String actividadId,
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    await _firestore
        .collection('actividades')
        .doc(actividadId)
        .collection('chats')
        .doc(messageId)
        .update({
      'reactions.$userId': emoji,
    });
  }

  /// Elimina una reacción de un mensaje
  Future<void> removeReaction({
    required String actividadId,
    required String messageId,
    required String userId,
  }) async {
    await _firestore
        .collection('actividades')
        .doc(actividadId)
        .collection('chats')
        .doc(messageId)
        .update({
      'reactions.$userId': FieldValue.delete(),
    });
  }

  /// Marca un mensaje como leído por un usuario
  Future<void> markAsRead({
    required String actividadId,
    required String messageId,
    required String userId,
  }) async {
    await _firestore
        .collection('actividades')
        .doc(actividadId)
        .collection('chats')
        .doc(messageId)
        .update({
      'readBy.$userId': Timestamp.now(),
    });
  }

  /// Marca todos los mensajes de una actividad como leídos
  Future<void> markAllAsRead({
    required String actividadId,
    required String userId,
  }) async {
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('actividades')
        .doc(actividadId)
        .collection('chats')
        .where('senderId', isNotEqualTo: userId)
        .get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'readBy.$userId': Timestamp.now(),
      });
    }

    await batch.commit();
  }

  /// Obtiene el conteo de mensajes no leídos para una actividad
  Stream<int> getUnreadCountStream(String actividadId, String userId) {
    return _firestore
        .collection('actividades')
        .doc(actividadId)
        .collection('chats')
        .where('senderId', isNotEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      int unreadCount = 0;
      for (final doc in snapshot.docs) {
        final message = ChatMessage.fromFirestore(doc);
        if (!message.isReadBy(userId)) {
          unreadCount++;
        }
      }
      return unreadCount;
    });
  }

  /// Busca mensajes que contengan un texto específico
  Future<List<ChatMessage>> searchMessages({
    required String actividadId,
    required String searchText,
  }) async {
    final snapshot = await _firestore
        .collection('actividades')
        .doc(actividadId)
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .get();

    final allMessages = snapshot.docs
        .map((doc) => ChatMessage.fromFirestore(doc))
        .toList();

    return allMessages.where((message) {
      return message.message.toLowerCase().contains(searchText.toLowerCase());
    }).toList();
  }

  /// Método privado para enviar notificación a través del backend
  Future<void> _sendNotification({
    required String actividadId,
    required String senderName,
    required String messagePreview,
  }) async {
    try {
      // Extraer el ID numérico de la actividad si viene en formato string
      int? actividadIdInt;
      try {
        actividadIdInt = int.parse(actividadId);
      } catch (e) {
        print('[ChatService] No se pudo convertir actividadId a int: $actividadId');
        return;
      }

      final dio = Dio();
      dio.options.baseUrl = AppConfig.apiBaseUrl;
      
      // Obtener el token JWT
      final jwtToken = _apiService.token;
      
      if (jwtToken == null) {
        print('[ChatService] No JWT token available, skipping notification');
        return;
      }
      
      dio.options.headers['Authorization'] = 'Bearer $jwtToken';
      
      await dio.post(
        '/Chat/notify-new-message',
        data: {
          'actividadId': actividadIdInt,
          'senderName': senderName,
          'messagePreview': messagePreview,
        },
      );
      
      print('[ChatService] Notification sent successfully');
    } catch (e) {
      print('[ChatService] Error sending notification: $e');
      // No lanzamos el error para no bloquear el envío del mensaje
    }
  }
}

