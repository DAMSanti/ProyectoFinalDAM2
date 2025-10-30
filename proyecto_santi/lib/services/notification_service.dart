import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart';
import 'package:proyecto_santi/config.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'dart:io' show Platform;

/// Servicio para manejar notificaciones push usando Firebase Cloud Messaging
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    // Solicitar permisos
    await _requestPermissions();
    
    // Configurar notificaciones locales para Android/iOS
    if (!kIsWeb) {
      await _initializeLocalNotifications();
    }
    
    // Obtener token FCM
    await _getFCMToken();
    
    // Configurar listeners
    _configureFirebaseListeners();
  }

  /// Solicita permisos para notificaciones
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

  /// Inicializa las notificaciones locales (para Android/iOS)
  Future<void> _initializeLocalNotifications() async {
    try {
      // Configuración para Android
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // Configuración para iOS
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      // Configuración general
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      // Inicializar con callback para cuando el usuario toca la notificación
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      // Crear canal de notificaciones para Android
      if (!kIsWeb && Platform.isAndroid) {
        await _createNotificationChannel();
      }
    } catch (e) {
      print('[Notifications] Error initializing local notifications: $e');
    }
  }

  /// Crea el canal de notificaciones para Android
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'acex_notifications', // id
      'ACEX Notifications', // nombre
      description: 'Notificaciones de actividades y mensajes de ACEX',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Obtiene el token FCM del dispositivo
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      print('[Notifications] FCM Token: $_fcmToken');
      
      // Escuchar cambios en el token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        print('[Notifications] FCM Token refreshed: $newToken');
        // TODO: Enviar el nuevo token al backend
      });
    } catch (e) {
      print('[Notifications] Error getting FCM token: $e');
    }
  }

  /// Configura los listeners de Firebase
  void _configureFirebaseListeners() {
    // Cuando la app está en FOREGROUND (abierta)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('[Notifications] Foreground message received: ${message.notification?.title}');
      _handleMessage(message);
      _showLocalNotification(message);
    });

    // Cuando el usuario toca una notificación con la app en BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('[Notifications] Background notification tapped: ${message.notification?.title}');
      _handleNotificationTap(message);
    });

    // Verificar si la app se abrió desde una notificación (cuando estaba cerrada)
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('[Notifications] App opened from terminated state via notification');
        _handleNotificationTap(message);
      }
    });
  }

  /// Muestra una notificación local cuando la app está abierta
  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (kIsWeb) return; // No soportado en web
    
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

  /// Maneja el contenido de la notificación
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

  /// Maneja cuando el usuario toca una notificación
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    
    // Navegar según el tipo de notificación
    switch (type) {
      case 'nueva_actividad':
      case 'actividad_actualizada':
      case 'profesor_anadido':
        final actividadId = data['actividadId'];
        if (actividadId != null) {
          // TODO: Navegar a la vista de detalle de actividad
          print('[Notifications] Navigate to activity: $actividadId');
        }
        break;
      case 'nuevo_mensaje':
        final chatId = data['chatId'];
        if (chatId != null) {
          // TODO: Navegar al chat
          print('[Notifications] Navigate to chat: $chatId');
        }
        break;
    }
  }

  /// Callback cuando el usuario toca una notificación local
  void _onNotificationTapped(NotificationResponse response) {
    print('[Notifications] Local notification tapped: ${response.payload}');
    // TODO: Implementar navegación según el payload
  }

  /// Handlers específicos para cada tipo de notificación
  
  void _handleNuevaActividad(Map<String, dynamic> data) {
    print('[Notifications] Nueva actividad: ${data['actividadNombre']}');
    // Aquí puedes actualizar el estado de la app, refrescar listas, etc.
  }

  void _handleActividadActualizada(Map<String, dynamic> data) {
    print('[Notifications] Actividad actualizada: ${data['actividadId']}');
    // Refrescar datos de la actividad
  }

  void _handleNuevoMensaje(Map<String, dynamic> data) {
    print('[Notifications] Nuevo mensaje de: ${data['senderName']}');
    // Actualizar contador de mensajes no leídos
  }

  void _handleProfesorAnadido(Map<String, dynamic> data) {
    print('[Notifications] Anadido a actividad: ${data['actividadNombre']}');
    // Mostrar alerta o actualizar lista de actividades
  }

  /// Suscribirse a un tópico (útil para notificaciones grupales)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('[Notifications] Subscribed to topic: $topic');
    } catch (e) {
      print('[Notifications] Error subscribing to topic: $e');
    }
  }

  /// Desuscribirse de un tópico
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('[Notifications] Unsubscribed from topic: $topic');
    } catch (e) {
      print('[Notifications] Error unsubscribing from topic: $e');
    }
  }

  /// Envía el token al backend para que pueda enviar notificaciones
  Future<void> sendTokenToBackend(String userId) async {
    if (_fcmToken == null) {
      print('[Notifications] No FCM token available');
      return;
    }
    
    try {
      final dio = Dio();
      dio.options.baseUrl = AppConfig.apiBaseUrl;
      
      // Obtener el token JWT del ApiService
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
          'deviceId': userId, // Puedes usar un ID único del dispositivo
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

/// Handler para notificaciones en background (fuera de la clase)
/// Debe ser una función top-level
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('[Notifications] Background message received: ${message.notification?.title}');
  // Aquí puedes procesar la notificación aunque la app esté cerrada
}
