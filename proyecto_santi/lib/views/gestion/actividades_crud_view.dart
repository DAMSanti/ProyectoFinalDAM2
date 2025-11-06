import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/services/actividad_service.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import 'package:proyecto_santi/tema/app_colors.dart';

/// Vista CRUD moderna para gestionar Actividades
class ActividadesCrudView extends StatefulWidget {
  const ActividadesCrudView({Key? key}) : super(key: key);

  @override
  State<ActividadesCrudView> createState() => _ActividadesCrudViewState();
}

class _ActividadesCrudViewState extends State<ActividadesCrudView> {
  final ActividadService _actividadService = ActividadService(ApiService());
  List<Actividad> _actividades = [];
  List<Actividad> _filteredActividades = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  bool get isDesktop => kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  @override
  void initState() {
    super.initState();
    _loadActividades();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadActividades() async {
    setState(() => _isLoading = true);
    try {
      final actividades = await _actividadService.fetchActivities(pageSize: 100);
      if (mounted) {
        setState(() {
          _actividades = actividades;
          _filteredActividades = actividades;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar actividades')),
        );
      }
    }
  }

  void _filterActividades(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredActividades = _actividades;
      } else {
        final queryLower = query.toLowerCase();
        _filteredActividades = _actividades.where((actividad) {
          return actividad.titulo.toLowerCase().contains(queryLower) ||
              actividad.tipo.toLowerCase().contains(queryLower) ||
              actividad.estado.toLowerCase().contains(queryLower);
        }).toList();
      }
    });
  }

  void _editActividad(Actividad actividad) {
    Navigator.pushNamed(
      context,
      '/activityDetail',
      arguments: actividad.id,
    ).then((_) => _loadActividades());
  }

  Future<void> _showDeleteDialog(Actividad actividad) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar Actividad'),
          ],
        ),
        content: Text(
          '¿Está seguro de que desea eliminar la actividad "${actividad.titulo}"?\n\nEsta funcionalidad estará disponible próximamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Funcionalidad de eliminación próximamente disponible'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Stack(
      children: [
        isDark 
            ? GradientBackgroundDark(child: Container()) 
            : GradientBackgroundLight(child: Container()),
        
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                // Botón crear solo en desktop
                if (!isMobile)
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/actividades/create')
                                .then((_) => _loadActividades());
                          },
                          icon: Icon(Icons.add, size: 20),
                          label: Text('Nueva'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Barra de búsqueda
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterActividades,
                    decoration: InputDecoration(
                      hintText: 'Buscar actividades...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterActividades('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Lista de actividades
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _filteredActividades.isEmpty
                          ? Center(
                              child: Text(
                                'No se encontraron actividades',
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : AppColors.textLight,
                                ),
                              ),
                            )
                          : _buildActividadesList(isDark, isMobile),
                ),
              ],
            ),
          ),
          floatingActionButton: isMobile
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/actividades/create')
                        .then((_) => _loadActividades());
                  },
                  child: Icon(Icons.add),
                  backgroundColor: AppColors.primary,
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildActividadesList(bool isDark, bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Color(0xFF1a1a2e).withOpacity(0.6),
                  Color(0xFF16213e).withOpacity(0.6),
                ]
              : [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.85),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
          // Inner shadow effect
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.white.withOpacity(0.8),
            blurRadius: 8,
            offset: Offset(0, -2),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: _filteredActividades.length,
          itemBuilder: (context, index) {
            final actividad = _filteredActividades[index];
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
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
                    color: isDark 
                        ? const Color.fromRGBO(0, 0, 0, 0.35) 
                        : const Color.fromRGBO(0, 0, 0, 0.12),
                    offset: const Offset(2, 3),
                    blurRadius: 10.0,
                    spreadRadius: -1,
                  ),
                ],
                border: Border.all(
                  color: isDark 
                      ? const Color.fromRGBO(255, 255, 255, 0.08) 
                      : const Color.fromRGBO(0, 0, 0, 0.04),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _editActividad(actividad),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header con título y menú
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icono de actividad
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.event_rounded,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 12),
                          // Título
                          Expanded(
                            child: Text(
                              actividad.titulo,
                              style: TextStyle(
                                fontSize: isMobile ? 16.sp : 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.primary,
                                height: 1.3,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Menú de 3 puntos
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert_rounded,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editActividad(actividad);
                              } else if (value == 'delete') {
                                _showDeleteDialog(actividad);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_rounded, size: 20, color: AppColors.primary),
                                    SizedBox(width: 12),
                                    Text('Editar'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_rounded, size: 20, color: Colors.red),
                                    SizedBox(width: 12),
                                    Text('Eliminar', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Divider sutil
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              isDark ? Colors.white12 : Colors.grey[300]!,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      // Chips de Tipo y Estado
                      Row(
                        children: [
                          Flexible(
                            child: _buildTipoChip(actividad.tipo),
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: _buildEstadoChip(actividad.estado),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
      ),
    );
  }

  Widget _buildTipoChip(String tipo) {
    Color color;
    IconData icon;
    
    switch (tipo.toLowerCase()) {
      case 'complementaria':
        color = AppColors.tipoComplementaria;
        icon = Icons.school_rounded;
        break;
      case 'extraescolar':
        color = AppColors.primary;
        icon = Icons.sports_rounded;
        break;
      default:
        color = Colors.grey;
        icon = Icons.event_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              tipo,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoChip(String estado) {
    Color color;
    IconData icon;
    
    switch (estado.toLowerCase()) {
      case 'aprobada':
      case 'aprobado':
        color = AppColors.estadoAprobado;
        icon = Icons.check_circle_rounded;
        break;
      case 'pendiente':
        color = AppColors.estadoPendiente;
        icon = Icons.schedule_rounded;
        break;
      case 'rechazada':
      case 'rechazado':
        color = AppColors.estadoRechazado;
        icon = Icons.cancel_rounded;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              estado,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
