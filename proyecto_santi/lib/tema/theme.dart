import 'package:flutter/material.dart';

// Define tus colores globales - Basados en el menú lateral
const Color colorFondoLight = Color(0xFFbbdefb); // Azul claro del menú
const Color colorTextoLight = Color.fromARGB(255, 108, 124, 136);
const Color colorAccentLight = Color(0xFFe3f2fd); // Azul muy claro del menú
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
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, inherit: true),
    ),
  ),
  // TEXTOS
  textTheme: TextTheme(
    displayLarge: TextStyle(color: colorTextoLight, inherit: true, fontSize: 16),
    displayMedium: TextStyle(color: colorTextoLight, inherit: true, fontSize: 16),
    displaySmall: TextStyle(color: colorTextoLight, inherit: true, fontSize: 16),
    headlineLarge: TextStyle(color: colorTextoLight, inherit: true, fontSize: 16),
    headlineMedium: TextStyle(color: colorTextoLight, inherit: true, fontSize: 16),
    headlineSmall: TextStyle(color: colorTextoLight, inherit: true, fontSize: 16, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(color: colorTextoLight, inherit: true, fontSize: 16),
    bodyMedium: TextStyle(color: colorTextoLight, inherit: true, fontSize: 14),
    bodySmall: TextStyle(color: colorTextoLight, inherit: true, fontSize: 12),
    titleLarge: TextStyle(color: colorTextoLight, inherit: true, fontSize: 16),
    titleMedium: TextStyle(color: colorTextoLight, inherit: true, fontSize: 16, fontWeight: FontWeight.bold),
    titleSmall: TextStyle(color: colorTextoLight, inherit: true, fontSize: 16),
    labelLarge: TextStyle(color: colorTextoLight, inherit: true, fontSize: 16),
    labelMedium: TextStyle(color: colorTextoLight, inherit: true, fontSize: 16),
    labelSmall: TextStyle(color: colorTextoLight, inherit: true, fontSize: 16),
  ),
  // APPBAR
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    titleTextStyle: TextStyle(color: colorTextoLight, fontSize: 20, inherit: true),
    iconTheme: IconThemeData(color: colorTextoLight),
  ),
  // CARDS
  cardTheme: CardThemeData(
    color: colorAccentLight,
    shadowColor: Colors.grey,
    elevation: 4,
  ),
  // LISTTILE
  listTileTheme: ListTileThemeData(
    titleTextStyle: TextStyle(color: colorTextoLight, fontSize: 16, fontWeight: FontWeight.bold, inherit: true),
    subtitleTextStyle: TextStyle(color: colorTextoLight, fontSize: 16, fontWeight: FontWeight.bold, inherit: true),
    textColor: colorTextoLight,
    iconColor: colorTextoLight,
  ),
  // DIALOG
  dialogTheme: DialogThemeData(
    backgroundColor: colorFondoLight,
    titleTextStyle: TextStyle(color: colorTextoLight, fontSize: 20, inherit: true),
    contentTextStyle: TextStyle(color: colorTextoLight, fontSize: 16, inherit: true),
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


// Colores oscuros - Basados en el menú lateral
const Color colorFondoDark = Color(0xFF16213e); // Azul oscuro del menú
const Color colorTextoDark = Color.fromARGB(255, 169, 231, 255);
const Color colorAccentDark = Color(0xFF1a1a2e); // Azul muy oscuro del menú

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
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, inherit: true),
    ),
  ),
  // TEXTOS
  textTheme: TextTheme(
    displayLarge: TextStyle(color: colorTextoDark, inherit: true, fontSize: 16),
    displayMedium: TextStyle(color: colorTextoDark, inherit: true, fontSize: 16),
    displaySmall: TextStyle(color: colorTextoDark, inherit: true, fontSize: 16),
    headlineLarge: TextStyle(color: colorTextoDark, inherit: true, fontSize: 16),
    headlineMedium: TextStyle(color: colorTextoDark, inherit: true, fontSize: 16),
    headlineSmall: TextStyle(color: colorTextoDark, inherit: true, fontSize: 16, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(color: colorTextoDark, inherit: true, fontSize: 16),
    bodyMedium: TextStyle(color: colorTextoDark, inherit: true, fontSize: 14),
    bodySmall: TextStyle(color: colorTextoDark, inherit: true, fontSize: 12),
    titleLarge: TextStyle(color: colorTextoDark, inherit: true, fontSize: 16),
    titleMedium: TextStyle(color: colorTextoDark, inherit: true, fontSize: 16, fontWeight: FontWeight.bold),
    titleSmall: TextStyle(color: colorTextoDark, inherit: true, fontSize: 16),
    labelLarge: TextStyle(color: colorTextoDark, inherit: true, fontSize: 16),
    labelMedium: TextStyle(color: colorTextoDark, inherit: true, fontSize: 16),
    labelSmall: TextStyle(color: colorTextoDark, inherit: true, fontSize: 16),
  ),
  // APPBAR
  appBarTheme: AppBarTheme(
    backgroundColor: colorAccentDark,
    titleTextStyle: TextStyle(color: colorTextoDark, fontSize: 20, inherit: true),
    iconTheme: IconThemeData(color: colorTextoDark),
  ),
  // CARDS
  cardTheme: CardThemeData(
    color: colorAccentDark,
    shadowColor: Colors.grey,
    elevation: 4,
  ),
// LISTTILE
  listTileTheme: ListTileThemeData(
    titleTextStyle: TextStyle(color: colorTextoDark, fontSize: 16, fontWeight: FontWeight.bold, inherit: true),
    subtitleTextStyle: TextStyle(color: colorTextoDark, fontSize: 16, fontWeight: FontWeight.bold, inherit: true),
    textColor: colorTextoDark,
    iconColor: colorTextoDark,
  ),
  // DIALOG
  dialogTheme: DialogThemeData(
    backgroundColor: colorFondoDark,
    titleTextStyle: TextStyle(color: colorTextoDark, fontSize: 20, inherit: true),
    contentTextStyle: TextStyle(color: colorTextoDark, fontSize: 16, inherit: true),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  // DRAWER
  drawerTheme: DrawerThemeData(
    backgroundColor: colorFondoDark,
  ),
  colorScheme: ColorScheme.dark(
      primary: colorAccentDark,
      secondary: colorFondoDark // Color específico para el DrawerHeader
  ),
);
