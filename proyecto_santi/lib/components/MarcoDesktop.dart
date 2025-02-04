import 'package:flutter/material.dart';
import 'package:proyecto_santi/func.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:proyecto_santi/views/home/components/home_user.dart';

class MarcoDesktop extends StatelessWidget {
  final Widget content;

  const MarcoDesktop({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            SizedBox(
              width: constraints.maxWidth * 0.15, // Adjust width based on screen size
              child: MenuDesktop(),
            ),
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: 92, // Fixed height for AppBar
                    child: DesktopBar(),
                  ),
                  Expanded(
                    child: content,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class DesktopBar extends StatelessWidget implements PreferredSizeWidget {

  const DesktopBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return AppBar(
          backgroundColor: Color.fromARGB(255, 87, 116, 243),
          centerTitle: true,
          automaticallyImplyLeading: false,
          flexibleSpace: UserInformation(),
          /*actions: [
            IconButton(
              icon: Icon(Icons.brightness_6),
              onPressed: onToggleTheme,
            ),
          ],*/
        );
      },
    );
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(20);
  }
}

class MenuDesktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double drawerWidth = constraints.maxWidth * 0.21;
        return SizedBox(
          width: drawerWidth, // Adjust the width of the Drawer
          child: Drawer(
            shape: ContinuousRectangleBorder(),
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
            height: 100.0,
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
                borderRadius: BorderRadius.zero,
              ),
              child: Align(
                alignment: Alignment.center,
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

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String text, required String routeName}) {
    return ListTile(
      leading: FaIcon(icon, color: Theme.of(context).primaryColor),
      title: Text(text),
      onTap: () {
        if (routeName == '/') {
          logout(context);
        } else if (ModalRoute.of(context)?.settings.name != routeName) {
          Navigator.pushReplacementNamed(context, routeName);
        } /*else {
          Navigator.pop(context);
        }*/
      },
    );
  }
}