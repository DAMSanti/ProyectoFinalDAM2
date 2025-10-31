import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/localizacion.dart';
import 'package:proyecto_santi/services/geocoding_service.dart';

/// Widgets reutilizables para el diálogo de localizaciones

/// Campo de búsqueda de direcciones
class SearchAddressField extends StatelessWidget {
  final TextEditingController controller;
  final bool isSearching;
  final VoidCallback onClear;

  const SearchAddressField({
    Key? key,
    required this.controller,
    required this.isSearching,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
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
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Buscar y añadir dirección',
          hintText: 'Ej: Calle Mayor 1, Torrelavega',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Color(0xFF1976d2),
          ),
          suffixIcon: isSearching
              ? Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976d2)),
                    ),
                  ),
                )
              : controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, color: Colors.grey),
                      onPressed: onClear,
                    )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

/// Lista de resultados de búsqueda
class SearchResultsList extends StatelessWidget {
  final List<GeocodingResult> results;
  final Function(GeocodingResult) onResultTap;
  final bool isDark;

  const SearchResultsList({
    Key? key,
    required this.results,
    required this.onResultTap,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.travel_explore_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Resultados de búsqueda - Haz clic para añadir',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976d2),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
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
          child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              
              return Container(
                margin: EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onResultTap(result),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.add_circle_outline_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              result.displayName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

/// Título de sección con icono y contador
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int? count;

  const SectionHeader({
    Key? key,
    required this.icon,
    required this.title,
    this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
        SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976d2),
          ),
        ),
        if (count != null) ...[
          SizedBox(width: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF1976d2).withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Mensaje de lista vacía
class EmptyLocalizacionesMessage extends StatelessWidget {
  final bool isDark;

  const EmptyLocalizacionesMessage({
    Key? key,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF1976d2).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                size: 48,
                color: Color(0xFF1976d2).withOpacity(0.5),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'No hay localizaciones añadidas',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
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
        ),
      ),
    );
  }
}

/// Card de localización individual
class LocalizacionCard extends StatelessWidget {
  final Localizacion localizacion;
  final IconData icon;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const LocalizacionCard({
    Key? key,
    required this.localizacion,
    required this.icon,
    required this.isDark,
    required this.onEdit,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: localizacion.esPrincipal 
            ? LinearGradient(
                colors: [
                  Colors.red.withOpacity(0.15),
                  Colors.red.withOpacity(0.08),
                ],
              )
            : null,
        color: localizacion.esPrincipal ? null : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: localizacion.esPrincipal
            ? Colors.red.withOpacity(0.4)
            : Colors.transparent,
          width: localizacion.esPrincipal ? 2 : 1,
        ),
        boxShadow: localizacion.esPrincipal
          ? [
              BoxShadow(
                color: Colors.red.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ]
          : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Icono de la localización
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: localizacion.esPrincipal
                      ? [Colors.red, Colors.red.shade700]
                      : [Color(0xFF1976d2), Color(0xFF1565c0)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: (localizacion.esPrincipal ? Colors.red : Color(0xFF1976d2))
                          .withOpacity(0.3),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              
              // Información de la localización
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            localizacion.nombre,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (localizacion.esPrincipal)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'PRINCIPAL',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (localizacion.direccion != null || localizacion.ciudad != null) ...[
                      SizedBox(height: 4),
                      Text(
                        [
                          if (localizacion.direccion != null) localizacion.direccion,
                          if (localizacion.ciudad != null) localizacion.ciudad,
                        ].join(', '),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Botones de acción
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_rounded, size: 20),
                    color: Color(0xFF1976d2),
                    onPressed: onEdit,
                    tooltip: 'Editar',
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(),
                  ),
                  SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.delete_rounded, size: 20),
                    color: Colors.red,
                    onPressed: onRemove,
                    tooltip: 'Eliminar',
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Divisor decorativo
class DecorativeDivider extends StatelessWidget {
  const DecorativeDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Color(0xFF1976d2).withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
