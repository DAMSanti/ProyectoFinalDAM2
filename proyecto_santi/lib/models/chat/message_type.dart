enum MessageType {
  text,
  image,
  video,
  audio,
  file;
  String toFirestore() {
    return name;
  }
  static MessageType fromFirestore(String value) {
    return MessageType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MessageType.text,
    );
  }
}