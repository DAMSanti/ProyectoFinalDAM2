import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/tema.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/image_preview_widget.dart';
import '../widgets/image_description_field.dart';

/// Layout portrait para el diálogo de preview de imagen
class ImagePreviewPortraitLayout extends StatelessWidget {
  final bool isDark;
  final bool isMobile;
  final bool isMobileLandscape;
  final XFile? imageFile;
  final String? imageUrl;
  final TextEditingController descriptionController;

  const ImagePreviewPortraitLayout({
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview de la imagen
          Container(
            constraints: BoxConstraints(
              maxHeight: isMobile ? 300 : 400,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
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
                  offset: Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isMobile ? 10 : 14),
              child: ImagePreviewWidget(
                imageFile: imageFile,
                imageUrl: imageUrl,
              ),
            ),
          ),
          
          SizedBox(height: isMobile ? 16 : 20),
          
          // Campo de descripción
          ImageDescriptionField(
            controller: descriptionController,
            isDark: isDark,
            isMobile: isMobile,
            isMobileLandscape: isMobileLandscape,
          ),
        ],
      ),
    );
  }
}
