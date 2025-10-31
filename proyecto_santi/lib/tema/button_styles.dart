import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Estilos de botones reutilizables para la aplicación
class ButtonStyles {
  /// Estilo para botón primario con gradiente azul
  static BoxDecoration primaryButtonDecoration({
    required bool isMobileLandscape,
    required bool isMobile,
    bool disabled = false,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: AppColors.primaryGradient,
      ),
      borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
      boxShadow: disabled ? [] : [
        BoxShadow(
          color: AppColors.primaryOpacity40,
          offset: Offset(0, isMobileLandscape ? 2 : (isMobile ? 2 : 4)),
          blurRadius: isMobileLandscape ? 3 : (isMobile ? 4 : 8),
        ),
      ],
    );
  }
  
  /// Estilo para botón cancelar con gradiente gris
  static BoxDecoration cancelButtonDecoration({
    required bool isMobileLandscape,
    required bool isMobile,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: AppColors.cancelGradient,
      ),
      borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          offset: Offset(0, isMobileLandscape ? 2 : (isMobile ? 2 : 4)),
          blurRadius: isMobileLandscape ? 3 : (isMobile ? 4 : 8),
        ),
      ],
    );
  }
  
  /// Estilo para botón de advertencia/eliminar con gradiente rojo
  static BoxDecoration warningButtonDecoration({
    required bool isMobileLandscape,
    required bool isMobile,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: AppColors.warningGradient,
      ),
      borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
      boxShadow: [
        BoxShadow(
          color: Colors.red.withOpacity(0.4),
          offset: Offset(0, isMobileLandscape ? 2 : (isMobile ? 2 : 4)),
          blurRadius: isMobileLandscape ? 3 : (isMobile ? 4 : 8),
        ),
      ],
    );
  }
  
  /// Padding para botones según tamaño
  static EdgeInsets buttonPadding({
    required bool isMobileLandscape,
    required bool isMobile,
  }) {
    return EdgeInsets.symmetric(
      horizontal: isMobileLandscape ? 12 : (isMobile ? 16 : 24), 
      vertical: isMobileLandscape ? 8 : (isMobile ? 10 : 12)
    );
  }
  
  /// TextStyle para texto de botones
  static TextStyle buttonTextStyle({
    required bool isMobileLandscape,
    required bool isMobile,
    Color color = Colors.white,
  }) {
    return TextStyle(
      color: color,
      fontWeight: FontWeight.bold,
      fontSize: isMobileLandscape ? 13 : (isMobile ? 14 : 16),
    );
  }
  
  /// Tamaño de iconos en botones
  static double buttonIconSize({
    required bool isMobileLandscape,
    required bool isMobile,
  }) {
    return isMobileLandscape ? 16 : (isMobile ? 18 : 20);
  }
  
  /// BorderRadius para botones
  static BorderRadius buttonBorderRadius({
    required bool isMobileLandscape,
    required bool isMobile,
  }) {
    return BorderRadius.circular(isMobileLandscape ? 6 : (isMobile ? 8 : 10));
  }
  
  /// Widget completo de botón primario reutilizable
  static Widget primaryButton({
    required VoidCallback? onPressed,
    required String text,
    required bool isMobileLandscape,
    required bool isMobile,
    IconData? icon,
    bool expanded = false,
  }) {
    final isDisabled = onPressed == null;
    
    Widget button = Container(
      decoration: primaryButtonDecoration(
        isMobileLandscape: isMobileLandscape,
        isMobile: isMobile,
        disabled: isDisabled,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: buttonBorderRadius(
            isMobileLandscape: isMobileLandscape,
            isMobile: isMobile,
          ),
          child: Padding(
            padding: buttonPadding(
              isMobileLandscape: isMobileLandscape,
              isMobile: isMobile,
            ),
            child: Row(
              mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: Colors.white,
                    size: buttonIconSize(
                      isMobileLandscape: isMobileLandscape,
                      isMobile: isMobile,
                    ),
                  ),
                  SizedBox(width: isMobileLandscape ? 4 : (isMobile ? 6 : 8)),
                ],
                Text(
                  text,
                  style: buttonTextStyle(
                    isMobileLandscape: isMobileLandscape,
                    isMobile: isMobile,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    if (expanded) {
      return Expanded(
        flex: isMobile ? 1 : 0,
        child: isDisabled ? Opacity(opacity: 0.5, child: button) : button,
      );
    }
    
    return isDisabled ? Opacity(opacity: 0.5, child: button) : button;
  }
  
  /// Widget completo de botón cancelar reutilizable
  static Widget cancelButton({
    required VoidCallback onPressed,
    required String text,
    required bool isMobileLandscape,
    required bool isMobile,
    IconData icon = Icons.close_rounded,
    bool expanded = false,
  }) {
    Widget button = Container(
      decoration: cancelButtonDecoration(
        isMobileLandscape: isMobileLandscape,
        isMobile: isMobile,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: buttonBorderRadius(
            isMobileLandscape: isMobileLandscape,
            isMobile: isMobile,
          ),
          child: Padding(
            padding: buttonPadding(
              isMobileLandscape: isMobileLandscape,
              isMobile: isMobile,
            ),
            child: Row(
              mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: buttonIconSize(
                    isMobileLandscape: isMobileLandscape,
                    isMobile: isMobile,
                  ),
                ),
                SizedBox(width: isMobileLandscape ? 4 : (isMobile ? 6 : 8)),
                Text(
                  text,
                  style: buttonTextStyle(
                    isMobileLandscape: isMobileLandscape,
                    isMobile: isMobile,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    if (expanded) {
      return Expanded(flex: isMobile ? 1 : 0, child: button);
    }
    
    return button;
  }
}
