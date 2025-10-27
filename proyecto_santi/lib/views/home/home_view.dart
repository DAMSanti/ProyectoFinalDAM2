import 'package:flutter/material.dart';
import 'package:proyecto_santi/components/app_bar.dart';
import 'package:proyecto_santi/components/menu.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/services/api_service.dart';
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
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _futureActivities = _apiService.fetchFutureActivities();
  }

  @override
  Widget build(BuildContext context) {
    // Si estamos en web o desktop, devolver el contenido con fondo degradado
    // pero sin Scaffold porque el DesktopShell ya proporciona el marco
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
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
                // Usar HomeLargeLandscapeLayout que ya NO tiene MarcoDesktop
                return HomeLargeLandscapeLayout(
                  activities: snapshot.data!,
                  onToggleTheme: widget.onToggleTheme,
                );
              }
            },
          ),
        ],
      );
    }
    
    // Para móvil, mantener el Scaffold completo
    return WillPopScope(
      onWillPop: () => onWillPopSalir(context, isHome: true),
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
              title: 'Inicio',
            )
                : null,
            drawer: Menu(),
            body: FutureBuilder<List<Actividad>>(
              future: _futureActivities,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay actividades próximas.'));
                } else {
                  return _buildMobileLayout(context, snapshot.data!);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, List<Actividad> activities) {
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