import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_santi/views/login/login_view.dart';
import 'package:proyecto_santi/views/home/home_view.dart';
import 'package:proyecto_santi/views/activities/views/activityDetail_view.dart';
import 'package:proyecto_santi/views/chat/ChatList_view.dart';
import 'package:proyecto_santi/views/activities/Activities_view.dart';
import 'package:proyecto_santi/tema/theme.dart';
import 'package:proyecto_santi/views/map/map_view.dart';
import 'package:window_manager/window_manager.dart';
import 'package:proyecto_santi/models/auth.dart';
import 'package:proyecto_santi/config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

void main() async {
  // Esta es la base de flutter, vamos a repetirlo en consultas asincronas
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializamos Firebase con la info de la APi en secure storage. TODO: variables de entorno.
    await SecureStorageConfig.storeFirebaseConfig();
    await initializeDateFormatting('es_ES', null);

    final config = await SecureStorageConfig
        .retrieveFirebaseConfig(); // Retrieve the config

    final firebaseConfig = FirebaseOptions(
      apiKey: config['apiKey']!,
      authDomain: config['authDomain']!,
      projectId: config['projectId']!,
      storageBucket: config['storageBucket']!,
      messagingSenderId: config['messagingSenderId']!,
      appId: config['appId']!,
      measurementId: config['measurementId']!,
    );

    await Firebase.initializeApp(options: firebaseConfig);

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
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

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
            title: 'ACEX',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: _themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => LoginView(onToggleTheme: _toggleTheme),
              '/home': (context) => HomeView(onToggleTheme: _toggleTheme),
              '/actividades': (context) =>
                  ActivitiesView(
                      onToggleTheme: _toggleTheme,
                      isDarkTheme: _themeMode == ThemeMode.dark),
              '/mapa': (context) =>
                  MapView(
                      onToggleTheme: _toggleTheme,
                      isDarkTheme: _themeMode == ThemeMode.dark),
              '/chat': (context) =>
                  ChatListView(
                      onToggleTheme: _toggleTheme,
                      isDarkTheme: _themeMode == ThemeMode.dark),
              // Cambia a ChatListView
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/activityDetail') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) {
                    return ActivityDetailView(
                      actividad: args['activity'],
                      onToggleTheme: _toggleTheme,
                      isDarkTheme: _themeMode == ThemeMode.dark,
                    );
                  },
                );
              }
              return null;
            },
          );
        }
    );
  }
}
