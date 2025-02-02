import 'package:flutter/material.dart';

// Define tus colores globales
const Color colorFondoLight = Color.fromARGB(255, 213, 223, 235);
const Color colorTextoLight = Color.fromARGB(255, 108, 124, 136);
const Color colorAccentLight = Color.fromARGB(255, 150, 178, 200);
const Color colorSoftLight = Color.fromARGB(255, 176, 196, 222);
const Color colorAccentDLight = Color.fromARGB(255, 126, 136, 180);
//0xFF6C7C88
//0xFFACC2D5
//0xFF96B2C8

// Tema claro
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: colorFondoLight,
  primaryColor: colorAccentLight,
  // TEXTFIELD
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(color: colorTextoLight), focusedBorder: OutlineInputBorder( borderSide: BorderSide(color: colorAccentDLight)),
    enabledBorder: OutlineInputBorder( borderSide: BorderSide(color: colorTextoLight)),
  ),
  // BOTONES
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colorAccentLight, // Color de fondo del botón
      foregroundColor: colorTextoLight, // Color del texto del botón
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),
  // TEXTOS
  textTheme: TextTheme(
    displayLarge: TextStyle(color: colorTextoLight),
    displayMedium: TextStyle(color: colorTextoLight),
    displaySmall: TextStyle(color: colorTextoLight),
    headlineLarge: TextStyle(color: colorTextoLight),
    headlineMedium: TextStyle(color: colorTextoLight),
    headlineSmall: TextStyle(color: colorTextoLight),
    bodyLarge: TextStyle(color: colorTextoLight),
    bodyMedium: TextStyle(color: colorTextoLight),
    bodySmall: TextStyle(color: colorTextoLight),
    titleLarge: TextStyle(color: colorTextoLight),
    titleMedium: TextStyle(color: colorTextoLight, fontSize: 20, fontWeight: FontWeight.bold),
    titleSmall: TextStyle(color: colorTextoLight),
    labelLarge: TextStyle(color: colorTextoLight),
    labelMedium: TextStyle(color: colorTextoLight),
    labelSmall: TextStyle(color: colorTextoLight),
  ),
  // APPBAR
  appBarTheme: AppBarTheme(
    color: Colors.transparent,
    titleTextStyle: TextStyle(color: colorTextoLight, fontSize: 20),
    iconTheme: IconThemeData(color: colorTextoLight),
  ),
  // CARDS
  cardTheme: CardTheme(
    color: colorAccentLight,
    shadowColor: Colors.grey,
    elevation: 4,
  ),
  // LISTTILE
  listTileTheme: ListTileThemeData(
    textColor: colorTextoLight,
    iconColor: colorTextoLight,
  ),
  // DIALOG
  dialogTheme: DialogTheme(
    backgroundColor: colorFondoLight,
    titleTextStyle: TextStyle(color: colorTextoLight, fontSize: 20),
    contentTextStyle: TextStyle(color: colorTextoLight, fontSize: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  // DRAWER
  drawerTheme: DrawerThemeData(
    backgroundColor: colorFondoLight,
  ),
  colorScheme: ColorScheme.light(
      primary: colorAccentLight,
      secondary: colorFondoLight // Color específico para el DrawerHeader
  ),
);




const Color colorFondoDark = Color.fromARGB(255, 47, 67, 75);
const Color colorTextoDark = Color.fromARGB(255, 169, 231, 255);
const Color colorAccentDark = Color.fromARGB(255, 32, 56, 71);

// Tema oscuro
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: colorFondoDark,
  primaryColor: colorAccentDark,
  // TEXTFIELD
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(color: colorTextoDark), focusedBorder: OutlineInputBorder( borderSide: BorderSide(color: colorAccentDark)),
    enabledBorder: OutlineInputBorder( borderSide: BorderSide(color: colorTextoDark)),
  ),
  // BOTONES
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colorAccentDark, // Color de fondo del botón
      foregroundColor: colorTextoDark, // Color del texto del botón
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),
  // TEXTOS
  textTheme: TextTheme(
    displayLarge: TextStyle(color: colorTextoDark),
    displayMedium: TextStyle(color: colorTextoDark),
    displaySmall: TextStyle(color: colorTextoDark),
    headlineLarge: TextStyle(color: colorTextoDark),
    headlineMedium: TextStyle(color: colorTextoDark),
    headlineSmall: TextStyle(color: colorTextoDark),
    bodyLarge: TextStyle(color: colorTextoDark),
    bodyMedium: TextStyle(color: colorTextoDark),
    bodySmall: TextStyle(color: colorTextoDark),
    titleLarge: TextStyle(color: colorTextoDark),
    titleMedium: TextStyle(color: colorTextoDark, fontSize: 20, fontWeight: FontWeight.bold),
    titleSmall: TextStyle(color: colorTextoDark),
    labelLarge: TextStyle(color: colorTextoDark),
    labelMedium: TextStyle(color: colorTextoDark),
    labelSmall: TextStyle(color: colorTextoDark),
  ),
  // APPBAR
  appBarTheme: AppBarTheme(
    color: colorAccentDark,
    titleTextStyle: TextStyle(color: colorTextoDark, fontSize: 20),
    iconTheme: IconThemeData(color: colorTextoDark),
  ),
  // CARDS
  cardTheme: CardTheme(
    color: colorAccentDark,
    shadowColor: Colors.grey,
    elevation: 4,
  ),
// LISTTILE
  listTileTheme: ListTileThemeData(
    textColor: colorTextoDark,
    iconColor: colorTextoDark,
  ),
  // DIALOG
  dialogTheme: DialogTheme(
    backgroundColor: colorFondoDark,
    titleTextStyle: TextStyle(color: colorTextoDark, fontSize: 20),
    contentTextStyle: TextStyle(color: colorTextoDark, fontSize: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
);
