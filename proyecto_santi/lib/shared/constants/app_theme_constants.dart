import 'package:flutter/material.dart';

/// Constantes de diseño compartidas en toda la aplicación
/// Centraliza colores, tamaños y estilos para mantener consistencia
class AppThemeConstants {
  // ===== COLORES PRINCIPALES =====
  static const Color primaryBlue = Color(0xFF1976d2);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color mediumBlue = Color(0xFF64B5F6);
  static const Color darkBlue = Color(0xFF1565C0);
  
  // Colores de fondo
  static const Color lightBackgroundBlue = Color(0xFFBBDEFB);
  static const Color lightBackgroundBlue2 = Color(0xFF90CAF9);
  static const Color surfaceLight = Color(0xFFE3F2FD);
  static const Color surfaceDark = Color(0xFF1A2332);
  
  // Colores de estado
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFFA726);
  static const Color errorRed = Color(0xFFEF5350);
  
  // ===== TAMAÑOS DE TARJETAS =====
  static const double cardBorderRadius = 20.0;
  static const double cardPaddingVertical = 12.0;
  static const double cardPaddingHorizontal = 14.0;
  
  // ===== ESPACIADOS =====
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 24.0;
  static const double spacingXXLarge = 32.0;
  
  // ===== TAMAÑOS DE ICONOS =====
  static const double iconSizeXSmall = 12.0;
  static const double iconSizeSmall = 14.0;
  static const double iconSizeMedium = 18.0;
  static const double iconSizeLarge = 22.0;
  static const double iconSizeXLarge = 24.0;
  static const double iconSizeXXLarge = 28.0;
  
  // ===== TAMAÑOS DE FUENTE =====
  static const double fontSizeXSmall = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeHeading = 28.0;
  
  // ===== SOMBRAS =====
  static BoxShadow get defaultShadow => BoxShadow(
    color: Colors.black.withValues(alpha: 0.15),
    offset: const Offset(0, 4),
    blurRadius: 12.0,
    spreadRadius: -1,
  );
  
  static BoxShadow get hoverShadow => BoxShadow(
    color: primaryBlue.withValues(alpha: 0.35),
    offset: const Offset(0, 12),
    blurRadius: 24.0,
    spreadRadius: 0,
  );
  
  static BoxShadow get lightShadow => BoxShadow(
    color: Colors.black.withValues(alpha: 0.08),
    offset: const Offset(0, 2),
    blurRadius: 8.0,
    spreadRadius: -2,
  );
  
  // ===== GRADIENTES =====
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [
      primaryBlue,
      lightBlue,
      mediumBlue,
    ],
  );
  
  static LinearGradient cardGradientLight(double opacity) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      lightBackgroundBlue.withValues(alpha: opacity * 0.85),
      lightBackgroundBlue2.withValues(alpha: opacity * 0.75),
    ],
  );
  
  static LinearGradient cardGradientDark(double opacity) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryBlue.withValues(alpha: opacity * 0.25),
      darkBlue.withValues(alpha: opacity * 0.20),
    ],
  );
  
  static LinearGradient get dividerGradient => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Colors.transparent,
      primaryBlue.withValues(alpha: 0.3),
      Colors.transparent,
    ],
  );
  
  // ===== DECORACIONES =====
  static BoxDecoration cardDecoration({
    required bool isDark,
    bool isHovered = false,
  }) => BoxDecoration(
    borderRadius: BorderRadius.circular(cardBorderRadius),
    gradient: isDark 
        ? cardGradientDark(1.0) 
        : cardGradientLight(1.0),
    boxShadow: [
      if (isHovered) hoverShadow else defaultShadow,
    ],
    border: Border.all(
      color: isHovered
          ? primaryBlue.withValues(alpha: 0.6)
          : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
      width: isHovered ? 2 : 1,
    ),
  );
}
