import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/photo.dart';
import '../sections/detail_info_section.dart';
import '../utils/detail_bar.dart';

class ActivityDetailLargeLandscapeLayout extends StatelessWidget {
  final Actividad actividad;
  final bool isDarkTheme;
  final VoidCallback onToggleTheme;
  final bool isDataChanged;
  final bool isAdminOrSolicitante;
  final List<Photo> imagesActividad;
  final List<XFile> selectedImages;
  final Map<String, String> selectedImagesDescriptions;
  final VoidCallback _showImagePicker;
  final Function(int) _removeSelectedImage;
  final Function(int)? _removeApiImage;
  final Function(int)? _removeApiImageConfirmed;
  final Function(int)? _editLocalImage;
  final VoidCallback _saveChanges;
  final VoidCallback? _revertChanges;
  final Function(Map<String, dynamic>)? onActivityDataChanged;
  final int reloadTrigger;

  const ActivityDetailLargeLandscapeLayout({
    super.key,
    required this.actividad,
    required this.isDarkTheme,
    required this.onToggleTheme,
    required this.isDataChanged,
    required this.isAdminOrSolicitante,
    required this.imagesActividad,
    required this.selectedImages,
    required this.selectedImagesDescriptions,
    required VoidCallback showImagePicker,
    required Function(int) removeSelectedImage,
    Function(int)? removeApiImage,
    Function(int)? removeApiImageConfirmed,
    Function(int)? editLocalImage,
    required VoidCallback saveChanges,
    VoidCallback? revertChanges,
    this.onActivityDataChanged,
    this.reloadTrigger = 0,
  })  : _showImagePicker = showImagePicker,
        _removeSelectedImage = removeSelectedImage,
        _removeApiImage = removeApiImage,
        _removeApiImageConfirmed = removeApiImageConfirmed,
        _editLocalImage = editLocalImage,
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
                selectedImagesDescriptions: selectedImagesDescriptions,
                showImagePicker: _showImagePicker,
                removeSelectedImage: _removeSelectedImage,
                removeApiImage: _removeApiImage,
                removeApiImageConfirmed: _removeApiImageConfirmed,
                editLocalImage: _editLocalImage,
                onActivityDataChanged: onActivityDataChanged,
                reloadTrigger: reloadTrigger,
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