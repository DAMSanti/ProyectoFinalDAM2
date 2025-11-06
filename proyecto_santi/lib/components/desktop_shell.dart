import 'package:flutter/material.dart';
import 'package:proyecto_santi/components/marco_desktop.dart';
import 'package:proyecto_santi/views/home/home_view.dart';
import 'package:proyecto_santi/views/activities/activities_view.dart';
import 'package:proyecto_santi/views/chat/chat_list_view.dart';
import 'package:proyecto_santi/views/chat/vistas/chat_view.dart';
import 'package:proyecto_santi/views/map/map_view.dart';
import 'package:proyecto_santi/views/activityDetail/activity_detail_view.dart';
import 'package:proyecto_santi/views/gestion/actividades_crud_view.dart';
import 'package:proyecto_santi/views/gestion/profesores_crud_view.dart';
import 'package:proyecto_santi/views/gestion/departamentos_crud_view.dart';
import 'package:proyecto_santi/views/gestion/grupos_crud_view.dart';
import 'package:proyecto_santi/views/gestion/cursos_crud_view.dart';
import 'package:proyecto_santi/views/gestion/alojamientos_crud_view.dart';
import 'package:proyecto_santi/views/gestion/empresas_transporte_crud_view.dart';
import 'package:proyecto_santi/views/gestion/usuarios_crud_view.dart';
import 'package:proyecto_santi/views/estadisticas/estadisticas_view.dart';
import 'package:proyecto_santi/func.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_santi/models/auth.dart';
import 'package:proyecto_santi/components/user_avatar.dart';

/// Shell que mantiene el menú fijo y solo cambia el contenido
class DesktopShell extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const DesktopShell({
    super.key,
    required this.onToggleTheme,
  });

  @override
  State<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<DesktopShell> {
  String _currentRoute = '/home'; // Siempre empieza en home
  String _previousRoute = '/home'; // Ruta anterior para volver atrás
  Map<String, dynamic>? _activityDetailArgs;
  Map<String, dynamic>? _chatViewArgs;
  int _activitiesCount = 0; // Contador de actividades

  @override
  void initState() {
    super.initState();
    // Siempre empezar en home
    _currentRoute = '/home';
  }

  // Método público para navegar entre rutas
  // Método para actualizar el contador de actividades
  void updateActivitiesCount(int count) {
    if (mounted) {
      setState(() {
        _activitiesCount = count;
      });
    }
  }

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
      case '/solicitar-actividad':
        return 'Solicitar Actividad';
      case '/estadisticas':
        return 'Estadísticas';
      case '/activityDetail':
        return 'Detalle de Actividad';
      case '/gestion/actividades':
        return 'Gestión de Actividades';
      case '/gestion/profesores':
        return 'Gestión de Profesores';
      case '/gestion/departamentos':
        return 'Gestión de Departamentos';
      case '/gestion/grupos':
        return 'Gestión de Grupos';
      case '/gestion/cursos':
        return 'Gestión de Cursos';
      case '/gestion/alojamientos':
        return 'Gestión de Alojamientos';
      case '/gestion/empresas-transporte':
        return 'Gestión de Empresas de Transporte';
      case '/gestion/usuarios':
        return 'Gestión de Usuarios';
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
          final auth = Provider.of<Auth>(context, listen: false);
          return ChatView(
            activityId: _chatViewArgs!['activityId'],
            displayName: _chatViewArgs!['displayName'],
            userId: auth.currentUser?.uuid ?? '0',
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
      case '/solicitar-actividad':
        return Center(
          child: Text(
            'Vista de Solicitar Actividad - Próximamente',
            style: TextStyle(fontSize: 24),
          ),
        );
      case '/estadisticas':
        return EstadisticasView();
      case '/activityDetail':
        if (_activityDetailArgs != null) {
          return ActivityDetailView(
            actividad: _activityDetailArgs!['activity'],
            onToggleTheme: widget.onToggleTheme,
            isDarkTheme: Theme.of(context).brightness == Brightness.dark,
          );
        }
        return HomeView(onToggleTheme: widget.onToggleTheme);
      case '/gestion/actividades':
        return ActividadesCrudView();
      case '/gestion/profesores':
        return ProfesoresCrudView();
      case '/gestion/departamentos':
        return DepartamentosCrudView();
      case '/gestion/grupos':
        return GruposCrudView();
      case '/gestion/cursos':
        return CursosCrudView();
      case '/gestion/alojamientos':
        return AlojamientosCrudView();
      case '/gestion/empresas-transporte':
        return EmpresasTransporteCrudView();
      case '/gestion/usuarios':
        return UsuariosCrudView();
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
        activitiesCount: _activitiesCount, // Pasar el contador
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

// Función helper para actualizar el contador de actividades
void updateActivitiesCountInShell(BuildContext context, int count) {
  final shellState = _DesktopShellScope.of(context);
  if (shellState != null) {
    shellState.updateActivitiesCount(count);
  }
}

// Función helper para verificar si estamos dentro del shell
bool isInsideDesktopShell(BuildContext context) {
  return _DesktopShellScope.of(context) != null;
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
    final auth = Provider.of<Auth>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatView(
          activityId: args['activityId'],
          displayName: args['displayName'],
          userId: auth.currentUser?.uuid ?? '0',
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
  final int activitiesCount; // Número de actividades
  final Function(String) onNavigate;
  final VoidCallback onToggleTheme;
  final Widget child;

  const DesktopShellFrame({
    super.key,
    required this.currentRoute,
    required this.currentTitle,
    required this.activitiesCount, // Nuevo parámetro
    required this.onNavigate,
    required this.onToggleTheme,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determinar si es móvil basándose en el ancho y alto
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
        
        // Móvil: ancho < 800 o (landscape con altura < 600)
        final isMobile = width < 800 || (isLandscape && height < 600);
        final isMobileLandscape = isMobile && isLandscape;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        if (isMobile) {
          // Obtener información del usuario para móvil
          final auth = Provider.of<Auth>(context, listen: false);
          final currentUser = auth.currentUser;
          
          // Versión móvil: Scaffold con Drawer oculto
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: isMobileLandscape ? 48 : 56, // Más compacto en landscape
              // Sin título, solo iconos y usuario
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Icon(
                    Icons.menu,
                    size: isMobileLandscape ? 20 : 24,
                    color: isDark ? Colors.white : const Color(0xFF1976d2),
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
              actions: [
                // Mostrar avatar y info del usuario en móvil (compacta)
                if (currentUser != null)
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _showAccountSettingsDialog(context, currentUser, isDark),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobileLandscape ? 4.0 : 8.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isMobileLandscape) // Ocultar texto en landscape
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currentUser.nombre,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : const Color(0xFF1976d2),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  currentUser.rol,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.amber : const Color(0xFF1976d2).withValues(alpha: 0.7),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          SizedBox(width: isMobileLandscape ? 4 : 8),
                          UserAvatar(
                            user: currentUser,
                            size: isMobileLandscape ? 28 : 36,
                            fontSize: isMobileLandscape ? 12 : 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    size: isMobileLandscape ? 20 : 24,
                    color: isDark ? Colors.amber : const Color(0xFF1976d2),
                  ),
                  onPressed: onToggleTheme,
                  tooltip: 'Cambiar tema',
                ),
              ],
            ),
            drawer: MenuDesktopStatic(
              currentRoute: currentRoute,
              onNavigate: onNavigate,
              showLogo: !isMobileLandscape, // Ocultar logo en landscape móvil
            ),
            body: child,
          );
        } else {
          // Versión desktop: menú fijo lateral
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
                            activitiesCount: currentRoute == '/home' ? activitiesCount : null, // Solo mostrar en home
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
                        color: Colors.black.withValues(alpha: 0.15),
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
        }
      },
    );
  }

  void _showAccountSettingsDialog(BuildContext context, dynamic currentUser, bool isDark) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.account_circle,
                color: isDark ? Colors.amber : Color(0xFF1976d2),
                size: 28,
              ),
              SizedBox(width: 12),
              Text('Configuración de Cuenta'),
            ],
          ),
          content: SingleChildScrollView(
            child: Container(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar y nombre del usuario
                  Center(
                    child: Column(
                      children: [
                        UserAvatar(
                          user: currentUser,
                          size: 80,
                          fontSize: 32,
                        ),
                        SizedBox(height: 16),
                        Text(
                          currentUser?.nombre ?? 'Usuario',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Color(0xFF1976d2),
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.amber.withValues(alpha: 0.2) : Color(0xFF1976d2).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            currentUser?.rol ?? 'Rol',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.amber : Color(0xFF1976d2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  Divider(),
                  SizedBox(height: 16),
                  
                  // Información del usuario
                  Text(
                    'Información Personal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Color(0xFF1976d2),
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  _buildInfoTile(
                    icon: Icons.email,
                    label: 'Correo',
                    value: currentUser?.correo ?? 'No disponible',
                    isDark: isDark,
                  ),
                  SizedBox(height: 8),
                  
                  _buildInfoTile(
                    icon: Icons.badge,
                    label: 'DNI',
                    value: currentUser?.dni?.isNotEmpty == true ? currentUser!.dni : 'No disponible',
                    isDark: isDark,
                  ),
                  
                  SizedBox(height: 24),
                  Divider(),
                  SizedBox(height: 16),
                  
                  // Opciones de configuración (placeholder)
                  Text(
                    'Opciones',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Color(0xFF1976d2),
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  ListTile(
                    leading: Icon(
                      Icons.lock,
                      color: isDark ? Colors.white70 : Color(0xFF1976d2),
                    ),
                    title: Text('Cambiar Contraseña'),
                    subtitle: Text('Próximamente disponible'),
                    contentPadding: EdgeInsets.zero,
                    enabled: false,
                  ),
                  
                  ListTile(
                    leading: Icon(
                      Icons.notifications,
                      color: isDark ? Colors.white70 : Color(0xFF1976d2),
                    ),
                    title: Text('Notificaciones'),
                    subtitle: Text('Próximamente disponible'),
                    contentPadding: EdgeInsets.zero,
                    enabled: false,
                  ),
                  
                  ListTile(
                    leading: Icon(
                      Icons.language,
                      color: isDark ? Colors.white70 : Color(0xFF1976d2),
                    ),
                    title: Text('Idioma'),
                    subtitle: Text('Español (predeterminado)'),
                    contentPadding: EdgeInsets.zero,
                    enabled: false,
                  ),
                ],
              ),
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
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? Colors.white70 : Color(0xFF1976d2),
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Menú lateral estático que usa callback en lugar de Navigator
class MenuDesktopStatic extends StatelessWidget {
  final String currentRoute;
  final Function(String) onNavigate;
  final bool showLogo;

  const MenuDesktopStatic({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    this.showLogo = true, // Por defecto mostrar logo
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const ContinuousRectangleBorder(),
      child: _buildMenuContent(context),
    );
  }

  Widget _buildMenuContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final height = MediaQuery.of(context).size.height;
    final isMobileLandscape = isLandscape && height < 600;
    
    // Obtener el usuario actual para verificar si es admin
    final auth = Provider.of<Auth>(context, listen: false);
    final currentUser = auth.currentUser;
    final isAdmin = currentUser?.rol.toLowerCase() == 'admin' || 
                    currentUser?.rol.toLowerCase() == 'administrador';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
              : [const Color(0xFFe3f2fd), const Color(0xFFbbdefb)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: <Widget>[
          // Header - Mostrar solo si showLogo es true
          if (showLogo)
            Container(
              height: 140.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0f3460), const Color(0xFF16213e)]
                      : [const Color(0xFF1976d2), const Color(0xFF2196f3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.school,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Column(
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
            )
          // Mostrar info de usuario en landscape móvil cuando no hay logo
          else if (isMobileLandscape && currentUser != null)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white12 : Colors.black12,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  UserAvatar(
                    user: currentUser,
                    size: 32,
                    fontSize: 14,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentUser.nombre,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1976d2),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          currentUser.rol,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.amber : const Color(0xFF1976d2).withValues(alpha: 0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: showLogo ? 16 : (isMobileLandscape ? 4 : 8)),

          // Items del menú
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: isMobileLandscape ? 6 : 8),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home_rounded,
                  text: 'Inicio',
                  routeName: '/home',
                  isCompact: isMobileLandscape,
                ),
                SizedBox(height: isMobileLandscape ? 4 : 8),
                _buildDrawerItem(
                  context,
                  icon: Icons.event_rounded,
                  text: 'Actividades',
                  routeName: '/actividades',
                  isCompact: isMobileLandscape,
                ),
                SizedBox(height: isMobileLandscape ? 4 : 8),
                _buildDrawerItem(
                  context,
                  icon: Icons.chat_bubble_rounded,
                  text: 'Chat',
                  routeName: '/chat',
                  isCompact: isMobileLandscape,
                ),
                SizedBox(height: isMobileLandscape ? 4 : 8),
                _buildDrawerItem(
                  context,
                  icon: Icons.map_rounded,
                  text: 'Mapa',
                  routeName: '/mapa',
                  isCompact: isMobileLandscape,
                ),
                SizedBox(height: isMobileLandscape ? 4 : 8),
                _buildDrawerItem(
                  context,
                  icon: Icons.add_circle_outline_rounded,
                  text: 'Solicitar actividad',
                  routeName: '/solicitar-actividad',
                  isCompact: isMobileLandscape,
                ),
                SizedBox(height: isMobileLandscape ? 4 : 8),
                _buildDrawerItem(
                  context,
                  icon: Icons.bar_chart_rounded,
                  text: 'Estadísticas',
                  routeName: '/estadisticas',
                  isCompact: isMobileLandscape,
                ),
                // Menú de Gestión solo para administradores
                if (isAdmin) ...[
                  SizedBox(height: isMobileLandscape ? 4 : 8),
                  _buildGestionMenu(context, isDark, isCompact: isMobileLandscape),
                ],
              ],
            ),
          ),

          // Separador
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(
              horizontal: 16, 
              vertical: isMobileLandscape ? 4 : 8,
            ),
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
            padding: EdgeInsets.symmetric(
              horizontal: isMobileLandscape ? 6 : 8, 
              vertical: isMobileLandscape ? 4 : 8,
            ),
            child: Column(
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_rounded,
                  text: 'Configuración',
                  routeName: '/configuracion',
                  isSettings: true,
                  isCompact: isMobileLandscape,
                ),
                SizedBox(height: isMobileLandscape ? 4 : 8),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout_rounded,
                  text: 'Salir',
                  routeName: '/',
                  isLogout: true,
                  isCompact: isMobileLandscape,
                ),
              ],
            ),
          ),
          SizedBox(height: isMobileLandscape ? 8 : 16),
        ],
      ),
    );
  }

  Widget _buildGestionMenu(BuildContext context, bool isDark, {bool isCompact = false}) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16, 
          vertical: isCompact ? 2 : 4,
        ),
        childrenPadding: EdgeInsets.zero,
        leading: Icon(
          Icons.admin_panel_settings_rounded,
          color: isDark ? Colors.white70 : const Color(0xFF1976d2),
          size: isCompact ? 20 : 24,
        ),
        title: Text(
          'Gestión',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1976d2),
            fontSize: isCompact ? 13 : 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconColor: isDark ? Colors.white70 : const Color(0xFF1976d2),
        collapsedIconColor: isDark ? Colors.white70 : const Color(0xFF1976d2),
        children: [
          _buildSubMenuItem(context, isDark, Icons.person, 'Profesores', '/gestion/profesores', isCompact: isCompact),
          _buildSubMenuItem(context, isDark, Icons.business, 'Departamentos', '/gestion/departamentos', isCompact: isCompact),
          _buildSubMenuItem(context, isDark, Icons.group, 'Grupos', '/gestion/grupos', isCompact: isCompact),
          _buildSubMenuItem(context, isDark, Icons.school, 'Cursos', '/gestion/cursos', isCompact: isCompact),
          _buildSubMenuItem(context, isDark, Icons.hotel, 'Alojamientos', '/gestion/alojamientos', isCompact: isCompact),
          _buildSubMenuItem(context, isDark, Icons.directions_bus, 'Empresas de Transporte', '/gestion/empresas-transporte', isCompact: isCompact),
          _buildSubMenuItem(context, isDark, Icons.account_circle, 'Usuarios', '/gestion/usuarios', isCompact: isCompact),
        ],
      ),
    );
  }

  Widget _buildSubMenuItem(BuildContext context, bool isDark, IconData icon, String text, String routeName, {bool isCompact = false}) {
    return Container(
      margin: EdgeInsets.only(
        bottom: isCompact ? 2 : 4, 
        left: isCompact ? 6 : 8, 
        right: isCompact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
          onTap: () {
            this.onNavigate(routeName);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 12 : 16, 
              vertical: isCompact ? 6 : 10,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDark ? Colors.white60 : const Color(0xFF1976d2).withValues(alpha: 0.7),
                  size: isCompact ? 18 : 20,
                ),
                SizedBox(width: isCompact ? 10 : 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF1976d2),
                      fontSize: isCompact ? 12 : 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
    bool isCompact = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCurrentRoute = currentRoute == routeName;

    return Container(
      decoration: BoxDecoration(
        gradient: isCurrentRoute
            ? LinearGradient(
                colors: isDark
                    ? [const Color(0xFF0f3460), const Color(0xFF16213e)]
                    : [const Color(0xFF1976d2), const Color(0xFF2196f3)],
              )
            : null,
        borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
        boxShadow: isCurrentRoute
            ? [
                BoxShadow(
                  color: (isDark ? Colors.blue : Colors.blue).withValues(alpha: 0.3),
                  offset: Offset(0, isCompact ? 2 : 4),
                  blurRadius: isCompact ? 4 : 8,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
          onTap: () async {
            if (isLogout) {
              // Mostrar diálogo de confirmación para salir
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Confirmar salida'),
                    content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text('Sí'),
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
              final isDarkSettings = Theme.of(context).brightness == Brightness.dark;
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Configuración'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Opciones de la aplicación',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            leading: const Icon(Icons.palette),
                            title: const Text('Tema'),
                            subtitle: Text(isDarkSettings 
                                ? 'Modo oscuro' 
                                : 'Modo claro'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          const ListTile(
                            leading: Icon(Icons.info),
                            title: Text('Versión'),
                            subtitle: Text('1.0.0'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          const ListTile(
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
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 12 : 16, 
              vertical: isCompact ? 8 : 14,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isCurrentRoute
                      ? Colors.white
                      : (isDark ? Colors.white70 : const Color(0xFF1976d2)),
                  size: isCompact ? 20 : 24,
                ),
                SizedBox(width: isCompact ? 12 : 16),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isCurrentRoute
                          ? Colors.white
                          : (isDark ? Colors.white : const Color(0xFF1976d2)),
                      fontSize: isCompact ? 13 : 15,
                      fontWeight: isCurrentRoute ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (isCurrentRoute)
                  Container(
                    width: isCompact ? 6 : 8,
                    height: isCompact ? 6 : 8,
                    decoration: const BoxDecoration(
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
