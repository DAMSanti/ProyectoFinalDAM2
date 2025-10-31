import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/localizacion.dart';

/// Layout portrait para el diálogo de edición de localización
class EditLocalizacionPortraitLayout extends StatelessWidget {
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

  const EditLocalizacionPortraitLayout({
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
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info de la localización
          _buildLocationInfo(),
          SizedBox(height: isMobile ? 14 : 20),
          
          // Checkbox para marcar como principal
          if (puedeSerPrincipal) _buildPrincipalCheckbox(),
          
          SizedBox(height: puedeSerPrincipal ? (isMobile ? 14 : 20) : 0),
          
          // Tipo de localización
          _buildTypeSelector(),
          SizedBox(height: isMobile ? 14 : 20),
          
          // Campo de descripción
          _buildDescription(),
          SizedBox(height: isMobile ? 14 : 20),
          
          // Selector de icono
          _buildIconSelector(),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
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
                      localizacion.nombre,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976d2),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      localizacion.direccionCompleta,
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
    );
  }

  Widget _buildPrincipalCheckbox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        border: Border.all(
          color: esPrincipal
            ? Colors.red.withOpacity(0.5)
            : Colors.transparent,
          width: esPrincipal ? 2 : 1,
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
        value: esPrincipal,
        onChanged: onEsPrincipalChanged,
        activeColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 16,
          vertical: isMobile ? 4 : 0,
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            value: tipoSeleccionado,
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
            items: tiposLocalizacion.map((tipo) {
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
            controller: descripcionController,
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
      ],
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            itemCount: iconosDisponibles.length,
            itemBuilder: (context, index) {
              final icono = iconosDisponibles[index];
              final isSelected = iconoSeleccionado == icono;
              
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onIconoSelected(icono),
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
    );
  }
}
