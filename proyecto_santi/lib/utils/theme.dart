import 'package:flutter/material.dart';

// Define tus colores globales
const Color colorFondoLight = Color.fromARGB(255, 213, 223, 235);
const Color colorFondoDark = Color.fromARGB(255, 47, 67, 75);
//0xFF6C7C88
//0xFFACC2D5
//0xFF96B2C8
const Color colorTextoLight = Color.fromARGB(255, 108, 124, 136);
const Color colorTextoDark = Color.fromARGB(255, 169, 231, 255);

const Color colorMenuLight = Color.fromARGB(255, 150, 178, 200);
const Color colorMenuDark = Color.fromARGB(255, 32, 56, 71);

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
    titleTextStyle: TextStyle(color: colorTextoLight, fontSize: 20),
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
    titleTextStyle: TextStyle(color: colorTextoDark, fontSize: 20),
  ),
);
