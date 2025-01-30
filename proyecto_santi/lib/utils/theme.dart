import 'package:flutter/material.dart';

// Define tus colores globales
const Color colorMenuLight = Color.fromARGB(255, 103, 178, 228);
const Color colorMenuDark = Color.fromARGB(255, 32, 56, 71);
const Color colorFondoLight = Color.fromARGB(255, 220, 226, 230);
const Color colorFondoDark = Color.fromARGB(255, 36, 37, 37);
const Color colorTextoLight = Colors.black;
const Color colorTextoDark = Color.fromARGB(255, 255, 255, 255);

// Tema claro
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: colorMenuLight,
  scaffoldBackgroundColor: colorFondoLight,
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: colorTextoLight, fontSize: 18),
    bodyLarge: TextStyle(color: colorTextoLight, fontSize: 16),
  ),
  appBarTheme: AppBarTheme(
    color: colorMenuLight,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
);

// Tema oscuro
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: colorMenuDark,
  scaffoldBackgroundColor: colorFondoDark,
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: colorTextoDark, fontSize: 18),
    bodyLarge: TextStyle(color: colorTextoDark, fontSize: 16),
  ),
  appBarTheme: AppBarTheme(
    color: colorMenuDark,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
);
