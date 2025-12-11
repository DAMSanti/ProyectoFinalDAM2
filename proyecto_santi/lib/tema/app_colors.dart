import 'package:flutter/material.dart';
class AppColors {
  static const Color primary = Color(0xFF1976d2);
  static const Color primaryDark = Color(0xFF1565c0);
  static const Color primaryLight = Color(0xFF42a5f5);
  static Color primaryOpacity90 = primary.withValues(alpha: 0.9);
  static Color primaryOpacity80 = primary.withValues(alpha: 0.8);
  static Color primaryOpacity50 = primary.withValues(alpha: 0.5);
  static Color primaryOpacity40 = primary.withValues(alpha: 0.4);
  static Color primaryOpacity30 = primary.withValues(alpha: 0.3);
  static Color primaryOpacity20 = primary.withValues(alpha: 0.2);
  static Color primaryOpacity15 = primary.withValues(alpha: 0.15);
  static Color primaryOpacity10 = primary.withValues(alpha: 0.1);
  static Color primaryDarkOpacity95 = primaryDark.withValues(alpha: 0.95);
  static Color primaryDarkOpacity90 = primaryDark.withValues(alpha: 0.90);
  static Color primaryDarkOpacity15 = primaryDark.withValues(alpha: 0.15);
  static Color primaryDarkOpacity10 = primaryDark.withValues(alpha: 0.1);
  static const List<Color> primaryGradient = [primary, primaryDark];
  static List<Color> primaryGradientOpacity(double opacity1, double opacity2) {
    return [
      primary.withValues(alpha: opacity1),
      primaryDark.withValues(alpha: opacity2),
    ];
  }
  static const Color backgroundLight = Color.fromARGB(255, 187, 222, 251);
  static const Color textLight = Color.fromARGB(255, 108, 124, 136);
  static const Color accentLight = Color.fromARGB(255, 227, 242, 253);
  static const Color softLight = Color.fromARGB(255, 176, 196, 222);
  static const Color accentDarkLight = Color.fromARGB(255, 126, 136, 180);
  static const Color backgroundDark = Color.fromARGB(255, 47, 67, 75);
  static const Color textDark = Color.fromARGB(255, 169, 231, 255);
  static const Color accentDark = Color.fromARGB(255, 32, 56, 71);
  static const List<Color> dialogBackgroundLight = [
    Color.fromRGBO(187, 222, 251, 0.95),
    Color.fromRGBO(144, 202, 249, 0.85),
  ];
  static const List<Color> dialogBackgroundDark = [
    Color.fromRGBO(25, 118, 210, 0.25),
    Color.fromRGBO(21, 101, 192, 0.20),
  ];
  static final Color warningRed = Colors.red[700]!;
  static final Color warningRedDark = Colors.red[800]!;
  static const List<Color> warningGradient = [
    Color.fromRGBO(211, 47, 47, 1.0),
    Color.fromRGBO(198, 40, 40, 1.0),
  ];
  static const List<Color> warningDialogBackgroundLight = [
    Color.fromRGBO(255, 205, 210, 0.95),
    Color.fromRGBO(239, 154, 154, 0.85),
  ];
  static const List<Color> warningDialogBackgroundDark = [
    Color.fromRGBO(211, 47, 47, 0.25),
    Color.fromRGBO(198, 40, 40, 0.20),
  ];
  static final Color cancelGrey = Colors.grey[400]!;
  static final Color cancelGreyDark = Colors.grey[500]!;
  static const List<Color> cancelGradient = [
    Color.fromRGBO(189, 189, 189, 1.0), 
    Color.fromRGBO(158, 158, 158, 1.0), 
  ];
  static const Color estadoPendiente = Colors.orange;
  static const Color estadoAprobado = Colors.green;
  static const Color estadoRechazado = Colors.red;
  static const Color tipoComplementaria = Colors.purple;
  static const Color presupuestoTransporte = Colors.purple;
  static const Color presupuestoAlojamiento = Colors.teal;
  static const Color presupuestoGastosVarios = Colors.amber;
  static const Color presupuestoGastosVariosShade700 = Color(0xFFFFA000); 
  static const Color presupuestoGastosVariosShade800 = Color(0xFFFF8F00); 
  static const Color accionEliminar = Color(0xFFD32F2F); 
  static const Color accionEditar = Color(0xFF1976D2); 
  static const Color warning = Colors.orange;
  static const List<Color> eliminarGradient = [
    Color(0xFFD32F2F), 
    Color(0xFFC62828), 
  ];
  static Color getTextColor(bool isDark) {
    return isDark ? Colors.white : primary;
  }
  static Color getBorderColor(bool isDark) {
    return isDark 
        ? Colors.white.withValues(alpha: 0.2)
        : primary.withValues(alpha: 0.3);
  }
  static Color getBackgroundColor(bool isDark) {
    return isDark ? backgroundDark : backgroundLight;
  }
  static Color getThemeTextColor(bool isDark) {
    return isDark ? textDark : textLight;
  }
  static Color getAccentColor(bool isDark) {
    return isDark ? accentDark : accentLight;
  }
}