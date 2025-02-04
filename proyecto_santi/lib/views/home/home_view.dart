import 'package:flutter/material.dart';
import 'package:proyecto_santi/components/appBar.dart';
import 'package:proyecto_santi/components/menu.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/views/home/views/home_portrait_layout.dart';
import 'package:proyecto_santi/views/home/views/home_small_landscape_layout.dart';
import 'package:proyecto_santi/views/home/views/home_large_landscape_layout.dart';
import 'package:proyecto_santi/tema/GradientBackground.dart';
import 'package:proyecto_santi/config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class HomeView extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomeView({super.key, required this.onToggleTheme});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
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
      onWillPop: _onWillPop,
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
                ? CustomAppBar(
              onToggleTheme: widget.onToggleTheme,
              title: 'Inicio',
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
      return HomeLargeLandscapeLayout(activities: activities);
    } else {
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

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Estás seguro?'),
        content: Text('¿Quieres salir de la aplicación?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Sí'),
          ),
        ],
      ),
    )) ??
        false;
  }
}