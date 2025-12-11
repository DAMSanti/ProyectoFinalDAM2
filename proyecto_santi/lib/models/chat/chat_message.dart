import 'package:cloud_firestore/cloud_firestore.dart';
import 'message_type.dart';
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String message;
  final MessageType type;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final int? duration; 
  final DateTime timestamp;
  final bool edited;
  final DateTime? editedAt;
  final Map<String, String> reactions; 
  final String? replyToId;
  final Map<String, DateTime> readBy; 
  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.message,
    required this.type,
    this.mediaUrl,
    this.thumbnailUrl,
    this.duration,
    required this.timestamp,
    this.edited = false,
    this.editedAt,
    this.reactions = const {},
    this.replyToId,
    this.readBy = const {},
  });
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'message': message,
      'type': type.toFirestore(),
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'timestamp': Timestamp.fromDate(timestamp),
      'edited': edited,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'reactions': reactions,
      'replyToId': replyToId,
      'readBy': readBy.map((key, value) => MapEntry(key, Timestamp.fromDate(value))),
    };
  }
  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Usuario',
      senderAvatar: data['senderAvatar'],
      message: data['message'] ?? '',
      type: MessageType.fromFirestore(data['type'] ?? 'text'),
      mediaUrl: data['mediaUrl'],
      thumbnailUrl: data['thumbnailUrl'],
      duration: data['duration'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      edited: data['edited'] ?? false,
      editedAt: (data['editedAt'] as Timestamp?)?.toDate(),
      reactions: Map<String, String>.from(data['reactions'] ?? {}),
      replyToId: data['replyToId'],
      readBy: (data['readBy'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as Timestamp).toDate()),
          ) ??
          {},
    );
  }
  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? message,
    MessageType? type,
    String? mediaUrl,
    String? thumbnailUrl,
    int? duration,
    DateTime? timestamp,
    bool? edited,
    DateTime? editedAt,
    Map<String, String>? reactions,
    String? replyToId,
    Map<String, DateTime>? readBy,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      message: message ?? this.message,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      timestamp: timestamp ?? this.timestamp,
      edited: edited ?? this.edited,
      editedAt: editedAt ?? this.editedAt,
      reactions: reactions ?? this.reactions,
      replyToId: replyToId ?? this.replyToId,
      readBy: readBy ?? this.readBy,
    );
  }
  bool isReadBy(String userId) {
    return readBy.containsKey(userId);
  }
  bool get hasReactions => reactions.isNotEmpty;
  Map<String, int> get reactionCounts {
    final counts = <String, int>{};
    for (final emoji in reactions.values) {
      counts[emoji] = (counts[emoji] ?? 0) + 1;
    }
    return counts;
  }
}