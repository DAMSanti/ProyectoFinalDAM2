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
            Theme.of(context).brightness == Brightness.dark
                ? GradientBackgroundDark(child: Container())
                : GradientBackgroundLight(child: Container()),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: shouldShowAppBar()
                  ? AndroidAppBar(
                onToggleTheme: onToggleTheme,
                title: 'Actividades',
              )
                  : null,
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
                  Expanded(
                    child: OtrasActividades(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }


  bool shouldShowAppBar() {
    // Implement your logic to show or hide the AppBar
    return true;
  }
}