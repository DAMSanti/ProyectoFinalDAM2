import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/components/appBar.dart';
import 'package:proyecto_santi/components/menu.dart';
import 'package:proyecto_santi/views/chat/vistas/chat_view.dart';

class ChatListView extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkTheme;

  const ChatListView(
      {Key? key, required this.onToggleTheme, required this.isDarkTheme})
      : super(key: key);

  @override
  _ChatListViewState createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
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
      {Key? key, required this.actividad, required this.isDarkTheme, required this.onToggleTheme,})
      : super(key: key);

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
                displayName: actividad.titulo ?? 'Chat',
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
              Text(actividad.titulo ?? 'Sin título',
                  style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 8.0),
              Text(actividad.descripcion ?? 'Sin descripción',
                  style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(height: 8.0),
              Text(
                  'Fecha: ${actividad.fini ?? 'N/A'} - ${actividad.ffin ?? 'N/A'}',
                  style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(height: 8.0),
              Text('Estado: ${actividad.estado ?? 'N/A'}',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}