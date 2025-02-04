import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_santi/components/appBar.dart';
import 'package:proyecto_santi/components/menu.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/tema/GradientBackground.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

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
      onWillPop:() async {
    Navigator.pushReplacementNamed(context, '/home');
    return false;
    },
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
            : MenuDesktop(),
        body: Column(
          children: [
            SearchBar(
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
    ],),
    );
  }
}

class SearchBar extends StatelessWidget {
  final Function(String) onSearchQueryChanged;
  final Function(String?, int?, String?, String?) onFilterSelected;

  SearchBar({required this.onSearchQueryChanged, required this.onFilterSelected});

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