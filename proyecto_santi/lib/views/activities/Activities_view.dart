import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_santi/components/appBar.dart';
import 'package:proyecto_santi/components/menu.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/tema/GradientBackground.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/func.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:proyecto_santi/views/activities/views/activitiesLarge_layout_layout.dart';
import 'package:proyecto_santi/views/activities/views/activitiesSmall_layout_layout.dart';
import 'dart:io' show Platform;

import 'package:proyecto_santi/views/activities/views/activities_portrait_layout.dart';

class ActivitiesView extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkTheme;

  const ActivitiesView({
    super.key,
    required this.onToggleTheme,
    required this.isDarkTheme,
  });

  @override
  _ActivitiesViewState createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends State<ActivitiesView> {
  late Future<List<Actividad>> _futureActivities;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _futureActivities = _apiService.fetchFutureActivities();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onWillPopSalir(context),
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
            appBar: shouldShowAppBar()
                ? AndroidAppBar(
              onToggleTheme: widget.onToggleTheme,
              title: 'Actividades',
            )
                : null,
            drawer: !(kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS)
                ? OrientationBuilder(
              builder: (context, orientation) {
                return orientation == Orientation.portrait
                    ? Menu()
                    : MenuLandscape();
              },
            )
                : Menu(),
            body: FutureBuilder<List<Actividad>>(
              future: _futureActivities,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No activities found.'));
                } else {
                  return _buildLayout(context, snapshot.data!);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayout(BuildContext context, List<Actividad> activities) {
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return ActivitiesLargeLandscapeLayout(activities: activities, onToggleTheme: widget.onToggleTheme);
    } else {
      return OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return ActivitiesPortraitLayout(activities: activities, onToggleTheme: widget.onToggleTheme);
          } else {
            return ActivitiesSmallLandscapeLayout(activities: activities, onToggleTheme: widget.onToggleTheme);
          }
        },
      );
    }
  }
}

class Busqueda extends StatelessWidget {
  final Function(String) onSearchQueryChanged;
  final Function(String?, int?, String?, String?) onFilterSelected;

  Busqueda({required this.onSearchQueryChanged, required this.onFilterSelected});

  @override
  Widget build(BuildContext context) {
    var searchText = '';
    var showPopup = false;

    return Column(
      children: [
        TextField(
          onChanged: (text) {
            searchText = text;
            onSearchQueryChanged(text);
          },
          decoration: InputDecoration(
            labelText: 'Buscar actividad...',
            prefixIcon: Icon(Icons.search),
            suffixIcon: IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {
                showPopup = !showPopup;
              },
            ),
          ),
        ),
        if (showPopup)
        // Implement filter options popup
          Container(),
      ],
    );
  }
}

class AllActividades extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final ApiService _apiService = ApiService();

    return FutureBuilder<List<Actividad>>(
      future: _apiService.fetchActivities(), // Use your API service here
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay actividades disponibles'));
        } else {
          var actividades = snapshot.data!;
          return ListView.builder(
            itemCount: actividades.length,
            itemBuilder: (context, index) {
              var actividad = actividades[index];
              return ListTile(
                title: Text(actividad.titulo ?? 'Sin título'),
                subtitle: Text(actividad.descripcion ?? 'Sin descripción'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/activityDetail',
                    arguments: {'activityId': actividad.id},
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}

class OtrasActividades extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ApiService _apiService = ApiService();

    return FutureBuilder<List<Actividad>>(
      future: _apiService.fetchFutureActivities(), // Use your API service here
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay otras actividades disponibles'));
        } else {
          var actividades = snapshot.data!;
          return ListView.builder(
            itemCount: actividades.length,
            itemBuilder: (context, index) {
              var actividad = actividades[index];
              return ListTile(
                title: Text(actividad.titulo ?? 'Sin título'),
                subtitle: Text(actividad.descripcion ?? 'Sin descripción'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/activityDetail',
                    arguments: {'activityId': actividad.id},
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
