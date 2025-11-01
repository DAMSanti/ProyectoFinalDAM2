import 'package:flutter/material.dart';
import 'package:proyecto_santi/func.dart';
import 'package:proyecto_santi/tema/theme.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_santi/models/auth.dart';
import 'package:proyecto_santi/components/user_avatar.dart';

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
  final int? activitiesCount; // Contador de actividades (opcional)

  const DesktopBar({
    super.key, 
    required this.onToggleTheme,
    this.title,
    this.activitiesCount, // Nuevo parámetro opcional
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Obtener información del usuario
    final auth = Provider.of<Auth>(context, listen: false);
    final currentUser = auth.currentUser;
    
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
              title: activitiesCount != null
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        // Si el ancho es muy pequeño, mostrar versión compacta
                        if (constraints.maxWidth < 400) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event_available_rounded,
                                color: Color(0xFF1976d2),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Actividades',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1976d2),
                                    letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Color(0xFF1976d2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$activitiesCount',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        
                        // Versión completa
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF1976d2).withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.event_available_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                title ?? 'Próximas Actividades',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1976d2),
                                  letterSpacing: 0.5,
                                  fontFamily: 'Roboto',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 12),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF1976d2).withValues(alpha: 0.3),
                                    offset: Offset(0, 2),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Text(
                                '$activitiesCount',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : Text(
                      title ?? 'Próximas Actividades',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976d2),
                        letterSpacing: 0.5,
                        fontFamily: 'Roboto',
                      ),
                    ),
              leading: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 12.0),
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showAccountSettingsDialog(context, currentUser, isDark),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            UserAvatar(
                              user: currentUser,
                              size: 48,
                              fontSize: 18,
                            ),
                            SizedBox(width: 12),
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (currentUser?.nombre != null)
                                    Text(
                                      currentUser!.nombre,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : Color(0xFF1976d2),
                                        height: 1.2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  if (currentUser?.rol != null)
                                    Text(
                                      currentUser!.rol,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.amber : Color(0xFF1976d2).withValues(alpha: 0.7),
                                        height: 1.2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.settings,
                              size: 18,
                              color: isDark ? Colors.white70 : Color(0xFF1976d2).withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
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
    
    // Obtener el usuario actual para verificar si es admin
    final auth = Provider.of<Auth>(context, listen: false);
    final currentUser = auth.currentUser;
    final isAdmin = currentUser?.rol.toLowerCase() == 'admin' || 
                    currentUser?.rol.toLowerCase() == 'administrador';
    
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
                    color: Colors.white.withValues(alpha: 0.2),
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
                // Menú de Gestión solo para administradores
                if (isAdmin) ...[
                  SizedBox(height: 8),
                  _buildGestionMenu(context, isDark),
                ],
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

  Widget _buildGestionMenu(BuildContext context, bool isDark) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: EdgeInsets.only(left: 8),
        leading: Icon(
          Icons.admin_panel_settings_rounded,
          color: isDark ? Colors.white70 : Color(0xFF1976d2),
          size: 24,
        ),
        title: Text(
          'Gestión',
          style: TextStyle(
            color: isDark ? Colors.white : Color(0xFF1976d2),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconColor: isDark ? Colors.white70 : Color(0xFF1976d2),
        collapsedIconColor: isDark ? Colors.white70 : Color(0xFF1976d2),
        children: [
          _buildSubMenuItem(context, isDark, Icons.event, 'Actividades', '/gestion/actividades'),
          _buildSubMenuItem(context, isDark, Icons.person, 'Profesores', '/gestion/profesores'),
          _buildSubMenuItem(context, isDark, Icons.business, 'Departamentos', '/gestion/departamentos'),
          _buildSubMenuItem(context, isDark, Icons.group, 'Grupos', '/gestion/grupos'),
          _buildSubMenuItem(context, isDark, Icons.school, 'Cursos', '/gestion/cursos'),
          _buildSubMenuItem(context, isDark, Icons.hotel, 'Alojamientos', '/gestion/alojamientos'),
          _buildSubMenuItem(context, isDark, Icons.directions_bus, 'Empresas de Transporte', '/gestion/empresas-transporte'),
        ],
      ),
    );
  }

  Widget _buildSubMenuItem(BuildContext context, bool isDark, IconData icon, String text, String routeName) {
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.pushReplacementNamed(context, routeName);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDark ? Colors.white60 : Color(0xFF1976d2).withValues(alpha: 0.7),
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Color(0xFF1976d2),
                      fontSize: 14,
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
                  color: (isDark ? Colors.blue : Colors.blue).withValues(alpha: 0.3),
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
