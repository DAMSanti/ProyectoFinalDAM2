import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/services/actividad_service.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/views/gestion/components/crud_data_table.dart';
import 'package:proyecto_santi/views/gestion/components/crud_search_bar.dart';
import 'package:proyecto_santi/views/gestion/components/crud_delete_dialog.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';

/// Vista CRUD para gestionar Actividades
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
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadActividades();
  }

  Future<void> _loadActividades() async {
    setState(() => _isLoading = true);
    try {
      final actividades = await _actividadService.fetchActivities(pageSize: 100);
      setState(() {
        _actividades = actividades;
        _filteredActividades = actividades;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar actividades: $e')),
        );
      }
    }
  }

  void _filterActividades(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredActividades = _actividades;
      } else {
        _filteredActividades = _actividades.where((actividad) {
          final tituloLower = actividad.titulo.toLowerCase();
          final tipoLower = actividad.tipo.toLowerCase();
          final estadoLower = actividad.estado.toLowerCase();
          final queryLower = query.toLowerCase();
          return tituloLower.contains(queryLower) ||
              tipoLower.contains(queryLower) ||
              estadoLower.contains(queryLower);
        }).toList();
      }
    });
  }

  void _editActividad(Actividad actividad) {
    // Navegar a la vista de detalle de actividad para editar
    Navigator.pushNamed(
      context,
      '/activityDetail',
      arguments: actividad.id,
    ).then((_) => _loadActividades());
  }

  Future<void> _deleteActividad(Actividad actividad) async {
    try {
      // TODO: Implementar endpoint de eliminación en el backend y servicio
      // Por ahora mostramos un mensaje de que la funcionalidad no está disponible
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Funcionalidad de eliminación no disponible aún'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar actividad: $e')),
        );
      }
    }
  }

  void _showDeleteDialog(Actividad actividad) {
    CrudDeleteDialog.show(
      context: context,
      title: 'Eliminar Actividad',
      content: '¿Estás seguro de que deseas eliminar la actividad "${actividad.titulo}"?',
      onConfirm: () => _deleteActividad(actividad),
    );
  }

  void _addActividad() {
    // Navegar a la vista de crear nueva actividad
    Navigator.pushNamed(context, '/actividades/create').then((_) => _loadActividades());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Theme.of(context).brightness == Brightness.dark
            ? GradientBackgroundDark(child: Container())
            : GradientBackgroundLight(child: Container()),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              CrudSearchBar(
                hintText: 'Buscar por título, tipo o estado...',
                onSearch: _filterActividades,
                onAdd: _addActividad,
                addButtonText: 'Nueva Actividad',
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(kIsWeb ? 4.sp : 16.dg),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(kIsWeb ? 4.sp : 16.dg),
                    child: CrudDataTable<Actividad>(
                      items: _filteredActividades,
                      isLoading: _isLoading,
                      emptyMessage: _searchQuery.isEmpty
                          ? 'No hay actividades disponibles'
                          : 'No se encontraron actividades que coincidan con "$_searchQuery"',
                  columns: [
                    DataColumn(
                      label: Text(
                        'ID',
                        style: TextStyle(
                          fontSize: kIsWeb ? 4.sp : 14.dg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Título',
                        style: TextStyle(
                          fontSize: kIsWeb ? 4.sp : 14.dg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Tipo',
                        style: TextStyle(
                          fontSize: kIsWeb ? 4.sp : 14.dg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Fecha Inicio',
                        style: TextStyle(
                          fontSize: kIsWeb ? 4.sp : 14.dg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Fecha Fin',
                        style: TextStyle(
                          fontSize: kIsWeb ? 4.sp : 14.dg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Estado',
                        style: TextStyle(
                          fontSize: kIsWeb ? 4.sp : 14.dg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  buildCells: (actividad) => [
                    DataCell(Text(
                      actividad.id.toString(),
                      style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                    )),
                    DataCell(Text(
                      actividad.titulo,
                      style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                    )),
                    DataCell(Text(
                      actividad.tipo,
                      style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                    )),
                    DataCell(Text(
                      actividad.fini,
                      style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                    )),
                    DataCell(Text(
                      actividad.ffin,
                      style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                    )),
                    DataCell(
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: kIsWeb ? 2.sp : 8.dg,
                          vertical: kIsWeb ? 1.sp : 4.dg,
                        ),
                        decoration: BoxDecoration(
                          color: _getEstadoColor(actividad.estado),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          actividad.estado,
                          style: TextStyle(
                            fontSize: kIsWeb ? 3.5.sp : 12.dg,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  onEdit: _editActividad,
                  onDelete: _showDeleteDialog,
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

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobada':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'rechazada':
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
