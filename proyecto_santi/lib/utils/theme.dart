import 'package:flutter/material.dart';

// Define tus colores globales
const Color colorFondoLight = Color.fromARGB(255, 213, 223, 235);
const Color colorTextoLight = Color.fromARGB(255, 108, 124, 136);
const Color colorMenuLight = Color.fromARGB(255, 150, 178, 200);
//0xFF6C7C88
//0xFFACC2D5
//0xFF96B2C8

// Tema claro
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: colorFondoLight,
  primaryColor: colorMenuLight,
  // TEXTFIELD
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(color: colorTextoLight),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: colorMenuLight),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: colorTextoLight),
    ),
  ),
  // BOTONES
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colorMenuLight, // Color de fondo del botón
      foregroundColor: colorTextoLight, // Color del texto del botón
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      textStyle: TextStyle(fontSize: 16),
    ),
  ),
  // TEXTOS
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: colorTextoLight, fontSize: 18),
    bodyLarge: TextStyle(color: colorTextoLight, fontSize: 16),
  ),
  // APPBAR
  appBarTheme: AppBarTheme(
    color: colorMenuLight,
    titleTextStyle: TextStyle(color: colorTextoLight, fontSize: 20),
    iconTheme: IconThemeData(color: colorTextoLight),
  ),
);

const Color colorFondoDark = Color.fromARGB(255, 47, 67, 75);
const Color colorTextoDark = Color.fromARGB(255, 169, 231, 255);
const Color colorMenuDark = Color.fromARGB(255, 32, 56, 71);

// Tema oscuro
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: colorFondoDark,
  primaryColor: colorMenuDark,
  // TEXTFIELD
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(color: colorTextoDark),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: colorMenuDark),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: colorTextoDark),
    ),
  ),
  // BOTONES
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colorMenuDark, // Color de fondo del botón
      foregroundColor: colorTextoDark, // Color del texto del botón
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      textStyle: TextStyle(fontSize: 16),
    ),
  ),
  // TEXTOS
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: colorTextoDark, fontSize: 18),
    bodyLarge: TextStyle(color: colorTextoDark, fontSize: 16),
  ),
  // APPBAR
  appBarTheme: AppBarTheme(
    color: colorMenuDark,
    titleTextStyle: TextStyle(color: colorTextoDark, fontSize: 20),
    iconTheme: IconThemeData(color: colorTextoDark),
  ),
);
