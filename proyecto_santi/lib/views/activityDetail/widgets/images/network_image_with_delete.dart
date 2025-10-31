import 'package:flutter/material.dart';

/// Widget para mostrar una imagen de red con botón de eliminar en hover
class NetworkImageWithDelete extends StatefulWidget {
  final String imageUrl;
  final double maxHeight;
  final bool showDeleteButton;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const NetworkImageWithDelete({
    Key? key,
    required this.imageUrl,
    required this.maxHeight,
    required this.showDeleteButton,
    this.onDelete,
    this.onTap,
  }) : super(key: key);

  @override
  NetworkImageWithDeleteState createState() => NetworkImageWithDeleteState();
}

class NetworkImageWithDeleteState extends State<NetworkImageWithDelete> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        height: widget.maxHeight,
        child: Stack(
          children: [
            GestureDetector(
              onTap: widget.onTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  widget.imageUrl,
                  key: ValueKey(widget.imageUrl),
                  fit: BoxFit.contain,
                  headers: {
                    'Access-Control-Allow-Origin': '*',
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Container(
                      width: widget.maxHeight,
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
                      width: widget.maxHeight,
                      color: Colors.grey[300],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.red),
                          SizedBox(height: 8),
                          Text(
                            'Error al cargar',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            // Botón de eliminar (solo visible en hover y si está habilitado)
            if (_isHovering && widget.showDeleteButton && widget.onDelete != null)
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
