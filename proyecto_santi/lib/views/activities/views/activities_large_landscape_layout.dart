import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import 'package:proyecto_santi/views/activities/components/activities_listas.dart';
import 'package:proyecto_santi/views/activities/components/activities_search_bar.dart';
import 'package:proyecto_santi/views/activities/components/activities_section_header.dart';
import 'package:proyecto_santi/views/activities/components/activities_list_container.dart';

class ActivitiesLargeLandscapeLayout extends StatefulWidget {
  final List<Actividad> activities;
  final VoidCallback onToggleTheme;

  const ActivitiesLargeLandscapeLayout({super.key, required this.activities, required this.onToggleTheme});

  @override
  State<ActivitiesLargeLandscapeLayout> createState() => _ActivitiesLargeLandscapeLayoutState();
}

class _ActivitiesLargeLandscapeLayoutState extends State<ActivitiesLargeLandscapeLayout> {
  String searchQuery = '';
  Map<String, dynamic> filters = {
    'fecha': null,
    'estado': null,
    'curso': null,
    'profesorId': null,
  };
  final ValueNotifier<List<Actividad>> _filteredActivitiesNotifier = ValueNotifier([]);
  int _allActivitiesCount = 0;
  int _userActivitiesCount = 0;

  @override
  void initState() {
    super.initState();
    _filterActivities();
  }

  void _filterActivities() {
    _filteredActivitiesNotifier.value = widget.activities.where((actividad) {
      // Filtro por búsqueda de texto
      final matchesSearch = actividad.titulo.toLowerCase().contains(searchQuery.toLowerCase());
      
      // Aquí puedes agregar más lógica de filtrado basada en filters
      // Por ahora solo filtramos por texto
      
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacementNamed(context, '/home');
          return false;
        },
        child: Stack(
          children: [
            Theme.of(context).brightness == Brightness.dark
                ? GradientBackgroundDark(child: Container())
                : GradientBackgroundLight(child: Container()),
            // Ya no usar Scaffold ni MarcoDesktop, solo el contenido
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Barra de búsqueda moderna
                  ActivitiesSearchBar(
                    onSearchQueryChanged: (query) {
                      setState(() {
                        searchQuery = query;
                        _filterActivities();
                      });
                    },
                    filters: filters,
                    onFiltersChanged: (newFilters) {
                      setState(() {
                        filters = newFilters;
                        _filterActivities();
                      });
                    },
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Sección: Todas las actividades
                  ActivitiesSectionHeader(
                    title: 'Todas las Actividades',
                    icon: Icons.grid_view_rounded,
                    count: _allActivitiesCount,
                  ),
                  
                  Flexible(
                    flex: 2,
                    child: ActivitiesListContainer(
                      child: AllActividades(
                        selectedFilter: null,
                        searchQuery: searchQuery,
                        selectedDate: filters['fecha'],
                        selectedCourse: filters['curso'],
                        selectedState: filters['estado'],
                        selectedProfesorId: filters['profesorId'],
                        onCountChanged: (count) {
                          if (mounted) {
                            setState(() {
                              _allActivitiesCount = count;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Sección: Tus actividades
                  ActivitiesSectionHeader(
                    title: 'Tus Actividades',
                    icon: Icons.person_rounded,
                    count: _userActivitiesCount,
                  ),
                  
                  Flexible(
                    flex: 1,
                    child: ActivitiesListContainer(
                      child: OtrasActividades(
                        selectedFilter: null,
                        searchQuery: searchQuery,
                        selectedDate: filters['fecha'],
                        selectedCourse: filters['curso'],
                        selectedState: filters['estado'],
                        selectedProfesorId: filters['profesorId'],
                        onCountChanged: (count) {
                          if (mounted) {
                            setState(() {
                              _userActivitiesCount = count;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}