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
import 'package:proyecto_santi/services/lifecycle_manager.dart'; 
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:syncfusion_flutter_core/core.dart';
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print('[Background] Notification received: ${message.notification?.title}');
  } catch (e) {
    print('[Background] Error handling notification: $e');
  }
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Registrar licencia de Syncfusion (Community License - gratuita para proyectos no comerciales)
  // Obtén tu clave gratuita en: https://www.syncfusion.com/products/communitylicense
  SyncfusionLicense.registerLicense('');
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      } catch (e) {
        print('[Firebase] Error setting background message handler: $e');
      }
    }
    await NotificationService().initialize();
    await initializeDateFormatting('es_ES', null);
    if (!kIsWeb && Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [SystemUiOverlay.top], 
      );
    }
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
    runApp(
      ChangeNotifierProvider(
        create: (context) => Auth()..checkAuthStatus(),
        child: MyApp(),
      ),
    );
  } catch (e) {
    print('Error initializing app: $e');
  }
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  MyAppState createState() => MyAppState();
}
class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = (!kIsWeb && Platform.isAndroid) 
      ? ThemeMode.light 
      : ThemeMode.system;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  LifecycleManager? _lifecycleManager; 
  void _toggleTheme() {
    setState(() {
      _themeMode =
      _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<Auth>();
      _lifecycleManager = LifecycleManager(auth);
    });
  }
  @override
  void dispose() {
    _lifecycleManager?.dispose(); 
    super.dispose();
  }
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
              if (!auth.isAuthenticated) {
                return LoginView(onToggleTheme: _toggleTheme);
              }
              return DesktopShell(onToggleTheme: _toggleTheme);
            },
          ),
        );
      },
    );
  }
}