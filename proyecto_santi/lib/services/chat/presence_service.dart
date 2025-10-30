import 'package:firebase_database/firebase_database.dart';

/// Servicio para manejar estados de presencia (online/offline/escribiendo)
class PresenceService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// Establece el usuario como online
  Future<void> setUserOnline(String userId) async {
    try {
      final ref = _database.ref('presence/$userId');
      await ref.set({
        'isOnline': true,
        'lastSeen': ServerValue.timestamp,
      });

      // Configurar para que se marque como offline al desconectarse
      await ref.onDisconnect().set({
        'isOnline': false,
        'lastSeen': ServerValue.timestamp,
      });
    } catch (e) {
      print('Error setting user online: $e');
    }
  }

  /// Establece el usuario como offline
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

  /// Stream para saber si un usuario está online
  Stream<bool> getUserOnlineStatus(String userId) {
    return _database
        .ref('presence/$userId/isOnline')
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return false;
      return event.snapshot.value as bool;
    });
  }

  /// Obtiene la última vez que un usuario estuvo online
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

  /// Establece que el usuario está escribiendo en una actividad
  Future<void> setTyping(String actividadId, String userId, bool isTyping) async {
    try {
      final ref = _database.ref('typing/$actividadId/$userId');
      
      if (isTyping) {
        await ref.set({
          'isTyping': true,
          'timestamp': ServerValue.timestamp,
        });

        // Auto-remover después de 3 segundos si no se actualiza
        await ref.onDisconnect().remove();
      } else {
        await ref.remove();
      }
    } catch (e) {
      print('Error setting typing status: $e');
    }
  }

  /// Stream para saber quién está escribiendo en una actividad
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

  /// Obtiene el estado de presencia de múltiples usuarios
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

  /// Limpia el estado de escritura cuando el usuario sale del chat
  Future<void> clearTypingStatus(String actividadId, String userId) async {
    try {
      await _database.ref('typing/$actividadId/$userId').remove();
    } catch (e) {
      print('Error clearing typing status: $e');
    }
  }

  /// Limpia toda la presencia del usuario (llamar al cerrar sesión)
  Future<void> clearUserPresence(String userId) async {
    try {
      await _database.ref('presence/$userId').remove();
    } catch (e) {
      print('Error clearing user presence: $e');
    }
  }
}
