import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/photo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'dart:ui' as ui;

class ActivityDetailInfo extends StatelessWidget {
  final Actividad actividad;
  final bool isAdminOrSolicitante;
  final List<Photo> imagesActividad;
  final List<XFile> selectedImages;
  final VoidCallback showImagePicker;
  final Function(int) removeSelectedImage;

  const ActivityDetailInfo({
    super.key,
    required this.actividad,
    required this.isAdminOrSolicitante,
    required this.imagesActividad,
    required this.selectedImages,
    required this.showImagePicker,
    required this.removeSelectedImage,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              _buildHeader(context, constraints),
              SizedBox(height: 16),
              _buildImages(context, constraints),
              SizedBox(height: 16),
              _buildComentarios(context, constraints)
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, BoxConstraints constraints) {
    final isWeb =
        kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final String formattedStartDate =
        dateFormat.format(DateTime.parse(actividad.fini));
    final String formattedEndDate =
        dateFormat.format(DateTime.parse(actividad.ffin));
    final String dateText = actividad.fini == actividad.ffin
        ? formattedStartDate
        : '$formattedStartDate a $formattedEndDate';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                actividad.titulo,
                style: TextStyle(
                    fontSize: !isWeb ? 20.dg : 7.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Color(0xFF1976d2)),
              onPressed: () => _showEditDialog(context),
            ),
          ],
        ),
        SizedBox(height: 16),
        // Descripción y Fecha en la misma línea
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Descripción con icono (izquierda)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.description, color: Color(0xFF1976d2), size: !isWeb ? 16.dg : 5.sp),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      actividad.descripcion ?? 'Sin descripción',
                      style: TextStyle(fontSize: !isWeb ? 13.dg : 4.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            // Fecha con icono (derecha)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.calendar_today, color: Color(0xFF1976d2), size: !isWeb ? 16.dg : 5.sp),
                SizedBox(width: 8),
                Text(
                  dateText,
                  style: TextStyle(fontSize: !isWeb ? 13.dg : 4.sp),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12),
        // Solicitante y Estado
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Solicitante con icono (izquierda)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.person, color: Color(0xFF1976d2), size: !isWeb ? 16.dg : 5.sp),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      actividad.solicitante != null 
                          ? '${actividad.solicitante!.nombre} ${actividad.solicitante!.apellidos}'
                          : 'Sin solicitante',
                      style: TextStyle(fontSize: !isWeb ? 13.dg : 4.sp),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            // Estado con icono (derecha)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, color: Color(0xFF1976d2), size: !isWeb ? 16.dg : 5.sp),
                SizedBox(width: 8),
                Text(
                  actividad.estado,
                  style: TextStyle(
                      fontSize: !isWeb ? 13.dg : 4.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Actividad'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Título'),
                controller: TextEditingController(text: actividad.titulo),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Descripción'),
                controller: TextEditingController(text: actividad.descripcion),
              ),
              // Add more fields as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Save changes logic here
                Navigator.of(context).pop();
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImages(BuildContext context, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fotos de la Actividad',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        _HorizontalImageScroller(
          constraints: constraints,
          isAdminOrSolicitante: isAdminOrSolicitante,
          showImagePicker: showImagePicker,
          imagesActividad: imagesActividad,
          selectedImages: selectedImages,
          onDeleteImage: (index) => _showDeleteConfirmationDialog(context, index),
        ),
      ],
    );
  }

  Widget _buildComentarios(BuildContext context, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción de la Actividad',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(actividad.comentarios ?? 'Sin comentarios'),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar imagen'),
          content: Text('¿Está seguro que quiere eliminar la imagen?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                removeSelectedImage(index); // Eliminar la imagen
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}

// Widget para mostrar la imagen con botón de eliminar en hover
class _ImageWithDeleteButton extends StatefulWidget {
  final XFile image;
  final double maxHeight;
  final VoidCallback onDelete;

  const _ImageWithDeleteButton({
    required this.image,
    required this.maxHeight,
    required this.onDelete,
  });

  @override
  _ImageWithDeleteButtonState createState() => _ImageWithDeleteButtonState();
}

class _ImageWithDeleteButtonState extends State<_ImageWithDeleteButton> {
  bool _isHovering = false;
  double? _aspectRatio;

  @override
  void initState() {
    super.initState();
    _loadImageDimensions();
  }

  Future<void> _loadImageDimensions() async {
    try {
      final bytes = await widget.image.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      setState(() {
        _aspectRatio = image.width / image.height;
      });
    } catch (e) {
      print('Error loading image dimensions: $e');
      setState(() {
        _aspectRatio = 1.0; // Default to square if error
      });
    }
  }

  Future<Widget> _buildImageWidget(XFile image) async {
    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      return Image.memory(bytes, fit: BoxFit.contain);
    } else {
      return Image.file(File(image.path), fit: BoxFit.contain);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_aspectRatio == null) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        width: widget.maxHeight, // Usar un ancho temporal
        height: widget.maxHeight,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final width = widget.maxHeight * _aspectRatio!;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        width: width,
        height: widget.maxHeight,
        child: Stack(
          children: [
            // Imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: FutureBuilder<Widget>(
                future: _buildImageWidget(widget.image),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data!;
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
            // Botón de eliminar (solo visible en hover)
            if (_isHovering)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Widget para mostrar imágenes de red con aspect ratio
class _NetworkImageWithAspectRatio extends StatelessWidget {
  final String imageUrl;
  final double maxHeight;

  const _NetworkImageWithAspectRatio({
    required this.imageUrl,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: maxHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: maxHeight, // Ancho temporal mientras carga
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: maxHeight,
              child: Icon(Icons.error),
            );
          },
        ),
      ),
    );
  }
}

// Widget con estado para scroll horizontal
class _HorizontalImageScroller extends StatefulWidget {
  final BoxConstraints constraints;
  final bool isAdminOrSolicitante;
  final VoidCallback showImagePicker;
  final List<Photo> imagesActividad;
  final List<XFile> selectedImages;
  final Function(int) onDeleteImage;

  const _HorizontalImageScroller({
    required this.constraints,
    required this.isAdminOrSolicitante,
    required this.showImagePicker,
    required this.imagesActividad,
    required this.selectedImages,
    required this.onDeleteImage,
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
    return SizedBox(
      width: widget.constraints.maxWidth,
      height: 200.0,
      child: Listener(
        onPointerSignal: (pointerSignal) {
          if (pointerSignal is PointerScrollEvent) {
            // Capturar el scroll de la rueda del ratón y aplicarlo horizontalmente
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
              if (widget.isAdminOrSolicitante)
                InkWell(
                  onTap: widget.showImagePicker,
                  child: Container(
                    width: 80.0,
                    height: 200.0,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.add_a_photo,
                      color: Color(0xFF1976d2),
                      size: 48,
                    ),
                  ),
                ),
              ...widget.imagesActividad.map((photo) {
                return _NetworkImageWithAspectRatio(
                  imageUrl: photo.urlFoto ?? '',
                  maxHeight: 200.0,
                );
              }),
              ...widget.selectedImages.asMap().entries.map((entry) {
                final index = entry.key;
                final image = entry.value;
                return _ImageWithDeleteButton(
                  image: image,
                  maxHeight: 200.0,
                  onDelete: () => widget.onDeleteImage(index),
                );
              }),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
