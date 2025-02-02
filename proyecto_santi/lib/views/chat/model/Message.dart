class Message {
  final String sender;
  final String content;
  final int timestamp;

  Message({required this.sender, required this.content, required this.timestamp});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'],
      content: json['content'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'content': content,
      'timestamp': timestamp,
    };
  }
}