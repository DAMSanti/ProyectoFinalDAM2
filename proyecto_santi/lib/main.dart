import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proyecto_santi/views/login/login_view.dart';
import 'package:proyecto_santi/views/home/home_view.dart';
import 'package:proyecto_santi/views/activities/views/activityDetail_view.dart';
import 'package:proyecto_santi/views/chat/ChatList_view.dart';
import 'package:proyecto_santi/views/activities/Activities_view.dart';
import 'package:proyecto_santi/tema/theme.dart';
import 'package:proyecto_santi/views/map/map_view.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const firebaseConfig = FirebaseOptions(
      apiKey: "AIzaSyDif9U1CH2ssVLTK0yDeh2-_C8SOlhTr7E",
      authDomain: "acexchat.firebaseapp.com",
      projectId: "acexchat",
      storageBucket: "acexchat.firebasestorage.app",
      messagingSenderId: "312191800375",
      appId: "1:312191800375:web:763bafc4184da334099bb2",
      measurementId: "G-B2VED5543T"
  );

  await Firebase.initializeApp(options: firebaseConfig);


  await Firebase.initializeApp();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions =
        WindowOptions(minimumSize: Size(400, 750), title: 'ACEX');
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
/*
  if (Platform.isWindows) {
    GoogleMapsFlutterPlatform.instance.init('AIzaSyB7qlgt4eNBQ8_XoV4di1IJISwVe-OiD5Q');
  }
*/
  runApp(MyApp());
}

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ACEX',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginView(onToggleTheme: _toggleTheme),
        '/home': (context) => HomeView(onToggleTheme: _toggleTheme),
        '/actividades': (context) => ActivitiesView(
            onToggleTheme: _toggleTheme,
            isDarkTheme: _themeMode == ThemeMode.dark),
        '/mapa': (context) => MapView(
            onToggleTheme: _toggleTheme,
            isDarkTheme: _themeMode == ThemeMode.dark),
        '/chat': (context) => ChatListView(
            onToggleTheme: _toggleTheme,
            isDarkTheme: _themeMode == ThemeMode.dark), // Cambia a ChatListView
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/activityDetail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return ActivityDetailView(
                activityId: args['activityId'],
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
}
