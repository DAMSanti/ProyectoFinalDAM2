import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width *
          0.65, // Ajusta el ancho del Drawer
      child: Drawer(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 150.0, // Establece la altura deseada para el DrawerHeader
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary, // Color específico para el DrawerHeader
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Menú',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Inicio'),
              onTap: () {
                if (ModalRoute.of(context)?.settings.name != '/home') {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/home');
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.event),
              title: Text('Actividades'),
              onTap: () {
                if (ModalRoute.of(context)?.settings.name != '/actividades') {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/actividades');
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Chat'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Mapa'),
              onTap: () {
                if (ModalRoute.of(context)?.settings.name != '/mapa') {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/mapa');
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            Spacer(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Salir'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
    );
  }
}
