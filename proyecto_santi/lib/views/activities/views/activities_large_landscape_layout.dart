import 'package:flutter/material.dart';
import 'package:proyecto_santi/components/marco_desktop.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import 'package:proyecto_santi/views/activities/components/activities_listas.dart';
import 'package:proyecto_santi/views/activities/components/activities_busqueda.dart';

class ActivitiesLargeLandscapeLayout extends StatefulWidget {
  final List<Actividad> activities;
  final VoidCallback onToggleTheme;

  const ActivitiesLargeLandscapeLayout({super.key, required this.activities, required this.onToggleTheme});

  @override
  State<ActivitiesLargeLandscapeLayout> createState() => _ActivitiesLargeLandscapeLayout();
}

class _ActivitiesLargeLandscapeLayout extends State<ActivitiesLargeLandscapeLayout> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
              ? GradientBackgroundDark(
            child: Container(),
          )
              : GradientBackgroundLight(
            child: Container(),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: MarcoDesktop(
              onToggleTheme: widget.onToggleTheme,
              content: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Busqueda(
                      onSearchQueryChanged: (query) {
                        // Handle search query change
                      },
                      onFilterSelected: (filter, date, course, state) {
                        // Handle filter selection
                      },
                    ),
                    Text("TODAS LAS ACTIVIDADES", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                    Flexible(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(-4, -4),
                                blurRadius: 10.0,
                                spreadRadius: 1.0,
                                blurStyle: BlurStyle.inner,
                              ),
                            ],
                          ),
                          child: AllActividades(
                            selectedFilter: null,
                            searchQuery: '',
                            selectedDate: null,
                            selectedCourse: null,
                            selectedState: null,
                          ),
                        ),
                      )
                    ),
                    SizedBox(
                      height: 60.0,
                      child: Text("TUS ACTIVIDADES", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                    ),
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(-4, -4),
                                blurRadius: 10.0,
                                spreadRadius: 1.0,
                                blurStyle: BlurStyle.inner,
                              ),
                            ],
                          ),
                          child: OtrasActividades(
                            selectedFilter: null,
                            searchQuery: '',
                            selectedDate: null,
                            selectedCourse: null,
                            selectedState: null,
                          ),
                        ),
                      )
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}