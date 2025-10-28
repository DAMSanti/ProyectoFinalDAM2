import 'package:flutter/material.dart';
import 'package:proyecto_santi/components/app_bar.dart';
import 'package:proyecto_santi/components/menu.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/views/home/views/home_portrait_layout.dart';
import 'package:proyecto_santi/views/home/views/home_small_landscape_layout.dart';
import 'package:proyecto_santi/views/home/views/home_large_landscape_layout.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import 'package:proyecto_santi/func.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class HomeView extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomeView({super.key, required this.onToggleTheme});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
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
    // El contenido se muestra directamente sin Scaffold
    // porque el DesktopShell ya proporciona el marco (tanto en desktop como en móvil)
    return Stack(
      children: [
        Theme.of(context).brightness == Brightness.dark
            ? GradientBackgroundDark(child: Container())
            : GradientBackgroundLight(child: Container()),
        FutureBuilder<List<Actividad>>(
          future: _futureActivities,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No hay actividades próximas.'));
            } else {
              return _buildResponsiveLayout(context, snapshot.data!);
            }
          },
        ),
      ],
    );
  }

  Widget _buildResponsiveLayout(BuildContext context, List<Actividad> activities) {
    // Detectar si es desktop o móvil
    final width = MediaQuery.of(context).size.width;
    final isDesktop = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    if (isDesktop && width >= 800) {
      // Vista de escritorio grande
      return HomeLargeLandscapeLayout(
        activities: activities,
        onToggleTheme: widget.onToggleTheme,
      );
    } else {
      // Vista móvil (portrait o landscape pequeño)
      return OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return HomePortraitLayout(activities: activities);
          } else {
            return HomeSmallLandscapeLayout(activities: activities);
          }
        },
      );
    }
  }
}