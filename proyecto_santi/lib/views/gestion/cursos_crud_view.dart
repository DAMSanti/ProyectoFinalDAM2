import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proyecto_santi/models/curso.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import '../gestion/components/crud_data_table.dart';
import '../gestion/components/crud_delete_dialog.dart';
import '../gestion/components/crud_search_bar.dart';

class CursosCrudView extends StatefulWidget {
  const CursosCrudView({Key? key}) : super(key: key);

  @override
  State<CursosCrudView> createState() => _CursosCrudViewState();
}

class _CursosCrudViewState extends State<CursosCrudView> {
  final ApiService _apiService = ApiService();
  late final CatalogoService _catalogoService;
  
  List<Curso> _cursos = [];
  List<Curso> _filteredCursos = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _catalogoService = CatalogoService(_apiService);
    _loadCursos();
  }

  Future<void> _loadCursos() async {
    setState(() => _isLoading = true);
    
    try {
      final cursos = await _catalogoService.fetchCursos();
      setState(() {
        _cursos = cursos;
        _filteredCursos = cursos;
        _isLoading = false;
      });
    } catch (e) {
      print('[ERROR] Error al cargar cursos: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar cursos: $e')),
        );
      }
    }
  }

  void _filterCursos(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredCursos = _cursos;
      } else {
        _filteredCursos = _cursos.where((curso) {
          final searchLower = query.toLowerCase();
          return curso.nombre.toLowerCase().contains(searchLower) ||
                 (curso.nivel?.toLowerCase().contains(searchLower) ?? false);
        }).toList();
      }
    });
  }

  void _addCurso() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad de añadir curso en desarrollo')),
    );
  }

  void _editCurso(Curso curso) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editar curso: ${curso.nombre}')),
    );
  }

  Future<void> _deleteCurso(Curso curso) async {
    await CrudDeleteDialog.show(
      context: context,
      title: 'Eliminar Curso',
      content: '¿Estás seguro de que deseas eliminar el curso "${curso.nombre}"?',
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Funcionalidad de eliminar curso en desarrollo')),
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
                hintText: 'Buscar por nombre o nivel...',
                onSearch: _filterCursos,
                onAdd: _addCurso,
                addButtonText: 'Nuevo Curso',
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
                    child: CrudDataTable<Curso>(
                      items: _filteredCursos,
                      isLoading: _isLoading,
                      emptyMessage: _searchQuery.isEmpty
                          ? 'No hay cursos disponibles'
                          : 'No se encontraron cursos que coincidan con "$_searchQuery"',
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
                            'Nivel',
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
                      buildCells: (curso) => [
                        DataCell(Text(
                          curso.id.toString(),
                          style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                        )),
                        DataCell(Text(
                          curso.nombre,
                          style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                        )),
                        DataCell(Text(
                          curso.nivel ?? 'N/A',
                          style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                        )),
                        DataCell(
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getActivoColor(curso.activo).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getActivoColor(curso.activo),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              curso.activo ? 'Activo' : 'Inactivo',
                              style: TextStyle(
                                color: _getActivoColor(curso.activo),
                                fontSize: kIsWeb ? 3.sp : 11.dg,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                      onEdit: _editCurso,
                      onDelete: _deleteCurso,
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
