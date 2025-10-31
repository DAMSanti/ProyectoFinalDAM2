import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Decoraciones y estilos comunes para diálogos
class DialogDecorations {
  /// Decoración para el contenedor principal del diálogo
  static BoxDecoration dialogContainer({
    required bool isDark,
    required bool isMobileLandscape,
    required bool isMobile,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark 
            ? AppColors.dialogBackgroundDark
            : AppColors.dialogBackgroundLight,
      ),
      borderRadius: BorderRadius.circular(
        isMobileLandscape ? 16 : (isMobile ? 20 : 20)
      ),
      border: Border.all(
        color: isDark 
            ? const Color.fromRGBO(255, 255, 255, 0.1) 
            : const Color.fromRGBO(0, 0, 0, 0.05),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          offset: Offset(0, isMobileLandscape ? 6 : 10),
          blurRadius: isMobileLandscape ? 20 : 30,
        ),
      ],
    );
  }
  
  /// Decoración para diálogos de advertencia (delete, etc)
  static BoxDecoration warningDialogContainer({
    required bool isDark,
    required bool isMobileLandscape,
    required bool isMobile,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? AppColors.warningDialogBackgroundDark
            : AppColors.warningDialogBackgroundLight,
      ),
      borderRadius: BorderRadius.circular(
        isMobileLandscape ? 16 : (isMobile ? 20 : 20)
      ),
      border: Border.all(
        color: isDark 
            ? const Color.fromRGBO(255, 255, 255, 0.1) 
            : const Color.fromRGBO(0, 0, 0, 0.05),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          offset: Offset(0, isMobileLandscape ? 6 : 10),
          blurRadius: isMobileLandscape ? 20 : 30,
        ),
      ],
    );
  }
  
  /// Padding para diálogos según tamaño de pantalla
  static EdgeInsets dialogPadding({
    required bool isMobileLandscape,
    required bool isMobile,
  }) {
    return isMobileLandscape
        ? EdgeInsets.symmetric(horizontal: 16, vertical: 12)
        : (isMobile 
            ? EdgeInsets.symmetric(horizontal: 16, vertical: 40)
            : EdgeInsets.symmetric(horizontal: 40, vertical: 24));
  }
  
  /// InputDecoration para campos de texto en diálogos
  static InputDecoration textFieldDecoration({
    required String label,
    required String hint,
    required bool isDark,
    required bool isMobileLandscape,
    required bool isMobile,
    IconData? prefixIcon,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon != null 
          ? Icon(
              prefixIcon,
              color: isDark ? Colors.white : AppColors.primary,
              size: isMobileLandscape ? 16 : (isMobile ? 18 : 20),
            )
          : null,
      suffixText: suffixText,
      suffixStyle: TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w500,
        fontSize: isMobileLandscape ? 11 : (isMobile ? 12 : 13),
      ),
      labelStyle: TextStyle(
        color: isDark ? Colors.white70 : AppColors.primary,
        fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14),
      ),
      hintStyle: TextStyle(
        color: isDark ? Colors.white38 : Colors.grey,
        fontSize: isMobileLandscape ? 11 : (isMobile ? 12 : 13),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : 10),
        borderSide: BorderSide(
          color: isDark 
              ? Colors.white.withOpacity(0.2)
              : AppColors.primaryOpacity30,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : 10),
        borderSide: BorderSide(
          color: isDark 
              ? Colors.white.withOpacity(0.2)
              : AppColors.primaryOpacity30,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : 10),
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: isMobileLandscape ? 10 : 12,
        vertical: isMobileLandscape ? 10 : 12,
      ),
    );
  }
  
  /// BoxDecoration para campos de búsqueda
  static BoxDecoration searchFieldDecoration({
    required bool isDark,
    required bool isMobileLandscape,
    required bool isMobile,
  }) {
    return BoxDecoration(
      color: isDark 
          ? Colors.white.withOpacity(0.05)
          : Colors.white.withOpacity(0.7),
      borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : 10),
      border: Border.all(
        color: AppColors.primaryOpacity30,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryOpacity10,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    );
  }
  
  /// Decoración para badges de contador
  static BoxDecoration counterBadgeDecoration({
    required bool isMobileLandscape,
    required bool isMobile,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: AppColors.primaryGradient,
      ),
      borderRadius: BorderRadius.circular(isMobileLandscape ? 12 : (isMobile ? 14 : 16)),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryOpacity30,
          offset: Offset(0, 2),
          blurRadius: 4,
        ),
      ],
    );
  }
}
