import 'package:flutter/material.dart';
import 'package:proyecto_santi/shared/constants/app_theme_constants.dart';

/// Título del calendario reutilizable
/// Aplica DRY (Don't Repeat Yourself)
class CalendarTitle extends StatelessWidget {
  final bool isCompact;

  const CalendarTitle({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppThemeConstants.spacingXLarge,
        vertical: AppThemeConstants.spacingMedium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_rounded,
            color: AppThemeConstants.primaryBlue,
            size: isCompact 
                ? AppThemeConstants.iconSizeLarge 
                : AppThemeConstants.iconSizeXLarge + 4,
          ),
          SizedBox(width: isCompact ? 10.0 : 12.0),
          Text(
            'Calendario de Actividades',
            style: TextStyle(
              fontSize: isCompact 
                  ? AppThemeConstants.fontSizeXLarge 
                  : AppThemeConstants.fontSizeTitle,
              fontWeight: FontWeight.bold,
              color: isDark 
                  ? Colors.white 
                  : AppThemeConstants.primaryBlue,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
