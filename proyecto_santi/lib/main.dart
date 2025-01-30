import 'package:flutter/material.dart';
import 'package:proyecto_santi/utils/theme.dart';
import 'package:proyecto_santi/views/login/login_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
      title: 'ACEX App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: LoginView(
          onToggleTheme: _toggleTheme), // Pasa la función de cambio de tema
    );
  }
}
