import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_santi/views/login/login_view.dart';
import 'package:proyecto_santi/components/desktop_shell.dart';
import 'package:proyecto_santi/tema/theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:proyecto_santi/models/auth.dart';
import 'package:proyecto_santi/services/notification_service.dart';
import 'package:proyecto_santi/services/lifecycle_manager.dart'; // ✅ NUEVO
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Handler global para mensajes en background
/// Debe estar fuera de cualquier clase y ser top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('[Background] Notification received: ${message.notification?.title}');
}

void main() async {
  // Esta es la base de flutter, vamos a repetirlo en consultas asincronas
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializamos Firebase con las opciones generadas automáticamente
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Configurar el handler de notificaciones en background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Inicializar el servicio de notificaciones
    await NotificationService().initialize();
    
    await initializeDateFormatting('es_ES', null);

    // Configurar modo inmersivo en Android (ocultar barra de navegación)
    if (!kIsWeb && Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [SystemUiOverlay.top], // Solo mantener la barra de estado
      );
    }

    // Limitamos el tamaño minimo de la ventana en windows, linux y mac
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      await windowManager.ensureInitialized();

      WindowOptions windowOptions =
          WindowOptions(minimumSize: Size(1208, 720), title: 'ACEX');
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
      windowManager.setAspectRatio(16 / 9);
    }

    // Lanzamos la App con ChangeNotifierProvier para tener acceso a Auth
    runApp(
      ChangeNotifierProvider(
        create: (context) => Auth()..checkAuthStatus(),
        child: MyApp(),
      ),
    );
  } catch (e) {
    // Handle initialization errors
    print('Error initializing app: $e');
  }
}

// Clase principal de la App
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  // En Android, usar tema claro por defecto. En otras plataformas, usar el del sistema
  ThemeMode _themeMode = (!kIsWeb && Platform.isAndroid) 
      ? ThemeMode.light 
      : ThemeMode.system;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  LifecycleManager? _lifecycleManager; // ✅ NUEVO

  void _toggleTheme() {
    setState(() {
      _themeMode =
      _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }
  
  @override
  void initState() {
    super.initState();
    // ✅ NUEVO: Inicializar lifecycle manager después de que el auth esté disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<Auth>();
      _lifecycleManager = LifecycleManager(auth);
    });
  }
  
  @override
  void dispose() {
    _lifecycleManager?.dispose(); // ✅ NUEVO: Liberar recursos
    super.dispose();
  }

// Construimos la App con las rutas y el tema
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'ACEX',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: _themeMode,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es', 'ES'),
            Locale('en', 'US'),
          ],
          locale: const Locale('es', 'ES'),
          home: Consumer<Auth>(
            builder: (context, auth, child) {
              // Si no está autenticado, mostrar login
              if (!auth.isAuthenticated) {
                return LoginView(onToggleTheme: _toggleTheme);
              }
              // Si está autenticado, mostrar el shell (que persiste)
              return DesktopShell(onToggleTheme: _toggleTheme);
            },
          ),
        );
      },
    );
  }
}
