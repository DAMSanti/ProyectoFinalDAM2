import 'package:flutter/material.dart';
import 'package:proyecto_santi/components/menu.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import 'package:proyecto_santi/views/activities/components/activities_listas.dart';
import 'package:proyecto_santi/views/activities/components/activities_busqueda.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ActivitiesSmallLandscapeLayout extends StatefulWidget {
  final List<Actividad> activities;
  final VoidCallback onToggleTheme;

  const ActivitiesSmallLandscapeLayout({
    super.key,
    required this.activities,
    required this.onToggleTheme,
  });

  @override
  _ActivitiesSmallLandscapeLayoutState createState() => _ActivitiesSmallLandscapeLayoutState();
}

class _ActivitiesSmallLandscapeLayoutState extends State<ActivitiesSmallLandscapeLayout> {
  String searchQuery = '';

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
            drawer: !(kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS)
                ? OrientationBuilder(
              builder: (context, orientation) {
                return orientation == Orientation.portrait ? Menu() : MenuLandscape();
              },
            )
                : null,
            body: Column(
              children: [
                Busqueda(
                  onSearchQueryChanged: (query) {
                    setState(() {
                      searchQuery = query;
                    });
                  },
                  onFilterSelected: (filter, date, course, state) {
                    // Handle filter selection
                  },
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("TODAS LAS ACTIVIDADES", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                              Expanded(
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
                                    searchQuery: searchQuery,
                                    selectedDate: null,
                                    selectedCourse: null,
                                    selectedState: null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("TUS ACTIVIDADES", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                              Expanded(
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
                                    searchQuery: searchQuery,
                                    selectedDate: null,
                                    selectedCourse: null,
                                    selectedState: null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}