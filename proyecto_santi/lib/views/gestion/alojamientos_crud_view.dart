import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proyecto_santi/models/alojamiento.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/tema/app_colors.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';

class AlojamientosCrudView extends StatefulWidget {
  const AlojamientosCrudView({Key? key}) : super(key: key);

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Alojamiento'),
        content: Text('¿Estás seguro de que deseas eliminar el alojamiento "${alojamiento.nombre}"?'),
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
        const SnackBar(content: Text('Funcionalidad de eliminar alojamiento en desarrollo')),
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
                          onPressed: _addAlojamiento,
                          icon: Icon(Icons.add, size: 20),
                          label: Text('Nuevo Alojamiento'),
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
                    onChanged: _filterAlojamientos,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre, ciudad o provincia...',
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
                // Lista de alojamientos
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredAlojamientos.isEmpty
                          ? Center(
                              child: Text(
                                _searchQuery.isEmpty
                                    ? 'No hay alojamientos disponibles'
                                    : 'No se encontraron alojamientos',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: isDark ? Colors.white70 : AppColors.textLight,
                                ),
                              ),
                            )
                          : _buildAlojamientosList(isDark, isMobile),
                ),
              ],
            ),
          ),
          floatingActionButton: isMobile
              ? FloatingActionButton(
                  onPressed: _addAlojamiento,
                  child: Icon(Icons.add),
                  backgroundColor: AppColors.primary,
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildAlojamientosList(bool isDark, bool isMobile) {
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
          itemCount: _filteredAlojamientos.length,
          itemBuilder: (context, index) {
            final alojamiento = _filteredAlojamientos[index];
            return _buildAlojamientoCard(alojamiento, isDark);
          },
        ),
      ),
    );
  }

  Widget _buildAlojamientoCard(Alojamiento alojamiento, bool isDark) {
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _editAlojamiento(alojamiento),
            child: Padding(
              padding: EdgeInsets.all(16.dg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con icono, nombre y menú
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icono de alojamiento
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.hotel_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Nombre del alojamiento
                      Expanded(
                        child: Text(
                          alojamiento.nombre,
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
                            _editAlojamiento(alojamiento);
                          } else if (value == 'delete') {
                            _deleteAlojamiento(alojamiento);
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
                  // Información del alojamiento
                  _buildInfoRow(
                    icon: Icons.location_city_rounded,
                    label: '${alojamiento.ciudad ?? 'N/A'}, ${alojamiento.provincia ?? 'N/A'}',
                    isDark: isDark,
                  ),
                  if (alojamiento.direccion != null && alojamiento.direccion!.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    _buildInfoRow(
                      icon: Icons.place_rounded,
                      label: alojamiento.direccion!,
                      isDark: isDark,
                    ),
                  ],
                  if (alojamiento.email != null && alojamiento.email!.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    _buildInfoRow(
                      icon: Icons.email_rounded,
                      label: alojamiento.email!,
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
            ),
          ),
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
