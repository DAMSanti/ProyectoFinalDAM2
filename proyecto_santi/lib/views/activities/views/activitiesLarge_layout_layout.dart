import 'package:flutter/material.dart';
import 'package:proyecto_santi/components/MarcoDesktop.dart';
import 'package:proyecto_santi/components/appBar.dart';
import 'package:proyecto_santi/components/menu.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/tema/GradientBackground.dart';
import 'package:proyecto_santi/views/activities/Activities_view.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ActivitiesLargeLandscapeLayout extends StatelessWidget {
  final List<Actividad> activities;
  final VoidCallback onToggleTheme;

  const ActivitiesLargeLandscapeLayout({
    super.key,
    required this.activities,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
      return WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacementNamed(context, '/home');
          return false;
        },
        child: Stack(
          children: [
            Scaffold(
              body: MarcoDesktop(
                onToggleTheme: onToggleTheme,
                content: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column (
                    children: [
                      Text("TODAS LAS ACTIVIDADES", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                      Busqueda(
                        onSearchQueryChanged: (query) {
                          // Handle search query change
                        },
                        onFilterSelected: (filter, date, course, state) {
                          // Handle filter selection
                        },
                      ),
                      Expanded(
                        child: AllActividades(
                          selectedFilter: null,
                          searchQuery: '',
                          selectedDate: null,
                          selectedCourse: null,
                          selectedState: null,
                        ),
                      ),
                      SizedBox(
                        height: 60.0,
                        child: Text("TUS ACTIVIDADES", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: OtrasActividades(),
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