import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/tema.dart';
import '../../../../models/localizacion.dart';
import '../../../../services/geocoding_service.dart';
import '../../widgets/locations/localizacion_widgets.dart';

/// Layout portrait para el diálogo de añadir localizaciones
class AddLocalizacionPortraitLayout extends StatelessWidget {
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

  const AddLocalizacionPortraitLayout({
    super.key,
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
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo de búsqueda
          SearchAddressField(
            controller: searchController,
            isSearching: isSearching,
            onClear: onClearSearch,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          
          // Resultados de búsqueda
          SearchResultsList(
            results: searchResults,
            onResultTap: onResultTap,
            isDark: isDark,
          ),
          
          // Divisor
          if (searchResults.isEmpty) DecorativeDivider(),
          SizedBox(height: isMobile ? 12 : 20),
          
          // Título de localizaciones
          SectionHeader(
            icon: Icons.list_alt_rounded,
            title: isMobile ? 'Localizaciones' : 'Localizaciones de esta actividad',
            count: localizacionesActuales.length,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          
          // Lista de localizaciones actuales
          Container(
            constraints: BoxConstraints(
              minHeight: isMobile ? 180 : 200, 
              maxHeight: isMobile ? 350 : 400
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
              border: Border.all(
                color: isDark 
                  ? Colors.white.withValues(alpha: 0.1) 
                  : Colors.black.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: localizacionesActuales.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(isMobile ? 6 : 8),
                    shrinkWrap: true,
                    itemCount: localizacionesActuales.length,
                    itemBuilder: (context, index) {
                      final loc = localizacionesActuales[index];
                      final icono = iconosLocalizaciones[loc.id] ?? 
                                   (loc.esPrincipal ? Icons.location_pin : Icons.location_on);
                      
                      return LocalizacionCard(
                        localizacion: loc,
                        icon: icono,
                        isDark: isDark,
                        isMobile: isMobile,
                        onEdit: () => onEdit(loc),
                        onRemove: () => onRemove(loc),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24 : 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                color: AppColors.primaryOpacity10,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                size: isMobile ? 36 : 48,
                color: AppColors.primaryOpacity50,
              ),
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              isMobile ? 'No hay localizaciones' : 'No hay localizaciones añadidas',
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!isMobile) ...[
              SizedBox(height: 8),
              Text(
                'Busca y añade direcciones usando el campo superior',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black38,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
