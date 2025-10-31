import 'package:flutter/material.dart';

/// Footer genérico para diálogos con botones de acción personalizables
class DialogFooter extends StatelessWidget {
  final bool isMobile;
  final bool isMobileLandscape;
  final bool isDark;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final String cancelText;
  final String saveText;
  final IconData cancelIcon;
  final IconData saveIcon;

  const DialogFooter({
    Key? key,
    required this.isMobile,
    required this.isMobileLandscape,
    required this.isDark,
    required this.onCancel,
    required this.onSave,
    this.cancelText = 'Cancelar',
    this.saveText = 'Guardar',
    this.cancelIcon = Icons.close_rounded,
    this.saveIcon = Icons.save_rounded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobileLandscape ? 12 : (isMobile ? 16 : 24)),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.grey[850]!.withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(isMobileLandscape ? 12 : (isMobile ? 16 : 16)),
          bottomRight: Radius.circular(isMobileLandscape ? 12 : (isMobile ? 16 : 16)),
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
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botón Cancelar
          Expanded(
            flex: isMobile ? 1 : 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey[400]!,
                    Colors.grey[500]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    offset: Offset(0, isMobileLandscape ? 2 : (isMobile ? 2 : 4)),
                    blurRadius: isMobileLandscape ? 3 : (isMobile ? 4 : 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onCancel,
                  borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobileLandscape ? 12 : (isMobile ? 16 : 24), 
                      vertical: isMobileLandscape ? 8 : (isMobile ? 10 : 12)
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          cancelIcon,
                          color: Colors.white,
                          size: isMobileLandscape ? 16 : (isMobile ? 18 : 20),
                        ),
                        SizedBox(width: isMobileLandscape ? 5 : (isMobile ? 6 : 8)),
                        Text(
                          cancelText,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobileLandscape ? 13 : (isMobile ? 14 : 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: isMobileLandscape ? 6 : (isMobile ? 8 : 12)),
          // Botón Guardar
          Expanded(
            flex: isMobile ? 1 : 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1976d2),
                    Color(0xFF1565c0),
                  ],
                ),
                borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF1976d2).withOpacity(0.4),
                    offset: Offset(0, isMobileLandscape ? 2 : (isMobile ? 2 : 4)),
                    blurRadius: isMobileLandscape ? 3 : (isMobile ? 4 : 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onSave,
                  borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobileLandscape ? 12 : (isMobile ? 16 : 24), 
                      vertical: isMobileLandscape ? 8 : (isMobile ? 10 : 12)
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          saveIcon,
                          color: Colors.white,
                          size: isMobileLandscape ? 16 : (isMobile ? 18 : 20),
                        ),
                        SizedBox(width: isMobileLandscape ? 5 : (isMobile ? 6 : 8)),
                        Text(
                          isMobile ? saveText : (saveText == 'Guardar' ? 'Guardar Cambios' : saveText),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobileLandscape ? 13 : (isMobile ? 14 : 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Footer del diálogo de edición (mantenido para compatibilidad)
class EditDialogFooter extends StatelessWidget {
  final bool isMobile;
  final bool isMobileLandscape;
  final bool isDark;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const EditDialogFooter({
    Key? key,
    required this.isMobile,
    required this.isMobileLandscape,
    required this.isDark,
    required this.onCancel,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogFooter(
      isMobile: isMobile,
      isMobileLandscape: isMobileLandscape,
      isDark: isDark,
      onCancel: onCancel,
      onSave: onSave,
      cancelText: 'Cancelar',
      saveText: 'Guardar',
      cancelIcon: Icons.close_rounded,
      saveIcon: Icons.save_rounded,
    );
  }
}
