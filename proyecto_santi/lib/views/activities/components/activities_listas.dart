import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/theme.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/services/api_service.dart';

class AllActividades extends StatefulWidget {
  final String? selectedFilter;
  final String searchQuery;
  final int? selectedDate;
  final String? selectedCourse;
  final String? selectedState;

  AllActividades({
    required this.selectedFilter,
    required this.searchQuery,
    required this.selectedDate,
    required this.selectedCourse,
    required this.selectedState,
  });

  @override
  AllActividadesState createState() => AllActividadesState();
}

class AllActividadesState extends State<AllActividades> {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Actividad>>(
      future: _apiService.fetchActivities(), // Use your API service here
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay actividades disponibles'));
        } else {
          var actividades = snapshot.data!;
          return ListView.builder(
            itemCount: actividades.length,
            itemBuilder: (context, index) {
              var actividad = actividades[index];
              return HoverableListItem(actividad: actividad);
            },
          );
        }
      },
    );
  }
}

class OtrasActividades extends StatefulWidget {
  final String? selectedFilter;
  final String searchQuery;
  final int? selectedDate;
  final String? selectedCourse;
  final String? selectedState;

  OtrasActividades({
    required this.selectedFilter,
    required this.searchQuery,
    required this.selectedDate,
    required this.selectedCourse,
    required this.selectedState,
  });

  @override
  OtrasActividadesState createState() => OtrasActividadesState();
}

class OtrasActividadesState extends State<OtrasActividades> {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Actividad>>(
      future: _apiService.fetchFutureActivities(), // Use your API service here
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay actividades disponibles'));
        } else {
          var actividades = snapshot.data!;
          return ListView.builder(
            itemCount: actividades.length,
            itemBuilder: (context, index) {
              var actividad = actividades[index];
              return HoverableListItem(actividad: actividad);
            },
          );
        }
      },
    );
  }
}

class HoverableListItem extends StatefulWidget {
  final Actividad actividad;

  HoverableListItem({required this.actividad});

  @override
  HoverableListItemState createState() => HoverableListItemState();
}

class HoverableListItemState extends State<HoverableListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? lightTheme.primaryColor
                : darkTheme.primaryColor,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(4, 4),
                blurRadius: 10.0,
                spreadRadius: 1.0,
                blurStyle: BlurStyle.inner,
              ),
            ],
          ),
          child: ListTile(
            title: Text(
              widget.actividad.titulo,
              style: TextStyle(
                color: _isHovered ? Colors.blue : Colors.black,
                fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              widget.actividad.descripcion ?? 'Sin descripción',
              style: TextStyle(
                color: _isHovered ? Colors.blueGrey : Colors.grey,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/activityDetail',
                arguments: {'activityId': widget.actividad.id},
              );
            },
          ),
        ),
      ),
    );
  }
}
