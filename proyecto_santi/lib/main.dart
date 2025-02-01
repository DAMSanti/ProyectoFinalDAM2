import 'package:flutter/material.dart';
import 'package:proyecto_santi/views/login_view.dart';
import 'package:proyecto_santi/views/home_view.dart';
import 'package:proyecto_santi/views/activityDetail_view.dart';
import 'package:proyecto_santi/views/activityList_view.dart';
import 'package:proyecto_santi/utils/theme.dart';
import 'package:proyecto_santi/views/map_view.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        '/actividades': (context) => ActividadesListView(
            onToggleTheme: _toggleTheme,
            isDarkTheme: _themeMode == ThemeMode.dark),
        '/mapa': (context) => MapView(
            onToggleTheme: _toggleTheme,
            isDarkTheme: _themeMode == ThemeMode.dark),
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
