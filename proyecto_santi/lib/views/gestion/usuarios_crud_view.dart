import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:proyecto_santi/models/usuario.dart';
import 'package:proyecto_santi/services/usuario_service.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import 'package:proyecto_santi/tema/app_colors.dart';
import 'package:proyecto_santi/views/gestion/dialogs/usuario_detail_dialog.dart';
import 'package:intl/intl.dart';

/// Vista CRUD de Usuarios siguiendo el patrón coherente de la app
class UsuariosCrudView extends StatefulWidget {
  const UsuariosCrudView({Key? key}) : super(key: key);

  @override
  State<UsuariosCrudView> createState() => _UsuariosCrudViewState();
}

class _UsuariosCrudViewState extends State<UsuariosCrudView> {
  final UsuarioService _usuarioService = UsuarioService(ApiService());
  List<Usuario> _usuarios = [];
  List<Usuario> _filteredUsuarios = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRolFilter; // null = todos los roles
  
  bool get isDesktop => kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  @override
  void initState() {
    super.initState();
    _loadUsuarios();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsuarios() async {
    setState(() => _isLoading = true);
    try {
      final usuarios = await _usuarioService.fetchUsuarios();
      if (mounted) {
        setState(() {
          _usuarios = usuarios;
          _filteredUsuarios = usuarios;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar usuarios')),
        );
      }
    }
  }

  void _filterUsuarios(String query) {
    setState(() {
      _filteredUsuarios = _usuarios.where((usuario) {
        // Filtro por texto de búsqueda
        final matchesSearch = query.isEmpty || 
            usuario.nombreUsuario.toLowerCase().contains(query.toLowerCase()) ||
            usuario.email.toLowerCase().contains(query.toLowerCase()) ||
            usuario.rol.toLowerCase().contains(query.toLowerCase());
        
        // Filtro por rol seleccionado
        final matchesRol = _selectedRolFilter == null || 
            usuario.rol.toLowerCase() == _selectedRolFilter!.toLowerCase();
        
        return matchesSearch && matchesRol;
      }).toList();
    });
  }

  void _applyFilters() {
    _filterUsuarios(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Stack(
      children: [
        // Fondo consistente
        isDark 
            ? GradientBackgroundDark(child: Container()) 
            : GradientBackgroundLight(child: Container()),
        
        // Contenido
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
                          onPressed: () => _showUsuarioDialog(),
                          icon: Icon(Icons.add, size: 20),
                          label: Text('Nuevo Usuario'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Barra de búsqueda y filtro
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      // Barra de búsqueda expandible
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark 
                                ? Colors.white.withOpacity(0.1) 
                                : Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: isDark 
                                    ? Colors.black.withOpacity(0.4)
                                    : Colors.black.withOpacity(0.12),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                              BoxShadow(
                                color: isDark 
                                    ? Colors.black.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.8),
                                blurRadius: 6,
                                offset: Offset(0, -2),
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _filterUsuarios,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Buscar usuarios...',
                              hintStyle: TextStyle(
                                color: isDark 
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.black54,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: isDark ? Colors.white70 : AppColors.primary,
                                size: 22,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 12),
                      
                      // Botón de filtros con indicador
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [AppColors.primary, AppColors.primary.withOpacity(0.8)]
                                    : [AppColors.primary, AppColors.primary.withOpacity(0.9)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _showRolFilterDialog(isDark),
                                child: Container(
                                  padding: EdgeInsets.all(14),
                                  child: Icon(
                                    Icons.tune_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Indicador de filtros activos
                          if (_selectedRolFilter != null)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? Colors.black : Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Lista de usuarios
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _filteredUsuarios.isEmpty
                          ? Center(
                              child: Text(
                                'No se encontraron usuarios',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: isDark ? Colors.white70 : AppColors.textLight,
                                ),
                              ),
                            )
                          : _buildUsuariosList(isDark, isMobile),
                ),
              ],
            ),
          ),
          floatingActionButton: isMobile
              ? FloatingActionButton(
                  onPressed: () => _showUsuarioDialog(),
                  child: Icon(Icons.add),
                  backgroundColor: AppColors.primary,
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildUsuariosList(bool isDark, bool isMobile) {
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
          itemCount: _filteredUsuarios.length,
          itemBuilder: (context, index) {
            final usuario = _filteredUsuarios[index];
            return _buildUsuarioCard(usuario, isDark);
          },
        ),
      ),
    );
  }

  Widget _buildUsuarioCard(Usuario usuario, bool isDark) {
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
        child: Padding(
          padding: EdgeInsets.all(16.dg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con avatar, nombre y menú
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar con inicial
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _getRolColor(usuario.rol).withOpacity(0.2),
                    child: Text(
                      usuario.nombreUsuario[0].toUpperCase(),
                      style: TextStyle(
                        color: _getRolColor(usuario.rol),
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Nombre del usuario y profesor
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuario.nombreUsuario,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.primary,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (usuario.profesorNombreCompleto != null && 
                            usuario.profesorNombreCompleto!.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            usuario.profesorNombreCompleto!,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
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
                        _showUsuarioDialog(usuario: usuario);
                      } else if (value == 'toggle') {
                        _toggleActivo(usuario);
                      } else if (value == 'delete') {
                        _deleteUsuario(usuario);
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
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              usuario.activo ? Icons.block : Icons.check_circle,
                              size: 20,
                              color: usuario.activo ? Colors.orange : Colors.green,
                            ),
                            SizedBox(width: 12),
                            Text(usuario.activo ? 'Desactivar' : 'Activar'),
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
              // Email
              _buildInfoRow(
                icon: Icons.email_rounded,
                label: usuario.email,
                isDark: isDark,
              ),
              SizedBox(height: 12.h),
              // Chips de rol y estado
              Row(
                children: [
                  Flexible(child: _buildRolChip(usuario.rol)),
                  SizedBox(width: 8.w),
                  Flexible(child: _buildStatusChip(usuario.activo)),
                ],
              ),
            ],
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRolChip(String rol) {
    final color = _getRolColor(rol);
    return Chip(
      label: Text(
        rol,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color, width: 1),
      padding: EdgeInsets.zero,
      labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  Widget _buildStatusChip(bool activo) {
    return Chip(
      label: Text(
        activo ? 'Activo' : 'Inactivo',
        style: TextStyle(
          color: activo ? Colors.green : Colors.red,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: activo ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
      side: BorderSide(color: activo ? Colors.green : Colors.red, width: 1),
      padding: EdgeInsets.zero,
      labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  Color _getRolColor(String rol) {
    switch (rol.toLowerCase()) {
      case 'admin':
      case 'administrador':
        return Colors.red;
      case 'coordinador':
        return AppColors.primary;
      case 'profesor':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showUsuarioDialog({Usuario? usuario}) {
    showDialog(
      context: context,
      builder: (context) => UsuarioDetailDialog(
        usuario: usuario,
        onSaved: _loadUsuarios,
      ),
    );
  }

  Future<void> _deleteUsuario(Usuario usuario) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Eliminar al usuario "${usuario.nombreUsuario}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _usuarioService.deleteUsuario(usuario.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Usuario eliminado correctamente')),
          );
        }
        await _loadUsuarios();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar usuario')),
          );
        }
      }
    }
  }

  Future<void> _toggleActivo(Usuario usuario) async {
    try {
      await _usuarioService.toggleUsuarioActivo(usuario.id, !usuario.activo);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(usuario.activo ? 'Usuario desactivado' : 'Usuario activado')),
        );
      }
      await _loadUsuarios();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar estado')),
        );
      }
    }
  }

  void _showRolFilterDialog(bool isDark) {
    final roles = ['Administrador', 'Coordinador', 'Profesor', 'Usuario'];
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final isMobileLandscape = isMobile && !isPortrait;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isMobileLandscape ? 12 : 16),
        ),
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobileLandscape ? 20 : (isMobile ? 16 : 40),
          vertical: isMobileLandscape ? 12 : (isMobile ? 20 : 24),
        ),
        child: Container(
          width: isMobile ? double.infinity : 500,
          constraints: BoxConstraints(
            maxHeight: isMobileLandscape 
                ? screenHeight * 0.9 
                : (isMobile ? screenHeight * 0.85 : 700),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isMobileLandscape ? 12 : 16),
            gradient: LinearGradient(
              colors: isDark
                  ? [Color(0xFF1a1a2e), Color(0xFF16213e)]
                  : [Colors.white, Color(0xFFf5f5f5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobileLandscape ? 10 : (isMobile ? 12 : 20),
                  vertical: isMobileLandscape ? 8 : (isMobile ? 12 : 16),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.primary, AppColors.primary.withOpacity(0.8)]
                        : [AppColors.primary, AppColors.primary.withOpacity(0.9)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isMobileLandscape ? 12 : 16),
                    topRight: Radius.circular(isMobileLandscape ? 12 : 16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_alt_rounded,
                      color: Colors.white,
                      size: isMobileLandscape ? 18 : (isMobile ? 20 : 24),
                    ),
                    SizedBox(width: isMobileLandscape ? 6 : 8),
                    Expanded(
                      child: Text(
                        'Filtrar por Rol',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobileLandscape ? 14 : (isMobile ? 16 : 18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close, 
                        color: Colors.white, 
                        size: isMobileLandscape ? 18 : (isMobile ? 20 : 24),
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.all(isMobileLandscape ? 2 : 4),
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Contenido
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobileLandscape ? 10 : (isMobile ? 12 : 20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filtro por rol usando FilterChips
                      Wrap(
                        spacing: isMobileLandscape ? 6 : (isMobile ? 8 : 10),
                        runSpacing: isMobileLandscape ? 6 : (isMobile ? 8 : 10),
                        children: [
                          // Opción "Todos"
                          FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.people_rounded,
                                  size: isMobileLandscape ? 14 : (isMobile ? 16 : 18),
                                  color: _selectedRolFilter == null ? AppColors.primary : Colors.grey,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Todos',
                                  style: TextStyle(fontSize: isMobileLandscape ? 11 : (isMobile ? 12 : 14)),
                                ),
                              ],
                            ),
                            selected: _selectedRolFilter == null,
                            onSelected: (selected) {
                              setState(() => _selectedRolFilter = null);
                              _applyFilters();
                              Navigator.pop(context);
                            },
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobileLandscape ? 6 : (isMobile ? 8 : 10),
                              vertical: isMobileLandscape ? 2 : (isMobile ? 4 : 6),
                            ),
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            checkmarkColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: _selectedRolFilter == null 
                                  ? AppColors.primary
                                  : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: _selectedRolFilter == null ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          // Opciones de roles
                          ...roles.map((rol) {
                            final isSelected = _selectedRolFilter == rol;
                            final color = _getRolColor(rol);
                            return FilterChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getRolIconData(rol),
                                    size: isMobileLandscape ? 14 : (isMobile ? 16 : 18),
                                    color: isSelected ? color : (isDark ? Colors.white70 : Colors.black54),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    rol,
                                    style: TextStyle(fontSize: isMobileLandscape ? 11 : (isMobile ? 12 : 14)),
                                  ),
                                ],
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() => _selectedRolFilter = selected ? rol : null);
                                _applyFilters();
                                Navigator.pop(context);
                              },
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobileLandscape ? 6 : (isMobile ? 8 : 10),
                                vertical: isMobileLandscape ? 2 : (isMobile ? 4 : 6),
                              ),
                              selectedColor: color.withOpacity(0.2),
                              checkmarkColor: color,
                              labelStyle: TextStyle(
                                color: isSelected 
                                    ? color
                                    : (isDark ? Colors.white70 : Colors.black87),
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Footer con botones
              Container(
                padding: EdgeInsets.all(isMobileLandscape ? 10 : (isMobile ? 12 : 20)),
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(isMobileLandscape ? 12 : 16),
                    bottomRight: Radius.circular(isMobileLandscape ? 12 : 16),
                  ),
                ),
                child: Row(
                  children: [
                    // Botón limpiar
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _selectedRolFilter = null);
                          _applyFilters();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: isMobileLandscape ? 8 : (isMobile ? 10 : 14),
                          ),
                          side: BorderSide(
                            color: isDark ? Colors.white30 : AppColors.primary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : 10),
                          ),
                        ),
                        child: Text(
                          'Limpiar',
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.primary,
                            fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 15),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isMobileLandscape ? 6 : (isMobile ? 8 : 12)),
                    // Botón cerrar
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: isMobileLandscape ? 8 : (isMobile ? 10 : 14),
                          ),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : 10),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Cerrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 15),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getRolIconData(String rol) {
    switch (rol.toLowerCase()) {
      case 'admin':
      case 'administrador':
        return Icons.admin_panel_settings_rounded;
      case 'coordinador':
        return Icons.supervisor_account_rounded;
      case 'profesor':
        return Icons.school_rounded;
      default:
        return Icons.person_rounded;
    }
  }
}
