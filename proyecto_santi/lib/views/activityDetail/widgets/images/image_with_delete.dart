import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;

/// Widget para mostrar una imagen local (XFile) con botón de eliminar en hover
class ImageWithDeleteButton extends StatefulWidget {
  final XFile image;
  final double maxHeight;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const ImageWithDeleteButton({
    super.key,
    required this.image,
    required this.maxHeight,
    required this.onDelete,
    this.onTap,
  });

  @override
  ImageWithDeleteButtonState createState() => ImageWithDeleteButtonState();
}

class ImageWithDeleteButtonState extends State<ImageWithDeleteButton> {
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
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        width: width,
        height: widget.maxHeight,
        child: Stack(
          children: [
            // Imagen con GestureDetector para el tap
            GestureDetector(
              onTap: widget.onTap,
              child: ClipRRect(
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
                      color: Colors.red.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(6),
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
