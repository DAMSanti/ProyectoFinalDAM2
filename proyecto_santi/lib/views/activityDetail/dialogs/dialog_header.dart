import 'package:flutter/material.dart';

/// Header genérico para diálogos
/// Permite personalizar el título y el icono
class DialogHeader extends StatelessWidget {
  final bool isMobile;
  final bool isMobileLandscape;
  final VoidCallback onClose;
  final String title;
  final IconData icon;

  const DialogHeader({
    super.key,
    required this.isMobile,
    required this.isMobileLandscape,
    required this.onClose,
    required this.title,
    this.icon = Icons.edit_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobileLandscape ? 12 : (isMobile ? 16 : 24), 
        vertical: isMobileLandscape ? 10 : (isMobile ? 14 : 20)
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1976d2).withValues(alpha: 0.9),
            Color(0xFF1565c0).withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isMobileLandscape ? 12 : (isMobile ? 16 : 20)),
          topRight: Radius.circular(isMobileLandscape ? 12 : (isMobile ? 16 : 20)),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1976d2).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isMobileLandscape ? 18 : (isMobile ? 20 : 24),
            ),
          ),
          SizedBox(width: isMobileLandscape ? 10 : (isMobile ? 12 : 16)),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobileLandscape ? 16 : (isMobile ? 18 : 22),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(isMobileLandscape ? 5 : (isMobile ? 6 : 8)),
            ),
            child: IconButton(
              icon: Icon(Icons.close_rounded, color: Colors.white),
              iconSize: isMobileLandscape ? 18 : (isMobile ? 20 : 24),
              padding: EdgeInsets.all(isMobileLandscape ? 4 : (isMobile ? 6 : 8)),
              constraints: BoxConstraints(),
              onPressed: onClose,
              tooltip: 'Cerrar',
            ),
          ),
        ],
      ),
    );
  }
}

/// Header del diálogo de edición de actividad (mantenido para compatibilidad)
class EditDialogHeader extends StatelessWidget {
  final bool isMobile;
  final bool isMobileLandscape;
  final VoidCallback onClose;

  const EditDialogHeader({
    super.key,
    required this.isMobile,
    required this.isMobileLandscape,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return DialogHeader(
      isMobile: isMobile,
      isMobileLandscape: isMobileLandscape,
      onClose: onClose,
      title: 'Editar Actividad',
      icon: Icons.edit_rounded,
    );
  }
}
