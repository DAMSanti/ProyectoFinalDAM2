import 'package:flutter/material.dart';
import 'package:proyecto_santi/components/menu.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/func.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:proyecto_santi/views/activities/views/activities_large_landscape_layout.dart';
import 'package:proyecto_santi/views/activities/views/activities_small_landscape_layout.dart';
import 'package:proyecto_santi/views/activities/views/activities_portrait_layout.dart';
import 'dart:io' show Platform;

class ActivitiesView extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const ActivitiesView({super.key, required this.onToggleTheme});

  @override
  ActivitiesViewState createState() => ActivitiesViewState();
}

class ActivitiesViewState extends State<ActivitiesView> {
  late Future<List<Actividad>> _futureActivities;
  late final ApiService _apiService;
  late final ActividadService _actividadService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _actividadService = ActividadService(_apiService);
    _futureActivities = _actividadService.fetchFutureActivities();
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
            appBar: null,
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
