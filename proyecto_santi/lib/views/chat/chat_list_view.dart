import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/components/app_bar.dart';
import 'package:proyecto_santi/components/desktop_shell.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

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
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _futureActivities = _apiService.fetchFutureActivities();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    // En desktop, el contenido se renderiza directamente (el DesktopShell proporciona el marco)
    if (isDesktop) {
      return _buildChatList();
    }
    
    // En mobile, usar Scaffold con AppBar y Drawer
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return false;
      },
      child: Scaffold(
        appBar: AndroidAppBar(
          onToggleTheme: widget.onToggleTheme,
          title: 'Chats',
        ),
        body: _buildChatList(),
      ),
    );
  }

  Widget _buildChatList() {
    return FutureBuilder<List<Actividad>>(
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
          // Navegar al chat usando el shell o navegación tradicional
          navigateToChatInShell(context, {
            'activityId': actividad.id.toString(),
            'displayName': actividad.titulo,
          });
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