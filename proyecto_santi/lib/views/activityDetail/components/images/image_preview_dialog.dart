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
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: !isWeb ? 500 : 600,
          maxHeight: !isWeb ? 700 : 800,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
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
              offset: Offset(0, 8),
              blurRadius: 24.0,
              spreadRadius: 2,
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
            // Contenido
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(25, 118, 210, 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.add_photo_alternate_rounded,
                            color: Color(0xFF1976d2),
                            size: !isWeb ? 20.dg : 6.sp,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.isEditing ? 'Editar Imagen' : 'Vista Previa de la Imagen',
                            style: TextStyle(
                              fontSize: !isWeb ? 16.dg : 5.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Color(0xFF1A237E),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: Colors.grey),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Preview de la imagen
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
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
                          borderRadius: BorderRadius.circular(14),
                          child: widget.imageUrl != null
                              ? Image.network(
                                  widget.imageUrl!,
                                  fit: BoxFit.contain,
                                  headers: {
                                    'Access-Control-Allow-Origin': '*',
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.broken_image_rounded,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                )
                              : kIsWeb
                                  ? Image.network(
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
                                    )
                                  : Image.file(
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
                                    ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Campo de descripción
                    Text(
                      'Descripción (opcional)',
                      style: TextStyle(
                        fontSize: !isWeb ? 13.dg : 4.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1976d2),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark 
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 3,
                        maxLength: 200,
                        style: TextStyle(
                          fontSize: !isWeb ? 13.dg : 4.sp,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Añade una descripción para esta imagen...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: !isWeb ? 12.dg : 3.8.sp,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Botones de acción
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Botón Cancelar
                        Container(
                          decoration: BoxDecoration(
                            color: isDark 
                                ? Colors.grey.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: !isWeb ? 13.dg : 4.sp,
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(width: 12),
                        
                        // Botón Añadir
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF1976d2),
                                Color(0xFF42A5F5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF1976d2).withOpacity(0.4),
                                offset: Offset(0, 4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              // Llamar al callback que maneja el cierre
                              widget.onConfirm(_descriptionController.text);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: !isWeb ? 18.dg : 5.sp,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  widget.isEditing ? 'Guardar Cambios' : 'Añadir Imagen',
                                  style: TextStyle(
                                    fontSize: !isWeb ? 13.dg : 4.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
