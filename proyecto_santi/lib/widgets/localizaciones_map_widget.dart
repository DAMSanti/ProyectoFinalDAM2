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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizacionesConCoords = widget.localizaciones
        .where((loc) => loc.latitud != null && loc.longitud != null)
        .toList();

    // Si no hay localizaciones, mostrar mensaje sobre el mapa
    if (localizacionesConCoords.isEmpty) {
      return Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _calcularCentro(),
              zoom: 13.0,
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
              MarkerLayer(markers: []), // Sin marcadores
            ],
          ),
          // Mensaje de no hay localizaciones
          Center(
            child: Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                    ? [
                        Color.fromRGBO(25, 118, 210, 0.95),
                        Color.fromRGBO(21, 101, 192, 0.90),
                      ]
                    : [
                        Color.fromRGBO(187, 222, 251, 0.95),
                        Color.fromRGBO(144, 202, 249, 0.90),
                      ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark 
                    ? Color.fromRGBO(255, 255, 255, 0.2) 
                    : Color.fromRGBO(0, 0, 0, 0.1),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1976d2).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_off_rounded,
                      size: 48,
                      color: isDark ? Colors.white : Color(0xFF1976d2),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay localizaciones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Color(0xFF1976d2),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Esta actividad aún no tiene\nlocalizaciones asignadas',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Si hay localizaciones, mostrar el mapa con marcadores
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _calcularCentro(),
            zoom: localizacionesConCoords.length == 1 ? 14.0 : 12.0,
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
            // Mostrar marcadores de localizaciones
            MarkerLayer(
              markers: localizacionesConCoords.map((localizacion) {
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
        // Leyenda
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
        // Info card cuando hay selección - Diseño moderno
        if (_selectedLocalizacion != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildLocalizacionInfoCard(_selectedLocalizacion!),
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

  Widget _buildLocalizacionInfoCard(Localizacion localizacion) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determinar icono y color según el tipo
    IconData tipoIcono;
    Color tipoColor;
    String tipoTexto = localizacion.tipoLocalizacion ?? 'Sin especificar';
    
    switch (localizacion.tipoLocalizacion) {
      case 'Punto de salida':
        tipoIcono = Icons.location_on_rounded;
        tipoColor = Color(0xFF4CAF50);
        break;
      case 'Punto de llegada':
        tipoIcono = Icons.flag_rounded;
        tipoColor = Color(0xFFF44336);
        break;
      case 'Alojamiento':
        tipoIcono = Icons.hotel_rounded;
        tipoColor = Color(0xFF9C27B0);
        break;
      case 'Actividad':
        tipoIcono = Icons.local_activity_rounded;
        tipoColor = Color(0xFF2196F3);
        break;
      default:
        tipoIcono = Icons.place_rounded;
        tipoColor = Color(0xFF757575);
    }
    
    return Container(
      constraints: BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
            ? const [
                Color.fromRGBO(25, 118, 210, 0.30),
                Color.fromRGBO(21, 101, 192, 0.25),
              ]
            : const [
                Color.fromRGBO(187, 222, 251, 0.95),
                Color.fromRGBO(144, 202, 249, 0.90),
              ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
            ? const Color.fromRGBO(255, 255, 255, 0.15) 
            : const Color.fromRGBO(0, 0, 0, 0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1976d2).withOpacity(0.3),
            offset: Offset(0, 8),
            blurRadius: 24,
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, 4),
            blurRadius: 12,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Patrón decorativo de fondo
          Positioned(
            right: -15,
            top: -15,
            child: Opacity(
              opacity: isDark ? 0.04 : 0.03,
              child: Icon(
                Icons.map_rounded,
                size: 100,
                color: Color(0xFF1976d2),
              ),
            ),
          ),
          // Contenido
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con nombre y botón cerrar
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icono del tipo de localización
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            tipoColor,
                            tipoColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: tipoColor.withOpacity(0.4),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        tipoIcono,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    // Nombre y badges
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizacion.nombre,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Color(0xFF1976d2),
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6),
                          // Badges de tipo y principal
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              // Badge del tipo
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      tipoColor.withOpacity(0.2),
                                      tipoColor.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: tipoColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      tipoIcono,
                                      size: 14,
                                      color: tipoColor,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      tipoTexto,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? tipoColor.withOpacity(0.9) : tipoColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Badge de principal si aplica
                              if (localizacion.esPrincipal)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.red.withOpacity(0.2),
                                        Colors.red.withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        size: 14,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'PRINCIPAL',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.red.withOpacity(0.9) : Colors.red,
                                          letterSpacing: 0.5,
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
                    // Botón cerrar
                    Container(
                      decoration: BoxDecoration(
                        color: isDark 
                          ? Colors.white.withOpacity(0.1) 
                          : Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: isDark ? Colors.white70 : Color(0xFF1976d2),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedLocalizacion = null;
                          });
                        },
                        tooltip: 'Cerrar',
                        padding: EdgeInsets.all(8),
                        constraints: BoxConstraints(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                
                // Divider decorativo
                Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        (isDark ? Colors.white : Color(0xFF1976d2)).withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12),
                
                // Dirección
                if (localizacion.direccionCompleta.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark 
                        ? Colors.white.withOpacity(0.05) 
                        : Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark 
                          ? Colors.white.withOpacity(0.1) 
                          : Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF1976d2).withOpacity(0.2),
                                Color(0xFF1976d2).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.place_rounded,
                            size: 16,
                            color: Color(0xFF1976d2),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            localizacion.direccionCompleta,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black87,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Descripción/Comentario
                if (localizacion.descripcion != null && localizacion.descripcion!.isNotEmpty) ...[
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                          ? [
                              Color(0xFF1976d2).withOpacity(0.15),
                              Color(0xFF1976d2).withOpacity(0.08),
                            ]
                          : [
                              Colors.white.withOpacity(0.8),
                              Colors.white.withOpacity(0.6),
                            ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color(0xFF1976d2).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Color(0xFF1976d2).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.description_rounded,
                                size: 14,
                                color: Color(0xFF1976d2),
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Descripción',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Color(0xFF1976d2),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          localizacion.descripcion!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white.withOpacity(0.85) : Colors.black87,
                            height: 1.4,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
