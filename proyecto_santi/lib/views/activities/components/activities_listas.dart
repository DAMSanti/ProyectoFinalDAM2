import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/theme.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/components/desktop_shell.dart';

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
  List<Actividad> _allActividades = [];
  List<Actividad> _filteredActividades = [];

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  void _fetchActivities() async {
    List<Actividad> actividades = await _apiService.fetchActivities();
    setState(() {
      _allActividades = actividades;
      _filterActivities();
    });
  }

  void _filterActivities() {
    setState(() {
      _filteredActividades = _allActividades.where((actividad) {
        return actividad.titulo.toLowerCase().contains(widget.searchQuery.toLowerCase());
      }).toList();
    });
  }

  @override
  void didUpdateWidget(AllActividades oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _filterActivities();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _filteredActividades.isEmpty
        ? Center(child: Text('No hay actividades disponibles'))
        : ListView.builder(
      itemCount: _filteredActividades.length,
      itemBuilder: (context, index) {
        var actividad = _filteredActividades[index];
        return HoverableListItem(actividad: actividad);
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
  List<Actividad> _otrasActividades = [];
  List<Actividad> _filteredOtrasActividades = [];

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  void _fetchActivities() async {
    List<Actividad> actividades = await _apiService.fetchActivities();
    setState(() {
      _otrasActividades = actividades;
      _filterActivities();
    });
  }

  void _filterActivities() {
    setState(() {
      _filteredOtrasActividades = _otrasActividades.where((actividad) {
        return actividad.titulo.toLowerCase().contains(widget.searchQuery.toLowerCase());
      }).toList();
    });
  }

  @override
  void didUpdateWidget(OtrasActividades oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _filterActivities();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _filteredOtrasActividades.isEmpty
        ? Center(child: Text('No hay actividades disponibles'))
        : ListView.builder(
      itemCount: _filteredOtrasActividades.length,
      itemBuilder: (context, index) {
        var actividad = _filteredOtrasActividades[index];
        return HoverableListItem(actividad: actividad);
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
                color: _isHovered ? Colors.blue : Theme.of(context).brightness == Brightness.light ? lightTheme.textTheme.labelMedium?.color
                    : darkTheme.textTheme.labelMedium?.color,
                fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.actividad.descripcion ?? 'Sin descripción',
                  style: TextStyle(
                    color: _isHovered ? Colors.blueGrey : Theme.of(context).brightness == Brightness.light ? lightTheme.textTheme.labelMedium?.color
                        : darkTheme.textTheme.labelMedium?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                SizedBox(height: 6.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.actividad.fini,
                      style: TextStyle(
                        color: _isHovered ? Colors.blueGrey : Theme.of(context).brightness == Brightness.light ? lightTheme.textTheme.labelMedium?.color
                            : darkTheme.textTheme.labelMedium?.color,
                      ),
                    ),
                    Text(
                      widget.actividad.estado,
                      style: TextStyle(
                        color: _isHovered ? Colors.blueGrey : Theme.of(context).brightness == Brightness.light ? lightTheme.textTheme.labelMedium?.color
                            : darkTheme.textTheme.labelMedium?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () {
              // Usar la navegación del shell para mantener el menú
              navigateToActivityDetailInShell(
                context,
                {'activity': widget.actividad},
              );
            },
          ),
        ),
      ),
    );
  }
}