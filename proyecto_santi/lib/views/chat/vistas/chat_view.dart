import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_santi/views/chat/model/message.dart';
import 'package:proyecto_santi/components/appBar.dart';

class ChatView extends StatelessWidget {
  final String activityId;
  final String displayName;
  final VoidCallback onToggleTheme;
  final bool isDarkTheme;

  ChatView({
    required this.activityId,
    required this.displayName,
    required this.onToggleTheme,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onToggleTheme: onToggleTheme,
        title: 'Chat',
      ),
      body: Stack(
        children: [
          Column(
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
          Positioned(
            top: kToolbarHeight,
            left: 0,
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
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