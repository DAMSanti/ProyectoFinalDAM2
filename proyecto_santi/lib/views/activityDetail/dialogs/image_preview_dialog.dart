import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'layouts/image_preview_portrait_layout.dart';
import 'layouts/image_preview_landscape_layout.dart';
import 'widgets/image_preview_widget.dart';
import 'widgets/image_description_field.dart';

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
                  ? ImagePreviewLandscapeLayout(
                      isDark: isDark,
                      isMobile: isMobile,
                      isMobileLandscape: isMobileLandscape,
                      imageFile: widget.imageFile,
                      imageUrl: widget.imageUrl,
                      descriptionController: _descriptionController,
                    )
                  : ImagePreviewPortraitLayout(
                      isDark: isDark,
                      isMobile: isMobile,
                      isMobileLandscape: isMobileLandscape,
                      imageFile: widget.imageFile,
                      imageUrl: widget.imageUrl,
                      descriptionController: _descriptionController,
                    ),
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
          // Botón Eliminar (solo en modo edición y móvil/tablet landscape)
          if (widget.isEditing && (isMobile || isMobileLandscape)) ...[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red[700]!,
                    Colors.red[800]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    offset: Offset(0, isMobileLandscape ? 2 : 4),
                    blurRadius: isMobileLandscape ? 6 : 8,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => _showDeleteConfirmation(context),
                icon: Icon(
                  Icons.delete_rounded,
                  size: isMobileLandscape ? 18 : 20,
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(isMobileLandscape ? 8 : 10),
                constraints: BoxConstraints(),
                tooltip: 'Eliminar',
              ),
            ),
            SizedBox(width: isMobileLandscape ? 8 : 10),
          ],
          
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

  // Confirmación de eliminación
  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        final screenWidth = MediaQuery.of(dialogContext).size.width;
        final screenHeight = MediaQuery.of(dialogContext).size.height;
        final orientation = MediaQuery.of(dialogContext).orientation;
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
            width: isMobile ? double.infinity : 450,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                  ? const [
                      Color.fromRGBO(211, 47, 47, 0.25),
                      Color.fromRGBO(198, 40, 40, 0.20),
                    ]
                  : const [
                      Color.fromRGBO(255, 205, 210, 0.95),
                      Color.fromRGBO(239, 154, 154, 0.85),
                    ],
              ),
              borderRadius: BorderRadius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 20)),
              border: Border.all(
                color: isDark 
                  ? const Color.fromRGBO(255, 255, 255, 0.1) 
                  : const Color.fromRGBO(0, 0, 0, 0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: Offset(0, isMobileLandscape ? 6 : 10),
                  blurRadius: isMobileLandscape ? 20 : 30,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header rojo
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobileLandscape ? 12 : (isMobile ? 16 : 20),
                    vertical: isMobileLandscape ? 10 : (isMobile ? 14 : 20),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red[700]!,
                        Colors.red[800]!,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 20)),
                      topRight: Radius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 20)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        offset: Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
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
                          Icons.warning_rounded,
                          color: Colors.white,
                          size: isMobileLandscape ? 18 : (isMobile ? 20 : 24),
                        ),
                      ),
                      SizedBox(width: isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
                      Expanded(
                        child: Text(
                          'Confirmar Eliminación',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobileLandscape ? 14 : (isMobile ? 16 : 18),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.all(isMobileLandscape ? 12 : (isMobile ? 16 : 20)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete_forever_rounded,
                        size: isMobileLandscape ? 48 : (isMobile ? 56 : 64),
                        color: Colors.red[700],
                      ),
                      SizedBox(height: isMobileLandscape ? 10 : 12),
                      Text(
                        '¿Seguro que deseas eliminar esta imagen?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobileLandscape ? 13 : (isMobile ? 14 : 15),
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: isMobileLandscape ? 6 : 8),
                      Text(
                        'Esta acción no se puede deshacer',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobileLandscape ? 10 : (isMobile ? 11 : 12),
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                Container(
                  padding: EdgeInsets.all(isMobileLandscape ? 10 : (isMobile ? 14 : 16)),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Colors.grey[850]!.withOpacity(0.9)
                        : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 20)),
                      bottomRight: Radius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 20)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: Offset(0, -4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? Colors.white : Colors.black87,
                            side: BorderSide(
                              color: isDark ? Colors.white54 : Colors.black45,
                              width: isMobileLandscape ? 1.5 : 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : 8),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: isMobileLandscape ? 10 : 12,
                            ),
                          ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: isMobileLandscape ? 12 : 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: isMobileLandscape ? 8 : 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: Colors.red.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : 8),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: isMobileLandscape ? 10 : 12,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_rounded,
                                size: isMobileLandscape ? 16 : 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Eliminar',
                                style: TextStyle(
                                  fontSize: isMobileLandscape ? 12 : 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == true && context.mounted) {
      // Cerrar el diálogo de edición y pasar resultado de eliminación
      Navigator.of(context).pop('delete');
    }
  }
}
