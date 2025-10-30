import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_santi/views/login/login_view.dart';
import 'package:proyecto_santi/components/desktop_shell.dart';
import 'package:proyecto_santi/tema/theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:proyecto_santi/models/auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

void main() async {
  // Esta es la base de flutter, vamos a repetirlo en consultas asincronas
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializamos Firebase con las opciones generadas automáticamente
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    await initializeDateFormatting('es_ES', null);

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
  ThemeMode _themeMode = ThemeMode.system;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void _toggleTheme() {
    setState(() {
      _themeMode =
      _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
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