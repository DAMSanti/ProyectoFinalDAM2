import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proyecto_santi/models/grupo.dart';
import 'package:proyecto_santi/models/curso.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import '../gestion/components/crud_data_table.dart';
import '../gestion/components/crud_delete_dialog.dart';
import '../gestion/components/crud_search_bar.dart';

class GruposCrudView extends StatefulWidget {
  const GruposCrudView({super.key});

  @override
  State<GruposCrudView> createState() => _GruposCrudViewState();
}

class _GruposCrudViewState extends State<GruposCrudView> {
  final ApiService _apiService = ApiService();
  late final CatalogoService _catalogoService;
  
  List<Grupo> _grupos = [];
  List<Grupo> _filteredGrupos = [];
  List<Curso> _cursos = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _catalogoService = CatalogoService(_apiService);
    _loadGrupos();
    _loadCursos();
  }

  Future<void> _loadGrupos() async {
    setState(() => _isLoading = true);
    
    try {
      final grupos = await _catalogoService.fetchGrupos();
      setState(() {
        _grupos = grupos;
        _filteredGrupos = grupos;
        _isLoading = false;
      });
    } catch (e) {
      print('[ERROR] Error al cargar grupos: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar grupos: $e')),
        );
      }
    }
  }

  Future<void> _loadCursos() async {
    try {
      final cursos = await _catalogoService.fetchCursos();
      setState(() {
        _cursos = cursos;
      });
    } catch (e) {
      print('[ERROR] Error al cargar cursos: $e');
    }
  }

  void _filterGrupos(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredGrupos = _grupos;
      } else {
        _filteredGrupos = _grupos.where((grupo) {
          final searchLower = query.toLowerCase();
          final nombreMatch = grupo.nombre.toLowerCase().contains(searchLower);
          final cursoMatch = grupo.curso != null && 
                            grupo.curso!.nombre.toLowerCase().contains(searchLower);
          return nombreMatch || cursoMatch;
        }).toList();
      }
    });
  }

  void _addGrupo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad de añadir grupo en desarrollo')),
    );
  }

  void _editGrupo(Grupo grupo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editar grupo: ${grupo.nombre}')),
    );
  }

  Future<void> _deleteGrupo(Grupo grupo) async {
    await CrudDeleteDialog.show(
      context: context,
      title: 'Eliminar Grupo',
      content: '¿Estás seguro de que deseas eliminar el grupo "${grupo.nombre}"?',
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Funcionalidad de eliminar grupo en desarrollo')),
        );
      },
    );
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
                hintText: 'Buscar por nombre o curso...',
                onSearch: _filterGrupos,
                onAdd: _addGrupo,
                addButtonText: 'Nuevo Grupo',
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
                    child: CrudDataTable<Grupo>(
                      items: _filteredGrupos,
                      isLoading: _isLoading,
                      emptyMessage: _searchQuery.isEmpty
                          ? 'No hay grupos disponibles'
                          : 'No se encontraron grupos que coincidan con "$_searchQuery"',
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
                            'Curso',
                            style: TextStyle(
                              fontSize: kIsWeb ? 4.sp : 14.dg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Nº Alumnos',
                            style: TextStyle(
                              fontSize: kIsWeb ? 4.sp : 14.dg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      buildCells: (grupo) => [
                        DataCell(Text(
                          grupo.id.toString(),
                          style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                        )),
                        DataCell(Text(
                          grupo.nombre,
                          style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                        )),
                        DataCell(Text(
                          grupo.curso?.nombre ?? 'Sin curso',
                          style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                        )),
                        DataCell(Text(
                          grupo.numeroAlumnos.toString(),
                          style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                        )),
                      ],
                      onEdit: _editGrupo,
                      onDelete: _deleteGrupo,
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
