/// Tipos de mensajes soportados en el chat
enum MessageType {
  text,
  image,
  video,
  audio,
  file;

  /// Convierte el tipo a string para Firestore
  String toFirestore() {
    return name;
  }

  /// Crea un MessageType desde un string de Firestore
  static MessageType fromFirestore(String value) {
    return MessageType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MessageType.text,
    );
  }
}
