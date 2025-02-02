import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_santi/components/appBar.dart';
import 'package:proyecto_santi/components/menu.dart';

class ActivitiesView extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkTheme;

  const ActivitiesView({
    Key? key,
    required this.onToggleTheme,
    required this.isDarkTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return false; // Prevent the default back button behavior
      },
      child: Scaffold(
        appBar: CustomAppBar(
          onToggleTheme: onToggleTheme,
          title: 'Actividades',
        ),
        drawer: Menu(),
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
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('actividades').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No hay actividades disponibles'));
        } else {
          var actividades = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
          return ListView.builder(
            itemCount: actividades.length,
            itemBuilder: (context, index) {
              var actividad = actividades[index];
              return ListTile(
                title: Text(actividad['titulo'] ?? 'Sin título'),
                subtitle: Text(actividad['descripcion'] ?? 'Sin descripción'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/activityDetail',
                    arguments: {'activityId': actividad['id']},
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
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('otras_actividades').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No hay otras actividades disponibles'));
        } else {
          var actividades = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
          return ListView.builder(
            itemCount: actividades.length,
            itemBuilder: (context, index) {
              var actividad = actividades[index];
              return ListTile(
                title: Text(actividad['titulo'] ?? 'Sin título'),
                subtitle: Text(actividad['descripcion'] ?? 'Sin descripción'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/activityDetail',
                    arguments: {'activityId': actividad['id']},
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