import 'package:flutter/material.dart';
import 'package:proyecto_santi/views/login/login_view.dart';
import 'package:proyecto_santi/views/home/home_view.dart';
import 'package:proyecto_santi/utils/theme.dart';

void main() {
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
      title: 'Flutter Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginView(onToggleTheme: _toggleTheme),
        '/home': (context) => HomeView(onToggleTheme: _toggleTheme),
      },
    );
  }
}
