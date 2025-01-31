import 'package:flutter/material.dart';
import 'package:proyecto_santi/components/AppBar.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/components/calendario.dart';
import 'package:proyecto_santi/components/activityCards.dart';

class HomeView extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomeView({Key? key, required this.onToggleTheme}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Future<List<Actividad>> _futureActivities;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _futureActivities = _apiService.fetchActivities();
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomAppBar(
          onToggleTheme: widget.onToggleTheme,
          title: 'Home',
        ),
        body: FutureBuilder<List<Actividad>>(
          future: _futureActivities,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No activities available"));
            } else {
              final activities = snapshot.data!;
              return Column(
                children: [
                  UserInformation(),
                  SizedBox(
                    height: 100, // Ajusta la altura según tus necesidades
                    child: ActivityList(activities: activities),
                  ),
                  Expanded(
                    child: CalendarView(activities: activities),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class UserInformation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Text("User Information"),
    );
  }
}
