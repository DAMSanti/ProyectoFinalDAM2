import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:proyecto_santi/components/appBar.dart';
import 'package:proyecto_santi/components/menu.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/services/api_service.dart';

class MapView extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkTheme;

  const MapView(
      {Key? key, required this.onToggleTheme, required this.isDarkTheme})
      : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late GoogleMapController mapController;
  final ApiService _apiService = ApiService();
  List<Actividad> activities = [];
  final LatLng _center = const LatLng(43.353, -4.064);
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    try {
      final fetchedActivities = await _apiService.fetchActivities();
      setState(() {
        activities = fetchedActivities
            .where((actividad) =>
        actividad.latitud != null && actividad.longitud != null)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching activities: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onToggleTheme: widget.onToggleTheme,
        title: 'Mapa',
      ),
      drawer: Menu(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 10.0,
        ),
        markers: activities.map((actividad) {
          return Marker(
            markerId: MarkerId(actividad.id.toString()),
            position: LatLng(actividad.latitud!, actividad.longitud!),
            infoWindow: InfoWindow(
              title: actividad.titulo,
              snippet: actividad.descripcion,
            ),
          );
        }).toSet(),
      ),
    );
  }
}