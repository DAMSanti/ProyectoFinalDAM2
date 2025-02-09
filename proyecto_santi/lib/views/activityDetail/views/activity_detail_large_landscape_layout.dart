import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/photo.dart';
import '../components/activity_detail_info.dart';
import '../components/detail_bar.dart';

class ActivityDetailLargeLandscapeLayout extends StatelessWidget {
  final Actividad actividad;
  final bool isDarkTheme;
  final VoidCallback onToggleTheme;
  final bool isDataChanged;
  final bool isAdminOrSolicitante;
  final List<Photo> imagesActividad;
  final List<XFile> selectedImages;
  final VoidCallback _showImagePicker;
  final VoidCallback _saveChanges;

  const ActivityDetailLargeLandscapeLayout({
    super.key,
    required this.actividad,
    required this.isDarkTheme,
    required this.onToggleTheme,
    required this.isDataChanged,
    required this.isAdminOrSolicitante,
    required this.imagesActividad,
    required this.selectedImages,
    required VoidCallback showImagePicker,
    required VoidCallback saveChanges,
  })  : _showImagePicker = showImagePicker,
        _saveChanges = saveChanges;

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
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: DetailBar(isDataChanged: isDataChanged, onSaveChanges: _saveChanges),
            ),
          ],
        );
      },
    );
  }
}