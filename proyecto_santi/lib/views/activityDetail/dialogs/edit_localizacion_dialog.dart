import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/tema.dart';
import 'package:proyecto_santi/models/localizacion.dart';
import 'layouts/edit_localizacion_landscape_layout.dart';
import 'layouts/edit_localizacion_portrait_layout.dart';

/// Diálogo para editar una localización existente
/// Permite cambiar el icono y marcar/desmarcar como principal
class EditLocalizacionDialog extends StatefulWidget {
  final Localizacion localizacion;
  final List<IconData> iconosDisponibles;
  final IconData? iconoActual;
  final bool puedeSerPrincipal;

  const EditLocalizacionDialog({
    Key? key,
    required this.localizacion,
    required this.iconosDisponibles,
    this.iconoActual,
    required this.puedeSerPrincipal,
  }) : super(key: key);

  @override
  EditLocalizacionDialogState createState() => EditLocalizacionDialogState();
}

class EditLocalizacionDialogState extends State<EditLocalizacionDialog> {
  late bool _esPrincipal;
  IconData? _iconoSeleccionado;
  late TextEditingController _descripcionController;
  String? _tipoSeleccionado;
  
  // Tipos de localización disponibles
  final List<String> _tiposLocalizacion = [
    'Punto de salida',
    'Punto de llegada',
    'Alojamiento',
    'Actividad',
  ];

  @override
  void initState() {
    super.initState();
    _esPrincipal = widget.localizacion.esPrincipal;
    _iconoSeleccionado = widget.iconoActual;
    _descripcionController = TextEditingController(text: widget.localizacion.descripcion ?? '');
    _tipoSeleccionado = widget.localizacion.tipoLocalizacion;
  }
  
  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          ? EdgeInsets.symmetric(horizontal: 12, vertical: 8)
          : (isMobile 
              ? EdgeInsets.symmetric(horizontal: 12, vertical: 24)
              : EdgeInsets.symmetric(horizontal: 40, vertical: 24)),
      child: Container(
        width: isMobile ? double.infinity : 550,
        constraints: BoxConstraints(
          maxHeight: isMobileLandscape
              ? screenHeight * 0.95
              : (isMobile ? screenHeight * 0.90 : screenHeight * 0.85)),
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
          borderRadius: BorderRadius.circular(isMobileLandscape ? 12 : (isMobile ? 16 : 20)),
          border: Border.all(
            color: isDark 
              ? const Color.fromRGBO(255, 255, 255, 0.1) 
              : const Color.fromRGBO(0, 0, 0, 0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: Offset(0, isMobileLandscape ? 4 : (isMobile ? 4 : 10)),
              blurRadius: isMobileLandscape ? 16 : (isMobile ? 16 : 30),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobileLandscape ? 10 : (isMobile ? 12 : 20),
                vertical: isMobileLandscape ? 8 : (isMobile ? 10 : 20),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMobileLandscape ? 12 : (isMobile ? 16 : 20)),
                  topRight: Radius.circular(isMobileLandscape ? 12 : (isMobile ? 16 : 20)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryOpacity30,
                    offset: Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobileLandscape ? 5 : (isMobile ? 6 : 10)),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(isMobileLandscape ? 5 : (isMobile ? 6 : 10)),
                    ),
                    child: Icon(
                      Icons.edit_location_rounded,
                      color: Colors.white,
                      size: isMobileLandscape ? 16 : (isMobile ? 18 : 24),
                    ),
                  ),
                  SizedBox(width: isMobileLandscape ? 6 : (isMobile ? 8 : 12)),
                  Expanded(
                    child: Text(
                      'Editar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobileLandscape ? 13 : (isMobile ? 14 : 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: Colors.white, size: isMobileLandscape ? 16 : (isMobile ? 20 : 24)),
                    padding: EdgeInsets.all(isMobileLandscape ? 3 : (isMobile ? 3 : 8)),
                    constraints: BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
            ),
            
            // Content - Layout condicional
            Flexible(
              child: isMobileLandscape
                  ? EditLocalizacionLandscapeLayout(
                      isDark: isDark,
                      isMobile: isMobile,
                      isMobileLandscape: isMobileLandscape,
                      localizacion: widget.localizacion,
                      puedeSerPrincipal: widget.puedeSerPrincipal,
                      esPrincipal: _esPrincipal,
                      onEsPrincipalChanged: (value) {
                        setState(() {
                          _esPrincipal = value ?? false;
                        });
                      },
                      tipoSeleccionado: _tipoSeleccionado,
                      tiposLocalizacion: _tiposLocalizacion,
                      onTipoChanged: (value) {
                        setState(() {
                          _tipoSeleccionado = value;
                        });
                      },
                      descripcionController: _descripcionController,
                      iconosDisponibles: widget.iconosDisponibles,
                      iconoSeleccionado: _iconoSeleccionado,
                      onIconoSelected: (icono) {
                        setState(() {
                          _iconoSeleccionado = icono;
                        });
                      },
                    )
                  : EditLocalizacionPortraitLayout(
                      isDark: isDark,
                      isMobile: isMobile,
                      isMobileLandscape: isMobileLandscape,
                      localizacion: widget.localizacion,
                      puedeSerPrincipal: widget.puedeSerPrincipal,
                      esPrincipal: _esPrincipal,
                      onEsPrincipalChanged: (value) {
                        setState(() {
                          _esPrincipal = value ?? false;
                        });
                      },
                      tipoSeleccionado: _tipoSeleccionado,
                      tiposLocalizacion: _tiposLocalizacion,
                      onTipoChanged: (value) {
                        setState(() {
                          _tipoSeleccionado = value;
                        });
                      },
                      descripcionController: _descripcionController,
                      iconosDisponibles: widget.iconosDisponibles,
                      iconoSeleccionado: _iconoSeleccionado,
                      onIconoSelected: (icono) {
                        setState(() {
                          _iconoSeleccionado = icono;
                        });
                      },
                    ),
            ),
            
            // Actions - Footer adaptivo
            Container(
              padding: EdgeInsets.all(isMobileLandscape ? 10 : (isMobile ? 12 : 20)),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.grey[850]!.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: Offset(0, -4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: isMobile
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón Guardar (full width en móvil)
                        _buildSaveButton(isMobile),
                        SizedBox(height: 8),
                        // Botón Cancelar (full width en móvil)
                        _buildCancelButton(isMobile),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildCancelButton(isMobile),
                        SizedBox(width: 12),
                        _buildSaveButton(isMobile),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton(bool isMobile) {
    return Container(
      constraints: isMobile ? BoxConstraints(minWidth: double.infinity) : BoxConstraints(),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[400]!,
            Colors.grey[500]!,
          ],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 24, 
              vertical: isMobile ? 10 : 12
            ),
            child: Row(
              mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: isMobile ? 18 : 20,
                ),
                SizedBox(width: isMobile ? 6 : 8),
                Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 15 : 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isMobile) {
    return Container(
      constraints: isMobile ? BoxConstraints(minWidth: double.infinity) : BoxConstraints(),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
        ),
        borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOpacity40,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop({
              'esPrincipal': _esPrincipal,
              'icono': _iconoSeleccionado,
              'descripcion': _descripcionController.text.trim(),
              'tipoLocalizacion': _tipoSeleccionado,
            });
          },
          borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 24, 
              vertical: isMobile ? 10 : 12
            ),
            child: Row(
              mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: isMobile ? 18 : 20,
                ),
                SizedBox(width: isMobile ? 6 : 8),
                Text(
                  'Guardar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 15 : 16,
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
