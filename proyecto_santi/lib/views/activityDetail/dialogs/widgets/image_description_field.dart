import 'package:flutter/material.dart';

class ImageDescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final bool isMobile;
  final bool isMobileLandscape;

  const ImageDescriptionField({
    super.key,
    required this.controller,
    required this.isDark,
    required this.isMobile,
    required this.isMobileLandscape,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              Icons.description_rounded,
              size: isMobileLandscape ? 14 : (isMobile ? 16 : 18),
              color: Color(0xFF1976d2),
            ),
            SizedBox(width: 6),
            Text(
              'Descripción (opcional)',
              style: TextStyle(
                fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14),
                fontWeight: FontWeight.w600,
                color: Color(0xFF1976d2),
              ),
            ),
          ],
        ),
        SizedBox(height: isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
        Container(
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
            border: Border.all(
              color: isDark 
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.5),
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: isMobileLandscape ? 4 : 3,
            maxLength: 200,
            style: TextStyle(
              fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14),
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: isMobileLandscape 
                  ? 'Añade descripción...' 
                  : 'Añade una descripción para esta imagen...',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: isMobileLandscape ? 11 : (isMobile ? 12 : 13),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
              counterStyle: TextStyle(
                fontSize: isMobileLandscape ? 9 : 11,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
