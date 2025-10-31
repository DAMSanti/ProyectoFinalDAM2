import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class InfoCardWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final int maxLines;
  final bool isMobile;

  const InfoCardWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.maxLines = 2,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    return Container(
      padding: EdgeInsets.all(isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withOpacity(0.05) 
            : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.1) 
              : Colors.white.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 5 : 6),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(25, 118, 210, 0.1),
              borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
            ),
            child: Icon(
              icon,
              color: Color(0xFF1976d2),
              size: isMobile ? 14 : (isWeb ? 16 : 18.0),
            ),
          ),
          SizedBox(width: isMobile ? 8 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isMobile ? 10 : (isWeb ? 11 : 13.0),
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1976d2),
                  ),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : (isWeb ? 13 : 15.0),
                    color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                    height: 1.3,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
