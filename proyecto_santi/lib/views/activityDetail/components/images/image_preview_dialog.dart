import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class ImagePreviewDialog extends StatefulWidget {
  final XFile? imageFile;
  final String? imageUrl;
  final String? initialDescription;
  final Function(String description) onConfirm;
  final bool isEditing;

  const ImagePreviewDialog({
    super.key,
    this.imageFile,
    this.imageUrl,
    this.initialDescription,
    required this.onConfirm,
    this.isEditing = false,
  }) : assert(imageFile != null || imageUrl != null, 'Debe proporcionar imageFile o imageUrl');

  @override
  State<ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<ImagePreviewDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  final bool isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  @override
  void initState() {
    super.initState();
    if (widget.initialDescription != null) {
      _descriptionController.text = widget.initialDescription!;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;
    final isMobile = screenWidth < 600;
    final isMobileLandscape = (isMobile && !isPortrait) || (!isPortrait && screenHeight < 500);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: isMobileLandscape
          ? EdgeInsets.symmetric(horizontal: 16, vertical: 12)
          : (isMobile 
              ? EdgeInsets.symmetric(horizontal: 16, vertical: 40)
              : EdgeInsets.symmetric(horizontal: 40, vertical: 24)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 600,
          maxHeight: isMobileLandscape
              ? screenHeight * 0.95
              : (isMobile 
                  ? screenHeight * 0.85 
                  : 800),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 24)),
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
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Color.fromRGBO(0, 0, 0, 0.5) 
                  : Color.fromRGBO(0, 0, 0, 0.2),
              offset: Offset(0, isMobileLandscape ? 4 : 8),
              blurRadius: isMobileLandscape ? 16 : 24.0,
              spreadRadius: isMobileLandscape ? 1 : 2,
            ),
          ],
          border: Border.all(
            color: isDark 
                ? Color.fromRGBO(255, 255, 255, 0.15) 
                : Color.fromRGBO(255, 255, 255, 0.6),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header compacto
            _buildHeader(context, isDark, isMobile, isMobileLandscape),
            
            // Contenido adaptativo
            Expanded(
              child: isMobileLandscape
                  ? _buildLandscapeLayout(isDark, isMobile, isMobileLandscape)
                  : _buildPortraitLayout(isDark, isMobile, isMobileLandscape),
            ),
            
            // Footer con botones
            _buildFooter(context, isDark, isMobile, isMobileLandscape),
          ],
        ),
      ),
    );
  }

  // Header compacto y moderno
  Widget _buildHeader(BuildContext context, bool isDark, bool isMobile, bool isMobileLandscape) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobileLandscape ? 12 : (isMobile ? 16 : 20),
        vertical: isMobileLandscape ? 8 : (isMobile ? 12 : 16),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1976d2).withOpacity(0.9),
            Color(0xFF1565c0).withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 24)),
          topRight: Radius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 24)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
            ),
            child: Icon(
              widget.isEditing ? Icons.edit_rounded : Icons.add_photo_alternate_rounded,
              color: Colors.white,
              size: isMobileLandscape ? 16 : (isMobile ? 18 : 24),
            ),
          ),
          SizedBox(width: isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
          Expanded(
            child: Text(
              widget.isEditing 
                  ? (isMobile ? 'Editar' : 'Editar Imagen')
                  : (isMobile ? 'Nueva Foto' : 'Vista Previa de la Imagen'),
              style: TextStyle(
                fontSize: isMobileLandscape ? 14 : (isMobile ? 16 : 18),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, color: Colors.white),
            iconSize: isMobileLandscape ? 18 : (isMobile ? 20 : 24),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.all(isMobileLandscape ? 4 : 8),
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // Layout para portrait (vertical)
  Widget _buildPortraitLayout(bool isDark, bool isMobile, bool isMobileLandscape) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview de la imagen
          Container(
            constraints: BoxConstraints(
              maxHeight: isMobile ? 300 : 400,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
              color: isDark 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.white.withOpacity(0.5),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF1976d2).withOpacity(0.1),
                  offset: Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isMobile ? 10 : 14),
              child: _buildImage(),
            ),
          ),
          
          SizedBox(height: isMobile ? 16 : 20),
          
          // Campo de descripción
          _buildDescriptionField(isDark, isMobile, isMobileLandscape),
        ],
      ),
    );
  }

  // Layout para landscape (horizontal - 2 columnas)
  Widget _buildLandscapeLayout(bool isDark, bool isMobile, bool isMobileLandscape) {
    return Padding(
      padding: EdgeInsets.all(isMobileLandscape ? 12 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna izquierda: Imagen
          Expanded(
            flex: 3,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: double.infinity,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isDark 
                    ? Colors.black.withOpacity(0.3)
                    : Colors.white.withOpacity(0.5),
                border: Border.all(
                  color: isDark 
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.6),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF1976d2).withOpacity(0.1),
                    offset: Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildImage(),
              ),
            ),
          ),
          
          SizedBox(width: 12),
          
          // Columna derecha: Descripción
          Expanded(
            flex: 2,
            child: _buildDescriptionField(isDark, isMobile, isMobileLandscape),
          ),
        ],
      ),
    );
  }

  // Widget de imagen reutilizable
  Widget _buildImage() {
    if (widget.imageUrl != null) {
      return Image.network(
        widget.imageUrl!,
        fit: BoxFit.contain,
        headers: {
          'Access-Control-Allow-Origin': '*',
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_rounded,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 8),
                Text(
                  'Error al cargar',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        },
      );
    } else if (kIsWeb) {
      return Image.network(
        widget.imageFile!.path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.broken_image_rounded,
              size: 64,
              color: Colors.grey,
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(widget.imageFile!.path),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.broken_image_rounded,
              size: 64,
              color: Colors.grey,
            ),
          );
        },
      );
    }
  }

  // Campo de descripción reutilizable
  Widget _buildDescriptionField(bool isDark, bool isMobile, bool isMobileLandscape) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              Icons.description_rounded,
              size: isMobileLandscape ? 14 : (isMobile ? 16 : 18),
              color: Color(0xFF1976d2),
            ),
            SizedBox(width: 6),
            Text(
              'Descripción (opcional)',
              style: TextStyle(
                fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14),
                fontWeight: FontWeight.w600,
                color: Color(0xFF1976d2),
              ),
            ),
          ],
        ),
        SizedBox(height: isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
        Container(
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
            border: Border.all(
              color: isDark 
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.5),
            ),
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: isMobileLandscape ? 4 : 3,
            maxLength: 200,
            style: TextStyle(
              fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14),
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: isMobileLandscape 
                  ? 'Añade descripción...' 
                  : 'Añade una descripción para esta imagen...',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: isMobileLandscape ? 11 : (isMobile ? 12 : 13),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
              counterStyle: TextStyle(
                fontSize: isMobileLandscape ? 9 : 11,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Footer con botones de acción
  Widget _buildFooter(BuildContext context, bool isDark, bool isMobile, bool isMobileLandscape) {
    return Container(
      padding: EdgeInsets.all(isMobileLandscape ? 10 : (isMobile ? 14 : 20)),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.grey[850]!.withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 24)),
          bottomRight: Radius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 24)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón Cancelar
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.grey.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: isMobileLandscape ? 8 : (isMobile ? 10 : 12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.close_rounded,
                      size: isMobileLandscape ? 16 : (isMobile ? 18 : 20),
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    if (!isMobileLandscape) ...[
                      SizedBox(width: 6),
                      Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 14,
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          SizedBox(width: isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
          
          // Botón Añadir/Guardar
          Expanded(
            flex: isMobileLandscape ? 2 : 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1976d2),
                    Color(0xFF42A5F5),
                  ],
                ),
                borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : (isMobile ? 8 : 12)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF1976d2).withOpacity(0.4),
                    offset: Offset(0, isMobileLandscape ? 2 : 4),
                    blurRadius: isMobileLandscape ? 8 : 12,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  widget.onConfirm(_descriptionController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(
                    vertical: isMobileLandscape ? 8 : (isMobile ? 10 : 12),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : (isMobile ? 8 : 12)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: isMobileLandscape ? 16 : (isMobile ? 18 : 20),
                      color: Colors.white,
                    ),
                    SizedBox(width: isMobileLandscape ? 4 : 6),
                    Text(
                      widget.isEditing 
                          ? (isMobileLandscape ? 'Guardar' : (isMobile ? 'Guardar' : 'Guardar Cambios'))
                          : (isMobileLandscape ? 'Añadir' : (isMobile ? 'Añadir' : 'Añadir Imagen')),
                      style: TextStyle(
                        fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
