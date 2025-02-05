import 'package:flutter/material.dart';
import 'package:proyecto_santi/components/appBar.dart';
import 'package:proyecto_santi/components/menu.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/tema/GradientBackground.dart';
import 'package:proyecto_santi/views/activities/components/activities_Listas.dart';
import 'package:proyecto_santi/views/activities/components/activities_Busqueda.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ActivitiesSmallLandscapeLayout extends StatelessWidget {
  final List<Actividad> activities;
  final VoidCallback onToggleTheme;

  const ActivitiesSmallLandscapeLayout({
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
                  child: OtrasActividades(
                    selectedFilter: null,
                    searchQuery: '',
                    selectedDate: null,
                    selectedCourse: null,
                    selectedState: null,
                  ),
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