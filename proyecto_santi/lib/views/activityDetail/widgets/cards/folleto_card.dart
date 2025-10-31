import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../../dialogs/folleto_upload_dialog.dart';

/// Widget de tarjeta para el folleto en el header de la actividad.
/// Usa internamente FolletoUploadWidget para manejar la lógica de upload.
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    return Container(
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
      child: FolletoUploadWidget(
        folletoUrl: actividadFolletoUrl,
        isAdminOrSolicitante: isAdminOrSolicitante,
        onFolletoChanged: (data) {
          // Propagar callbacks al padre
          // El padre (activity_detail_info) maneja _selectFolleto y _deleteFolleto
          // No es necesario hacer nada aquí, el widget FolletoUploadWidget
          // ya llama a _selectFolleto internamente cuando se presiona upload
        },
        compact: true, // Versión compacta para el header
        isMobile: isMobile,
      ),
    );
  }
}
