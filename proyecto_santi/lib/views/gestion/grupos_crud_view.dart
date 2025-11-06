import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proyecto_santi/models/grupo.dart';
import 'package:proyecto_santi/models/curso.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/tema/app_colors.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import 'package:proyecto_santi/views/gestion/dialogs/grupo_detail_dialog.dart';

class GruposCrudView extends StatefulWidget {
  const GruposCrudView({Key? key}) : super(key: key);

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

  void _showGrupoDialog({Grupo? grupo}) {
    showDialog(
      context: context,
      builder: (context) => GrupoDetailDialog(
        grupo: grupo,
        cursos: _cursos,
        onSaved: _loadGrupos,
      ),
    );
  }

  void _addGrupo() {
    _showGrupoDialog();
  }

  void _editGrupo(Grupo grupo) {
    _showGrupoDialog(grupo: grupo);
  }

  Future<void> _deleteGrupo(Grupo grupo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Grupo'),
        content: Text('¿Estás seguro de que deseas eliminar el grupo "${grupo.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Funcionalidad de eliminar grupo en desarrollo')),
      );
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
                    padding: EdgeInsets.all(16.dg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _addGrupo,
                          icon: Icon(Icons.add, size: 20),
                          label: Text('Nuevo Grupo'),
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
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: TextField(
                    onChanged: _filterGrupos,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o curso...',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                // Lista de grupos
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredGrupos.isEmpty
                          ? Center(
                              child: Text(
                                _searchQuery.isEmpty
                                    ? 'No hay grupos disponibles'
                                    : 'No se encontraron grupos',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: isDark ? Colors.white70 : AppColors.textLight,
                                ),
                              ),
                            )
                          : _buildGruposList(isDark, isMobile),
                ),
              ],
            ),
          ),
          floatingActionButton: isMobile
              ? FloatingActionButton(
                  onPressed: _addGrupo,
                  child: Icon(Icons.add),
                  backgroundColor: AppColors.primary,
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildGruposList(bool isDark, bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
          padding: EdgeInsets.all(16.dg),
          itemCount: _filteredGrupos.length,
          itemBuilder: (context, index) {
            final grupo = _filteredGrupos[index];
            return _buildGrupoCard(grupo, isDark);
          },
        ),
      ),
    );
  }

  Widget _buildGrupoCard(Grupo grupo, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
      child: Padding(
        padding: EdgeInsets.all(16.dg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con icono, nombre y menú
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono de grupo
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.group_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12.w),
                // Nombre del grupo
                Expanded(
                  child: Text(
                    grupo.nombre,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.primary,
                      height: 1.3,
                    ),
                    maxLines: 2,
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
                      _editGrupo(grupo);
                    } else if (value == 'delete') {
                      _deleteGrupo(grupo);
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
            SizedBox(height: 12.h),
            // Divider sutil con gradiente
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
            SizedBox(height: 12.h),
            // Información del grupo (curso y alumnos)
            Row(
              children: [
                // Chip de curso
                Flexible(
                  child: _buildInfoChip(
                    icon: Icons.school_rounded,
                    label: grupo.curso?.titulo ?? 'Sin curso',
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: 8.w),
                // Chip de alumnos
                Flexible(
                  child: _buildInfoChip(
                    icon: Icons.people_rounded,
                    label: '${grupo.numeroAlumnos} alumnos',
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label, required bool isDark}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13.sp,
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
