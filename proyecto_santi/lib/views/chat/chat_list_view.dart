import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/components/app_bar.dart';
import 'package:proyecto_santi/components/menu.dart';
import 'package:proyecto_santi/views/chat/vistas/chat_view.dart';

class ChatListView extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkTheme;

  const ChatListView(
      {super.key, required this.onToggleTheme, required this.isDarkTheme});

  @override
  ChatListViewState createState() => ChatListViewState();
}

class ChatListViewState extends State<ChatListView> {
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
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return false; // Prevent the default back button behavior
      },
      child: Scaffold(
        appBar: AndroidAppBar(
          onToggleTheme: widget.onToggleTheme,
          title: 'Chats',
        ),
        drawer: Menu(),
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
              final actividades = snapshot.data!;
              return ListView.builder(
                itemCount: actividades.length,
                itemBuilder: (context, index) {
                  final actividad = actividades[index];
                  return ActividadCard(
                    actividad: actividad,
                    isDarkTheme: widget.isDarkTheme,
                    onToggleTheme: widget.onToggleTheme,
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class ActividadCard extends StatelessWidget {
  final Actividad actividad;
  final bool isDarkTheme;
  final VoidCallback onToggleTheme;

  const ActividadCard(
      {super.key, required this.actividad, required this.isDarkTheme, required this.onToggleTheme,});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          // Navigate to the ChatView of the activity
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatView(
                activityId: actividad.id.toString(),
                displayName: actividad.titulo,
                onToggleTheme: onToggleTheme,
                isDarkTheme: isDarkTheme,
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(actividad.titulo,
                  style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 8.0),
              Text(actividad.descripcion ?? 'Sin descripción',
                  style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(height: 8.0),
              Text(
                  'Fecha: ${actividad.fini} - ${actividad.ffin}',
                  style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(height: 8.0),
              Text('Estado: ${actividad.estado}',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}