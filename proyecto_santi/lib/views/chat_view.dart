import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_santi/views/chat/message.dart';

class ChatView extends StatelessWidget {
  final String activityId;
  final String displayName;

  ChatView({required this.activityId, required this.displayName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(activityId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var messages = snapshot.data!.docs.map((doc) => Message.fromJson(doc.data() as Map<String, dynamic>)).toList();
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    return ListTile(
                      title: Text(message.sender),
                      subtitle: Text(message.content),
                      trailing: Text(formatTimestamp(message.timestamp)),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(),
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // Implement send message functionality
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatTimestamp(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.hour}:${date.minute}';
  }
}

void sendMessage(String activityId, String sender, String content) {
  var message = Message(
    sender: sender,
    content: content,
    timestamp: DateTime.now().millisecondsSinceEpoch,
  );
  FirebaseFirestore.instance
      .collection('chats')
      .doc(activityId)
      .collection('messages')
      .add(message.toJson());
}
