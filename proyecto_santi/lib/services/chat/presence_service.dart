import 'package:firebase_database/firebase_database.dart';
class PresenceService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  Future<void> setUserOnline(String userId) async {
    try {
      final ref = _database.ref('presence/$userId');
      await ref.set({
        'isOnline': true,
        'lastSeen': ServerValue.timestamp,
      });
      await ref.onDisconnect().set({
        'isOnline': false,
        'lastSeen': ServerValue.timestamp,
      });
    } catch (e) {
      print('Error setting user online: $e');
    }
  }
  Future<void> setUserOffline(String userId) async {
    try {
      final ref = _database.ref('presence/$userId');
      await ref.set({
        'isOnline': false,
        'lastSeen': ServerValue.timestamp,
      });
    } catch (e) {
      print('Error setting user offline: $e');
    }
  }
  Stream<bool> getUserOnlineStatus(String userId) {
    return _database
        .ref('presence/$userId/isOnline')
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return false;
      return event.snapshot.value as bool;
    });
  }
  Stream<DateTime?> getUserLastSeen(String userId) {
    return _database
        .ref('presence/$userId/lastSeen')
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return null;
      final timestamp = event.snapshot.value as int;
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    });
  }
  Future<void> setTyping(String actividadId, String userId, bool isTyping) async {
    try {
      final ref = _database.ref('typing/$actividadId/$userId');
      if (isTyping) {
        await ref.set({
          'isTyping': true,
          'timestamp': ServerValue.timestamp,
        });
        await ref.onDisconnect().remove();
      } else {
        await ref.remove();
      }
    } catch (e) {
      print('Error setting typing status: $e');
    }
  }
  Stream<List<String>> getTypingUsers(String actividadId) {
    return _database
        .ref('typing/$actividadId')
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return <String>[];
      final Map<dynamic, dynamic> typingData = 
          event.snapshot.value as Map<dynamic, dynamic>;
      final List<String> typingUsers = [];
      typingData.forEach((userId, data) {
        if (data is Map && data['isTyping'] == true) {
          typingUsers.add(userId as String);
        }
      });
      return typingUsers;
    });
  }
  Stream<Map<String, bool>> getMultipleUsersOnlineStatus(List<String> userIds) {
    return _database.ref('presence').onValue.map((event) {
      final Map<String, bool> statuses = {};
      if (event.snapshot.value == null) {
        for (final userId in userIds) {
          statuses[userId] = false;
        }
        return statuses;
      }
      final Map<dynamic, dynamic> presenceData = 
          event.snapshot.value as Map<dynamic, dynamic>;
      for (final userId in userIds) {
        if (presenceData.containsKey(userId)) {
          final userData = presenceData[userId] as Map;
          statuses[userId] = userData['isOnline'] ?? false;
        } else {
          statuses[userId] = false;
        }
      }
      return statuses;
    });
  }
  Future<void> clearTypingStatus(String actividadId, String userId) async {
    try {
      await _database.ref('typing/$actividadId/$userId').remove();
    } catch (e) {
      print('Error clearing typing status: $e');
    }
  }
  Future<void> clearUserPresence(String userId) async {
    try {
      await _database.ref('presence/$userId').remove();
    } catch (e) {
      print('Error clearing user presence: $e');
    }
  }
}