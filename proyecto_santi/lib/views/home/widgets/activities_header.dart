import 'package:flutter/material.dart';
import 'package:proyecto_santi/shared/constants/app_theme_constants.dart';

/// Header reutilizable para la sección de actividades
/// Aplica DRY (Don't Repeat Yourself)
class ActivitiesHeader extends StatelessWidget {
  final int activityCount;
  final bool isCompact;
  final String title;

  const ActivitiesHeader({
    super.key,
    required this.activityCount,
    this.isCompact = false,
    this.title = 'Próximas Actividades',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isCompact ? 12.0 : 20.0,
        12.0,
        isCompact ? 12.0 : 20.0,
        8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available_rounded,
            color: AppThemeConstants.primaryBlue,
            size: isCompact 
                ? AppThemeConstants.iconSizeXLarge 
                : AppThemeConstants.iconSizeXLarge,
          ),
          SizedBox(width: isCompact ? 10.0 : 12.0),
          Text(
            title,
            style: TextStyle(
              fontSize: isCompact 
                  ? AppThemeConstants.fontSizeLarge 
                  : AppThemeConstants.fontSizeXXLarge,
              fontWeight: FontWeight.bold,
              color: isDark 
                  ? Colors.white 
                  : AppThemeConstants.primaryBlue,
              letterSpacing: 0.3,
              decoration: TextDecoration.none,
            ),
          ),
          SizedBox(width: AppThemeConstants.spacingSmall),
          // Burbuja con número
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 8.0 : 10.0,
              vertical: isCompact ? 3.0 : 4.0,
            ),
            decoration: BoxDecoration(
              color: AppThemeConstants.primaryBlue,
              borderRadius: BorderRadius.circular(isCompact ? 10.0 : 12.0),
              boxShadow: [
                BoxShadow(
                  color: AppThemeConstants.primaryBlue.withOpacity(0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Text(
              '$activityCount',
              style: TextStyle(
                fontSize: isCompact 
                    ? AppThemeConstants.fontSizeSmall 
                    : AppThemeConstants.fontSizeMedium,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
