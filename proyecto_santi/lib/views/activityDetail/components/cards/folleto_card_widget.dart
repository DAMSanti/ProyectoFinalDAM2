import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../dialogs/pdf_viewer_dialog.dart';

class FolletoCardWidget extends StatelessWidget {
  final String? folletoFileName;
  final bool folletoMarkedForDeletion;
  final String? actividadFolletoUrl;
  final bool isAdminOrSolicitante;
  final VoidCallback onSelectFolleto;
  final VoidCallback onDeleteFolleto;
  final bool isMobile;

  const FolletoCardWidget({
    super.key,
    required this.folletoFileName,
    required this.folletoMarkedForDeletion,
    required this.actividadFolletoUrl,
    required this.isAdminOrSolicitante,
    required this.onSelectFolleto,
    required this.onDeleteFolleto,
    this.isMobile = false,
  });

  String _extractFileName(String url) {
    final parts = url.split('/');
    if (parts.isEmpty) return 'folleto.pdf';
    
    final fileName = parts.last;
    
    // Si el nombre tiene formato "timestamp_nombreOriginal.pdf", extraer solo el nombre original
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

    // Determinar si hay un folleto disponible para ver
    final bool hasFolleto = !folletoMarkedForDeletion && actividadFolletoUrl != null;
    final String displayFileName = folletoMarkedForDeletion 
        ? 'Sin folleto' 
        : (folletoFileName ?? 
            (actividadFolletoUrl != null 
                ? _extractFileName(actividadFolletoUrl!)
                : 'Sin folleto'));

    void _openPdfViewer() {
      if (hasFolleto) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return PdfViewerDialog(
              pdfUrl: actividadFolletoUrl!,
              fileName: displayFileName,
            );
          },
        );
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasFolleto ? _openPdfViewer : null,
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 10 : 12),
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.white.withOpacity(0.05) 
                : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
            border: Border.all(
              color: isDark 
                  ? Colors.white.withOpacity(0.1) 
                  : Colors.white.withOpacity(0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Folleto',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : (isWeb ? 11 : 13.0),
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1976d2),
                      ),
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    Text(
                      displayFileName,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : (isWeb ? 13 : 15.0),
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
              SizedBox(width: isMobile ? 8 : 10),
              Container(
                padding: EdgeInsets.all(isMobile ? 5 : 6),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(25, 118, 210, 0.1),
                  borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                ),
                child: Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Color(0xFF1976d2),
                  size: isMobile ? 14 : (isWeb ? 16 : 18.0),
                ),
              ),
              if (isAdminOrSolicitante) ...[
                SizedBox(width: isMobile ? 6 : 8),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF1976d2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.upload_file_rounded, color: Color(0xFF1976d2)),
                    iconSize: isMobile ? 16 : (isWeb ? 18 : 20.0),
                    padding: EdgeInsets.all(isMobile ? 6 : 8),
                    constraints: BoxConstraints(),
                    onPressed: onSelectFolleto,
                    tooltip: 'Subir folleto PDF',
                  ),
                ),
                if (!folletoMarkedForDeletion && 
                    (folletoFileName != null || actividadFolletoUrl != null)) ...[
                  SizedBox(width: isMobile ? 3 : 4),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close_rounded, color: Colors.red),
                      iconSize: isMobile ? 16 : (isWeb ? 18 : 20.0),
                      padding: EdgeInsets.all(isMobile ? 6 : 8),
                      constraints: BoxConstraints(),
                      onPressed: onDeleteFolleto,
                      tooltip: 'Eliminar folleto',
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
