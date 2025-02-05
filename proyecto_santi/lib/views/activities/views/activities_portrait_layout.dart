import 'package:flutter/material.dart';
import 'package:proyecto_santi/components/menu.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import 'package:proyecto_santi/views/activities/components/activities_listas.dart';
import 'package:proyecto_santi/views/activities/components/activities_busqueda.dart';

class ActivitiesPortraitLayout extends StatelessWidget {
  final List<Actividad> activities;
  final VoidCallback onToggleTheme;

  const ActivitiesPortraitLayout({
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
            drawer: OrientationBuilder(
              builder: (context, orientation) {
                return orientation == Orientation.portrait
                    ? Menu()
                    : MenuLandscape();
              },
            ),
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
                Text("TODAS LAS ACTIVIDADES", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 6.0),
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
                  ),
                ),
                SizedBox(
                  height: 24.0,
                  child: Text("TUS ACTIVIDADES", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 6.0),
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
