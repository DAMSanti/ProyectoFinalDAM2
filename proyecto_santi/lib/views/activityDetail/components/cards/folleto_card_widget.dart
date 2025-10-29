import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

class FolletoCardWidget extends StatelessWidget {
  final String? folletoFileName;
  final bool folletoMarkedForDeletion;
  final String? actividadFolletoUrl;
  final bool isAdminOrSolicitante;
  final VoidCallback onSelectFolleto;
  final VoidCallback onDeleteFolleto;

  const FolletoCardWidget({
    super.key,
    required this.folletoFileName,
    required this.folletoMarkedForDeletion,
    required this.actividadFolletoUrl,
    required this.isAdminOrSolicitante,
    required this.onSelectFolleto,
    required this.onDeleteFolleto,
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withOpacity(0.05) 
            : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
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
                    fontSize: !isWeb ? 11.dg : 3.5.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1976d2),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  folletoMarkedForDeletion 
                      ? 'Sin folleto' 
                      : (folletoFileName ?? 
                          (actividadFolletoUrl != null 
                              ? _extractFileName(actividadFolletoUrl!)
                              : 'Sin folleto')),
                  style: TextStyle(
                    fontSize: !isWeb ? 13.dg : 4.sp,
                    color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(25, 118, 210, 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.picture_as_pdf_rounded,
              color: Color(0xFF1976d2),
              size: !isWeb ? 16.dg : 5.sp,
            ),
          ),
          if (isAdminOrSolicitante) ...[
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF1976d2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.upload_file_rounded, color: Color(0xFF1976d2)),
                iconSize: !isWeb ? 18.dg : 5.sp,
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(),
                onPressed: onSelectFolleto,
                tooltip: 'Subir folleto PDF',
              ),
            ),
            if (!folletoMarkedForDeletion && 
                (folletoFileName != null || actividadFolletoUrl != null)) ...[
              SizedBox(width: 4),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.close_rounded, color: Colors.red),
                  iconSize: !isWeb ? 18.dg : 5.sp,
                  padding: EdgeInsets.all(8),
                  constraints: BoxConstraints(),
                  onPressed: onDeleteFolleto,
                  tooltip: 'Eliminar folleto',
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
