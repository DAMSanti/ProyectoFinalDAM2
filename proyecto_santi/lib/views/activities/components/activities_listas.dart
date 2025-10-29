import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:proyecto_santi/tema/theme.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/components/desktop_shell.dart';

class AllActividades extends StatefulWidget {
  final String? selectedFilter;
  final String searchQuery;
  final DateTime? selectedDate;
  final String? selectedCourse;
  final String? selectedState;
  final Function(int)? onCountChanged;

  AllActividades({
    required this.selectedFilter,
    required this.searchQuery,
    required this.selectedDate,
    required this.selectedCourse,
    required this.selectedState,
    this.onCountChanged,
  });

  @override
  AllActividadesState createState() => AllActividadesState();
}

class AllActividadesState extends State<AllActividades> {
  late final ApiService _apiService;
  late final ActividadService _actividadService;
  List<Actividad> _allActividades = [];
  List<Actividad> _filteredActividades = [];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _actividadService = ActividadService(_apiService);
    _fetchActivities();
  }

  void _fetchActivities() async {
    List<Actividad> actividades = await _actividadService.fetchActivities();
    setState(() {
      _allActividades = actividades;
      _filterActivities();
    });
  }

  void _filterActivities() {
    setState(() {
      _filteredActividades = _allActividades.where((actividad) {
        // Filtro por texto de búsqueda
        final matchesSearch = actividad.titulo.toLowerCase().contains(widget.searchQuery.toLowerCase());
        
        // Filtro por fecha (si está seleccionada)
        bool matchesDate = true;
        if (widget.selectedDate != null) {
          try {
            // Parsear la fecha de inicio (formato esperado: "yyyy-MM-dd")
            final actividadFecha = DateTime.parse(actividad.fini);
            matchesDate = actividadFecha.year == widget.selectedDate!.year &&
                         actividadFecha.month == widget.selectedDate!.month &&
                         actividadFecha.day == widget.selectedDate!.day;
          } catch (e) {
            matchesDate = false;
          }
        }
        
        // Filtro por estado (si está seleccionado)
        bool matchesState = true;
        if (widget.selectedState != null && widget.selectedState!.isNotEmpty) {
          matchesState = actividad.estado.toLowerCase() == widget.selectedState!.toLowerCase();
        }
        
        // Filtro por curso (si está seleccionado)
        bool matchesCourse = true;
        if (widget.selectedCourse != null && widget.selectedCourse!.isNotEmpty) {
          // Aquí deberías implementar la lógica según cómo se relacionan las actividades con los cursos
          // Por ahora, asumimos que se puede verificar en grupos participantes
          matchesCourse = true; // Implementar según tu modelo de datos
        }
        
        return matchesSearch && matchesDate && matchesState && matchesCourse;
      }).toList();
    });
    
    // Notificar el cambio de contador después del build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.onCountChanged?.call(_filteredActividades.length);
    });
  }

  @override
  void didUpdateWidget(AllActividades oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.selectedState != widget.selectedState ||
        oldWidget.selectedCourse != widget.selectedCourse) {
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
  final DateTime? selectedDate;
  final String? selectedCourse;
  final String? selectedState;
  final Function(int)? onCountChanged;

  OtrasActividades({
    required this.selectedFilter,
    required this.searchQuery,
    required this.selectedDate,
    required this.selectedCourse,
    required this.selectedState,
    this.onCountChanged,
  });

  @override
  OtrasActividadesState createState() => OtrasActividadesState();
}

class OtrasActividadesState extends State<OtrasActividades> {
  late final ApiService _apiService;
  late final ActividadService _actividadService;
  List<Actividad> _otrasActividades = [];
  List<Actividad> _filteredOtrasActividades = [];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _actividadService = ActividadService(_apiService);
    _fetchActivities();
  }

  void _fetchActivities() async {
    List<Actividad> actividades = await _actividadService.fetchActivities();
    setState(() {
      _otrasActividades = actividades;
      _filterActivities();
    });
  }

  void _filterActivities() {
    setState(() {
      _filteredOtrasActividades = _otrasActividades.where((actividad) {
        // Filtro por texto de búsqueda
        final matchesSearch = actividad.titulo.toLowerCase().contains(widget.searchQuery.toLowerCase());
        
        // Filtro por fecha (si está seleccionada)
        bool matchesDate = true;
        if (widget.selectedDate != null) {
          try {
            // Parsear la fecha de inicio (formato esperado: "yyyy-MM-dd")
            final actividadFecha = DateTime.parse(actividad.fini);
            matchesDate = actividadFecha.year == widget.selectedDate!.year &&
                         actividadFecha.month == widget.selectedDate!.month &&
                         actividadFecha.day == widget.selectedDate!.day;
          } catch (e) {
            matchesDate = false;
          }
        }
        
        // Filtro por estado (si está seleccionado)
        bool matchesState = true;
        if (widget.selectedState != null && widget.selectedState!.isNotEmpty) {
          matchesState = actividad.estado.toLowerCase() == widget.selectedState!.toLowerCase();
        }
        
        // Filtro por curso (si está seleccionado)
        bool matchesCourse = true;
        if (widget.selectedCourse != null && widget.selectedCourse!.isNotEmpty) {
          // Aquí deberías implementar la lógica según cómo se relacionan las actividades con los cursos
          // Por ahora, asumimos que se puede verificar en grupos participantes
          matchesCourse = true; // Implementar según tu modelo de datos
        }
        
        return matchesSearch && matchesDate && matchesState && matchesCourse;
      }).toList();
    });
    
    // Notificar el cambio de contador después del build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.onCountChanged?.call(_filteredOtrasActividades.length);
    });
  }

  @override
  void didUpdateWidget(OtrasActividades oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.selectedState != widget.selectedState ||
        oldWidget.selectedCourse != widget.selectedCourse) {
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