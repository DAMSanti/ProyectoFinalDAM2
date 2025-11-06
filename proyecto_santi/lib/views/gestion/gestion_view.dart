import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Vista principal de Gestión con navegación a todas las entidades CRUD
class GestionView extends StatelessWidget {
  const GestionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestión',
          style: TextStyle(fontSize: isMobile ? 18.sp : 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Panel de Administración',
                  style: TextStyle(
                    fontSize: isMobile ? 20.sp : 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976d2),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isMobile ? 8 : 12),
                Text(
                  'Selecciona una entidad para gestionar',
                  style: TextStyle(
                    fontSize: isMobile ? 12.sp : 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isMobile ? 16 : 24),
                _buildEntityGrid(context, isMobile, isDesktop),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEntityGrid(BuildContext context, bool isMobile, bool isDesktop) {
    final entities = [
      {
        'name': 'Actividades',
        'icon': Icons.event,
        'route': '/gestion/actividades',
        'color': Colors.blue,
      },
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
        'name': 'Empresas de Transporte',
        'icon': Icons.directions_bus,
        'route': '/gestion/empresas-transporte',
        'color': Colors.red,
      },
    ];

    // Determinar número de columnas basado en el ancho de pantalla
    int crossAxisCount;
    double childAspectRatio;
    
    if (isMobile) {
      crossAxisCount = 2;
      childAspectRatio = 1.0; // Más cuadrado en móvil
    } else if (isDesktop) {
      crossAxisCount = 4;
      childAspectRatio = 1.2;
    } else {
      crossAxisCount = 3; // Tablet
      childAspectRatio = 1.1;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: isMobile ? 8 : 12,
        mainAxisSpacing: isMobile ? 8 : 12,
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
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 8 : 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isMobile ? 32.sp : 40,
                color: color,
              ),
              SizedBox(height: isMobile ? 6 : 8),
              Flexible(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: isMobile ? 11.sp : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
