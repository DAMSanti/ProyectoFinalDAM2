import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/localizacion.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/utils/icon_helper.dart';
import 'package:proyecto_santi/components/desktop_shell.dart';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MapView extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkTheme;

  const MapView({super.key, required this.onToggleTheme, required this.isDarkTheme});

  @override
  MapViewState createState() => MapViewState();
}

class MapViewState extends State<MapView> with SingleTickerProviderStateMixin {
  late final ApiService _apiService;
  late final ActividadService _actividadService;
  late final LocalizacionService _localizacionService;
  List<Actividad> activities = [];
  List<Actividad> filteredActivities = [];
  Map<int, List<Localizacion>> actividadLocalizaciones = {}; // Map actividadId -> lista de localizaciones
  final LatLng _center = LatLng(43.353, -4.064);
  bool isLoading = true;
  
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Actividad? _selectedActividad;
  bool _showSearchResults = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Modo detalle de actividad
  bool _activityDetailMode = false;
  Actividad? _activityInDetailMode;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _actividadService = ActividadService(_apiService);
    _localizacionService = LocalizacionService(_apiService);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _searchController.addListener(_onSearchChanged);
    _fetchActivities();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _showSearchResults = _searchController.text.isNotEmpty;
      if (_searchController.text.isEmpty) {
        filteredActivities = activities;
      } else {
        final query = _searchController.text.toLowerCase();
        filteredActivities = activities.where((actividad) {
          return actividad.titulo.toLowerCase().contains(query) ||
                 (actividad.descripcion?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  Future<void> _fetchActivities() async {
    try {
      final fetchedActivities = await _actividadService.fetchFutureActivities();
      
      // Cargar localizaciones para cada actividad
      for (var actividad in fetchedActivities) {
        try {
          final localizacionesData = await _localizacionService.fetchLocalizaciones(actividad.id);
          final localizaciones = localizacionesData
              .map((data) => Localizacion.fromJson(data))
              .toList();
          actividadLocalizaciones[actividad.id] = localizaciones;
        } catch (e) {
          print('[MAP] Error cargando localizaciones para actividad ${actividad.id}: $e');
          actividadLocalizaciones[actividad.id] = [];
        }
      }
      
      setState(() {
        // Solo incluir actividades que tienen al menos una localización principal con coordenadas
        activities = fetchedActivities.where((actividad) {
          final localizaciones = actividadLocalizaciones[actividad.id] ?? [];
          return localizaciones.any((loc) => 
            loc.esPrincipal && 
            loc.latitud != null && 
            loc.longitud != null
          );
        }).toList();
        filteredActivities = activities;
        isLoading = false;
      });
    } catch (e) {
      print('[MAP] Error fetching activities: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onMarkerTapped(Actividad actividad) {
    setState(() {
      _selectedActividad = actividad;
      _animationController.forward();
    });
    
    // Centrar el mapa en la localización principal de la actividad seleccionada
    final localizaciones = actividadLocalizaciones[actividad.id] ?? [];
    final locPrincipal = localizaciones.firstWhere(
      (loc) => loc.esPrincipal,
      orElse: () => localizaciones.first,
    );
    
    if (locPrincipal.latitud != null && locPrincipal.longitud != null) {
      _mapController.move(
        LatLng(locPrincipal.latitud!, locPrincipal.longitud!),
        14.0,
      );
    }
  }

  void _onActivitySearchSelected(Actividad actividad) {
    _onMarkerTapped(actividad);
    _searchController.clear();
    setState(() {
      _showSearchResults = false;
    });
    _searchFocusNode.unfocus();
  }

  void _showActivityDetails(Actividad actividad) {
    setState(() {
      _activityDetailMode = true;
      _activityInDetailMode = actividad;
      _selectedActividad = null; // Cerrar el info card
      _animationController.reverse(); // Animar salida del card
    });
    
    // Centrar el mapa en la localización principal
    final localizaciones = actividadLocalizaciones[actividad.id] ?? [];
    if (localizaciones.isNotEmpty) {
      final locPrincipal = localizaciones.firstWhere(
        (loc) => loc.esPrincipal,
        orElse: () => localizaciones.first,
      );
      
      if (locPrincipal.latitud != null && locPrincipal.longitud != null) {
        _mapController.move(
          LatLng(locPrincipal.latitud!, locPrincipal.longitud!),
          13.0,
        );
      }
    }
  }
  
  void _exitDetailMode() {
    setState(() {
      _activityDetailMode = false;
      _activityInDetailMode = null;
      _selectedActividad = null;
    });
    
    // Volver a la vista general del mapa
    _mapController.move(_center, 11.0);
  }
  
  // Construir markers en modo normal (solo localizaciones principales)
  List<Marker> _buildNormalModeMarkers() {
    return activities.expand((actividad) {
      final localizaciones = actividadLocalizaciones[actividad.id] ?? [];
      final locPrincipales = localizaciones.where((loc) => loc.esPrincipal).toList();
      
      return locPrincipales.map((loc) {
        if (loc.latitud == null || loc.longitud == null) return null;
        
        final isSelected = _selectedActividad?.id == actividad.id;
        
        IconData markerIcon = Icons.location_on;
        if (loc.icono != null && loc.icono!.isNotEmpty) {
          markerIcon = IconHelper.getIcon(
            loc.icono!,
            defaultIcon: Icons.location_on,
          );
        }
        
        return Marker(
          point: LatLng(loc.latitud!, loc.longitud!),
          width: isSelected ? 60 : 50,
          height: isSelected ? 60 : 50,
          builder: (ctx) => GestureDetector(
            onTap: () => _onMarkerTapped(actividad),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected)
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1976d2).withOpacity(0.3),
                      ),
                    ),
                  Container(
                    width: isSelected ? 50 : 40,
                    height: isSelected ? 50 : 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isSelected
                            ? [
                                Color(0xFF1976d2),
                                Color(0xFF42A5F5),
                              ]
                            : [
                                Colors.red,
                                Colors.redAccent,
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isSelected ? Color(0xFF1976d2) : Colors.red)
                              .withOpacity(0.6),
                          blurRadius: isSelected ? 20 : 15,
                          offset: Offset(0, 4),
                          spreadRadius: isSelected ? 2 : 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      markerIcon,
                      color: Colors.white,
                      size: isSelected ? 30 : 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).whereType<Marker>().toList();
    }).toList();
  }
  
  // Construir markers en modo detalle (todas las localizaciones de una actividad)
  List<Marker> _buildDetailModeMarkers(Actividad actividad) {
    final localizaciones = actividadLocalizaciones[actividad.id] ?? [];
    
    return localizaciones.map((loc) {
      if (loc.latitud == null || loc.longitud == null) return null;
      
      final isPrincipal = loc.esPrincipal;
      
      IconData markerIcon = Icons.location_on;
      if (loc.icono != null && loc.icono!.isNotEmpty) {
        markerIcon = IconHelper.getIcon(
          loc.icono!,
          defaultIcon: Icons.location_on,
        );
      }
      
      return Marker(
        point: LatLng(loc.latitud!, loc.longitud!),
        width: isPrincipal ? 60 : 50,
        height: isPrincipal ? 60 : 50,
        builder: (ctx) => GestureDetector(
          onTap: () {
            // Mostrar información de la localización
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (loc.descripcion != null && loc.descripcion!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(loc.descripcion!),
                      ),
                    if (loc.direccion != null && loc.direccion!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.white70),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                loc.direccion!,
                                style: TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                backgroundColor: Color(0xFF1976d2),
                duration: Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Efecto especial para localización principal
                if (isPrincipal)
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1976d2).withOpacity(0.2),
                    ),
                  ),
                Container(
                  width: isPrincipal ? 50 : 40,
                  height: isPrincipal ? 50 : 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isPrincipal
                          ? [
                              Color(0xFF1976d2),
                              Color(0xFF42A5F5),
                            ]
                          : [
                              Color(0xFF4CAF50),
                              Color(0xFF81C784),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isPrincipal ? Color(0xFF1976d2) : Color(0xFF4CAF50))
                            .withOpacity(0.6),
                        blurRadius: isPrincipal ? 20 : 15,
                        offset: Offset(0, 4),
                        spreadRadius: isPrincipal ? 2 : 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    markerIcon,
                    color: Colors.white,
                    size: isPrincipal ? 30 : 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).whereType<Marker>().toList();
  }

  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Color.fromRGBO(25, 118, 210, 0.95),
                        Color.fromRGBO(21, 101, 192, 0.95),
                      ]
                    : [
                        Colors.white,
                        Color.fromRGBO(255, 255, 255, 0.95),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF1976d2).withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Color(0xFF1976d2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      color: isDark ? Colors.white : Color(0xFF1976d2),
                      size: !isWeb ? 20.dg : 7.sp,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: !isWeb ? 14.dg : 5.sp,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Buscar actividades...',
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.white.withOpacity(0.5)
                              : Colors.grey[500],
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.red,
                          size: !isWeb ? 18.dg : 6.sp,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _searchFocusNode.unfocus();
                        },
                        tooltip: 'Limpiar búsqueda',
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Resultados de búsqueda
          if (_showSearchResults && filteredActivities.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 8),
              constraints: BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Color.fromRGBO(30, 30, 30, 0.98),
                          Color.fromRGBO(40, 40, 40, 0.98),
                        ]
                      : [
                          Colors.white,
                          Color.fromRGBO(245, 245, 245, 0.98),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemCount: filteredActivities.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                  ),
                  itemBuilder: (context, index) {
                    final actividad = filteredActivities[index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _onActivitySearchSelected(actividad),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF1976d2),
                                      Color(0xFF42A5F5),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF1976d2).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.event_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      actividad.titulo,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: !isWeb ? 13.dg : 4.5.sp,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (actividad.descripcion != null &&
                                        actividad.descripcion!.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(top: 2),
                                        child: Text(
                                          actividad.descripcion!,
                                          style: TextStyle(
                                            fontSize: !isWeb ? 11.dg : 3.8.sp,
                                            color: isDark
                                                ? Colors.white.withOpacity(0.6)
                                                : Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: Color(0xFF1976d2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          if (_showSearchResults && filteredActivities.isEmpty)
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? Color.fromRGBO(30, 30, 30, 0.98)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    color: Colors.grey,
                    size: 32,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No se encontraron actividades',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: !isWeb ? 13.dg : 4.5.sp,
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

  Widget _buildActivityInfoCard() {
    // No mostrar el info card en modo detalle
    if (_activityDetailMode || _selectedActividad == null) return SizedBox.shrink();
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final localizaciones = actividadLocalizaciones[_selectedActividad!.id] ?? [];
    final locPrincipal = localizaciones.firstWhere(
      (loc) => loc.esPrincipal,
      orElse: () => localizaciones.isNotEmpty ? localizaciones.first : Localizacion(
        id: 0,
        nombre: 'Sin nombre',
        direccion: 'Sin dirección',
        esPrincipal: false,
      ),
    );
    
    String direccionCompleta = '';
    bool hasDireccion = false;
    if (locPrincipal.direccion != null && locPrincipal.direccion!.isNotEmpty) {
      direccionCompleta = locPrincipal.direccion!;
      if (locPrincipal.ciudad != null && locPrincipal.ciudad!.isNotEmpty) {
        direccionCompleta += ', ${locPrincipal.ciudad}';
      }
      hasDireccion = true;
    }
    
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Color.fromRGBO(25, 118, 210, 0.95),
                      Color.fromRGBO(21, 101, 192, 0.95),
                    ]
                  : [
                      Colors.white,
                      Color.fromRGBO(255, 255, 255, 0.95),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF1976d2).withOpacity(0.4),
                blurRadius: 30,
                offset: Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Patrón decorativo de fondo
              Positioned(
                right: -30,
                top: -30,
                child: Opacity(
                  opacity: isDark ? 0.05 : 0.03,
                  child: Icon(
                    Icons.event_rounded,
                    size: 150,
                    color: Color(0xFF1976d2),
                  ),
                ),
              ),
              // Contenido
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header con título y botón cerrar
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF1976d2),
                                Color(0xFF42A5F5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF1976d2).withOpacity(0.4),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.event_rounded,
                            color: Colors.white,
                            size: !isWeb ? 24.dg : 8.sp,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedActividad!.titulo,
                                style: TextStyle(
                                  fontSize: !isWeb ? 16.dg : 5.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Color(0xFF4CAF50).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Color(0xFF4CAF50),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Localización Principal',
                                  style: TextStyle(
                                    fontSize: !isWeb ? 10.dg : 3.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: isDark ? Colors.white : Colors.black87,
                              size: !isWeb ? 20.dg : 7.sp,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedActividad = null;
                                _animationController.reverse();
                              });
                            },
                            tooltip: 'Cerrar',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Divider con gradiente
                    Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1976d2),
                            Color(0xFF42A5F5),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Dirección (solo si existe)
                    if (hasDireccion)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: !isWeb ? 18.dg : 6.sp,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                direccionCompleta,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.grey[700],
                                  fontSize: !isWeb ? 12.dg : 4.sp,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Descripción de la actividad
                    if (_selectedActividad!.descripcion != null &&
                        _selectedActividad!.descripcion!.isNotEmpty) ...[
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: !isWeb ? 18.dg : 6.sp,
                              color: Color(0xFF1976d2),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedActividad!.descripcion!,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.grey[700],
                                  fontSize: !isWeb ? 12.dg : 4.sp,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 16),
                    // Botón ver detalles
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF1976d2),
                              Color(0xFF42A5F5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF1976d2).withOpacity(0.4),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _showActivityDetails(_selectedActividad!),
                          icon: Icon(
                            Icons.visibility_rounded,
                            size: !isWeb ? 18.dg : 6.sp,
                          ),
                          label: Text(
                            'Ver Detalles',
                            style: TextStyle(
                              fontSize: !isWeb ? 14.dg : 5.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildDetailModeBanner() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    return Positioned(
      top: 90, // Debajo de la barra de búsqueda
      left: 16,
      right: 16,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1976d2),
              Color(0xFF42A5F5),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF1976d2).withOpacity(0.5),
              blurRadius: 20,
              offset: Offset(0, 4),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icono de información
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: Colors.white,
                size: !isWeb ? 24.dg : 8.sp,
              ),
            ),
            SizedBox(width: 12),
            // Texto informativo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Viendo localizaciones de:',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: !isWeb ? 11.dg : 3.8.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    _activityInDetailMode!.titulo,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: !isWeb ? 14.dg : 5.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF1976d2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Principal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: !isWeb ? 10.dg : 3.5.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Secundaria',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: !isWeb ? 10.dg : 3.5.sp,
                                fontWeight: FontWeight.w600,
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
            SizedBox(width: 12),
            // Botón para ir a detalles completos de la actividad
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (_activityInDetailMode != null) {
                      // Guardar referencia a la actividad antes de salir del modo detalle
                      final activityToNavigate = _activityInDetailMode;
                      // Salir del modo detalle ANTES de navegar
                      _exitDetailMode();
                      // Navegar a los detalles de la actividad usando la función helper
                      navigateToActivityDetailInShell(context, {
                        'activity': activityToNavigate,
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.white,
                          size: !isWeb ? 24.dg : 8.sp,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Info',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: !isWeb ? 10.dg : 3.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            // Botón de cerrar/volver
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _exitDetailMode,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: !isWeb ? 24.dg : 8.sp,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Volver',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: !isWeb ? 10.dg : 3.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return false;
      },
      child: Scaffold(
        backgroundColor: isDark ? Color(0xFF121212) : Colors.grey[100],
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
          child: SafeArea(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF1976d2),
                                Color(0xFF42A5F5),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF1976d2).withOpacity(0.4),
                                blurRadius: 20,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(height: 24),
                        Text(
                          'Cargando mapa de actividades...',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      // Mapa
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          center: _center,
                          zoom: 10.0,
                          minZoom: 3.0,
                          maxZoom: 18.0,
                          interactiveFlags: InteractiveFlag.all,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: isDark
                                ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                                : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: ['a', 'b', 'c'],
                            userAgentPackageName: 'com.proyecto_santi.app',
                          ),
                          MarkerLayer(
                            markers: _activityDetailMode && _activityInDetailMode != null
                                ? // MODO DETALLE: Mostrar TODAS las localizaciones de la actividad seleccionada
                                  _buildDetailModeMarkers(_activityInDetailMode!)
                                : // MODO NORMAL: Mostrar solo localizaciones principales de todas las actividades
                                  _buildNormalModeMarkers(),
                          ),
                        ],
                      ),
                      // Barra de búsqueda
                      _buildSearchBar(),
                      // Banner de modo detalle (cuando estamos viendo una actividad específica)
                      if (_activityDetailMode && _activityInDetailMode != null)
                        _buildDetailModeBanner(),
                      // Info card de actividad seleccionada
                      _buildActivityInfoCard(),
                      // Botón centrar mapa
                      Positioned(
                        bottom: _selectedActividad != null ? 240 : 24,
                        right: 16,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF1976d2),
                                Color(0xFF42A5F5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF1976d2).withOpacity(0.4),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                _mapController.move(_center, 10.0);
                                setState(() {
                                  _selectedActividad = null;
                                  _animationController.reverse();
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Icon(
                                  Icons.my_location_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
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