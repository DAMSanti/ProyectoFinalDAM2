import 'package:flutter/material.dart';
import 'app_colors.dart';
const Color colorFondoLight = AppColors.backgroundLight;
const Color colorTextoLight = AppColors.textLight;
const Color colorAccentLight = AppColors.accentLight;
const Color colorSoftLight = AppColors.softLight;
const Color colorAccentDLight = AppColors.accentDarkLight;
const Color colorFondoDark = AppColors.backgroundDark;
const Color colorTextoDark = AppColors.textDark;
const Color colorAccentDark = AppColors.accentDark;
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.backgroundLight,
  primaryColor: AppColors.accentLight,
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(color: AppColors.textLight), 
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.accentDarkLight)
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.textLight)
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accentLight,
      foregroundColor: AppColors.textLight,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, inherit: true),
    ),
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(color: AppColors.textLight, inherit: true, fontSize: 16),
    displayMedium: TextStyle(color: AppColors.textLight, inherit: true, fontSize: 16),
    displaySmall: TextStyle(color: AppColors.textLight, inherit: true, fontSize: 16),
    headlineLarge: TextStyle(color: AppColors.textLight, inherit: true, fontSize: 16),
    headlineMedium: TextStyle(color: AppColors.textLight, inherit: true, fontSize: 16),
    headlineSmall: TextStyle(color: AppColors.textLight, inherit: true, fontSize: 16, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(color: AppColors.textLight, inherit: true, fontSize: 16),
    bodyMedium: TextStyle(color: AppColors.textLight, inherit: true, fontSize: 14),
    bodySmall: TextStyle(color: AppColors.textLight, inherit: true, fontSize: 12),
    titleLarge: TextStyle(color: AppColors.textLight, inherit: true, fontSize: 16),
    titleMedium: TextStyle(color: AppColors.textLight, inherit: true, fontSize: 16, fontWeight: FontWeight.bold),
    titleSmall: TextStyle(color: AppColors.textLight, inherit: true, fontSize: 16),
    labelLarge: TextStyle(color: AppColors.textLight, inherit: true, fontSize: 16),
    labelMedium: TextStyle(color: AppColors.textLight, inherit: true, fontSize: 16),
    labelSmall: TextStyle(color: AppColors.textLight, inherit: true, fontSize: 16),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    titleTextStyle: TextStyle(
      color: AppColors.primary, 
      fontSize: 20,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
      inherit: true,
    ),
    iconTheme: IconThemeData(color: AppColors.primary),
  ),
  cardTheme: CardThemeData(
    color: AppColors.accentLight,
    shadowColor: Colors.grey,
    elevation: 4,
  ),
  listTileTheme: ListTileThemeData(
    titleTextStyle: TextStyle(color: AppColors.textLight, fontSize: 16, fontWeight: FontWeight.bold, inherit: true),
    subtitleTextStyle: TextStyle(color: AppColors.textLight, fontSize: 16, fontWeight: FontWeight.bold, inherit: true),
    textColor: AppColors.textLight,
    iconColor: AppColors.textLight,
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.backgroundLight,
    titleTextStyle: TextStyle(color: AppColors.textLight, fontSize: 20, inherit: true),
    contentTextStyle: TextStyle(color: AppColors.textLight, fontSize: 16, inherit: true),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: AppColors.backgroundLight,
  ),
  colorScheme: ColorScheme.light(
      primary: AppColors.accentLight,
      secondary: AppColors.backgroundLight
  ),
);
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.backgroundDark,
  primaryColor: AppColors.accentDark,
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(color: AppColors.textDark), 
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.accentDark)
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.textDark)
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accentDark,
      foregroundColor: AppColors.textDark,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, inherit: true),
    ),
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(color: AppColors.textDark, inherit: true, fontSize: 16),
    displayMedium: TextStyle(color: AppColors.textDark, inherit: true, fontSize: 16),
    displaySmall: TextStyle(color: AppColors.textDark, inherit: true, fontSize: 16),
    headlineLarge: TextStyle(color: AppColors.textDark, inherit: true, fontSize: 16),
    headlineMedium: TextStyle(color: AppColors.textDark, inherit: true, fontSize: 16),
    headlineSmall: TextStyle(color: AppColors.textDark, inherit: true, fontSize: 16, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(color: AppColors.textDark, inherit: true, fontSize: 16),
    bodyMedium: TextStyle(color: AppColors.textDark, inherit: true, fontSize: 14),
    bodySmall: TextStyle(color: AppColors.textDark, inherit: true, fontSize: 12),
    titleLarge: TextStyle(color: AppColors.textDark, inherit: true, fontSize: 16),
    titleMedium: TextStyle(color: AppColors.textDark, inherit: true, fontSize: 16, fontWeight: FontWeight.bold),
    titleSmall: TextStyle(color: AppColors.textDark, inherit: true, fontSize: 16),
    labelLarge: TextStyle(color: AppColors.textDark, inherit: true, fontSize: 16),
    labelMedium: TextStyle(color: AppColors.textDark, inherit: true, fontSize: 16),
    labelSmall: TextStyle(color: AppColors.textDark, inherit: true, fontSize: 16),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.accentDark,
    titleTextStyle: TextStyle(
      color: AppColors.primary, 
      fontSize: 20,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
      inherit: true,
    ),
    iconTheme: IconThemeData(color: AppColors.textDark),
  ),
  cardTheme: CardThemeData(
    color: AppColors.accentDark,
    shadowColor: Colors.grey,
    elevation: 4,
  ),
  listTileTheme: ListTileThemeData(
    titleTextStyle: TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.bold, inherit: true),
    subtitleTextStyle: TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.bold, inherit: true),
    textColor: AppColors.textDark,
    iconColor: AppColors.textDark,
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.backgroundDark,
    titleTextStyle: TextStyle(color: AppColors.textDark, fontSize: 20, inherit: true),
    contentTextStyle: TextStyle(color: AppColors.textDark, fontSize: 16, inherit: true),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: AppColors.backgroundDark,
  ),
  colorScheme: ColorScheme.dark(
      primary: AppColors.accentDark,
      secondary: AppColors.backgroundDark
  ),
);