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
  final Function(Map<String, dynamic>) onFolletoChanged;
  final bool isMobile;

  const FolletoCardWidget({
    super.key,
    required this.folletoFileName,
    required this.folletoMarkedForDeletion,
    required this.actividadFolletoUrl,
    required this.isAdminOrSolicitante,
    required this.onFolletoChanged,
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
            ? Colors.white.withValues(alpha: 0.05) 
            : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.1) 
              : Colors.white.withValues(alpha: 0.5),
        ),
      ),
      child: FolletoUploadWidget(
        key: ValueKey('${actividadFolletoUrl ?? 'no_folleto'}_${folletoFileName ?? 'none'}_$folletoMarkedForDeletion'), // Key para forzar recreación al revertir
        folletoUrl: actividadFolletoUrl,
        initialFolletoFileName: folletoFileName,
        initialFolletoMarkedForDeletion: folletoMarkedForDeletion,
        isAdminOrSolicitante: isAdminOrSolicitante,
        onFolletoChanged: onFolletoChanged,
        compact: true, // Versión compacta para el header
        isMobile: isMobile,
      ),
    );
  }
}
