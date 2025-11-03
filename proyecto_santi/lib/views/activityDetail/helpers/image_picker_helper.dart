import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/tema.dart';
import 'package:image_picker/image_picker.dart';
import '../dialogs/image_preview_dialog.dart';

/// Helper para manejar la selección y gestión de imágenes
class ImagePickerHelper {
  /// Muestra el selector de imágenes con opciones de cámara o galería en móvil
  static Future<void> showImagePicker({
    required BuildContext context,
    required Function(XFile image, String description) onImageSelected,
  }) async {
    final ImagePicker picker = ImagePicker();
    
    // Detectar si es móvil
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    XFile? image;
    
    // En móvil, mostrar opciones de cámara o galería
    if (isMobile) {
      final ImageSource? source = await _showImageSourceSelector(context);
      
      // Si el usuario canceló, salir
      if (source == null) return;
      
      // Obtener imagen de la fuente seleccionada
      image = await picker.pickImage(source: source);
    } else {
      // En desktop, usar directamente la galería
      image = await picker.pickImage(source: ImageSource.gallery);
    }
    
    if (image != null && context.mounted) {
      // Mostrar diálogo de preview con descripción
      await _showImagePreviewDialog(
        context: context,
        image: image,
        onConfirm: (description) => onImageSelected(image!, description),
      );
    }
  }

  /// Muestra el diálogo para editar la descripción de una imagen
  static Future<void> editImageDescription({
    required BuildContext context,
    required XFile image,
    String? currentDescription,
    required Function(String description) onDescriptionChanged,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ImagePreviewDialog(
          imageFile: image,
          initialDescription: currentDescription,
          isEditing: true,
          onConfirm: onDescriptionChanged,
        );
      },
    );
  }

  /// Muestra el diálogo de confirmación para eliminar una imagen
  static Future<bool> confirmImageDeletion(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar imagen'),
          content: Text(
            '¿Está seguro que quiere eliminar esta imagen? Se eliminará al guardar los cambios.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Eliminar', style: TextStyle(color: AppColors.estadoRechazado)),
            ),
          ],
        );
      },
    );

    return confirmed == true;
  }

  // ==================== MÉTODOS PRIVADOS ====================

  /// Muestra el selector de fuente de imagen (cámara o galería)
  static Future<ImageSource?> _showImageSourceSelector(BuildContext context) async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Color.fromRGBO(25, 118, 210, 0.25),
                      Color.fromRGBO(21, 101, 192, 0.20),
                    ]
                  : [
                      Color.fromRGBO(187, 222, 251, 0.95),
                      Color.fromRGBO(144, 202, 249, 0.85),
                    ],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle visual
                Container(
                  margin: EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white30 : Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),
                // Título
                Text(
                  'Seleccionar imagen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Color(0xFF1976d2),
                  ),
                ),
                SizedBox(height: 16),
                // Opción: Tomar foto
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF1976d2).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Color(0xFF1976d2),
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'Tomar foto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Usa la cámara',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                // Opción: Galería
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.tipoComplementaria.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.tipoComplementaria,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'Galería',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Elige de tus fotos',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                SizedBox(height: 8),
                // Botón cancelar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Muestra el diálogo de preview de imagen con campo de descripción
  static Future<void> _showImagePreviewDialog({
    required BuildContext context,
    required XFile image,
    required Function(String description) onConfirm,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ImagePreviewDialog(
          imageFile: image,
          onConfirm: (description) {
            // Cerrar el diálogo
            Navigator.of(dialogContext).pop();
            // Ejecutar callback
            onConfirm(description);
          },
        );
      },
    );
  }
}
