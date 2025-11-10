import 'package:flutter/material.dart';
import 'package:proyecto_santi/views/estadisticas/models/trend_data.dart';

class TrendStatCard extends StatelessWidget {
  final TrendData data;
  final bool isDark;
  final bool isMobile;
  final VoidCallback? onTap;

  const TrendStatCard({
    Key? key,
    required this.data,
    required this.isDark,
    required this.isMobile,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.02),
                ]
              : [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 12 : 14),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.1) 
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: data.color.withValues(alpha: 0.08),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isMobile ? 12 : 14),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 10 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header compacto con icono y tendencia
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isMobile ? 6 : 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            data.color,
                            data.color.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        data.icon,
                        color: Colors.white,
                        size: isMobile ? 16 : 18,
                      ),
                    ),
                    Spacer(),
                    // Indicador de tendencia compacto
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 6 : 8,
                        vertical: isMobile ? 3 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: data.trendColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: data.trendColor.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            data.trendIcon,
                            size: isMobile ? 12 : 14,
                            color: data.trendColor,
                          ),
                          SizedBox(width: 3),
                          Text(
                            data.trendText,
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 11,
                              fontWeight: FontWeight.bold,
                              color: data.trendColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 8 : 10),
                
                // Valor actual más compacto
                Text(
                  data.currentValue,
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: data.color,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 2),
                
                // Título compacto
                Text(
                  data.title,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.black.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: isMobile ? 6 : 8),
                
                // Comparación compacta
                Row(
                  children: [
                    Icon(
                      Icons.compare_arrows_rounded,
                      size: isMobile ? 12 : 13,
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.4)
                          : Colors.black.withValues(alpha: 0.35),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${data.previousValue}',
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 11,
                          color: isDark 
                              ? Colors.white.withValues(alpha: 0.5)
                              : Colors.black.withValues(alpha: 0.45),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
