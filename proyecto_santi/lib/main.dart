import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_santi/views/login/login_view.dart';
import 'package:proyecto_santi/views/home/home_view.dart';
import 'package:proyecto_santi/views/activityDetail/activity_detail_view.dart';
import 'package:proyecto_santi/views/chat/chat_list_view.dart';
import 'package:proyecto_santi/views/activities/activities_view.dart';
import 'package:proyecto_santi/tema/theme.dart';
import 'package:proyecto_santi/views/map/map_view.dart';
import 'package:proyecto_santi/components/desktop_shell.dart';
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
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
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
    final isDesktop = kIsWeb || (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS));
    
    return ScreenUtilInit(
      designSize: Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'ACEX',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: _themeMode,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            final auth = Provider.of<Auth>(context, listen: false);
            WidgetBuilder builder;

            // PROTECCIÓN DE RUTAS: Si no está autenticado y intenta acceder a rutas protegidas
            if (!auth.isAuthenticated && settings.name != '/') {
              // Redirigir siempre al login
              builder = (context) => LoginView(onToggleTheme: _toggleTheme);
            } else {
              switch (settings.name) {
                case '/':
                  builder = (context) => LoginView(onToggleTheme: _toggleTheme);
                  break;
                case '/home':
                case '/actividades':
                case '/mapa':
                case '/chat':
                  // En desktop/web, usar el shell que mantiene el menú fijo
                  if (isDesktop) {
                    String initialRoute = settings.name ?? '/home';
                    builder = (context) => DesktopShell(
                      onToggleTheme: _toggleTheme,
                      initialRoute: initialRoute,
                    );
                  } else {
                    // En mobile, usar las vistas individuales con navegación tradicional
                    switch (settings.name) {
                      case '/home':
                        builder = (context) => HomeView(onToggleTheme: _toggleTheme);
                        break;
                      case '/actividades':
                        builder = (context) => ActivitiesView(onToggleTheme: _toggleTheme);
                        break;
                      case '/mapa':
                        builder = (context) => MapView(
                          onToggleTheme: _toggleTheme,
                          isDarkTheme: _themeMode == ThemeMode.dark,
                        );
                        break;
                      case '/chat':
                        builder = (context) => ChatListView(
                          onToggleTheme: _toggleTheme,
                          isDarkTheme: _themeMode == ThemeMode.dark,
                        );
                        break;
                      default:
                        builder = (context) => HomeView(onToggleTheme: _toggleTheme);
                    }
                  }
                  break;
                case '/activityDetail':
                  final args = settings.arguments as Map<String, dynamic>;
                  builder = (context) => ActivityDetailView(
                    actividad: args['activity'],
                    onToggleTheme: _toggleTheme,
                    isDarkTheme: _themeMode == ThemeMode.dark,
                  );
                  break;
                default:
                  // Cualquier ruta no definida redirige al login (protección adicional)
                  builder = (context) => LoginView(onToggleTheme: _toggleTheme);
                  break;
              }
            }
            return MaterialPageRoute(builder: builder, settings: settings);
          },
        );
      },
    );
  }
}