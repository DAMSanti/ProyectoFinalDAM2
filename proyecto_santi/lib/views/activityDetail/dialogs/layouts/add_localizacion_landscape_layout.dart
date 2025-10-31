import 'package:flutter/material.dart';
import '../../../../models/localizacion.dart';
import '../../../../services/geocoding_service.dart';
import '../../widgets/locations/localizacion_widgets.dart';

/// Layout landscape para el diálogo de añadir localizaciones
class AddLocalizacionLandscapeLayout extends StatelessWidget {
  final bool isDark;
  final bool isMobile;
  final TextEditingController searchController;
  final bool isSearching;
  final List<GeocodingResult> searchResults;
  final List<Localizacion> localizacionesActuales;
  final Map<int, IconData> iconosLocalizaciones;
  final VoidCallback onClearSearch;
  final Function(GeocodingResult) onResultTap;
  final Function(Localizacion) onEdit;
  final Function(Localizacion) onRemove;

  const AddLocalizacionLandscapeLayout({
    Key? key,
    required this.isDark,
    required this.isMobile,
    required this.searchController,
    required this.isSearching,
    required this.searchResults,
    required this.localizacionesActuales,
    required this.iconosLocalizaciones,
    required this.onClearSearch,
    required this.onResultTap,
    required this.onEdit,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna izquierda: Buscador y resultados
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Campo de búsqueda compacto
                SearchAddressField(
                  controller: searchController,
                  isSearching: isSearching,
                  onClear: onClearSearch,
                ),
                SizedBox(height: 10),
                
                // Resultados de búsqueda (lista compacta)
                if (searchResults.isNotEmpty)
                  Expanded(
                    child: SearchResultsList(
                      results: searchResults,
                      onResultTap: onResultTap,
                      isDark: isDark,
                    ),
                  ),
              ],
            ),
          ),
          
          SizedBox(width: 12),
          
          // Columna derecha: Lista de localizaciones
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título compacto
                _buildCompactHeader(),
                SizedBox(height: 10),
                
                // Lista de localizaciones compacta
                Expanded(
                  child: _buildLocationsList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.list_alt_rounded,
            size: 14,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 8),
        Text(
          'Localizaciones',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Color(0xFF1976d2),
          ),
        ),
        SizedBox(width: 6),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Color(0xFF1976d2).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${localizacionesActuales.length}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976d2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark 
            ? Colors.white.withOpacity(0.1) 
            : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: localizacionesActuales.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: EdgeInsets.all(6),
              itemCount: localizacionesActuales.length,
              itemBuilder: (context, index) {
                final loc = localizacionesActuales[index];
                final icono = iconosLocalizaciones[loc.id] ?? 
                             (loc.esPrincipal ? Icons.location_pin : Icons.location_on);
                
                return LocalizacionCard(
                  localizacion: loc,
                  icon: icono,
                  isDark: isDark,
                  isMobile: true, // Usar versión compacta
                  onEdit: () => onEdit(loc),
                  onRemove: () => onRemove(loc),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_rounded,
            size: 32,
            color: Color(0xFF1976d2).withOpacity(0.5),
          ),
          SizedBox(height: 8),
          Text(
            'Sin localizaciones',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
