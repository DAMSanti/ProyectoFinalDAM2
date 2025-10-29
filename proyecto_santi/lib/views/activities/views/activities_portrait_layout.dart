import 'package:flutter/material.dart';
import 'package:proyecto_santi/components/menu.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import 'package:proyecto_santi/views/activities/components/activities_listas.dart';
import 'package:proyecto_santi/views/activities/components/activities_search_bar.dart';
import 'package:proyecto_santi/views/activities/components/activities_section_header.dart';
import 'package:proyecto_santi/views/activities/components/activities_list_container.dart';

class ActivitiesPortraitLayout extends StatefulWidget {
  final List<Actividad> activities;
  final VoidCallback onToggleTheme;

  const ActivitiesPortraitLayout({
    super.key,
    required this.activities,
    required this.onToggleTheme,
  });

  @override
  _ActivitiesPortraitLayoutState createState() => _ActivitiesPortraitLayoutState();
}

class _ActivitiesPortraitLayoutState extends State<ActivitiesPortraitLayout> {
  String searchQuery = '';
  Map<String, dynamic> filters = {
    'fecha': null,
    'estado': null,
    'curso': null,
  };
  int _allActivitiesCount = 0;
  int _userActivitiesCount = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return false;
      },
      child: Stack(
        children: [
          Theme.of(context).brightness == Brightness.dark
              ? GradientBackgroundDark(child: Container())
              : GradientBackgroundLight(child: Container()),
          Scaffold(
            backgroundColor: Colors.transparent,
            drawer: OrientationBuilder(
              builder: (context, orientation) {
                return orientation == Orientation.portrait
                    ? Menu()
                    : MenuLandscape();
              },
            ),
            body: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 8),
                  
                  // Barra de búsqueda moderna
                  ActivitiesSearchBar(
                    onSearchQueryChanged: (query) {
                      setState(() {
                        searchQuery = query;
                      });
                    },
                    filters: filters,
                    onFiltersChanged: (newFilters) {
                      setState(() {
                        filters = newFilters;
                      });
                    },
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Sección: Todas las actividades
                  ActivitiesSectionHeader(
                    title: 'Todas las Actividades',
                    icon: Icons.grid_view_rounded,
                    count: _allActivitiesCount,
                  ),
                  
                  Expanded(
                    child: ActivitiesListContainer(
                      child: AllActividades(
                        selectedFilter: null,
                        searchQuery: searchQuery,
                        selectedDate: filters['fecha'],
                        selectedCourse: filters['curso'],
                        selectedState: filters['estado'],
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
                  
                  SizedBox(height: 8),
                  
                  // Sección: Tus actividades
                  ActivitiesSectionHeader(
                    title: 'Tus Actividades',
                    icon: Icons.person_rounded,
                    count: _userActivitiesCount,
                  ),
                  
                  Expanded(
                    child: ActivitiesListContainer(
                      child: OtrasActividades(
                        selectedFilter: null,
                        searchQuery: searchQuery,
                        selectedDate: filters['fecha'],
                        selectedCourse: filters['curso'],
                        selectedState: filters['estado'],
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
                  
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}