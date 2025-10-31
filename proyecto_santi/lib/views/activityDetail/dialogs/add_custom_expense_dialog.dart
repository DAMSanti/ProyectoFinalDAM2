import 'package:flutter/material.dart';
import 'package:proyecto_santi/shared/widgets/dialog_header.dart';

/// Muestra diálogo para agregar un nuevo gasto personalizado
Future<Map<String, dynamic>?> mostrarDialogoAgregarGasto(
  BuildContext context,
) async {
  final conceptoController = TextEditingController();
  final cantidadController = TextEditingController();
  
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
          width: isMobile ? double.infinity : 550,
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
                    Color.fromRGBO(25, 118, 210, 0.25),
                    Color.fromRGBO(21, 101, 192, 0.20),
                  ]
                : const [
                    Color.fromRGBO(187, 222, 251, 0.95),
                    Color.fromRGBO(144, 202, 249, 0.85),
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
              // Header
              DialogHeader(
                isMobile: isMobile,
                isMobileLandscape: isMobileLandscape,
                onClose: () => Navigator.of(context).pop(false),
                title: isMobile ? 'Agregar Gasto' : 'Agregar Gasto Personalizado',
                icon: Icons.add_card_rounded,
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobileLandscape ? 12 : (isMobile ? 16 : 20)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Campo Concepto
                      Text(
                        'Concepto',
                        style: TextStyle(
                          fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14),
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Color(0xFF1976d2),
                        ),
                      ),
                      SizedBox(height: isMobileLandscape ? 6 : 8),
                      TextField(
                        controller: conceptoController,
                        decoration: InputDecoration(
                          hintText: 'Ej: Material didáctico, entradas...',
                          hintStyle: TextStyle(
                            fontSize: isMobileLandscape ? 11 : (isMobile ? 12 : 13),
                          ),
                          filled: true,
                          fillColor: isDark 
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white.withOpacity(0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : 10),
                            borderSide: BorderSide(
                              color: isDark 
                                  ? Colors.white.withOpacity(0.2)
                                  : Color(0xFF1976d2).withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : 10),
                            borderSide: BorderSide(
                              color: isDark 
                                  ? Colors.white.withOpacity(0.2)
                                  : Color(0xFF1976d2).withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : 10),
                            borderSide: BorderSide(
                              color: Color(0xFF1976d2),
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isMobileLandscape ? 10 : 12,
                            vertical: isMobileLandscape ? 10 : 12,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      
                      SizedBox(height: isMobileLandscape ? 12 : 16),
                      
                      // Campo Cantidad
                      Text(
                        'Cantidad (€)',
                        style: TextStyle(
                          fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14),
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Color(0xFF1976d2),
                        ),
                      ),
                      SizedBox(height: isMobileLandscape ? 6 : 8),
                      TextField(
                        controller: cantidadController,
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            fontSize: isMobileLandscape ? 11 : (isMobile ? 12 : 13),
                          ),
                          prefixText: '€ ',
                          prefixStyle: TextStyle(
                            fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14),
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976d2),
                          ),
                          filled: true,
                          fillColor: isDark 
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white.withOpacity(0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : 10),
                            borderSide: BorderSide(
                              color: isDark 
                                  ? Colors.white.withOpacity(0.2)
                                  : Color(0xFF1976d2).withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : 10),
                            borderSide: BorderSide(
                              color: isDark 
                                  ? Colors.white.withOpacity(0.2)
                                  : Color(0xFF1976d2).withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : 10),
                            borderSide: BorderSide(
                              color: Color(0xFF1976d2),
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isMobileLandscape ? 10 : 12,
                            vertical: isMobileLandscape ? 10 : 12,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                            foregroundColor: Color(0xFF1976d2),
                            side: BorderSide(
                              color: Color(0xFF1976d2),
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
                    // Botón Agregar
                    Expanded(
                      flex: isMobile ? 1 : 0,
                      child: Container(
                        height: isMobileLandscape ? 38 : (isMobile ? 42 : 44),
                        child: ElevatedButton(
                          onPressed: () {
                            final concepto = conceptoController.text.trim();
                            final cantidadStr = cantidadController.text.trim();
                            
                            if (concepto.isEmpty || cantidadStr.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Por favor completa todos los campos'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            
                            // Reemplazar coma por punto para asegurar parseo correcto
                            final textoLimpio = cantidadStr.replaceAll(',', '.');
                            final cantidad = double.tryParse(textoLimpio);
                            if (cantidad == null || cantidad <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Ingresa una cantidad válida'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            
                            Navigator.of(context).pop(true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1976d2),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: Color(0xFF1976d2).withOpacity(0.5),
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
                                Icons.add_rounded,
                                size: isMobileLandscape ? 16 : (isMobile ? 18 : 20),
                              ),
                              SizedBox(width: isMobileLandscape ? 4 : 6),
                              Text(
                                'Agregar',
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
  
  if (result == true) {
    final concepto = conceptoController.text.trim();
    final cantidadStr = cantidadController.text.trim().replaceAll(',', '.');
    final cantidad = double.tryParse(cantidadStr);
    
    return {
      'concepto': concepto,
      'cantidad': cantidad,
    };
  }
  
  return null;
}
