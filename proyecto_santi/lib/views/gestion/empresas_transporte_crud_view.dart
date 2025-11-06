import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proyecto_santi/models/empresa_transporte.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/tema/app_colors.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import 'package:proyecto_santi/views/gestion/dialogs/empresa_transporte_detail_dialog.dart';

class EmpresasTransporteCrudView extends StatefulWidget {
  const EmpresasTransporteCrudView({Key? key}) : super(key: key);

  @override
  State<EmpresasTransporteCrudView> createState() => _EmpresasTransporteCrudViewState();
}

class _EmpresasTransporteCrudViewState extends State<EmpresasTransporteCrudView> {
  final ApiService _apiService = ApiService();
  late final ActividadService _actividadService;
  
  List<EmpresaTransporte> _empresas = [];
  List<EmpresaTransporte> _filteredEmpresas = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _actividadService = ActividadService(_apiService);
    _loadEmpresas();
  }

  Future<void> _loadEmpresas() async {
    setState(() => _isLoading = true);
    
    try {
      final empresas = await _actividadService.fetchEmpresasTransporte();
      setState(() {
        _empresas = empresas;
        _filteredEmpresas = empresas;
        _isLoading = false;
      });
    } catch (e) {
      print('[ERROR] Error al cargar empresas de transporte: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar empresas de transporte: $e')),
        );
      }
    }
  }

  void _filterEmpresas(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredEmpresas = _empresas;
      } else {
        _filteredEmpresas = _empresas.where((empresa) {
          final searchLower = query.toLowerCase();
          return empresa.nombre.toLowerCase().contains(searchLower) ||
                 (empresa.cif?.toLowerCase().contains(searchLower) ?? false) ||
                 (empresa.telefono?.toLowerCase().contains(searchLower) ?? false) ||
                 (empresa.email?.toLowerCase().contains(searchLower) ?? false);
        }).toList();
      }
    });
  }

  void _showEmpresaDialog({EmpresaTransporte? empresa}) {
    showDialog(
      context: context,
      builder: (context) => EmpresaTransporteDetailDialog(
        empresa: empresa,
        onSaved: _loadEmpresas,
      ),
    );
  }

  void _addEmpresa() {
    _showEmpresaDialog();
  }

  void _editEmpresa(EmpresaTransporte empresa) {
    _showEmpresaDialog(empresa: empresa);
  }

  Future<void> _deleteEmpresa(EmpresaTransporte empresa) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Empresa de Transporte'),
        content: Text('¿Estás seguro de que deseas eliminar la empresa "${empresa.nombre}"?'),
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
        const SnackBar(content: Text('Funcionalidad de eliminar empresa en desarrollo')),
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
                          onPressed: _addEmpresa,
                          icon: Icon(Icons.add, size: 20),
                          label: Text('Nueva Empresa'),
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
                    onChanged: _filterEmpresas,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre, CIF, teléfono o email...',
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
                // Lista de empresas
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredEmpresas.isEmpty
                          ? Center(
                              child: Text(
                                _searchQuery.isEmpty
                                    ? 'No hay empresas de transporte disponibles'
                                    : 'No se encontraron empresas',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: isDark ? Colors.white70 : AppColors.textLight,
                                ),
                              ),
                            )
                          : _buildEmpresasList(isDark, isMobile),
                ),
              ],
            ),
          ),
          floatingActionButton: isMobile
              ? FloatingActionButton(
                  onPressed: _addEmpresa,
                  child: Icon(Icons.add),
                  backgroundColor: AppColors.primary,
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildEmpresasList(bool isDark, bool isMobile) {
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
          itemCount: _filteredEmpresas.length,
          itemBuilder: (context, index) {
            final empresa = _filteredEmpresas[index];
            return _buildEmpresaCard(empresa, isDark);
          },
        ),
      ),
    );
  }

  Widget _buildEmpresaCard(EmpresaTransporte empresa, bool isDark) {
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
                // Icono de empresa de transporte
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.directions_bus_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12.w),
                // Nombre de la empresa
                Expanded(
                  child: Text(
                    empresa.nombre,
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
                      _editEmpresa(empresa);
                    } else if (value == 'delete') {
                      _deleteEmpresa(empresa);
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
            // Información de la empresa
            if (empresa.cif != null && empresa.cif!.isNotEmpty) ...[
              _buildInfoRow(
                icon: Icons.badge_rounded,
                label: 'CIF: ${empresa.cif}',
                isDark: isDark,
              ),
              SizedBox(height: 8.h),
            ],
            if (empresa.telefono != null && empresa.telefono!.isNotEmpty) ...[
              _buildInfoRow(
                icon: Icons.phone_rounded,
                label: empresa.telefono!,
                isDark: isDark,
              ),
              SizedBox(height: 8.h),
            ],
            if (empresa.email != null && empresa.email!.isNotEmpty) ...[
              _buildInfoRow(
                icon: Icons.email_rounded,
                label: empresa.email!,
                isDark: isDark,
              ),
              SizedBox(height: 8.h),
            ],
            if (empresa.direccion != null && empresa.direccion!.isNotEmpty) ...[
              _buildInfoRow(
                icon: Icons.place_rounded,
                label: empresa.direccion!,
                isDark: isDark,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required bool isDark}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.white70 : Colors.grey[600],
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
