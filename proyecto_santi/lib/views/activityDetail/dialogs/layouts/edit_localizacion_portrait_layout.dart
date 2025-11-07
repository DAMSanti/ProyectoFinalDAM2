import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/localizacion.dart';
import 'package:proyecto_santi/tema/app_colors.dart';

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
      padding: EdgeInsets.all(isMobile ? 10 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info de la localización
          _buildLocationInfo(),
          SizedBox(height: isMobile ? 10 : 20),
          
          // Checkbox para marcar como principal
          if (puedeSerPrincipal) _buildPrincipalCheckbox(),
          
          SizedBox(height: puedeSerPrincipal ? (isMobile ? 10 : 20) : 0),
          
          // Tipo de localización
          _buildTypeSelector(),
          SizedBox(height: isMobile ? 10 : 20),
          
          // Campo de descripción
          _buildDescription(),
          SizedBox(height: isMobile ? 10 : 20),
          
          // Selector de icono
          _buildIconSelector(),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        border: Border.all(
          color: Color(0xFF1976d2).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 5 : 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
              ),
              borderRadius: BorderRadius.circular(isMobile ? 5 : 8),
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: Colors.white,
              size: isMobile ? 16 : 20,
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizacion.nombre,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 16,
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
                    fontSize: isMobile ? 10 : 13,
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
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        border: Border.all(
          color: esPrincipal
            ? Colors.red.withValues(alpha: 0.5)
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
              size: isMobile ? 16 : 20,
            ),
            SizedBox(width: isMobile ? 4 : 8),
            Expanded(
              child: Text(
                'Localización principal',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
            ),
          ],
        ),
        subtitle: isMobile ? null : Padding(
          padding: EdgeInsets.only(left: 28, top: 4),
          child: Text(
            'Desmarcará la localización principal actual',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black45,
            ),
          ),
        ),
        value: esPrincipal,
        onChanged: onEsPrincipalChanged,
        activeColor: AppColors.estadoRechazado,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 6 : 16,
          vertical: isMobile ? 0 : 0,
        ),
        dense: isMobile,
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
              padding: EdgeInsets.all(isMobile ? 4 : 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                ),
                borderRadius: BorderRadius.circular(isMobile ? 5 : 8),
              ),
              child: Icon(
                Icons.label_rounded,
                color: Colors.white,
                size: isMobile ? 14 : 18,
              ),
            ),
            SizedBox(width: isMobile ? 6 : 10),
            Text(
              'Tipo:',
              style: TextStyle(
                fontSize: isMobile ? 12 : 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976d2),
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 6 : 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
            border: Border.all(
              color: Color(0xFF1976d2).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: tipoSeleccionado,
            decoration: InputDecoration(
              hintText: 'Selecciona el tipo',
              hintStyle: TextStyle(fontSize: isMobile ? 12 : 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 10 : 16, 
                vertical: isMobile ? 8 : 14
              ),
              prefixIcon: Icon(
                Icons.category_rounded,
                color: Color(0xFF1976d2),
                size: isMobile ? 18 : 24,
              ),
              isDense: isMobile,
            ),
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
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
                    Icon(iconoTipo, size: isMobile ? 16 : 20, color: Color(0xFF1976d2)),
                    SizedBox(width: isMobile ? 6 : 10),
                    Text(tipo, style: TextStyle(fontSize: isMobile ? 12 : 14)),
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
              padding: EdgeInsets.all(isMobile ? 4 : 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                ),
                borderRadius: BorderRadius.circular(isMobile ? 5 : 8),
              ),
              child: Icon(
                Icons.description_rounded,
                color: Colors.white,
                size: isMobile ? 14 : 18,
              ),
            ),
            SizedBox(width: isMobile ? 6 : 10),
            Text(
              'Descripción:',
              style: TextStyle(
                fontSize: isMobile ? 12 : 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976d2),
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 6 : 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
            border: Border.all(
              color: Color(0xFF1976d2).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: TextField(
            controller: descripcionController,
            maxLines: isMobile ? 2 : 3,
            maxLength: 500,
            style: TextStyle(fontSize: isMobile ? 12 : 14),
            decoration: InputDecoration(
              hintText: 'Añade un comentario...',
              hintStyle: TextStyle(fontSize: isMobile ? 12 : 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.all(isMobile ? 10 : 16),
              isDense: isMobile,
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
              padding: EdgeInsets.all(isMobile ? 4 : 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                ),
                borderRadius: BorderRadius.circular(isMobile ? 5 : 8),
              ),
              child: Icon(
                Icons.category_rounded,
                color: Colors.white,
                size: isMobile ? 14 : 18,
              ),
            ),
            SizedBox(width: isMobile ? 6 : 10),
            Text(
              'Icono:',
              style: TextStyle(
                fontSize: isMobile ? 12 : 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976d2),
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 6 : 12),
        Container(
          height: isMobile ? 160 : 240,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
            border: Border.all(
              color: Color(0xFF1976d2).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: GridView.builder(
            padding: EdgeInsets.all(isMobile ? 6 : 12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 5 : 5,
              crossAxisSpacing: isMobile ? 6 : 10,
              mainAxisSpacing: isMobile ? 6 : 10,
            ),
            itemCount: iconosDisponibles.length,
            itemBuilder: (context, index) {
              final icono = iconosDisponibles[index];
              final isSelected = iconoSeleccionado == icono;
              
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onIconoSelected(icono),
                  borderRadius: BorderRadius.circular(isMobile ? 6 : 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              Color(0xFF1976d2).withValues(alpha: 0.3),
                              Color(0xFF1565c0).withValues(alpha: 0.2),
                            ],
                          )
                        : null,
                      color: isSelected 
                          ? null
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(isMobile ? 6 : 10),
                      border: Border.all(
                        color: isSelected 
                            ? Color(0xFF1976d2)
                            : Colors.grey.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Icon(
                      icono,
                      size: isMobile ? 20 : 28,
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
