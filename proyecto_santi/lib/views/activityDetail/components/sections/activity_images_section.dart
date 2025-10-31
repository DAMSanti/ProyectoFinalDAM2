import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_santi/models/photo.dart';
import '../images/network_image_with_delete.dart';
import '../images/image_with_delete_button.dart';
import '../images/image_preview_dialog.dart';

/// Widget que maneja toda la sección de imágenes de una actividad.
/// 
/// Responsabilidades:
/// - Mostrar imágenes existentes de la API
/// - Mostrar imágenes nuevas seleccionadas localmente
/// - Permitir agregar nuevas imágenes
/// - Permitir eliminar imágenes
/// - Permitir editar descripciones de imágenes
class ActivityImagesSection extends StatefulWidget {
  final List<Photo> imagesActividad;
  final List<XFile> selectedImages;
  final Map<String, String> selectedImagesDescriptions;
  final bool isAdminOrSolicitante;
  final VoidCallback showImagePicker;
  final Function(int) removeSelectedImage;
  final Function(int)? removeApiImage;
  final Function(int)? editLocalImage;
  final Function(Map<String, dynamic>)? onDataChanged;

  const ActivityImagesSection({
    super.key,
    required this.imagesActividad,
    required this.selectedImages,
    required this.selectedImagesDescriptions,
    required this.isAdminOrSolicitante,
    required this.showImagePicker,
    required this.removeSelectedImage,
    this.removeApiImage,
    this.editLocalImage,
    this.onDataChanged,
  });

  @override
  State<ActivityImagesSection> createState() => _ActivityImagesSectionState();
}

class _ActivityImagesSectionState extends State<ActivityImagesSection> {
  // Mapa para guardar cambios temporales en descripciones antes de guardar
  final Map<int, String> _photoDescriptionChanges = {};

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _buildImagesContainer(context, constraints);
      },
    );
  }

  Widget _buildImagesContainer(BuildContext context, BoxConstraints constraints) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color.fromRGBO(25, 118, 210, 0.25),
                  Color.fromRGBO(21, 101, 192, 0.20),
                ]
              : const [
                  Color.fromRGBO(187, 222, 251, 0.85),
                  Color.fromRGBO(144, 202, 249, 0.75),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? const Color.fromRGBO(0, 0, 0, 0.4) 
                : const Color.fromRGBO(0, 0, 0, 0.15),
            offset: const Offset(0, 4),
            blurRadius: 12.0,
            spreadRadius: -1,
          ),
        ],
        border: Border.all(
          color: isDark 
              ? const Color.fromRGBO(255, 255, 255, 0.1) 
              : const Color.fromRGBO(0, 0, 0, 0.05),
          width: 1,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Patrón decorativo de fondo
          Positioned(
            right: -20,
            top: -20,
            child: Opacity(
              opacity: isDark ? 0.03 : 0.02,
              child: Icon(
                Icons.photo_library_rounded,
                size: 120,
                color: Color(0xFF1976d2),
              ),
            ),
          ),
          // Contenido
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título con icono
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(25, 118, 210, 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.photo_library_rounded,
                        color: Color(0xFF1976d2),
                        size: isWeb ? 18 : 20.0,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Fotos de la Actividad',
                      style: TextStyle(
                        fontSize: isWeb ? 14 : 16.0,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Color(0xFF1976d2),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _HorizontalImageScroller(
                  constraints: constraints,
                  isAdminOrSolicitante: widget.isAdminOrSolicitante,
                  showImagePicker: widget.showImagePicker,
                  imagesActividad: widget.imagesActividad,
                  selectedImages: widget.selectedImages,
                  selectedImagesDescriptions: widget.selectedImagesDescriptions,
                  onDeleteImage: (index) => widget.removeSelectedImage(index),
                  onDeleteApiImage: (index) async {
                    if (widget.removeApiImage != null) {
                      await widget.removeApiImage!(index);
                    }
                  },
                  onImageTap: (photo) => _showImageEditDialog(context, photo),
                  onLocalImageTap: (index) {
                    if (widget.editLocalImage != null) {
                      widget.editLocalImage!(index);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra el diálogo para editar la descripción de una foto existente
  void _showImageEditDialog(BuildContext context, Photo photo) async {
    // Obtener la descripción actual (puede haber cambios pendientes)
    final currentDescription = _photoDescriptionChanges.containsKey(photo.id)
        ? _photoDescriptionChanges[photo.id]
        : photo.descripcion;
    
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return ImagePreviewDialog(
          imageUrl: photo.urlFoto ?? '',
          initialDescription: currentDescription?.isNotEmpty == true ? currentDescription : null,
          isEditing: true,
          onConfirm: (description) {
            Navigator.of(dialogContext).pop(description);
          },
        );
      },
    );
    
    // Si se confirmó, guardar cambio localmente
    if (result != null && mounted) {
      setState(() {
        _photoDescriptionChanges[photo.id] = result;
        photo.descripcion = result;
      });
      
      // Notificar cambios pendientes
      if (widget.onDataChanged != null) {
        widget.onDataChanged!({
          'photoDescriptionChanges': Map<int, String>.from(_photoDescriptionChanges),
        });
      }
      
      // Mostrar feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Descripción actualizada (pendiente de guardar)'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Retorna el mapa de cambios de descripciones para que el padre pueda guardarlos
  Map<int, String> getPhotoDescriptionChanges() {
    return Map<int, String>.from(_photoDescriptionChanges);
  }

  /// Limpia los cambios pendientes (llamar después de guardar exitosamente)
  void clearPhotoDescriptionChanges() {
    if (mounted) {
      setState(() {
        _photoDescriptionChanges.clear();
      });
    }
  }
}

/// Widget interno que maneja el scroll horizontal de imágenes
class _HorizontalImageScroller extends StatefulWidget {
  final BoxConstraints constraints;
  final bool isAdminOrSolicitante;
  final VoidCallback showImagePicker;
  final List<Photo> imagesActividad;
  final List<XFile> selectedImages;
  final Map<String, String> selectedImagesDescriptions;
  final Function(int) onDeleteImage;
  final Function(int)? onDeleteApiImage;
  final Function(Photo)? onImageTap;
  final Function(int)? onLocalImageTap;

  const _HorizontalImageScroller({
    required this.constraints,
    required this.isAdminOrSolicitante,
    required this.showImagePicker,
    required this.imagesActividad,
    required this.selectedImages,
    required this.selectedImagesDescriptions,
    required this.onDeleteImage,
    this.onDeleteApiImage,
    this.onImageTap,
    this.onLocalImageTap,
  });

  @override
  _HorizontalImageScrollerState createState() => _HorizontalImageScrollerState();
}

class _HorizontalImageScrollerState extends State<_HorizontalImageScroller> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = widget.constraints.maxWidth < 600;
    
    return SizedBox(
      width: widget.constraints.maxWidth,
      height: 200.0,
      child: Row(
        children: [
          // Botón de cámara fijo (no hace scroll)
          if (widget.isAdminOrSolicitante)
            Container(
              width: isMobile ? 100.0 : 160.0,
              height: 200.0,
              margin: EdgeInsets.only(right: isMobile ? 8 : 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Color.fromRGBO(25, 118, 210, 0.2),
                          Color.fromRGBO(21, 101, 192, 0.15),
                        ]
                      : [
                          Color.fromRGBO(187, 222, 251, 0.6),
                          Color.fromRGBO(144, 202, 249, 0.5),
                        ],
                ),
                borderRadius: BorderRadius.circular(isMobile ? 12.0 : 16.0),
                border: Border.all(
                  color: Color(0xFF1976d2).withOpacity(0.3),
                  width: isMobile ? 1.5 : 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF1976d2).withOpacity(0.2),
                    offset: Offset(0, isMobile ? 2 : 4),
                    blurRadius: isMobile ? 8 : 12,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.showImagePicker,
                  borderRadius: BorderRadius.circular(isMobile ? 12.0 : 16.0),
                  child: isMobile
                      ? _buildMobileAddButton(isDark)
                      : _buildDesktopAddButton(isDark),
                ),
              ),
            ),
          // Área con scroll para las imágenes
          Expanded(
            child: Listener(
              onPointerSignal: (pointerSignal) {
                if (pointerSignal is PointerScrollEvent) {
                  final newOffset = _scrollController.offset + pointerSignal.scrollDelta.dy;
                  _scrollController.jumpTo(newOffset.clamp(
                    0.0,
                    _scrollController.position.maxScrollExtent,
                  ));
                }
              },
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imágenes de la API
                      ...widget.imagesActividad.asMap().entries.map((entry) {
                        final index = entry.key;
                        final photo = entry.value;
                        return NetworkImageWithDelete(
                          imageUrl: photo.urlFoto ?? '',
                          maxHeight: 200.0,
                          showDeleteButton: widget.isAdminOrSolicitante,
                          onDelete: widget.onDeleteApiImage != null 
                              ? () => widget.onDeleteApiImage!(index)
                              : null,
                          onTap: widget.onImageTap != null
                              ? () => widget.onImageTap!(photo)
                              : null,
                        );
                      }),
                      // Imágenes locales seleccionadas
                      ...widget.selectedImages.asMap().entries.map((entry) {
                        final index = entry.key;
                        final image = entry.value;
                        return ImageWithDeleteButton(
                          image: image,
                          maxHeight: 200.0,
                          onDelete: () => widget.onDeleteImage(index),
                          onTap: widget.onLocalImageTap != null
                              ? () => widget.onLocalImageTap!(index)
                              : null,
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Botón compacto para móviles
  Widget _buildMobileAddButton(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1976d2).withOpacity(0.2),
                Color(0xFF1976d2).withOpacity(0.1),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0xFF1976d2).withOpacity(0.3),
                offset: Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(
            Icons.add_a_photo_rounded,
            color: Color(0xFF1976d2),
            size: 32,
          ),
        ),
        SizedBox(height: 8),
        Column(
          children: [
            Icon(
              Icons.add_circle_rounded,
              color: Color(0xFF1976d2).withOpacity(0.7),
              size: 16,
            ),
            SizedBox(height: 4),
            Text(
              'Foto',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1976d2),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Botón para desktop
  Widget _buildDesktopAddButton(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF1976d2).withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add_photo_alternate_rounded,
            color: Color(0xFF1976d2),
            size: 48,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Añadir Foto',
          style: TextStyle(
            color: Color(0xFF1976d2),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
