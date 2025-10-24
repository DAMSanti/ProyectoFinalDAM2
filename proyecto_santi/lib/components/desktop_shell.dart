import 'package:flutter/material.dart';
import 'package:proyecto_santi/components/marco_desktop.dart';
import 'package:proyecto_santi/views/home/home_view.dart';
import 'package:proyecto_santi/views/activities/activities_view.dart';
import 'package:proyecto_santi/views/chat/chat_list_view.dart';
import 'package:proyecto_santi/views/chat/vistas/chat_view.dart';
import 'package:proyecto_santi/views/map/map_view.dart';
import 'package:proyecto_santi/views/activityDetail/activity_detail_view.dart';
import 'package:proyecto_santi/func.dart';

/// Shell que mantiene el menú fijo y solo cambia el contenido
class DesktopShell extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final String initialRoute;

  const DesktopShell({
    super.key,
    required this.onToggleTheme,
    this.initialRoute = '/home',
  });

  @override
  State<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<DesktopShell> {
  late String _currentRoute;
  String _previousRoute = '/home'; // Ruta anterior para volver atrás
  Map<String, dynamic>? _activityDetailArgs;
  Map<String, dynamic>? _chatViewArgs;

  @override
  void initState() {
    super.initState();
    _currentRoute = widget.initialRoute;
  }

  // Método público para navegar entre rutas
  void navigateTo(String route) {
    if (route != _currentRoute) {
      setState(() {
        _previousRoute = _currentRoute; // Guardar la ruta actual como anterior
        _currentRoute = route;
        _activityDetailArgs = null; // Limpiar args cuando no es detalle
        _chatViewArgs = null; // Limpiar args del chat
      });
    }
  }

  String _getTitleForRoute() {
    switch (_currentRoute) {
      case '/home':
        return 'Próximas Actividades';
      case '/actividades':
        return 'Actividades';
      case '/chat':
        return 'Chat';
      case '/chatView':
        return _chatViewArgs?['displayName'] ?? 'Chat';
      case '/mapa':
        return 'Mapa';
      case '/activityDetail':
        return 'Detalle de Actividad';
      default:
        return 'Próximas Actividades';
    }
  }

  // Método público para navegar al detalle de actividad
  void navigateToActivityDetail(Map<String, dynamic> args) {
    setState(() {
      _previousRoute = _currentRoute; // Guardar ruta actual antes de ir al detalle
      _currentRoute = '/activityDetail';
      _activityDetailArgs = args;
      _chatViewArgs = null;
    });
  }

  // Método público para navegar al chat de una actividad
  void navigateToChatView(Map<String, dynamic> args) {
    setState(() {
      _previousRoute = _currentRoute; // Guardar ruta actual antes de ir al chat
      _currentRoute = '/chatView';
      _chatViewArgs = args;
      _activityDetailArgs = null;
    });
  }

  // Método público para volver a la ruta anterior
  void navigateBack() {
    setState(() {
      _currentRoute = _previousRoute;
      _activityDetailArgs = null;
    });
  }

  Widget _buildCurrentView() {
    switch (_currentRoute) {
      case '/home':
        return HomeView(onToggleTheme: widget.onToggleTheme);
      case '/actividades':
        return ActivitiesView(onToggleTheme: widget.onToggleTheme);
      case '/chat':
        return ChatListView(
          onToggleTheme: widget.onToggleTheme,
          isDarkTheme: Theme.of(context).brightness == Brightness.dark,
        );
      case '/chatView':
        if (_chatViewArgs != null) {
          return ChatView(
            activityId: _chatViewArgs!['activityId'],
            displayName: _chatViewArgs!['displayName'],
            onToggleTheme: widget.onToggleTheme,
            isDarkTheme: Theme.of(context).brightness == Brightness.dark,
          );
        }
        return ChatListView(
          onToggleTheme: widget.onToggleTheme,
          isDarkTheme: Theme.of(context).brightness == Brightness.dark,
        );
      case '/mapa':
        return MapView(
          onToggleTheme: widget.onToggleTheme,
          isDarkTheme: Theme.of(context).brightness == Brightness.dark,
        );
      case '/activityDetail':
        if (_activityDetailArgs != null) {
          return ActivityDetailView(
            actividad: _activityDetailArgs!['activity'],
            onToggleTheme: widget.onToggleTheme,
            isDarkTheme: Theme.of(context).brightness == Brightness.dark,
          );
        }
        return HomeView(onToggleTheme: widget.onToggleTheme);
      default:
        return HomeView(onToggleTheme: widget.onToggleTheme);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _DesktopShellScope(
      state: this,
      child: DesktopShellFrame(
        currentRoute: _currentRoute,
        currentTitle: _getTitleForRoute(),
        onNavigate: navigateTo,
        onToggleTheme: widget.onToggleTheme,
        child: _buildCurrentView(),
      ),
    );
  }
}

// InheritedWidget para acceder al estado del shell desde cualquier lugar
class _DesktopShellScope extends InheritedWidget {
  final _DesktopShellState state;

  const _DesktopShellScope({
    required this.state,
    required super.child,
  });

  static _DesktopShellState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_DesktopShellScope>()?.state;
  }

  @override
  bool updateShouldNotify(_DesktopShellScope oldWidget) => false;
}

// Función helper para navegar al detalle de actividad desde cualquier lugar
void navigateToActivityDetailInShell(BuildContext context, Map<String, dynamic> args) {
  final shellState = _DesktopShellScope.of(context);
  if (shellState != null) {
    shellState.navigateToActivityDetail(args);
  } else {
    // Fallback para mobile o si no hay shell
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityDetailView(
          actividad: args['activity'],
          onToggleTheme: () {},
          isDarkTheme: Theme.of(context).brightness == Brightness.dark,
        ),
      ),
    );
  }
}

// Función helper para volver atrás desde el detalle de actividad
void navigateBackFromDetail(BuildContext context, String defaultRoute) {
  final shellState = _DesktopShellScope.of(context);
  if (shellState != null) {
    // Si estamos en el shell, volver a la ruta anterior
    shellState.navigateBack();
  } else {
    // Si no, usar navegación tradicional (mobile)
    Navigator.pop(context);
  }
}

// Función helper para navegar al chat de una actividad desde cualquier lugar
void navigateToChatInShell(BuildContext context, Map<String, dynamic> args) {
  final shellState = _DesktopShellScope.of(context);
  if (shellState != null) {
    shellState.navigateToChatView(args);
  } else {
    // Fallback para mobile o si no hay shell
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatView(
          activityId: args['activityId'],
          displayName: args['displayName'],
          onToggleTheme: () {},
          isDarkTheme: Theme.of(context).brightness == Brightness.dark,
        ),
      ),
    );
  }
}

/// Frame del shell con menú lateral y barra superior
class DesktopShellFrame extends StatelessWidget {
  final String currentRoute;
  final String currentTitle;
  final Function(String) onNavigate;
  final VoidCallback onToggleTheme;
  final Widget child;

  const DesktopShellFrame({
    super.key,
    required this.currentRoute,
    required this.currentTitle,
    required this.onNavigate,
    required this.onToggleTheme,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minMenuWidth = 200.0;
        final menuWidth = constraints.maxWidth * 0.15;
        final effectiveMenuWidth = menuWidth < minMenuWidth ? minMenuWidth : menuWidth;

        return Stack(
          children: [
            Row(
              children: [
                SizedBox(width: effectiveMenuWidth),
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 92,
                        child: DesktopBar(
                          onToggleTheme: onToggleTheme,
                          title: currentTitle,
                        ),
                      ),
                      Expanded(
                        child: child,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: effectiveMenuWidth,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: Offset(3, 0),
                    ),
                  ],
                ),
                child: MenuDesktopStatic(
                  currentRoute: currentRoute,
                  onNavigate: onNavigate,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Menú lateral estático que usa callback en lugar de Navigator
class MenuDesktopStatic extends StatelessWidget {
  final String currentRoute;
  final Function(String) onNavigate;

  const MenuDesktopStatic({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: ContinuousRectangleBorder(),
      child: _buildMenuContent(context),
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
          // Header
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
                Column(
                  children: [
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

          // Separador
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

          // Footer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_rounded,
                  text: 'Configuración',
                  routeName: '/configuracion',
                  isSettings: true,
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
    bool isSettings = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCurrentRoute = currentRoute == routeName;

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
          onTap: () async {
            if (isLogout) {
              // Mostrar diálogo de confirmación para salir
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: Text('Confirmar salida'),
                    content: Text('¿Estás seguro de que quieres cerrar sesión?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: Text('Sí'),
                      ),
                    ],
                  );
                },
              );
              
              if (shouldLogout == true) {
                logout(context);
              }
            } else if (isSettings) {
              // Mostrar ventana de configuración
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: Text('Configuración'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Opciones de la aplicación',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 16),
                          ListTile(
                            leading: Icon(Icons.palette),
                            title: Text('Tema'),
                            subtitle: Text(Theme.of(context).brightness == Brightness.dark 
                                ? 'Modo oscuro' 
                                : 'Modo claro'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          ListTile(
                            leading: Icon(Icons.info),
                            title: Text('Versión'),
                            subtitle: Text('1.0.0'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          ListTile(
                            leading: Icon(Icons.description),
                            title: Text('Acerca de'),
                            subtitle: Text('Sistema de Gestión ACEX'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text('Cerrar'),
                      ),
                    ],
                  );
                },
              );
            } else if (!isCurrentRoute) {
              onNavigate(routeName);
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
