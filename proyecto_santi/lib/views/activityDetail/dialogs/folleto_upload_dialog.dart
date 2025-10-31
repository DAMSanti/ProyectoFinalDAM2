import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../dialogs/pdf_viewer_dialog.dart';

/// Widget especializado para la gestión de folletos PDF en una actividad.
/// 
/// Responsabilidades:
/// - Mostrar folleto actual (si existe)
/// - Permitir seleccionar nuevo folleto PDF
/// - Permitir eliminar folleto
/// - Notificar cambios al padre
/// - Soportar modo compacto para header
class FolletoUploadWidget extends StatefulWidget {
  final String? folletoUrl;
  final bool isAdminOrSolicitante;
  final Function(Map<String, dynamic>) onFolletoChanged;
  final bool compact; // Modo compacto para el header
  final bool isMobile;

  const FolletoUploadWidget({
    super.key,
    this.folletoUrl,
    required this.isAdminOrSolicitante,
    required this.onFolletoChanged,
    this.compact = false,
    this.isMobile = false,
  });

  @override
  State<FolletoUploadWidget> createState() => _FolletoUploadWidgetState();
}

class _FolletoUploadWidgetState extends State<FolletoUploadWidget> {
  String? _folletoFileName;
  String? _folletoFilePath;
  bool _folletoChanged = false;
  bool _folletoMarkedForDeletion = false;

  @override
  void initState() {
    super.initState();
    if (widget.folletoUrl != null && widget.folletoUrl!.isNotEmpty) {
      _folletoFileName = _extractFileName(widget.folletoUrl!);
    }
  }

  Future<void> _selectFolleto() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: kIsWeb,
      );

      if (result != null) {
        final file = result.files.single;
        setState(() {
          _folletoFileName = file.name;
          _folletoMarkedForDeletion = false;
          
          if (kIsWeb) {
            _folletoFilePath = null;
            if (file.bytes != null) {
              widget.onFolletoChanged({
                'folletoFileName': file.name,
                'folletoBytes': file.bytes,
              });
            }
          } else {
            _folletoFilePath = file.path;
            widget.onFolletoChanged({
              'folletoFileName': file.name,
              'folletoFilePath': file.path,
            });
          }
          _folletoChanged = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar el archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteFolleto() {
    setState(() {
      _folletoMarkedForDeletion = true;
      _folletoFileName = null;
      _folletoFilePath = null;
      
      widget.onFolletoChanged({
        'deleteFolleto': true,
      });
    });
  }

  String _extractFileName(String url) {
    final parts = url.split('/');
    if (parts.isEmpty) return 'folleto.pdf';
    
    final fileName = parts.last;
    
    // Extraer nombre original si tiene formato "timestamp_nombreOriginal.pdf"
    final timestampPattern = RegExp(r'^\d+_(.+)$');
    final match = timestampPattern.firstMatch(fileName);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }
    
    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    // Modo compacto para el header
    if (widget.compact) {
      return _buildCompactMode(context, isDark, isWeb);
    }

    // Modo completo: Si está marcado para eliminación y no hay nuevo folleto, no mostrar nada
    if (_folletoMarkedForDeletion && _folletoFileName == null) {
      return widget.isAdminOrSolicitante
          ? _buildUploadButton(isDark, isWeb)
          : SizedBox.shrink();
    }

    // Si hay folleto (nuevo o existente)
    if (_folletoFileName != null) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color.fromRGBO(244, 67, 54, 0.25),
                    Color.fromRGBO(229, 57, 53, 0.20),
                  ]
                : const [
                    Color.fromRGBO(255, 205, 210, 0.85),
                    Color.fromRGBO(255, 171, 145, 0.75),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? const Color.fromRGBO(255, 255, 255, 0.1)
                : const Color.fromRGBO(0, 0, 0, 0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.picture_as_pdf,
              color: Colors.red[700],
              size: 32,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Folleto',
                    style: TextStyle(
                      fontSize: isWeb ? 12 : 14.0,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.red[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _folletoFileName!,
                    style: TextStyle(
                      fontSize: isWeb ? 11 : 13.0,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (widget.isAdminOrSolicitante) ...[
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue[700]),
                onPressed: _selectFolleto,
                tooltip: 'Cambiar folleto',
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red[700]),
                onPressed: _deleteFolleto,
                tooltip: 'Eliminar folleto',
              ),
            ],
          ],
        ),
      );
    }

    // Si no hay folleto y es admin
    if (widget.isAdminOrSolicitante) {
      return _buildUploadButton(isDark, isWeb);
    }

    // Si no hay folleto y no es admin, no mostrar nada
    return SizedBox.shrink();
  }

  /// Modo compacto para el header (horizontal, sin padding extra)
  Widget _buildCompactMode(BuildContext context, bool isDark, bool isWeb) {
    final bool hasFolleto = !_folletoMarkedForDeletion && 
                           (_folletoFileName != null || widget.folletoUrl != null);
    final String displayFileName = _folletoMarkedForDeletion 
        ? 'Sin folleto' 
        : (_folletoFileName ?? 
            (widget.folletoUrl != null 
                ? _extractFileName(widget.folletoUrl!)
                : 'Sin folleto'));

    void _openPdfViewer() {
      if (hasFolleto && widget.folletoUrl != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return PdfViewerDialog(
              pdfUrl: widget.folletoUrl!,
              fileName: displayFileName,
            );
          },
        );
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: hasFolleto ? _openPdfViewer : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Folleto',
                  style: TextStyle(
                    fontSize: widget.isMobile ? 10 : (isWeb ? 11 : 13.0),
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1976d2),
                  ),
                ),
                SizedBox(height: widget.isMobile ? 2 : 4),
                Text(
                  displayFileName,
                  style: TextStyle(
                    fontSize: widget.isMobile ? 12 : (isWeb ? 13 : 15.0),
                    color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                    decoration: hasFolleto ? TextDecoration.underline : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: widget.isMobile ? 8 : 10),
        GestureDetector(
          onTap: hasFolleto ? _openPdfViewer : null,
          child: Container(
            padding: EdgeInsets.all(widget.isMobile ? 5 : 6),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(25, 118, 210, 0.1),
              borderRadius: BorderRadius.circular(widget.isMobile ? 6 : 8),
            ),
            child: Icon(
              Icons.picture_as_pdf_rounded,
              color: Color(0xFF1976d2),
              size: widget.isMobile ? 14 : (isWeb ? 16 : 18.0),
            ),
          ),
        ),
        if (widget.isAdminOrSolicitante) ...[
          SizedBox(width: widget.isMobile ? 6 : 8),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF1976d2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(widget.isMobile ? 6 : 8),
            ),
            child: IconButton(
              icon: Icon(Icons.upload_file_rounded, color: Color(0xFF1976d2)),
              iconSize: widget.isMobile ? 16 : (isWeb ? 18 : 20.0),
              padding: EdgeInsets.all(widget.isMobile ? 6 : 8),
              constraints: BoxConstraints(),
              onPressed: _selectFolleto,
              tooltip: 'Subir folleto PDF',
            ),
          ),
          if (!_folletoMarkedForDeletion && 
              (_folletoFileName != null || widget.folletoUrl != null)) ...[
            SizedBox(width: widget.isMobile ? 3 : 4),
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(widget.isMobile ? 6 : 8),
              ),
              child: IconButton(
                icon: Icon(Icons.close_rounded, color: Colors.red),
                iconSize: widget.isMobile ? 16 : (isWeb ? 18 : 20.0),
                padding: EdgeInsets.all(widget.isMobile ? 6 : 8),
                constraints: BoxConstraints(),
                onPressed: _deleteFolleto,
                tooltip: 'Eliminar folleto',
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildUploadButton(bool isDark, bool isWeb) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFf44336).withOpacity(0.8),
            Color(0xFFe53935).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _selectFolleto,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.upload_file,
                  color: Colors.white,
                  size: isWeb ? 18 : 20.0,
                ),
                SizedBox(width: 8),
                Text(
                  'Subir Folleto PDF',
                  style: TextStyle(
                    fontSize: isWeb ? 13 : 15.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
