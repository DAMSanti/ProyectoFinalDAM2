import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_santi/models/chat/chat_message.dart';
import 'package:proyecto_santi/models/chat/message_type.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/config.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
class FirebaseChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  final ApiService _apiService = ApiService();
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
    await _sendNotification(
      actividadId: actividadId,
      senderName: senderName,
      messagePreview: message.length > 50 ? '${message.substring(0, 50)}...' : message,
    );
  }
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
  Future<void> _sendNotification({
    required String actividadId,
    required String senderName,
    required String messagePreview,
  }) async {
    try {
      int? actividadIdInt;
      try {
        actividadIdInt = int.parse(actividadId);
      } catch (e) {
        print('[ChatService] No se pudo convertir actividadId a int: $actividadId');
        return;
      }
      final dio = Dio();
      dio.options.baseUrl = AppConfig.apiBaseUrl;
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
    }
  }
}