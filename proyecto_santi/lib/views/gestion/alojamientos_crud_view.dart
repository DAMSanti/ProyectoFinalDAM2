import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proyecto_santi/models/alojamiento.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import '../gestion/components/crud_data_table.dart';
import '../gestion/components/crud_delete_dialog.dart';
import '../gestion/components/crud_search_bar.dart';

class AlojamientosCrudView extends StatefulWidget {
  const AlojamientosCrudView({super.key});

  @override
  State<AlojamientosCrudView> createState() => _AlojamientosCrudViewState();
}

class _AlojamientosCrudViewState extends State<AlojamientosCrudView> {
  final ApiService _apiService = ApiService();
  late final ActividadService _actividadService;
  
  List<Alojamiento> _alojamientos = [];
  List<Alojamiento> _filteredAlojamientos = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _actividadService = ActividadService(_apiService);
    _loadAlojamientos();
  }

  Future<void> _loadAlojamientos() async {
    setState(() => _isLoading = true);
    
    try {
      final alojamientos = await _actividadService.fetchAlojamientos();
      setState(() {
        _alojamientos = alojamientos;
        _filteredAlojamientos = alojamientos;
        _isLoading = false;
      });
    } catch (e) {
      print('[ERROR] Error al cargar alojamientos: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar alojamientos: $e')),
        );
      }
    }
  }

  void _filterAlojamientos(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredAlojamientos = _alojamientos;
      } else {
        _filteredAlojamientos = _alojamientos.where((alojamiento) {
          final searchLower = query.toLowerCase();
          return alojamiento.nombre.toLowerCase().contains(searchLower) ||
                 (alojamiento.ciudad?.toLowerCase().contains(searchLower) ?? false) ||
                 (alojamiento.provincia?.toLowerCase().contains(searchLower) ?? false);
        }).toList();
      }
    });
  }

  void _addAlojamiento() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad de añadir alojamiento en desarrollo')),
    );
  }

  void _editAlojamiento(Alojamiento alojamiento) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editar alojamiento: ${alojamiento.nombre}')),
    );
  }

  Future<void> _deleteAlojamiento(Alojamiento alojamiento) async {
    await CrudDeleteDialog.show(
      context: context,
      title: 'Eliminar Alojamiento',
      content: '¿Estás seguro de que deseas eliminar el alojamiento "${alojamiento.nombre}"?',
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Funcionalidad de eliminar alojamiento en desarrollo')),
        );
      },
    );
  }

  Color _getActivoColor(bool activo) {
    return activo ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Fondo con degradado
        isDark 
          ? GradientBackgroundDark(child: Container()) 
          : GradientBackgroundLight(child: Container()),
        // Contenido
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              CrudSearchBar(
                hintText: 'Buscar por nombre, ciudad o provincia...',
                onSearch: _filterAlojamientos,
                onAdd: _addAlojamiento,
                addButtonText: 'Nuevo Alojamiento',
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
                    child: CrudDataTable<Alojamiento>(
                      items: _filteredAlojamientos,
                      isLoading: _isLoading,
                      emptyMessage: _searchQuery.isEmpty
                          ? 'No hay alojamientos disponibles'
                          : 'No se encontraron alojamientos que coincidan con "$_searchQuery"',
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
                            'Nombre',
                            style: TextStyle(
                              fontSize: kIsWeb ? 4.sp : 14.dg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Ciudad',
                            style: TextStyle(
                              fontSize: kIsWeb ? 4.sp : 14.dg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Provincia',
                            style: TextStyle(
                              fontSize: kIsWeb ? 4.sp : 14.dg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Capacidad',
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
                      buildCells: (alojamiento) => [
                        DataCell(Text(
                          alojamiento.id.toString(),
                          style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                        )),
                        DataCell(Text(
                          alojamiento.nombre,
                          style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                        )),
                        DataCell(Text(
                          alojamiento.ciudad ?? 'N/A',
                          style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                        )),
                        DataCell(Text(
                          alojamiento.provincia ?? 'N/A',
                          style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                        )),
                        DataCell(Text(
                          alojamiento.capacidadTotal?.toString() ?? 'N/A',
                          style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                        )),
                        DataCell(
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getActivoColor(alojamiento.activo).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getActivoColor(alojamiento.activo),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              alojamiento.activo ? 'Activo' : 'Inactivo',
                              style: TextStyle(
                                color: _getActivoColor(alojamiento.activo),
                                fontSize: kIsWeb ? 3.sp : 11.dg,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                      onEdit: _editAlojamiento,
                      onDelete: _deleteAlojamiento,
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
}
