import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:proyecto_santi/components/app_bar.dart';
import 'package:proyecto_santi/components/menu.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/services/services.dart';

class MapView extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkTheme;

  const MapView({super.key, required this.onToggleTheme, required this.isDarkTheme});

  @override
  MapViewState createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  late final ApiService _apiService;
  late final ActividadService _actividadService;
  List<Actividad> activities = [];
  final LatLng _center = LatLng(43.353, -4.064);
  bool isLoading = true;
  
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  Actividad? _selectedActividad;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _actividadService = ActividadService(_apiService);
    _fetchActivities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchActivities() async {
    try {
      final fetchedActivities = await _actividadService.fetchFutureActivities();
      setState(() {
        // Filtrar actividades que tienen localización con coordenadas
        activities = fetchedActivities.where((actividad) => 
          actividad.localizacion != null && 
          actividad.localizacion!.latitud != null && 
          actividad.localizacion!.longitud != null
        ).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching activities: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        _mapController.move(
          LatLng(location.latitude, location.longitude),
          13.0,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ubicación encontrada'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo encontrar la ubicación'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onMarkerTapped(Actividad actividad) {
    setState(() {
      _selectedActividad = actividad;
    });
    
    // Centrar el mapa en la actividad seleccionada
    _mapController.move(
      LatLng(
        actividad.localizacion!.latitud!, 
        actividad.localizacion!.longitud!
      ),
      14.0,
    );
  }

  void _showActivityDetails(Actividad actividad) {
    Navigator.pushNamed(
      context,
      '/activity/details',
      arguments: actividad,
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey[600]),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar dirección, ciudad, código postal...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: _searchLocation,
                ),
              ),
              IconButton(
                icon: Icon(Icons.clear, color: Colors.grey[600]),
                onPressed: () {
                  _searchController.clear();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityInfoCard() {
    if (_selectedActividad == null) return SizedBox.shrink();
    
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedActividad!.titulo,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _selectedActividad = null;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              if (_selectedActividad!.localizacion != null)
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _selectedActividad!.localizacion!.direccionCompleta,
                        style: TextStyle(color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              if (_selectedActividad!.descripcion != null && _selectedActividad!.descripcion!.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  _selectedActividad!.descripcion!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showActivityDetails(_selectedActividad!),
                  icon: Icon(Icons.visibility),
                  label: Text('Ver Detalles'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1976d2),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return false;
      },
      child: Scaffold(
        appBar: AndroidAppBar(
          onToggleTheme: widget.onToggleTheme,
          title: 'Mapa de Actividades',
        ),
        drawer: Menu(),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Stack(
                children: [
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
                        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: ['a', 'b', 'c'],
                        userAgentPackageName: 'com.proyecto_santi.app',
                      ),
                      MarkerLayer(
                        markers: activities.map((actividad) {
                          final isSelected = _selectedActividad?.id == actividad.id;
                          return Marker(
                            point: LatLng(
                              actividad.localizacion!.latitud!, 
                              actividad.localizacion!.longitud!
                            ),
                            width: isSelected ? 50 : 40,
                            height: isSelected ? 50 : 40,
                            builder: (ctx) => GestureDetector(
                              onTap: () => _onMarkerTapped(actividad),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.location_on,
                                  color: isSelected ? Color(0xFF1976d2) : Colors.red,
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
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  _buildSearchBar(),
                  _buildActivityInfoCard(),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _mapController.move(_center, 10.0);
            setState(() {
              _selectedActividad = null;
            });
          },
          backgroundColor: Color(0xFF1976d2),
          child: Icon(Icons.my_location, color: Colors.white),
          tooltip: 'Volver al centro',
        ),
      ),
    );
  }
}