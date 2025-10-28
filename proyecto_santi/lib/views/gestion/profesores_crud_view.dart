import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/services/profesor_service.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/views/gestion/components/crud_data_table.dart';
import 'package:proyecto_santi/views/gestion/components/crud_search_bar.dart';
import 'package:proyecto_santi/views/gestion/components/crud_delete_dialog.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';

/// Vista CRUD para gestionar Profesores
class ProfesoresCrudView extends StatefulWidget {
  const ProfesoresCrudView({Key? key}) : super(key: key);

  @override
  State<ProfesoresCrudView> createState() => _ProfesoresCrudViewState();
}

class _ProfesoresCrudViewState extends State<ProfesoresCrudView> {
  final ProfesorService _profesorService = ProfesorService(ApiService());
  List<Profesor> _profesores = [];
  List<Profesor> _filteredProfesores = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProfesores();
  }

  Future<void> _loadProfesores() async {
    setState(() => _isLoading = true);
    try {
      final profesores = await _profesorService.fetchProfesores();
      setState(() {
        _profesores = profesores;
        _filteredProfesores = profesores;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar profesores: $e')),
        );
      }
    }
  }

  void _filterProfesores(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredProfesores = _profesores;
      } else {
        _filteredProfesores = _profesores.where((profesor) {
          final nombreLower = profesor.nombre.toLowerCase();
          final apellidosLower = profesor.apellidos.toLowerCase();
          final correoLower = profesor.correo.toLowerCase();
          final rolLower = profesor.rol.toLowerCase();
          final queryLower = query.toLowerCase();
          return nombreLower.contains(queryLower) ||
              apellidosLower.contains(queryLower) ||
              correoLower.contains(queryLower) ||
              rolLower.contains(queryLower);
        }).toList();
      }
    });
  }

  void _editProfesor(Profesor profesor) {
    // TODO: Implementar diálogo de edición de profesor
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Funcionalidad de edición no implementada aún')),
    );
  }

  Future<void> _deleteProfesor(Profesor profesor) async {
    try {
      final success = await _profesorService.deleteProfesor(profesor.uuid);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profesor eliminado correctamente')),
        );
        await _loadProfesores();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo eliminar el profesor')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar profesor: $e')),
        );
      }
    }
  }

  void _showDeleteDialog(Profesor profesor) {
    CrudDeleteDialog.show(
      context: context,
      title: 'Eliminar Profesor',
      content: '¿Estás seguro de que deseas eliminar al profesor "${profesor.nombre} ${profesor.apellidos}"?',
      onConfirm: () => _deleteProfesor(profesor),
    );
  }

  void _addProfesor() {
    // TODO: Implementar diálogo de creación de profesor
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
                hintText: 'Buscar por nombre, apellidos, correo o rol...',
                onSearch: _filterProfesores,
                onAdd: _addProfesor,
                addButtonText: 'Nuevo Profesor',
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(kIsWeb ? 4.sp : 16.dg),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(kIsWeb ? 4.sp : 16.dg),
                    child: CrudDataTable<Profesor>(
                      items: _filteredProfesores,
                      isLoading: _isLoading,
                      emptyMessage: _searchQuery.isEmpty
                          ? 'No hay profesores disponibles'
                          : 'No se encontraron profesores que coincidan con "$_searchQuery"',
                  columns: [
                    DataColumn(
                      label: Text(
                        'DNI',
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
                        'Apellidos',
                        style: TextStyle(
                          fontSize: kIsWeb ? 4.sp : 14.dg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Correo',
                        style: TextStyle(
                          fontSize: kIsWeb ? 4.sp : 14.dg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Rol',
                        style: TextStyle(
                          fontSize: kIsWeb ? 4.sp : 14.dg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Departamento',
                        style: TextStyle(
                          fontSize: kIsWeb ? 4.sp : 14.dg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  buildCells: (profesor) => [
                    DataCell(Text(
                      profesor.dni,
                      style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                    )),
                    DataCell(Text(
                      profesor.nombre,
                      style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                    )),
                    DataCell(Text(
                      profesor.apellidos,
                      style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                    )),
                    DataCell(Text(
                      profesor.correo,
                      style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                    )),
                    DataCell(
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: kIsWeb ? 2.sp : 8.dg,
                          vertical: kIsWeb ? 1.sp : 4.dg,
                        ),
                        decoration: BoxDecoration(
                          color: _getRolColor(profesor.rol),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          profesor.rol,
                          style: TextStyle(
                            fontSize: kIsWeb ? 3.5.sp : 12.dg,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(
                      profesor.depart?.nombre ?? 'N/A',
                      style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                    )),
                  ],
                  onEdit: _editProfesor,
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

  Color _getRolColor(String rol) {
    switch (rol.toLowerCase()) {
      case 'admin':
      case 'administrador':
        return Colors.red;
      case 'profesor':
        return Colors.blue;
      case 'jefe de departamento':
      case 'jefe':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
