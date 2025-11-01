import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/tema.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/image_preview_widget.dart';
import '../widgets/image_description_field.dart';

/// Layout landscape para el diálogo de preview de imagen
class ImagePreviewLandscapeLayout extends StatelessWidget {
  final bool isDark;
  final bool isMobile;
  final bool isMobileLandscape;
  final XFile? imageFile;
  final String? imageUrl;
  final TextEditingController descriptionController;

  const ImagePreviewLandscapeLayout({
    Key? key,
    required this.isDark,
    required this.isMobile,
    required this.isMobileLandscape,
    this.imageFile,
    this.imageUrl,
    required this.descriptionController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(isMobileLandscape ? 12 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna izquierda: Imagen
          Expanded(
            flex: 3,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: double.infinity,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isDark 
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.5),
                border: Border.all(
                  color: isDark 
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.6),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryOpacity10,
                    offset: Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ImagePreviewWidget(
                  imageFile: imageFile,
                  imageUrl: imageUrl,
                ),
              ),
            ),
          ),
          
          SizedBox(width: 12),
          
          // Columna derecha: Descripción
          Expanded(
            flex: 2,
            child: ImageDescriptionField(
              controller: descriptionController,
              isDark: isDark,
              isMobile: isMobile,
              isMobileLandscape: isMobileLandscape,
            ),
          ),
        ],
      ),
    );
  }
}
