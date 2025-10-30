import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/views/activityDetail/components/detail_bar.dart';
import 'package:proyecto_santi/models/photo.dart';
import 'package:proyecto_santi/views/activityDetail/components/activity_detail_info.dart';

class ActivityDetailPortraitLayout extends StatelessWidget {
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
  final Function(int)? _editLocalImage;
  final VoidCallback _saveChanges;
  final VoidCallback? _revertChanges;
  final Function(Map<String, dynamic>)? onActivityDataChanged;

  const ActivityDetailPortraitLayout({
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
    Function(int)? editLocalImage,
    required VoidCallback saveChanges,
    VoidCallback? revertChanges,
    this.onActivityDataChanged,
  })  : _showImagePicker = showImagePicker,
        _removeSelectedImage = removeSelectedImage,
        _editLocalImage = editLocalImage,
        _saveChanges = saveChanges,
        _revertChanges = revertChanges;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(top: 40.0),
                child: ActivityDetailInfo(
                  actividad: actividad,
                  isAdminOrSolicitante: isAdminOrSolicitante,
                  imagesActividad: imagesActividad,
                  selectedImages: selectedImages,
                  selectedImagesDescriptions: selectedImagesDescriptions,
                  showImagePicker: _showImagePicker,
                  removeSelectedImage: _removeSelectedImage,
                  editLocalImage: _editLocalImage,
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
      ),
    );
  }
}