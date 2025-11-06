import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:proyecto_santi/tema/gradient_background.dart';
import 'package:proyecto_santi/tema/app_colors.dart';

/// Vista principal de Gestión con navegación a todas las entidades CRUD
class GestionView extends StatelessWidget {
  const GestionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final isDesktop = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    return Stack(
      children: [
        // Fondo con gradiente consistente con el resto de la app
        isDark 
            ? GradientBackgroundDark(child: Container()) 
            : GradientBackgroundLight(child: Container()),
        
        // Contenido
        SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header simple sin gradiente complejo
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Panel de Gestión',
                        style: TextStyle(
                          fontSize: isMobile ? 28.sp : 32,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Administra todas las entidades del sistema',
                        style: TextStyle(
                          fontSize: isMobile ? 14.sp : 16,
                          color: isDark ? Colors.white70 : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Grid de entidades
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: 8,
                ),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 1400),
                      child: _buildEntityGrid(context, isMobile, isTablet, isDesktop, isDark),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEntityGrid(BuildContext context, bool isMobile, bool isTablet, bool isDesktop, bool isDark) {
    final entities = [
      {
        'name': 'Usuarios',
        'icon': Icons.account_circle,
        'route': '/gestion/usuarios',
        'color': Colors.deepPurple,
      },
      {
        'name': 'Profesores',
        'icon': Icons.person,
        'route': '/gestion/profesores',
        'color': Colors.green,
      },
      {
        'name': 'Alojamientos',
        'icon': Icons.hotel,
        'route': '/gestion/alojamientos',
        'color': Colors.orange,
      },
      {
        'name': 'Departamentos',
        'icon': Icons.business,
        'route': '/gestion/departamentos',
        'color': Colors.purple,
      },
      {
        'name': 'Grupos',
        'icon': Icons.group,
        'route': '/gestion/grupos',
        'color': Colors.teal,
      },
      {
        'name': 'Cursos',
        'icon': Icons.school,
        'route': '/gestion/cursos',
        'color': Colors.indigo,
      },
      {
        'name': 'Transporte',
        'icon': Icons.directions_bus,
        'route': '/gestion/empresas-transporte',
        'color': Colors.red,
      },
    ];

    // Determinar número de columnas
    int crossAxisCount;
    double childAspectRatio;
    
    if (isMobile) {
      crossAxisCount = 2;
      childAspectRatio = 1.1;
    } else if (isTablet) {
      crossAxisCount = 3;
      childAspectRatio = 1.2;
    } else {
      crossAxisCount = 4;
      childAspectRatio = 1.3;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: isMobile ? 12 : 16,
        mainAxisSpacing: isMobile ? 12 : 16,
      ),
      itemCount: entities.length,
      itemBuilder: (context, index) {
        final entity = entities[index];
        return _buildEntityCard(
          context,
          name: entity['name'] as String,
          icon: entity['icon'] as IconData,
          route: entity['route'] as String,
          color: entity['color'] as Color,
          isMobile: isMobile,
          isDark: isDark,
        );
      },
    );
  }

  Widget _buildEntityCard(
    BuildContext context, {
    required String name,
    required IconData icon,
    required String route,
    required Color color,
    required bool isMobile,
    required bool isDark,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDark ? Colors.grey[850] : Colors.white,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: isMobile ? 32.sp : 40,
                color: color,
              ),
            ),
            SizedBox(height: isMobile ? 8 : 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                name,
                style: TextStyle(
                  fontSize: isMobile ? 13.sp : 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textLight,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
