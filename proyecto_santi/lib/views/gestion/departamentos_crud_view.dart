import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:proyecto_santi/models/departamento.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/config.dart';
import 'package:proyecto_santi/views/gestion/components/crud_data_table.dart';
import 'package:proyecto_santi/views/gestion/components/crud_search_bar.dart';
import 'package:proyecto_santi/views/gestion/components/crud_delete_dialog.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';

/// Vista CRUD para gestionar Departamentos
class DepartamentosCrudView extends StatefulWidget {
  const DepartamentosCrudView({super.key});

  @override
  State<DepartamentosCrudView> createState() => _DepartamentosCrudViewState();
}

class _DepartamentosCrudViewState extends State<DepartamentosCrudView> {
  final ApiService _apiService = ApiService();
  List<Departamento> _departamentos = [];
  List<Departamento> _filteredDepartamentos = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDepartamentos();
  }

  Future<void> _loadDepartamentos() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getData(AppConfig.departamentosEndpoint);
      // La respuesta de Dio tiene la propiedad data
      List<dynamic> data;
      if (response.data is List) {
        data = response.data;
      } else if (response.data is Map && response.data.containsKey('data')) {
        data = response.data['data'];
      } else {
        data = [];
      }
      final departamentos = data.map((json) => Departamento.fromJson(json)).toList();
      setState(() {
        _departamentos = departamentos;
        _filteredDepartamentos = departamentos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar departamentos: $e')),
        );
      }
    }
  }

  void _filterDepartamentos(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredDepartamentos = _departamentos;
      } else {
        _filteredDepartamentos = _departamentos.where((depto) {
          final nombreLower = depto.nombre.toLowerCase();
          final codigoLower = (depto.codigo ?? '').toLowerCase();
          final queryLower = query.toLowerCase();
          return nombreLower.contains(queryLower) || codigoLower.contains(queryLower);
        }).toList();
      }
    });
  }

  void _editDepartamento(Departamento departamento) {
    // TODO: Implementar diálogo de edición
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Funcionalidad de edición no implementada aún')),
    );
  }

  Future<void> _deleteDepartamento(Departamento departamento) async {
    try {
      // TODO: Implementar endpoint de eliminación en el backend
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
          SnackBar(content: Text('Error al eliminar departamento: $e')),
        );
      }
    }
  }

  void _showDeleteDialog(Departamento departamento) {
    CrudDeleteDialog.show(
      context: context,
      title: 'Eliminar Departamento',
      content: '¿Estás seguro de que deseas eliminar el departamento "${departamento.nombre}"?',
      onConfirm: () => _deleteDepartamento(departamento),
    );
  }

  void _addDepartamento() {
    // TODO: Implementar diálogo de creación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Funcionalidad de creación no implementada aún')),
    );
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
                hintText: 'Buscar por nombre o código...',
                onSearch: _filterDepartamentos,
                onAdd: _addDepartamento,
                addButtonText: 'Nuevo Departamento',
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
                    child: CrudDataTable<Departamento>(
                      items: _filteredDepartamentos,
                      isLoading: _isLoading,
                      emptyMessage: _searchQuery.isEmpty
                          ? 'No hay departamentos disponibles'
                          : 'No se encontraron departamentos que coincidan con "$_searchQuery"',
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
                        'Código',
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
                  ],
                  buildCells: (departamento) => [
                    DataCell(Text(
                      departamento.id.toString(),
                      style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                    )),
                    DataCell(Text(
                      departamento.codigo ?? '',
                      style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                    )),
                    DataCell(Text(
                      departamento.nombre,
                      style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                    )),
                  ],
                  onEdit: _editDepartamento,
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
}
