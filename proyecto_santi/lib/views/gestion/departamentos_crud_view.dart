import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:proyecto_santi/models/departamento.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/services/catalogo_service.dart';
import 'package:proyecto_santi/config.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import 'package:proyecto_santi/tema/app_colors.dart';
import 'package:proyecto_santi/views/gestion/dialogs/departamento_detail_dialog.dart';

/// Vista CRUD moderna para gestionar Departamentos
class DepartamentosCrudView extends StatefulWidget {
  const DepartamentosCrudView({Key? key}) : super(key: key);

  @override
  State<DepartamentosCrudView> createState() => _DepartamentosCrudViewState();
}

class _DepartamentosCrudViewState extends State<DepartamentosCrudView> {
  final ApiService _apiService = ApiService();
  List<Departamento> _departamentos = [];
  List<Departamento> _filteredDepartamentos = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  bool get isDesktop => kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  @override
  void initState() {
    super.initState();
    _loadDepartamentos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartamentos() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getData('${AppConfig.departamentosEndpoint}');
      List<dynamic> data;
      if (response.data is List) {
        data = response.data;
      } else if (response.data is Map && response.data.containsKey('data')) {
        data = response.data['data'];
      } else {
        data = [];
      }
      final departamentos = data.map((json) => Departamento.fromJson(json)).toList();
      if (mounted) {
        setState(() {
          _departamentos = departamentos;
          _filteredDepartamentos = departamentos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar departamentos')),
        );
      }
    }
  }

  void _filterDepartamentos(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDepartamentos = _departamentos;
      } else {
        final queryLower = query.toLowerCase();
        _filteredDepartamentos = _departamentos.where((depto) {
          return depto.nombre.toLowerCase().contains(queryLower) ||
              (depto.codigo?.toLowerCase().contains(queryLower) ?? false);
        }).toList();
      }
    });
  }

  void _addDepartamento() {
    showDialog(
      context: context,
      builder: (context) => DepartamentoDetailDialog(
        onSaved: _loadDepartamentos,
      ),
    );
  }

  void _editDepartamento(Departamento departamento) {
    showDialog(
      context: context,
      builder: (context) => DepartamentoDetailDialog(
        departamento: departamento,
        onSaved: _loadDepartamentos,
      ),
    );
  }

  Future<void> _showDeleteDialog(Departamento departamento) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar Departamento'),
          ],
        ),
        content: Text(
          '¿Está seguro de que desea eliminar el departamento "${departamento.nombre}"?\n\nEsta funcionalidad estará disponible próximamente.',
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
                          onPressed: _addDepartamento,
                          icon: Icon(Icons.add, size: 20),
                          label: Text('Nuevo'),
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
                    onChanged: _filterDepartamentos,
                    decoration: InputDecoration(
                      hintText: 'Buscar departamentos...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterDepartamentos('');
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

                // Lista de departamentos
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _filteredDepartamentos.isEmpty
                          ? Center(
                              child: Text(
                                'No se encontraron departamentos',
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : AppColors.textLight,
                                ),
                              ),
                            )
                          : _buildDepartamentosList(isDark, isMobile),
                ),
              ],
            ),
          ),
          floatingActionButton: isMobile
              ? FloatingActionButton(
                  onPressed: _addDepartamento,
                  child: Icon(Icons.add),
                  backgroundColor: AppColors.primary,
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildDepartamentosList(bool isDark, bool isMobile) {
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
          itemCount: _filteredDepartamentos.length,
          itemBuilder: (context, index) {
            final departamento = _filteredDepartamentos[index];
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
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                          // Header con nombre y menú
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icono de departamento
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.business_rounded,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 12),
                              // Nombre del departamento
                              Expanded(
                                child: Text(
                                  departamento.nombre,
                                  style: TextStyle(
                                    fontSize: isMobile ? 16.sp : 18,
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
                                    _editDepartamento(departamento);
                                  } else if (value == 'delete') {
                                    _showDeleteDialog(departamento);
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
                          if (departamento.codigo != null && departamento.codigo!.isNotEmpty) ...[
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
                            // Chip de código
                            Row(
                              children: [
                                Flexible(
                                  child: _buildCodigoChip(departamento.codigo!, isDark),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
          },
        ),
      ),
    );
  }

  Widget _buildCodigoChip(String codigo, bool isDark) {
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
          Icon(Icons.tag_rounded, size: 16, color: AppColors.primary),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              codigo,
              style: TextStyle(
                color: AppColors.primary,
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
