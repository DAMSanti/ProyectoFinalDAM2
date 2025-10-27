import 'package:flutter/material.dart';
import 'package:proyecto_santi/func.dart';
import 'package:proyecto_santi/views/home/components/home_user.dart';
import 'package:proyecto_santi/tema/theme.dart';

class MarcoDesktop extends StatelessWidget {
  final Widget content;
  final VoidCallback onToggleTheme;

  const MarcoDesktop({super.key, required this.content, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Ancho mínimo del menú para evitar descuadres
        final minMenuWidth = 200.0;
        final menuWidth = constraints.maxWidth * 0.15;
        final effectiveMenuWidth = menuWidth < minMenuWidth ? minMenuWidth : menuWidth;
        
        return Row(
          children: [
            SizedBox(
              width: effectiveMenuWidth,
              child: MenuDesktop(),
            ),
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: 92, // Fixed height for AppBar
                    child: DesktopBar(onToggleTheme: onToggleTheme),
                  ),
                  Expanded(
                    child: Navigator(
                      onGenerateRoute: (settings) {
                        return MaterialPageRoute(
                          builder: (context) => content,
                        );
                      },
                    ),
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
  final VoidCallback onToggleTheme;
  final String? title;

  const DesktopBar({
    super.key, 
    required this.onToggleTheme,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return OrientationBuilder(
      builder: (context, orientation) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [colorFondoDark, colorAccentDark]
                  : [colorFondoLight, colorAccentLight],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: Text(
                title ?? 'Próximas Actividades',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976d2), // Azul de los items del menú
                  letterSpacing: 0.5,
                ),
              ),
              leading: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Center(child: UserInformation()),
              ),
              leadingWidth: 250,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Center(
                    child: IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        size: 24,
                        color: isDark ? Colors.amber : Color(0xFF1976d2),
                      ),
                      onPressed: onToggleTheme,
                      tooltip: 'Cambiar tema',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(92);
  }
}

class MenuDesktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double drawerWidth = constraints.maxWidth * 0.21;
        return SizedBox(
          width: drawerWidth,
          child: Drawer(
            shape: ContinuousRectangleBorder(),
            child: _buildMenuContent(context),
          ),
        );
      },
    );
  }

  Widget _buildMenuContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [Color(0xFF1a1a2e), Color(0xFF16213e)]
              : [Color(0xFFe3f2fd), Color(0xFFbbdefb)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: <Widget>[
          // Header modernizado
          Container(
            height: 140.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [Color(0xFF0f3460), Color(0xFF16213e)]
                    : [Color(0xFF1976d2), Color(0xFF2196f3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.school,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'ACEX',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'Sistema de Gestión',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Items del menú
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 8),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home_rounded,
                  text: 'Inicio',
                  routeName: '/home',
                ),
                SizedBox(height: 8),
                _buildDrawerItem(
                  context,
                  icon: Icons.event_rounded,
                  text: 'Actividades',
                  routeName: '/actividades',
                ),
                SizedBox(height: 8),
                _buildDrawerItem(
                  context,
                  icon: Icons.chat_bubble_rounded,
                  text: 'Chat',
                  routeName: '/chat',
                ),
                SizedBox(height: 8),
                _buildDrawerItem(
                  context,
                  icon: Icons.map_rounded,
                  text: 'Mapa',
                  routeName: '/mapa',
                ),
              ],
            ),
          ),
          
          // Separador con gradiente
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  isDark ? Colors.white24 : Colors.black26,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          // Items del footer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_rounded,
                  text: 'Configuración',
                  routeName: '/configuracion',
                ),
                SizedBox(height: 8),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout_rounded,
                  text: 'Salir',
                  routeName: '/',
                  isLogout: true,
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required String routeName,
    bool isLogout = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCurrentRoute = ModalRoute.of(context)?.settings.name == routeName;
    
    return Container(
      decoration: BoxDecoration(
        gradient: isCurrentRoute
            ? LinearGradient(
                colors: isDark
                    ? [Color(0xFF0f3460), Color(0xFF16213e)]
                    : [Color(0xFF1976d2), Color(0xFF2196f3)],
              )
            : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isCurrentRoute
            ? [
                BoxShadow(
                  color: (isDark ? Colors.blue : Colors.blue).withOpacity(0.3),
                  offset: Offset(0, 4),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (isLogout) {
              logout(context);
            } else if (!isCurrentRoute) {
              Navigator.pushReplacementNamed(context, routeName);
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isCurrentRoute
                      ? Colors.white
                      : (isDark ? Colors.white70 : Color(0xFF1976d2)),
                  size: 24,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isCurrentRoute
                          ? Colors.white
                          : (isDark ? Colors.white : Color(0xFF1976d2)),
                      fontSize: 15,
                      fontWeight: isCurrentRoute ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (isCurrentRoute)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}