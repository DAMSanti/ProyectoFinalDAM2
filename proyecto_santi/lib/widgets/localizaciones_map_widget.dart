import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:proyecto_santi/models/localizacion.dart';
import 'package:proyecto_santi/utils/icon_helper.dart';

class LocalizacionesMapWidget extends StatefulWidget {
  final List<Localizacion> localizaciones;
  final Map<int, IconData> iconosLocalizaciones;
  final Function(Localizacion)? onLocalizacionTapped;

  const LocalizacionesMapWidget({
    Key? key,
    required this.localizaciones,
    this.iconosLocalizaciones = const {},
    this.onLocalizacionTapped,
  }) : super(key: key);

  @override
  State<LocalizacionesMapWidget> createState() => _LocalizacionesMapWidgetState();
}

class _LocalizacionesMapWidgetState extends State<LocalizacionesMapWidget> {
  final MapController _mapController = MapController();
  Localizacion? _selectedLocalizacion;

  @override
  void initState() {
    super.initState();
    // Centrar el mapa en la primera localización o en la principal
    if (widget.localizaciones.isNotEmpty) {
      final localizacionInicial = widget.localizaciones.firstWhere(
        (loc) => loc.esPrincipal,
        orElse: () => widget.localizaciones.first,
      );
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (localizacionInicial.latitud != null && localizacionInicial.longitud != null) {
          _mapController.move(
            LatLng(localizacionInicial.latitud!, localizacionInicial.longitud!),
            widget.localizaciones.length == 1 ? 14.0 : 12.0,
          );
        }
      });
    }
  }

  void _onMarkerTapped(Localizacion localizacion) {
    setState(() {
      _selectedLocalizacion = localizacion;
    });
    
    if (localizacion.latitud != null && localizacion.longitud != null) {
      _mapController.move(
        LatLng(localizacion.latitud!, localizacion.longitud!),
        14.0,
      );
    }
    
    if (widget.onLocalizacionTapped != null) {
      widget.onLocalizacionTapped!(localizacion);
    }
  }

  LatLng _calcularCentro() {
    // Coordenadas del IES Miguel Herrero Pereda, Torrelavega
    const defaultLocation = LatLng(43.3506, -4.0462);
    
    if (widget.localizaciones.isEmpty) {
      return defaultLocation;
    }
    
    final localizacionesConCoords = widget.localizaciones
        .where((loc) => loc.latitud != null && loc.longitud != null)
        .toList();
    
    if (localizacionesConCoords.isEmpty) {
      return defaultLocation;
    }
    
    double sumLat = 0;
    double sumLng = 0;
    
    for (var loc in localizacionesConCoords) {
      sumLat += loc.latitud!;
      sumLng += loc.longitud!;
    }
    
    return LatLng(
      sumLat / localizacionesConCoords.length,
      sumLng / localizacionesConCoords.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizacionesConCoords = widget.localizaciones
        .where((loc) => loc.latitud != null && loc.longitud != null)
        .toList();

    // Siempre mostrar el mapa, incluso si no hay localizaciones
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _calcularCentro(),
            zoom: localizacionesConCoords.isEmpty ? 13.0 : (localizacionesConCoords.length == 1 ? 14.0 : 12.0),
            minZoom: 3.0,
            maxZoom: 18.0,
            interactiveFlags: InteractiveFlag.all,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
              userAgentPackageName: 'com.proyecto_santi.app',
            ),
            // Mostrar marcador por defecto o los marcadores de localizaciones
            MarkerLayer(
              markers: localizacionesConCoords.isEmpty 
                ? [
                    // Marcador por defecto en IES Miguel Herrero Pereda
                    Marker(
                      point: LatLng(43.3506, -4.0462),
                      width: 40,
                      height: 50,
                      builder: (ctx) => Column(
                        children: [
                          Icon(
                            Icons.school,
                            color: Color(0xFF1976d2),
                            size: 40,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]
                : localizacionesConCoords.map((localizacion) {
                final isSelected = _selectedLocalizacion?.id == localizacion.id;
                final isPrincipal = localizacion.esPrincipal;
                
                // Obtener el icono desde la base de datos o usar el por defecto
                final IconData icono;
                if (localizacion.icono != null && localizacion.icono!.isNotEmpty) {
                  // Usar el icono guardado en la base de datos
                  icono = IconHelper.getIcon(
                    localizacion.icono,
                    defaultIcon: isPrincipal ? Icons.location_pin : Icons.location_on,
                  );
                } else {
                  // Usar icono personalizado del mapa temporal o el por defecto
                  icono = widget.iconosLocalizaciones[localizacion.id] ?? 
                      (isPrincipal ? Icons.location_pin : Icons.location_on);
                }
                
                // Determinar el color según el estado
                final Color iconColor;
                if (isPrincipal) {
                  iconColor = Colors.red;
                } else if (isSelected) {
                  iconColor = Color(0xFF1976d2);
                } else {
                  iconColor = Colors.orange;
                }
                
                return Marker(
                  point: LatLng(localizacion.latitud!, localizacion.longitud!),
                  width: isSelected ? 50 : 40,
                  height: isSelected ? 60 : 50,
                  builder: (ctx) => GestureDetector(
                    onTap: () => _onMarkerTapped(localizacion),
                    child: Column(
                      children: [
                        // Icono personalizado de marker
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          child: Icon(
                            icono,
                            color: iconColor,
                            size: isSelected ? 50 : 40,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        // Leyenda (solo mostrar si hay localizaciones)
        if (localizacionesConCoords.isNotEmpty)
          Positioned(
            top: 8,
            right: 8,
            child: Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLeyendaItem(Icons.location_pin, Colors.red, 'Principal'),
                  SizedBox(height: 4),
                  _buildLeyendaItem(Icons.location_on, Colors.orange, 'Secundaria'),
                ],
              ),
            ),
          ),
        ),
        // Info card cuando hay selección
        if (_selectedLocalizacion != null)
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Card(
              elevation: 8,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedLocalizacion!.nombre,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() {
                              _selectedLocalizacion = null;
                            });
                          },
                        ),
                      ],
                    ),
                    if (_selectedLocalizacion!.esPrincipal)
                      Chip(
                        label: Text('Principal', style: TextStyle(fontSize: 11)),
                        backgroundColor: Colors.red[100],
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    SizedBox(height: 4),
                    Text(
                      _selectedLocalizacion!.direccionCompleta,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLeyendaItem(IconData icon, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11)),
      ],
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
