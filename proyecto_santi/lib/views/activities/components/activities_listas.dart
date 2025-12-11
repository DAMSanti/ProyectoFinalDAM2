import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/auth.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/components/desktop_shell.dart';
import 'package:proyecto_santi/shared/helpers/activity_formatters.dart';
class AllActividades extends StatefulWidget {
  final String? selectedFilter;
  final String searchQuery;
  final DateTime? selectedDate;
  final String? selectedCourse;
  final String? selectedState;
  final String? selectedProfesorId;
  final Function(int)? onCountChanged;
  AllActividades({
    required this.selectedFilter,
    required this.searchQuery,
    required this.selectedDate,
    required this.selectedCourse,
    required this.selectedState,
    this.selectedProfesorId,
    this.onCountChanged,
  });
  @override
  AllActividadesState createState() => AllActividadesState();
}
class AllActividadesState extends State<AllActividades> {
  late final ApiService _apiService;
  late final ActividadService _actividadService;
  late final CatalogoService _catalogoService;
  late final ProfesorService _profesorService;
  List<Actividad> _allActividades = [];
  List<Actividad> _filteredActividades = [];
  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _actividadService = ActividadService(_apiService);
    _catalogoService = CatalogoService(_apiService);
    _profesorService = ProfesorService(_apiService);
    _fetchActivities();
  }
  void _fetchActivities() async {
    List<Actividad> actividades = await _actividadService.fetchActivities(pageSize: 100);
    setState(() {
      _allActividades = actividades;
    });
    await _filterActivities();
  }
  Future<void> _filterActivities() async {
    List<Actividad> filtered = [];
    for (var actividad in _allActividades) {
      final matchesSearch = actividad.titulo.toLowerCase().contains(widget.searchQuery.toLowerCase());
      if (!matchesSearch) continue;
      filtered.add(actividad);
    }
    filtered.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.fini);
        final dateB = DateTime.parse(b.fini);
        return dateA.compareTo(dateB);
      } catch (e) {
        return 0; 
      }
    });
    setState(() {
      _filteredActividades = filtered;
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.onCountChanged?.call(_filteredActividades.length);
    });
  }
  @override
  void didUpdateWidget(AllActividades oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.selectedState != widget.selectedState ||
        oldWidget.selectedCourse != widget.selectedCourse ||
        oldWidget.selectedProfesorId != widget.selectedProfesorId) {
      _filterActivities();
    }
  }
  @override
  Widget build(BuildContext context) {
    return _filteredActividades.isEmpty
        ? Center(child: Text('No hay actividades disponibles'))
        : ListView.builder(
      itemCount: _filteredActividades.length,
      itemBuilder: (context, index) {
        var actividad = _filteredActividades[index];
        return HoverableListItem(actividad: actividad);
      },
    );
  }
}
class OtrasActividades extends StatefulWidget {
  final String? selectedFilter;
  final String searchQuery;
  final DateTime? selectedDate;
  final String? selectedCourse;
  final String? selectedState;
  final String? selectedProfesorId;
  final Function(int)? onCountChanged;
  OtrasActividades({
    required this.selectedFilter,
    required this.searchQuery,
    required this.selectedDate,
    required this.selectedCourse,
    required this.selectedState,
    this.selectedProfesorId,
    this.onCountChanged,
  });
  @override
  OtrasActividadesState createState() => OtrasActividadesState();
}
class OtrasActividadesState extends State<OtrasActividades> {
  late final ApiService _apiService;
  late final ActividadService _actividadService;
  late final CatalogoService _catalogoService;
  late final ProfesorService _profesorService;
  List<Actividad> _otrasActividades = [];
  List<Actividad> _filteredOtrasActividades = [];
  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _actividadService = ActividadService(_apiService);
    _catalogoService = CatalogoService(_apiService);
    _profesorService = ProfesorService(_apiService);
    _fetchActivities();
  }
  void _fetchActivities() async {
    List<Actividad> actividades = await _actividadService.fetchActivities(pageSize: 100);
    setState(() {
      _otrasActividades = actividades;
    });
    await _filterActivities();
  }
  Future<void> _filterActivities() async {
    final auth = Provider.of<Auth>(context, listen: false);
    final currentUser = auth.currentUser;
    final currentUserUuid = currentUser?.uuid;
    final rol = currentUser?.rol;
    if (currentUserUuid == null) {
      print('[OtrasActividades] ⚠️ No hay usuario autenticado');
      setState(() {
        _filteredOtrasActividades = [];
      });
      SchedulerBinding.instance.addPostFrameCallback((_) {
        widget.onCountChanged?.call(0);
      });
      return;
    }
    print('[OtrasActividades] 🔍 Filtrando actividades para usuario: $currentUserUuid (Rol: $rol)');
    final isAdminOrCoord = rol == 'Administrador' || rol == 'Admin' || rol == 'Coordinador' || rol == 'ED';
    List<Actividad> filtered = [];
    for (var actividad in _otrasActividades) {
      final matchesSearch = actividad.titulo.toLowerCase().contains(widget.searchQuery.toLowerCase());
      if (!matchesSearch) continue;
      bool matchesState = true;
      if (widget.selectedState != null && widget.selectedState!.isNotEmpty) {
        matchesState = actividad.estado.toLowerCase() == widget.selectedState!.toLowerCase();
      }
      if (!matchesState) continue;
      bool matchesCourse = true;
      if (widget.selectedCourse != null && widget.selectedCourse!.isNotEmpty) {
        try {
          final gruposParticipantes = await _catalogoService.fetchGruposParticipantes(actividad.id);
          matchesCourse = gruposParticipantes.any((grupo) {
            final cursoNombre = grupo['cursoNombre']?.toString() ?? '';
            return cursoNombre.trim().toLowerCase() == widget.selectedCourse!.trim().toLowerCase();
          });
        } catch (e) {
          print('[ERROR] Error obteniendo grupos para actividad ${actividad.id}: $e');
          matchesCourse = false;
        }
      }
      if (!matchesCourse) continue;
      bool isUserActivity = true; 
      if (!isAdminOrCoord) {
        isUserActivity = false;
        try {
          bool isResponsable = actividad.responsable?.uuid.toLowerCase() == currentUserUuid.toLowerCase();
          bool isParticipante = actividad.profesoresParticipantesIds
              .any((id) => id.toLowerCase() == currentUserUuid.toLowerCase());
          isUserActivity = isResponsable || isParticipante;
          print('[OtrasActividades] Actividad ${actividad.id} "${actividad.titulo}": '
              'Responsable=$isResponsable, Participante=$isParticipante → ${isUserActivity ? "✅ INCLUIR" : "❌ EXCLUIR"}');
        } catch (e) {
          print('[ERROR] Error verificando participación en actividad ${actividad.id}: $e');
          isUserActivity = false;
        }
      }
      if (!isUserActivity) continue;
      filtered.add(actividad);
    }
    filtered.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.fini);
        final dateB = DateTime.parse(b.fini);
        return dateB.compareTo(dateA); 
      } catch (e) {
        return 0; 
      }
    });
    print('[OtrasActividades] ✅ Total actividades filtradas: ${filtered.length} ${isAdminOrCoord ? "(Admin/Coord - Todas)" : "(Profesor - Solo las suyas)"}');
    setState(() {
      _filteredOtrasActividades = filtered;
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.onCountChanged?.call(_filteredOtrasActividades.length);
    });
  }
  @override
  void didUpdateWidget(OtrasActividades oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.selectedState != widget.selectedState ||
        oldWidget.selectedCourse != widget.selectedCourse ||
        oldWidget.selectedProfesorId != widget.selectedProfesorId) {
      _filterActivities();
    }
  }
  @override
  Widget build(BuildContext context) {
    return _filteredOtrasActividades.isEmpty
        ? Center(child: Text('No hay actividades disponibles'))
        : ListView.builder(
      itemCount: _filteredOtrasActividades.length,
      itemBuilder: (context, index) {
        var actividad = _filteredOtrasActividades[index];
        return HoverableListItem(actividad: actividad);
      },
    );
  }
}
class HoverableListItem extends StatefulWidget {
  final Actividad actividad;
  const HoverableListItem({super.key, required this.actividad});
  @override
  HoverableListItemState createState() => HoverableListItemState();
}
class HoverableListItemState extends State<HoverableListItem> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fechaHora = ActivityFormatters.formatearFechaHora(widget.actividad);
    final estadoColor = ActivityFormatters.getEstadoColor(widget.actividad.estado);
    final estadoIcon = ActivityFormatters.getEstadoIcon(widget.actividad.estado);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          transform: _isHovered 
              ? (Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..setTranslationRaw(8.0, 0.0, 0.0)
                ..multiply(Matrix4.diagonal3Values(1.005, 1.005, 1.0)))
              : Matrix4.identity(),
          child: Container(
            height: 95, 
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: isDark
                    ? const [
                        Color.fromRGBO(25, 118, 210, 0.20),
                        Color.fromRGBO(21, 101, 192, 0.15),
                      ]
                    : const [
                        Color.fromRGBO(187, 222, 251, 0.75),
                        Color.fromRGBO(144, 202, 249, 0.65),
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered 
                      ? const Color.fromRGBO(25, 118, 210, 0.30)
                      : (isDark ? const Color.fromRGBO(0, 0, 0, 0.35) : const Color.fromRGBO(0, 0, 0, 0.12)),
                  offset: _isHovered ? const Offset(6, 8) : const Offset(2, 3),
                  blurRadius: _isHovered ? 20.0 : 10.0,
                  spreadRadius: _isHovered ? 0 : -1,
                ),
                if (_isHovered)
                  const BoxShadow(
                    color: Color.fromRGBO(25, 118, 210, 0.15),
                    offset: Offset(3, 4),
                    blurRadius: 12.0,
                  ),
              ],
              border: Border.all(
                color: _isHovered
                    ? const Color.fromRGBO(25, 118, 210, 0.5)
                    : (isDark ? const Color.fromRGBO(255, 255, 255, 0.08) : const Color.fromRGBO(0, 0, 0, 0.04)),
                width: _isHovered ? 1.5 : 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: widget.actividad.tipo == 'Complementaria'
                              ? [
                                  Color(0xFF1976d2), 
                                  Color(0xFF42A5F5), 
                                  Color(0xFF64B5F6), 
                                ]
                              : [
                                  Color(0xFFE65100), 
                                  Color(0xFFFF6F00), 
                                  Color(0xFFFF9800), 
                                ],
                          ),
                        ),
                      ),
                    ),
                    if (_isHovered)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                const Color.fromRGBO(25, 118, 210, 0.08),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      right: -15,
                      top: -15,
                      child: Opacity(
                        opacity: isDark ? 0.04 : 0.03,
                        child: Icon(
                          Icons.event_note_rounded,
                          size: 90,
                          color: Color(0xFF1976d2),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        navigateToActivityDetailInShell(
                          context,
                          {'activity': widget.actividad},
                        );
                      },
                      borderRadius: BorderRadius.circular(16.0),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(25, 118, 210, 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color.fromRGBO(25, 118, 210, 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.event_available_rounded,
                                color: Color(0xFF1976d2),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.actividad.titulo,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Color(0xFF1A237E),
                                      letterSpacing: -0.3,
                                      height: 1.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.actividad.descripcion?.isNotEmpty == true 
                                        ? widget.actividad.descripcion! 
                                        : 'Sin descripción',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white60 : Colors.black54,
                                      height: 1.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 14,
                                      color: isDark ? Colors.white54 : Colors.black45,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      fechaHora,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? Colors.white60 : Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(
                                      (estadoColor.r * 255.0).round(),
                                      (estadoColor.g * 255.0).round(),
                                      (estadoColor.b * 255.0).round(),
                                      0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Color.fromRGBO(
                                        (estadoColor.r * 255.0).round(),
                                        (estadoColor.g * 255.0).round(),
                                        (estadoColor.b * 255.0).round(),
                                        0.4,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        estadoIcon,
                                        size: 12,
                                        color: estadoColor,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        widget.actividad.estado,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: estadoColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}