import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_santi/models/auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  void _logout(BuildContext context) {
    Provider.of<Auth>(context, listen: false).logout();
    Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String text, required String routeName}) {
    return ListTile(
      leading: FaIcon(icon, color: Theme.of(context).primaryColor),
      title: Text(text),
      onTap: () {
        if (routeName == '/') {
          _logout(context);
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

  void _logout(BuildContext context) {
    Provider.of<Auth>(context, listen: false).logout();
    Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String text, required String routeName}) {
    return ListTile(
      leading: FaIcon(icon, color: Theme.of(context).primaryColor),
      title: Text(text),
      onTap: () {
        if (routeName == '/') {
          _logout(context);
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