import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/localizacion.dart';

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
          ? EdgeInsets.symmetric(horizontal: 16, vertical: 12)
          : (isMobile 
              ? EdgeInsets.symmetric(horizontal: 16, vertical: 40)
              : EdgeInsets.symmetric(horizontal: 40, vertical: 24)),
      child: Container(
        width: isMobile ? double.infinity : 550,
        constraints: BoxConstraints(
          maxHeight: isMobileLandscape
              ? screenHeight * 0.95
              : (isMobile ? screenHeight * 0.88 : screenHeight * 0.85)),
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
              offset: Offset(0, isMobileLandscape ? 6 : (isMobile ? 6 : 10)),
              blurRadius: isMobileLandscape ? 20 : (isMobile ? 20 : 30),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobileLandscape ? 12 : (isMobile ? 14 : 20),
                vertical: isMobileLandscape ? 10 : (isMobile ? 14 : 20),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1976d2),
                    Color(0xFF1565c0),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMobileLandscape ? 16 : 20),
                  topRight: Radius.circular(isMobileLandscape ? 16 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF1976d2).withOpacity(0.3),
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
                      Icons.edit_location_rounded,
                      color: Colors.white,
                      size: isMobileLandscape ? 18 : (isMobile ? 20 : 24),
                    ),
                  ),
                  SizedBox(width: isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
                  Expanded(
                    child: Text(
                      isMobile ? 'Editar' : 'Editar Localización',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobileLandscape ? 14 : (isMobile ? 16 : 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: Colors.white, size: isMobileLandscape ? 18 : (isMobile ? 22 : 24)),
                    padding: EdgeInsets.all(isMobileLandscape ? 4 : (isMobile ? 4 : 8)),
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
                  ? _buildLandscapeMobileLayout(isDark, isMobile, isMobileLandscape)
                  : _buildPortraitLayout(isDark, isMobile, isMobileLandscape),
            ),
            
            // Actions - Footer adaptivo
            Container(
              padding: EdgeInsets.all(isMobileLandscape ? 10 : (isMobile ? 12 : 20)),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.grey[850]!.withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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

  // Layout para móvil en modo landscape (horizontal)
  Widget _buildLandscapeMobileLayout(bool isDark, bool isMobile, bool isMobileLandscape) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna izquierda: Info + Checkbox + Tipo
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info compacta
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(0xFF1976d2).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFF1976d2),
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.localizacion.nombre,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1976d2),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Text(
                                widget.localizacion.direccionCompleta,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  
                  // Checkbox compacto
                  if (widget.puedeSerPrincipal)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _esPrincipal
                            ? Colors.red.withOpacity(0.5)
                            : Colors.transparent,
                          width: _esPrincipal ? 2 : 1,
                        ),
                      ),
                      child: CheckboxListTile(
                        title: Text(
                          'Principal',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                        value: _esPrincipal,
                        onChanged: (value) {
                          setState(() {
                            _esPrincipal = value ?? false;
                          });
                        },
                        activeColor: Colors.red,
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      ),
                    ),
                  
                  if (widget.puedeSerPrincipal) SizedBox(height: 10),
                  
                  // Tipo compacto
                  Text(
                    'Tipo:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976d2),
                    ),
                  ),
                  SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _tipoSeleccionado,
                      decoration: InputDecoration(
                        hintText: 'Tipo',
                        hintStyle: TextStyle(fontSize: 11),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        isDense: true,
                      ),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                      items: _tiposLocalizacion.map((tipo) {
                        return DropdownMenuItem<String>(
                          value: tipo,
                          child: Text(tipo, style: TextStyle(fontSize: 11)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _tipoSeleccionado = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(width: 12),
          
          // Columna derecha: Descripción + Iconos
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Descripción compacta
                Text(
                  'Descripción:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976d2),
                  ),
                ),
                SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _descripcionController,
                    maxLines: 2,
                    maxLength: 500,
                    style: TextStyle(fontSize: 11),
                    decoration: InputDecoration(
                      hintText: 'Añade un comentario...',
                      hintStyle: TextStyle(fontSize: 11),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.all(10),
                      isDense: true,
                      counterText: '',
                    ),
                  ),
                ),
                SizedBox(height: 10),
                
                // Iconos compactos
                Text(
                  'Icono:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976d2),
                  ),
                ),
                SizedBox(height: 6),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GridView.builder(
                      padding: EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemCount: widget.iconosDisponibles.length,
                      itemBuilder: (context, index) {
                        final icono = widget.iconosDisponibles[index];
                        final isSelected = _iconoSeleccionado == icono;
                        
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _iconoSeleccionado = icono;
                            });
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected 
                                ? Color(0xFF1976d2).withOpacity(0.2)
                                : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected 
                                  ? Color(0xFF1976d2)
                                  : Colors.grey.withOpacity(0.3),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Icon(
                              icono,
                              size: 20,
                              color: isSelected 
                                ? Color(0xFF1976d2) 
                                : Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Layout para portrait (vertical) - móvil y escritorio
  Widget _buildPortraitLayout(bool isDark, bool isMobile, bool isMobileLandscape) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info de la localización
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
              border: Border.all(
                color: Color(0xFF1976d2).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF1976d2).withOpacity(0.1),
                  offset: Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isMobile ? 6 : 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                        ),
                        borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: isMobile ? 18 : 20,
                      ),
                    ),
                    SizedBox(width: isMobile ? 10 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.localizacion.nombre,
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1976d2),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.localizacion.direccionCompleta,
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 13,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 14 : 20),
          
          // Checkbox para marcar como principal
          if (widget.puedeSerPrincipal)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                border: Border.all(
                  color: _esPrincipal
                    ? Colors.red.withOpacity(0.5)
                    : Colors.transparent,
                  width: _esPrincipal ? 2 : 1,
                ),
              ),
              child: CheckboxListTile(
                title: Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: Colors.red,
                      size: isMobile ? 18 : 20,
                    ),
                    SizedBox(width: isMobile ? 6 : 8),
                    Expanded(
                      child: Text(
                        isMobile ? 'Localización principal' : 'Marcar como localización principal',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 13 : 14,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(left: isMobile ? 24 : 28, top: 4),
                  child: Text(
                    isMobile ? 'Desmarcará la actual' : 'Desmarcará la localización principal actual',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: isDark ? Colors.white60 : Colors.black45,
                    ),
                  ),
                ),
                value: _esPrincipal,
                onChanged: (value) {
                  setState(() {
                    _esPrincipal = value ?? false;
                  });
                },
                activeColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 16,
                  vertical: isMobile ? 4 : 0,
                ),
              ),
            ),
          
          SizedBox(height: widget.puedeSerPrincipal ? (isMobile ? 14 : 20) : 0),
          
          // Tipo de localización
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 5 : 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                  ),
                  borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                ),
                child: Icon(
                  Icons.label_rounded,
                  color: Colors.white,
                  size: isMobile ? 16 : 18,
                ),
              ),
              SizedBox(width: isMobile ? 8 : 10),
              Text(
                'Tipo de localización:',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976d2),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 10 : 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
              border: Border.all(
                color: Color(0xFF1976d2).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF1976d2).withOpacity(0.1),
                  offset: Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: _tipoSeleccionado,
              decoration: InputDecoration(
                hintText: 'Selecciona el tipo',
                hintStyle: TextStyle(fontSize: isMobile ? 13 : 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16, 
                  vertical: isMobile ? 10 : 14
                ),
                prefixIcon: Icon(
                  Icons.category_rounded,
                  color: Color(0xFF1976d2),
                  size: isMobile ? 20 : 24,
                ),
              ),
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
              dropdownColor: isDark ? Colors.grey[800] : Colors.white,
              items: _tiposLocalizacion.map((tipo) {
                IconData iconoTipo;
                switch (tipo) {
                  case 'Punto de salida':
                    iconoTipo = Icons.location_on_rounded;
                    break;
                  case 'Punto de llegada':
                    iconoTipo = Icons.flag_rounded;
                    break;
                  case 'Alojamiento':
                    iconoTipo = Icons.hotel_rounded;
                    break;
                  case 'Actividad':
                    iconoTipo = Icons.local_activity_rounded;
                    break;
                  default:
                    iconoTipo = Icons.place_rounded;
                }
                
                return DropdownMenuItem<String>(
                  value: tipo,
                  child: Row(
                    children: [
                      Icon(iconoTipo, size: isMobile ? 18 : 20, color: Color(0xFF1976d2)),
                      SizedBox(width: isMobile ? 8 : 10),
                      Text(tipo),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _tipoSeleccionado = value;
                });
              },
            ),
          ),
          SizedBox(height: isMobile ? 14 : 20),
          
          // Campo de descripción
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 5 : 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                  ),
                  borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                ),
                child: Icon(
                  Icons.description_rounded,
                  color: Colors.white,
                  size: isMobile ? 16 : 18,
                ),
              ),
              SizedBox(width: isMobile ? 8 : 10),
              Text(
                'Descripción:',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976d2),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 10 : 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
              border: Border.all(
                color: Color(0xFF1976d2).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF1976d2).withOpacity(0.1),
                  offset: Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: TextField(
              controller: _descripcionController,
              maxLines: isMobile ? 2 : 3,
              maxLength: 500,
              style: TextStyle(fontSize: isMobile ? 13 : 14),
              decoration: InputDecoration(
                hintText: isMobile 
                  ? 'Añade un comentario...' 
                  : 'Añade un comentario o descripción sobre esta localización...',
                hintStyle: TextStyle(fontSize: isMobile ? 13 : 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
              ),
            ),
          ),
          SizedBox(height: isMobile ? 14 : 20),
          
          // Selector de icono
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 5 : 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                  ),
                  borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                ),
                child: Icon(
                  Icons.category_rounded,
                  color: Colors.white,
                  size: isMobile ? 16 : 18,
                ),
              ),
              SizedBox(width: isMobile ? 8 : 10),
              Text(
                'Seleccionar icono:',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976d2),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 10 : 12),
          Container(
            height: isMobile ? 200 : 240,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
              border: Border.all(
                color: Color(0xFF1976d2).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF1976d2).withOpacity(0.1),
                  offset: Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: GridView.builder(
              padding: EdgeInsets.all(isMobile ? 8 : 12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 4 : 5,
                crossAxisSpacing: isMobile ? 8 : 10,
                mainAxisSpacing: isMobile ? 8 : 10,
              ),
              itemCount: widget.iconosDisponibles.length,
              itemBuilder: (context, index) {
                final icono = widget.iconosDisponibles[index];
                final isSelected = _iconoSeleccionado == icono;
                
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _iconoSeleccionado = icono;
                      });
                    },
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                Color(0xFF1976d2).withOpacity(0.3),
                                Color(0xFF1565c0).withOpacity(0.2),
                              ],
                            )
                          : null,
                        color: isSelected 
                            ? null
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
                        border: Border.all(
                          color: isSelected 
                              ? Color(0xFF1976d2)
                              : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Color(0xFF1976d2).withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : [],
                      ),
                      child: Icon(
                        icono,
                        size: isMobile ? 24 : 28,
                        color: isSelected 
                          ? Color(0xFF1976d2) 
                          : isDark ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
            color: Colors.grey.withOpacity(0.3),
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
          colors: [
            Color(0xFF1976d2),
            Color(0xFF1565c0),
          ],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1976d2).withOpacity(0.4),
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
