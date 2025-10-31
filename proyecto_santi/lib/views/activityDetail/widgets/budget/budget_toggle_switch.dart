import 'package:flutter/material.dart';

/// Widget reutilizable para switches de activación de transporte/alojamiento
/// con diseño con gradiente y responsive
class BudgetToggleSwitchWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool value;
  final bool isWeb;
  final Function(bool) onChanged;

  const BudgetToggleSwitchWidget({
    Key? key,
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    required this.isWeb,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Detectar si es móvil
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 16, 
        vertical: isMobile ? 6 : 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: value 
            ? [
                color.withOpacity(0.25),
                color.withOpacity(0.15),
              ]
            : [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1),
              ],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        border: Border.all(
          color: value ? color.withOpacity(0.5) : Colors.white.withOpacity(0.3),
          width: isMobile ? 1 : 2,
        ),
        boxShadow: value ? [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: isMobile ? 4 : 8,
            offset: Offset(0, isMobile ? 1 : 3),
          ),
        ] : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ocultar icono en móvil
                if (!isMobile)
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: value
                        ? LinearGradient(
                            colors: [
                              color.withOpacity(0.8),
                              color.withOpacity(0.6),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              Colors.grey.withOpacity(0.3),
                              Colors.grey.withOpacity(0.2),
                            ],
                          ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: value ? Colors.white : Colors.grey[600],
                      size: isWeb ? 20 : 22.0,
                    ),
                  ),
                if (!isMobile) SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: isMobile ? 13 : (isWeb ? 14 : 16.0),
                      fontWeight: FontWeight.bold,
                      color: value ? color : Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: isMobile ? 0.7 : 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: color,
              activeTrackColor: color.withOpacity(0.5),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[300],
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
