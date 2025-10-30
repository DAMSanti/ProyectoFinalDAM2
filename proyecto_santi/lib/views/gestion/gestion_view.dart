import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Vista principal de Gestión con navegación a todas las entidades CRUD
class GestionView extends StatelessWidget {
  const GestionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestión',
          style: TextStyle(fontSize: kIsWeb ? 20 : 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(kIsWeb ? 20 : 24),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Panel de Administración',
                  style: TextStyle(
                    fontSize: kIsWeb ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976d2),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: kIsWeb ? 12 : 16),
                Text(
                  'Selecciona una entidad para gestionar',
                  style: TextStyle(
                    fontSize: kIsWeb ? 14 : 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: kIsWeb ? 24 : 32),
                _buildEntityGrid(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEntityGrid(BuildContext context) {
    final entities = [
      {
        'name': 'Actividades',
        'icon': Icons.event,
        'route': '/gestion/actividades',
        'color': Colors.blue,
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

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: kIsWeb ? 4 : 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: kIsWeb ? 12 : 16,
        mainAxisSpacing: kIsWeb ? 12 : 16,
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
          padding: EdgeInsets.all(kIsWeb ? 12 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: kIsWeb ? 40 : 48,
                color: color,
              ),
              SizedBox(height: kIsWeb ? 8 : 12),
              Text(
                name,
                style: TextStyle(
                  fontSize: kIsWeb ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
