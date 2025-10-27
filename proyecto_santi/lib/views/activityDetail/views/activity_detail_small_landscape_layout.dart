import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/photo.dart';
import '../components/activity_detail_info.dart';
import '../components/detail_bar.dart';

class ActivityDetailSmallLandscapeLayout extends StatelessWidget {
  final Actividad actividad;
  final bool isDarkTheme;
  final VoidCallback onToggleTheme;
  final bool isDataChanged;
  final bool isAdminOrSolicitante;
  final List<Photo> imagesActividad;
  final List<XFile> selectedImages;
  final VoidCallback _showImagePicker;
  final Function(int) _removeSelectedImage;
  final VoidCallback _saveChanges;
  final VoidCallback? _revertChanges;
  final Function(Map<String, dynamic>)? onActivityDataChanged;

  const ActivityDetailSmallLandscapeLayout({
    super.key,
    required this.actividad,
    required this.isDarkTheme,
    required this.onToggleTheme,
    required this.isDataChanged,
    required this.isAdminOrSolicitante,
    required this.imagesActividad,
    required this.selectedImages,
    required VoidCallback showImagePicker,
    required Function(int) removeSelectedImage,
    required VoidCallback saveChanges,
    VoidCallback? revertChanges,
    this.onActivityDataChanged,
  })
      : _showImagePicker = showImagePicker,
        _removeSelectedImage = removeSelectedImage,
        _saveChanges = saveChanges,
        _revertChanges = revertChanges;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(top: 40.0), // Adjust the top padding to make space for the DetailBar
              child: ActivityDetailInfo(
                actividad: actividad,
                isAdminOrSolicitante: isAdminOrSolicitante,
                imagesActividad: imagesActividad,
                selectedImages: selectedImages,
                showImagePicker: _showImagePicker,
                removeSelectedImage: _removeSelectedImage,
                onActivityDataChanged: onActivityDataChanged,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: DetailBar(
                isDataChanged: isDataChanged,
                onSaveChanges: _saveChanges,
                onRevertChanges: _revertChanges,
              ),
            ),
          ],
        );
      },
    );
  }
}