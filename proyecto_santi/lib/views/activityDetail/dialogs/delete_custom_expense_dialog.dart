import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/gasto_personalizado.dart';
import 'package:proyecto_santi/shared/widgets/dialog_header.dart';

/// Confirma eliminación de un gasto personalizado
Future<bool> confirmarEliminarGasto(
  BuildContext context,
  GastoPersonalizado gasto,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
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
          width: isMobile ? double.infinity : 450,
          constraints: BoxConstraints(
            maxHeight: isMobileLandscape
                ? screenHeight * 0.95
                : (isMobile ? screenHeight * 0.85 : screenHeight * 0.85),
          ),
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
              // Header - Custom red warning header
              _buildWarningHeader(isMobile, isMobileLandscape, context),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobileLandscape ? 12 : (isMobile ? 16 : 20)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete_forever_rounded,
                        size: isMobileLandscape ? 48 : (isMobile ? 56 : 64),
                        color: Colors.red[700],
                      ),
                      SizedBox(height: isMobileLandscape ? 12 : 16),
                      Text(
                        '¿Seguro que deseas eliminar este gasto?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobileLandscape ? 14 : (isMobile ? 15 : 16),
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: isMobileLandscape ? 8 : 12),
                      Container(
                        padding: EdgeInsets.all(isMobileLandscape ? 10 : 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : 10),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              size: isMobileLandscape ? 16 : (isMobile ? 18 : 20),
                              color: Colors.red[700],
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '"${gasto.concepto}"',
                                style: TextStyle(
                                  fontSize: isMobileLandscape ? 13 : (isMobile ? 14 : 15),
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isMobileLandscape ? 8 : 12),
                      Text(
                        'Esta acción no se puede deshacer',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobileLandscape ? 11 : (isMobile ? 12 : 13),
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Actions - Footer
              Container(
                padding: EdgeInsets.all(isMobileLandscape ? 12 : (isMobile ? 16 : 20)),
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
                  mainAxisAlignment: isMobile ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
                  children: [
                    // Botón Cancelar
                    Expanded(
                      flex: isMobile ? 1 : 0,
                      child: Container(
                        height: isMobileLandscape ? 38 : (isMobile ? 42 : 44),
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? Colors.white : Colors.black87,
                            side: BorderSide(
                              color: isDark ? Colors.white54 : Colors.black45,
                              width: isMobileLandscape ? 1.5 : 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : 10),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobileLandscape ? 16 : (isMobile ? 20 : 24),
                            ),
                          ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
                    // Botón Eliminar
                    Expanded(
                      flex: isMobile ? 1 : 0,
                      child: Container(
                        height: isMobileLandscape ? 38 : (isMobile ? 42 : 44),
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: Colors.red.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : 10),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobileLandscape ? 16 : (isMobile ? 20 : 24),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_rounded,
                                size: isMobileLandscape ? 16 : (isMobile ? 18 : 20),
                              ),
                              SizedBox(width: isMobileLandscape ? 4 : 6),
                              Text(
                                'Eliminar',
                                style: TextStyle(
                                  fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
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
  
  return result ?? false;
}

/// Builds a custom red warning header for delete confirmation
Widget _buildWarningHeader(bool isMobile, bool isMobileLandscape, BuildContext context) {
  return Container(
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
        IconButton(
          icon: Icon(Icons.close_rounded, color: Colors.white),
          iconSize: isMobileLandscape ? 18 : (isMobile ? 20 : 24),
          onPressed: () => Navigator.of(context).pop(false),
          padding: EdgeInsets.all(isMobileLandscape ? 4 : (isMobile ? 4 : 8)),
          constraints: BoxConstraints(),
          tooltip: 'Cerrar',
        ),
      ],
    ),
  );
}
