import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart';
import 'package:proyecto_santi/config.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'dart:io' show Platform;
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  String? _fcmToken;
  String? get fcmToken => _fcmToken;
  Future<void> initialize() async {
    await _requestPermissions();
    if (!kIsWeb) {
      await _initializeLocalNotifications();
    }
    await _getFCMToken();
    _configureFirebaseListeners();
  }
  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('[Notifications] Permission status: ${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('[Notifications] User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('[Notifications] User granted provisional permission');
    } else {
      print('[Notifications] User declined or has not accepted permission');
    }
  }
  Future<void> _initializeLocalNotifications() async {
    try {
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      if (!kIsWeb && Platform.isAndroid) {
        await _createNotificationChannel();
      }
    } catch (e) {
      print('[Notifications] Error initializing local notifications: $e');
    }
  }
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'acex_notifications', 
      'ACEX Notifications', 
      description: 'Notificaciones de actividades y mensajes de ACEX',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  Future<void> _getFCMToken() async {
    if (kIsWeb) {
      print('[Notifications] Firebase Messaging not supported on web');
      return;
    }
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      print('[Notifications] FCM Token: $_fcmToken');
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        print('[Notifications] FCM Token refreshed: $newToken');
      });
    } catch (e) {
      print('[Notifications] Error getting FCM token: $e');
      print('[Notifications] Note: Firebase Messaging may not be properly configured');
    }
  }
  void _configureFirebaseListeners() {
    if (kIsWeb) {
      print('[Notifications] Firebase Messaging not supported on web');
      return;
    }
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('[Notifications] Foreground message received: ${message.notification?.title}');
        _handleMessage(message);
        _showLocalNotification(message);
      });
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('[Notifications] Background notification tapped: ${message.notification?.title}');
        _handleNotificationTap(message);
      });
      _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          print('[Notifications] App opened from terminated state via notification');
          _handleNotificationTap(message);
        }
      }).catchError((e) {
        print('[Notifications] Error getting initial message: $e');
      });
    } catch (e) {
      print('[Notifications] Error configuring Firebase listeners: $e');
      print('[Notifications] Note: Firebase Messaging may not be available on this platform');
    }
  }
  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (kIsWeb) return; 
    final notification = message.notification;
    final android = message.notification?.android;
    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'acex_notifications',
            'ACEX Notifications',
            channelDescription: 'Notificaciones de actividades y mensajes de ACEX',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }
  void _handleMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    print('[Notifications] Message data: $data');
    switch (type) {
      case 'nueva_actividad':
        _handleNuevaActividad(data);
        break;
      case 'actividad_actualizada':
        _handleActividadActualizada(data);
        break;
      case 'nuevo_mensaje':
        _handleNuevoMensaje(data);
        break;
      case 'profesor_anadido':
        _handleProfesorAnadido(data);
        break;
      default:
        print('[Notifications] Unknown notification type: $type');
    }
  }
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    switch (type) {
      case 'nueva_actividad':
      case 'actividad_actualizada':
      case 'profesor_anadido':
        final actividadId = data['actividadId'];
        if (actividadId != null) {
          print('[Notifications] Navigate to activity: $actividadId');
        }
        break;
      case 'nuevo_mensaje':
        final chatId = data['chatId'];
        if (chatId != null) {
          print('[Notifications] Navigate to chat: $chatId');
        }
        break;
    }
  }
  void _onNotificationTapped(NotificationResponse response) {
    print('[Notifications] Local notification tapped: ${response.payload}');
  }
  void _handleNuevaActividad(Map<String, dynamic> data) {
    print('[Notifications] Nueva actividad: ${data['actividadNombre']}');
  }
  void _handleActividadActualizada(Map<String, dynamic> data) {
    print('[Notifications] Actividad actualizada: ${data['actividadId']}');
  }
  void _handleNuevoMensaje(Map<String, dynamic> data) {
    print('[Notifications] Nuevo mensaje de: ${data['senderName']}');
  }
  void _handleProfesorAnadido(Map<String, dynamic> data) {
    print('[Notifications] Anadido a actividad: ${data['actividadNombre']}');
  }
  Future<void> subscribeToTopic(String topic) async {
    try {
      if (kIsWeb) {
        print('[Notifications] Cannot subscribe to topics on web');
        return;
      }
      await _firebaseMessaging.subscribeToTopic(topic);
      print('[Notifications] Subscribed to topic: $topic');
    } catch (e) {
      print('[Notifications] Error subscribing to topic: $e');
    }
  }
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      if (kIsWeb) {
        print('[Notifications] Cannot unsubscribe from topics on web');
        return;
      }
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('[Notifications] Unsubscribed from topic: $topic');
    } catch (e) {
      print('[Notifications] Error unsubscribing from topic: $e');
    }
  }
  Future<void> sendTokenToBackend(String userId) async {
    if (_fcmToken == null) {
      print('[Notifications] No FCM token available');
      return;
    }
    try {
      final dio = Dio();
      dio.options.baseUrl = AppConfig.apiBaseUrl;
      final apiService = ApiService();
      final jwtToken = apiService.token;
      if (jwtToken == null) {
        print('[Notifications] No JWT token available');
        return;
      }
      dio.options.headers['Authorization'] = 'Bearer $jwtToken';
      String? deviceType;
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          deviceType = 'android';
        } else if (Platform.isIOS) {
          deviceType = 'ios';
        } else if (Platform.isWindows) {
          deviceType = 'windows';
        } else if (Platform.isMacOS) {
          deviceType = 'macos';
        } else if (Platform.isLinux) {
          deviceType = 'linux';
        } else {
          deviceType = 'unknown';
        }
      } else {
        deviceType = 'web';
      }
      print('[Notifications] Sending token to backend. Device: $deviceType, UserId: $userId');
      final response = await dio.post(
        '/Notification/register-token',
        data: {
          'token': _fcmToken,
          'deviceType': deviceType,
          'deviceId': userId, 
        },
      );
      if (response.statusCode == 200) {
        print('[Notifications] ✅ Token sent to backend successfully');
        print('[Notifications] Response: ${response.data}');
      } else {
        print('[Notifications] ⚠️ Token sent but got status: ${response.statusCode}');
      }
    } catch (e) {
      print('[Notifications] ❌ Error sending token to backend: $e');
      if (e is DioException) {
        print('[Notifications] Error details: ${e.response?.data}');
        print('[Notifications] Status code: ${e.response?.statusCode}');
      }
    }
  }
}
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('[Notifications] Background message received: ${message.notification?.title}');
}