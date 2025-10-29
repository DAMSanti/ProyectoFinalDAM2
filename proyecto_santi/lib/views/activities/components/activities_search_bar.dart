import 'package:flutter/material.dart';
import 'package:proyecto_santi/views/activities/components/activities_filter_dialog.dart';

/// Barra de búsqueda moderna con botón de filtros integrado
class ActivitiesSearchBar extends StatelessWidget {
  final Function(String) onSearchQueryChanged;
  final Map<String, dynamic> filters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const ActivitiesSearchBar({
    super.key,
    required this.onSearchQueryChanged,
    required this.filters,
    required this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasActiveFilters = filters.values.any((value) => value != null && value != '');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Barra de búsqueda expandible
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.white.withOpacity(0.1) 
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark 
                        ? Colors.black.withOpacity(0.4)
                        : Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                  // Inner shadow para profundidad
                  BoxShadow(
                    color: isDark 
                        ? Colors.black.withOpacity(0.2)
                        : Colors.white.withOpacity(0.8),
                    blurRadius: 6,
                    offset: Offset(0, -2),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: TextField(
                onChanged: onSearchQueryChanged,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar actividades...',
                  hintStyle: TextStyle(
                    color: isDark 
                        ? Colors.white.withOpacity(0.5)
                        : Colors.black54,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? Colors.white70 : Color(0xFF1976d2),
                    size: 22,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          
          SizedBox(width: 12),
          
          // Botón de filtros con indicador
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Color(0xFF1976d2), Color(0xFF1565c0)]
                        : [Color(0xFF1976d2), Color(0xFF2196f3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF1976d2).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showFilterDialog(context),
                    child: Container(
                      padding: EdgeInsets.all(14),
                      child: Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
              // Indicador de filtros activos
              if (hasActiveFilters)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.black : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ActivitiesFilterDialog(
        currentFilters: filters,
        onApplyFilters: onFiltersChanged,
      ),
    );
  }
}
