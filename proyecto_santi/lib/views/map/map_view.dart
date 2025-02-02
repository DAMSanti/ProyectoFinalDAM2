import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:proyecto_santi/components/appBar.dart';
import 'package:proyecto_santi/components/menu.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'dart:io' show Platform;

class MapView extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkTheme;

  const MapView({Key? key, required this.onToggleTheme, required this.isDarkTheme}) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final ApiService _apiService = ApiService();
  List<Actividad> activities = [];
  final latlong.LatLng _center = latlong.LatLng(43.353, -4.064);
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
        activities = fetchedActivities.where((actividad) => actividad.latitud != null && actividad.longitud != null).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching activities: $e');
      setState(() {
        isLoading = false;
      });
    }
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
          : Platform.isWindows
          ? FlutterMap(
        options: MapOptions(
          center: _center,
          zoom: 10.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: activities.map((actividad) {
              return Marker(
                point: latlong.LatLng(actividad.latitud!, actividad.longitud!),
                builder: (ctx) => Container(
                  child: Icon(Icons.location_on, color: Colors.red),
                ),
              );
            }).toList(),
          ),
        ],
      )
          : google_maps.GoogleMap(
        initialCameraPosition: google_maps.CameraPosition(
          target: google_maps.LatLng(43.353, -4.064),
          zoom: 10,
        ),
        markers: activities.map((actividad) {
          return google_maps.Marker(
            markerId: google_maps.MarkerId(actividad.id.toString()),
            position: google_maps.LatLng(actividad.latitud!, actividad.longitud!),
            infoWindow: google_maps.InfoWindow(
              title: actividad.titulo,
              snippet: actividad.descripcion,
            ),
          );
        }).toSet(),
      ),
    );
  }
}