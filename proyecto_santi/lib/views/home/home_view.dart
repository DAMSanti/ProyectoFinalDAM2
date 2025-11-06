import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/auth.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/views/home/views/home_portrait_layout.dart';
import 'package:proyecto_santi/views/home/views/home_small_landscape_layout.dart';
import 'package:proyecto_santi/views/home/views/home_large_landscape_layout.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:proyecto_santi/shared/widgets/state_widgets.dart';

class HomeView extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomeView({super.key, required this.onToggleTheme});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  late Future<List<Actividad>> _futureActivities;
  late final ApiService _apiService;
  late final ActividadService _actividadService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _actividadService = ActividadService(_apiService);
    _futureActivities = _loadAndFilterActivities();
  }

  Future<List<Actividad>> _loadAndFilterActivities() async {
    final auth = Provider.of<Auth>(context, listen: false);
    final currentUser = auth.currentUser;
    final rol = currentUser?.rol;
    final profesorUuid = currentUser?.uuid;

    print('[HomeView] Usuario actual: ${currentUser?.nombre}');
    print('[HomeView] Rol: $rol');
    print('[HomeView] ProfesorUuid: $profesorUuid');

    // Cargar todas las actividades
    final actividades = await _actividadService.fetchFutureActivities();
    
    print('[HomeView] Total actividades cargadas: ${actividades.length}');

    // Filtrar según el rol
    if (rol == 'Administrador' || rol == 'Admin' || rol == 'Coordinador' || rol == 'ED') {
      // Administradores y coordinadores ven todas las actividades
      print('[HomeView] Admin/Coordinador - Mostrando todas las actividades');
      return actividades;
    } else if (rol == 'Profesor' || rol == 'PROF') {
      // Profesores solo ven actividades donde son responsables o participantes
      print('[HomeView] Filtrando actividades para profesor...');
      
      final actividadesFiltradas = actividades.where((actividad) {
        // Es responsable
        final esResponsable = actividad.responsable?.uuid == profesorUuid;
        
        print('[HomeView] Actividad ${actividad.id} - ${actividad.titulo}');
        print('[HomeView]   Responsable UUID: ${actividad.responsable?.uuid}');
        print('[HomeView]   Es responsable: $esResponsable');
        
        // Es participante (cuando implementemos la lista de participantes)
        // Por ahora solo filtramos por responsable
        return esResponsable;
      }).toList();
      
      print('[HomeView] Actividades filtradas: ${actividadesFiltradas.length}');
      return actividadesFiltradas;
    } else {
      // Otros roles no ven actividades
      print('[HomeView] Rol sin acceso: $rol');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final rol = auth.currentUser?.rol;

    // Bloquear acceso a usuarios normales
    if (rol != null && 
        rol != 'Administrador' && 
        rol != 'Admin' && 
        rol != 'Coordinador' && 
        rol != 'ED' && 
        rol != 'Profesor' && 
        rol != 'PROF') {
      return Stack(
        children: [
          Theme.of(context).brightness == Brightness.dark
              ? GradientBackgroundDark(child: Container())
              : GradientBackgroundLight(child: Container()),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.error.withOpacity(0.6),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Acceso Restringido',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Temporalmente el acceso está restringido a usuarios.\nSolo profesores, coordinadores y administradores pueden acceder.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // El contenido se muestra directamente sin Scaffold
    // porque el DesktopShell ya proporciona el marco (tanto en desktop como en móvil)
    return Stack(
      children: [
        Theme.of(context).brightness == Brightness.dark
            ? GradientBackgroundDark(child: Container())
            : GradientBackgroundLight(child: Container()),
        FutureBuilder<List<Actividad>>(
          future: _futureActivities,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingState();
            } else if (snapshot.hasError) {
              return ErrorState(error: snapshot.error.toString());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return EmptyState(
                message: 'No hay actividades próximas',
                icon: Icons.event_busy_rounded,
              );
            } else {
              return _buildResponsiveLayout(context, snapshot.data!);
            }
          },
        ),
      ],
    );
  }

  Widget _buildResponsiveLayout(BuildContext context, List<Actividad> activities) {
    // Detectar si es desktop o móvil
    final width = MediaQuery.of(context).size.width;
    final isDesktop = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    if (isDesktop && width >= 800) {
      // Vista de escritorio grande
      return HomeLargeLandscapeLayout(
        activities: activities,
        onToggleTheme: widget.onToggleTheme,
      );
    } else {
      // Vista móvil (portrait o landscape pequeño)
      return OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return HomePortraitLayout(activities: activities);
          } else {
            return HomeSmallLandscapeLayout(activities: activities);
          }
        },
      );
    }
  }
}
