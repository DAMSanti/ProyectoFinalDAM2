import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_santi/views/activityDetail/state/activity_detail_state.dart';
import 'package:proyecto_santi/tema/app_colors.dart';

/// Clase que maneja toda la lógica relacionada con imágenes
class ImageHandler {
  final ActivityDetailState state;
  final Function(VoidCallback) setState;

  ImageHandler(this.state, this.setState);

  /// Muestra el selector de imágenes y añade la imagen seleccionada
  Future<void> showImagePicker() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        state.selectedImages.add(image);
        state.markAsChanged();
      });
    }
  }

  /// Elimina una imagen seleccionada (aún no subida)
  void removeSelectedImage(int index) {
    setState(() {
      state.selectedImages.removeAt(index);
      state.markAsChanged();
    });
  }

  /// Muestra diálogo de confirmación y marca imagen de API para eliminar
  Future<void> removeApiImage(BuildContext context, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar imagen'),
          content: Text('¿Está seguro que quiere eliminar esta imagen? Se eliminará al guardar los cambios.'),
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

    if (confirmed == true && index < state.imagesActividad.length) {
      final photo = state.imagesActividad[index];
      setState(() {
        state.imagesToDelete.add(photo.id);
        state.imagesActividad.removeAt(index);
        state.markAsChanged();
      });
    }
  }

  /// Carga las fotos de la actividad desde el servidor
  Future<void> loadPhotos(int actividadId) async {
    try {
      final photos = await state.photoService.fetchPhotosByActivityId(actividadId);
      setState(() {
        state.imagesActividad = photos;
      });
    } catch (e) {
    }
  }

  /// Sube las imágenes seleccionadas al servidor
  Future<bool> uploadSelectedImages(int actividadId) async {
    if (state.selectedImages.isEmpty) {
      return true;
    }

    
    for (XFile imageFile in state.selectedImages) {
      try {
        final bytes = await imageFile.readAsBytes();
        await state.photoService.uploadPhotosFromBytes(
          activityId: actividadId,
          filename: imageFile.name,
          bytes: bytes,
        );
      } catch (e) {
        return false;
      }
    }
    
    return true;
  }

  /// Elimina las imágenes marcadas para eliminación
  Future<bool> deleteMarkedImages() async {
    if (state.imagesToDelete.isEmpty) {
      return true;
    }

    
    for (int photoId in state.imagesToDelete) {
      try {
        await state.photoService.deletePhoto(photoId);
      } catch (e) {
        return false;
      }
    }
    
    return true;
  }
}
