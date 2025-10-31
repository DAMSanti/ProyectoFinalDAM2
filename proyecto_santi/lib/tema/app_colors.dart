import 'package:flutter/material.dart';

/// Colores de la aplicación
/// Centraliza todos los colores usados en la app para mantener consistencia visual
class AppColors {
  // ============================================================================
  // COLORES PRINCIPALES - Usados en diálogos, botones, y elementos destacados
  // ============================================================================
  
  /// Color azul principal (#1976d2) - Usado en botones, headers, acciones primarias
  static const Color primary = Color(0xFF1976d2);
  
  /// Color azul oscuro (#1565c0) - Usado en gradientes con primary
  static const Color primaryDark = Color(0xFF1565c0);
  
  /// Color azul claro (#42a5f5) - Opcional para variaciones
  static const Color primaryLight = Color(0xFF42a5f5);
  
  // Variaciones con opacidad del color primario (azul)
  static Color primaryOpacity90 = primary.withOpacity(0.9);
  static Color primaryOpacity80 = primary.withOpacity(0.8);
  static Color primaryOpacity50 = primary.withOpacity(0.5);
  static Color primaryOpacity40 = primary.withOpacity(0.4);
  static Color primaryOpacity30 = primary.withOpacity(0.3);
  static Color primaryOpacity20 = primary.withOpacity(0.2);
  static Color primaryOpacity15 = primary.withOpacity(0.15);
  static Color primaryOpacity10 = primary.withOpacity(0.1);
  
  static Color primaryDarkOpacity95 = primaryDark.withOpacity(0.95);
  static Color primaryDarkOpacity90 = primaryDark.withOpacity(0.90);
  static Color primaryDarkOpacity15 = primaryDark.withOpacity(0.15);
  static Color primaryDarkOpacity10 = primaryDark.withOpacity(0.1);
  
  /// Gradiente primario [azul, azul oscuro]
  static const List<Color> primaryGradient = [primary, primaryDark];
  
  /// Genera gradiente primario con opacidades personalizadas
  static List<Color> primaryGradientOpacity(double opacity1, double opacity2) {
    return [
      primary.withOpacity(opacity1),
      primaryDark.withOpacity(opacity2),
    ];
  }
  
  // ============================================================================
  // COLORES DEL TEMA GENERAL - Fondos y textos de la aplicación
  // ============================================================================
  
  // --- TEMA CLARO ---
  /// Fondo principal del tema claro (#BBDEF7)
  static const Color backgroundLight = Color.fromARGB(255, 187, 222, 251);
  
  /// Color de texto principal del tema claro (#6C7C88)
  static const Color textLight = Color.fromARGB(255, 108, 124, 136);
  
  /// Color de acento/cards del tema claro (#E3F2FD)
  static const Color accentLight = Color.fromARGB(255, 227, 242, 253);
  
  /// Color suave adicional del tema claro (#B0C4DE)
  static const Color softLight = Color.fromARGB(255, 176, 196, 222);
  
  /// Color de acento oscuro del tema claro (#7E88B4)
  static const Color accentDarkLight = Color.fromARGB(255, 126, 136, 180);
  
  // --- TEMA OSCURO ---
  /// Fondo principal del tema oscuro (#2F434B)
  static const Color backgroundDark = Color.fromARGB(255, 47, 67, 75);
  
  /// Color de texto principal del tema oscuro (#A9E7FF)
  static const Color textDark = Color.fromARGB(255, 169, 231, 255);
  
  /// Color de acento/cards del tema oscuro (#203847)
  static const Color accentDark = Color.fromARGB(255, 32, 56, 71);
  
  // ============================================================================
  // COLORES PARA DIÁLOGOS
  // ============================================================================
  
  /// Fondo de diálogos en tema claro (gradiente azul suave)
  static const List<Color> dialogBackgroundLight = [
    Color.fromRGBO(187, 222, 251, 0.95),
    Color.fromRGBO(144, 202, 249, 0.85),
  ];
  
  /// Fondo de diálogos en tema oscuro (gradiente azul oscuro)
  static const List<Color> dialogBackgroundDark = [
    Color.fromRGBO(25, 118, 210, 0.25),
    Color.fromRGBO(21, 101, 192, 0.20),
  ];
  
  // ============================================================================
  // COLORES DE ADVERTENCIA/ELIMINAR (ROJO)
  // ============================================================================
  
  /// Color rojo para advertencias (#D32F2F)
  static final Color warningRed = Colors.red[700]!;
  
  /// Color rojo oscuro para advertencias (#C62828)
  static final Color warningRedDark = Colors.red[800]!;
  
  /// Gradiente rojo para botones de advertencia
  static const List<Color> warningGradient = [
    Color.fromRGBO(211, 47, 47, 1.0),
    Color.fromRGBO(198, 40, 40, 1.0),
  ];
  
  /// Fondo de diálogos de advertencia en tema claro
  static const List<Color> warningDialogBackgroundLight = [
    Color.fromRGBO(255, 205, 210, 0.95),
    Color.fromRGBO(239, 154, 154, 0.85),
  ];
  
  /// Fondo de diálogos de advertencia en tema oscuro
  static const List<Color> warningDialogBackgroundDark = [
    Color.fromRGBO(211, 47, 47, 0.25),
    Color.fromRGBO(198, 40, 40, 0.20),
  ];
  
  // ============================================================================
  // COLORES DE BOTONES CANCELAR (GRIS)
  // ============================================================================
  
  /// Gris para botones cancelar (#BDBDBD)
  static final Color cancelGrey = Colors.grey[400]!;
  
  /// Gris oscuro para botones cancelar (#9E9E9E)
  static final Color cancelGreyDark = Colors.grey[500]!;
  
  /// Gradiente gris para botones cancelar
  static const List<Color> cancelGradient = [
    Color.fromRGBO(189, 189, 189, 1.0), // grey[400]
    Color.fromRGBO(158, 158, 158, 1.0), // grey[500]
  ];
  
  // ============================================================================
  // MÉTODOS HELPER
  // ============================================================================
  
  /// Obtiene el color de texto apropiado según el tema
  /// En tema oscuro retorna blanco, en claro retorna el azul primario
  static Color getTextColor(bool isDark) {
    return isDark ? Colors.white : primary;
  }
  
  /// Obtiene el color de borde apropiado según el tema
  static Color getBorderColor(bool isDark) {
    return isDark 
        ? Colors.white.withOpacity(0.2)
        : primary.withOpacity(0.3);
  }
  
  /// Obtiene el color de fondo según el tema
  static Color getBackgroundColor(bool isDark) {
    return isDark ? backgroundDark : backgroundLight;
  }
  
  /// Obtiene el color de texto del tema según isDark
  static Color getThemeTextColor(bool isDark) {
    return isDark ? textDark : textLight;
  }
  
  /// Obtiene el color de acento según el tema
  static Color getAccentColor(bool isDark) {
    return isDark ? accentDark : accentLight;
  }
}
