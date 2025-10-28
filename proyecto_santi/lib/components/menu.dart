import 'package:flutter/material.dart';
import 'package:proyecto_santi/func.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_santi/models/auth.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double drawerWidth = constraints.maxWidth * 0.35;
        if (constraints.maxWidth > 1200) {
          drawerWidth = constraints.maxWidth * 0.20;
        } else if (constraints.maxWidth < 600) {
          drawerWidth = constraints.maxWidth * 0.65;
        }

        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: drawerWidth, // Adjust the width of the Drawer
          child: Drawer(
            child: _buildMenuContent(context),
          ),
        );
      },
    );
  }

  Widget _buildMenuContent(BuildContext context) {
    // Obtener el usuario actual para verificar si es admin
    final auth = Provider.of<Auth>(context, listen: false);
    final currentUser = auth.currentUser;
    final isAdmin = currentUser?.rol.toLowerCase() == 'admin' || 
                    currentUser?.rol.toLowerCase() == 'administrador';

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 150.0,
            // Set the desired height for the DrawerHeader
            child: DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).primaryColor
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Menú',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            text: 'Inicio',
            routeName: '/home',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.event,
            text: 'Actividades',
            routeName: '/actividades',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.chat,
            text: 'Chat',
            routeName: '/chat',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.map,
            text: 'Mapa',
            routeName: '/mapa',
          ),
          // Menú de Gestión solo para administradores
          if (isAdmin)
            _buildGestionMenu(context),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings,
                    text: 'Configuración',
                    routeName: '/configuracion',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.exit_to_app,
                    text: 'Salir',
                    routeName: '/',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGestionMenu(BuildContext context) {
    return ExpansionTile(
      leading: FaIcon(Icons.admin_panel_settings, color: Theme.of(context).primaryColor),
      title: Text('Gestión'),
      children: [
        ListTile(
          leading: Icon(Icons.event, size: 20),
          title: Text('Actividades', style: TextStyle(fontSize: 14)),
          contentPadding: EdgeInsets.only(left: 72, right: 16),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/gestion/actividades');
          },
        ),
        ListTile(
          leading: Icon(Icons.person, size: 20),
          title: Text('Profesores', style: TextStyle(fontSize: 14)),
          contentPadding: EdgeInsets.only(left: 72, right: 16),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/gestion/profesores');
          },
        ),
        ListTile(
          leading: Icon(Icons.business, size: 20),
          title: Text('Departamentos', style: TextStyle(fontSize: 14)),
          contentPadding: EdgeInsets.only(left: 72, right: 16),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/gestion/departamentos');
          },
        ),
        ListTile(
          leading: Icon(Icons.group, size: 20),
          title: Text('Grupos', style: TextStyle(fontSize: 14)),
          contentPadding: EdgeInsets.only(left: 72, right: 16),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/gestion/grupos');
          },
        ),
        ListTile(
          leading: Icon(Icons.school, size: 20),
          title: Text('Cursos', style: TextStyle(fontSize: 14)),
          contentPadding: EdgeInsets.only(left: 72, right: 16),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/gestion/cursos');
          },
        ),
        ListTile(
          leading: Icon(Icons.hotel, size: 20),
          title: Text('Alojamientos', style: TextStyle(fontSize: 14)),
          contentPadding: EdgeInsets.only(left: 72, right: 16),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/gestion/alojamientos');
          },
        ),
        ListTile(
          leading: Icon(Icons.directions_bus, size: 20),
          title: Text('Empresas de Transporte', style: TextStyle(fontSize: 14)),
          contentPadding: EdgeInsets.only(left: 72, right: 16),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/gestion/empresas-transporte');
          },
        ),
      ],
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String text, required String routeName}) {
    return ListTile(
      leading: FaIcon(icon, color: Theme.of(context).primaryColor),
      title: Text(text),
      onTap: () {
        if (routeName == '/') {
          logout(context);
        } else if (ModalRoute.of(context)?.settings.name != routeName) {
          Navigator.pop(context);
          Navigator.pushNamed(context, routeName);
        } else {
          Navigator.pop(context);
        }
      },
    );
  }
}

class MenuLandscape extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double drawerWidth = constraints.maxWidth * 0.35;
        if (constraints.maxWidth > 1200) {
          drawerWidth = constraints.maxWidth * 0.20;
        } else if (constraints.maxWidth < 600) {
          drawerWidth = constraints.maxWidth * 0.65;
        }

        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: drawerWidth, // Adjust the width of the Drawer
          child: Drawer(
            child: SingleChildScrollView(
              child: _buildMenuContent(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuContent(BuildContext context) {
    // Obtener el usuario actual para verificar si es admin
    final auth = Provider.of<Auth>(context, listen: false);
    final currentUser = auth.currentUser;
    final isAdmin = currentUser?.rol.toLowerCase() == 'admin' || 
                    currentUser?.rol.toLowerCase() == 'administrador';

    return Column(
      children: <Widget>[
        SizedBox(
          height: 150.0,
          // Set the desired height for the DrawerHeader
          child: DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).primaryColor
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Menú',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        _buildDrawerItem(
          context,
          icon: Icons.home,
          text: 'Inicio',
          routeName: '/home',
        ),
        _buildDrawerItem(
          context,
          icon: Icons.event,
          text: 'Actividades',
          routeName: '/actividades',
        ),
        _buildDrawerItem(
          context,
          icon: Icons.chat,
          text: 'Chat',
          routeName: '/chat',
        ),
        _buildDrawerItem(
          context,
          icon: Icons.map,
          text: 'Mapa',
          routeName: '/mapa',
        ),
        // Menú de Gestión solo para administradores
        if (isAdmin)
          _buildGestionMenuLandscape(context),
        _buildDrawerItem(
          context,
          icon: Icons.settings,
          text: 'Configuración',
          routeName: '/configuracion',
        ),
        _buildDrawerItem(
          context,
          icon: Icons.exit_to_app,
          text: 'Salir',
          routeName: '/',
        ),
      ],
    );
  }

  Widget _buildGestionMenuLandscape(BuildContext context) {
    return ExpansionTile(
      leading: FaIcon(Icons.admin_panel_settings, color: Theme.of(context).primaryColor),
      title: Text('Gestión'),
      children: [
        ListTile(
          leading: Icon(Icons.event, size: 20),
          title: Text('Actividades', style: TextStyle(fontSize: 14)),
          contentPadding: EdgeInsets.only(left: 72, right: 16),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/gestion/actividades');
          },
        ),
        ListTile(
          leading: Icon(Icons.person, size: 20),
          title: Text('Profesores', style: TextStyle(fontSize: 14)),
          contentPadding: EdgeInsets.only(left: 72, right: 16),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/gestion/profesores');
          },
        ),
        ListTile(
          leading: Icon(Icons.business, size: 20),
          title: Text('Departamentos', style: TextStyle(fontSize: 14)),
          contentPadding: EdgeInsets.only(left: 72, right: 16),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/gestion/departamentos');
          },
        ),
        ListTile(
          leading: Icon(Icons.group, size: 20),
          title: Text('Grupos', style: TextStyle(fontSize: 14)),
          contentPadding: EdgeInsets.only(left: 72, right: 16),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/gestion/grupos');
          },
        ),
        ListTile(
          leading: Icon(Icons.school, size: 20),
          title: Text('Cursos', style: TextStyle(fontSize: 14)),
          contentPadding: EdgeInsets.only(left: 72, right: 16),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/gestion/cursos');
          },
        ),
        ListTile(
          leading: Icon(Icons.hotel, size: 20),
          title: Text('Alojamientos', style: TextStyle(fontSize: 14)),
          contentPadding: EdgeInsets.only(left: 72, right: 16),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/gestion/alojamientos');
          },
        ),
        ListTile(
          leading: Icon(Icons.directions_bus, size: 20),
          title: Text('Empresas de Transporte', style: TextStyle(fontSize: 14)),
          contentPadding: EdgeInsets.only(left: 72, right: 16),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/gestion/empresas-transporte');
          },
        ),
      ],
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String text, required String routeName}) {
    return ListTile(
      leading: FaIcon(icon, color: Theme.of(context).primaryColor),
      title: Text(text),
      onTap: () {
        if (routeName == '/') {
          logout(context);
        } else if (ModalRoute.of(context)?.settings.name != routeName) {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, routeName);
        } else {
          Navigator.pop(context);
        }
      },
    );
  }
}