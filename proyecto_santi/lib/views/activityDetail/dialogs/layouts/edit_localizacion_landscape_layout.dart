import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/localizacion.dart';

/// Layout landscape para el diálogo de edición de localización
class EditLocalizacionLandscapeLayout extends StatelessWidget {
  final bool isDark;
  final bool isMobile;
  final bool isMobileLandscape;
  final Localizacion localizacion;
  final bool puedeSerPrincipal;
  final bool esPrincipal;
  final ValueChanged<bool?> onEsPrincipalChanged;
  final String? tipoSeleccionado;
  final List<String> tiposLocalizacion;
  final ValueChanged<String?> onTipoChanged;
  final TextEditingController descripcionController;
  final List<IconData> iconosDisponibles;
  final IconData? iconoSeleccionado;
  final ValueChanged<IconData> onIconoSelected;

  const EditLocalizacionLandscapeLayout({
    Key? key,
    required this.isDark,
    required this.isMobile,
    required this.isMobileLandscape,
    required this.localizacion,
    required this.puedeSerPrincipal,
    required this.esPrincipal,
    required this.onEsPrincipalChanged,
    required this.tipoSeleccionado,
    required this.tiposLocalizacion,
    required this.onTipoChanged,
    required this.descripcionController,
    required this.iconosDisponibles,
    required this.iconoSeleccionado,
    required this.onIconoSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna izquierda: Info + Checkbox + Tipo
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info compacta
                    _buildLocationInfo(),
                    SizedBox(height: 10),
                    
                    // Checkbox compacto
                    if (puedeSerPrincipal) _buildPrincipalCheckbox(),
                    
                    if (puedeSerPrincipal) SizedBox(height: 10),
                    
                    // Tipo compacto
                    _buildTypeSelector(),
                  ],
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
                    _buildDescription(),
                    SizedBox(height: 10),
                    
                    // Iconos compactos (altura fija)
                    SizedBox(
                      height: 200,
                      child: _buildIconSelector(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Color(0xFF1976d2).withValues(alpha: 0.3),
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
                  localizacion.nombre,
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
                  localizacion.direccionCompleta,
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
    );
  }

  Widget _buildPrincipalCheckbox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: esPrincipal
            ? Colors.red.withValues(alpha: 0.5)
            : Colors.transparent,
          width: esPrincipal ? 2 : 1,
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
        value: esPrincipal,
        onChanged: onEsPrincipalChanged,
        activeColor: Colors.red,
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: tipoSeleccionado,
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
            items: tiposLocalizacion.map((tipo) {
              return DropdownMenuItem<String>(
                value: tipo,
                child: Text(tipo, style: TextStyle(fontSize: 11)),
              );
            }).toList(),
            onChanged: onTipoChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: descripcionController,
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
      ],
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Icono:',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976d2),
          ),
        ),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GridView.builder(
            padding: EdgeInsets.all(8),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: iconosDisponibles.length,
            itemBuilder: (context, index) {
              final icono = iconosDisponibles[index];
              final isSelected = iconoSeleccionado == icono;
              
              return InkWell(
                onTap: () => onIconoSelected(icono),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? Color(0xFF1976d2).withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected 
                        ? Color(0xFF1976d2)
                        : Colors.grey.withValues(alpha: 0.3),
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
      ],
    );
  }
}
