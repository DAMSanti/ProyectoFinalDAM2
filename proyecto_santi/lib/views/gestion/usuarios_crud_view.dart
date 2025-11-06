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
      if (query.isEmpty) {
        _filteredUsuarios = _usuarios;
      } else {
        final queryLower = query.toLowerCase();
        _filteredUsuarios = _usuarios.where((usuario) {
          return usuario.nombreUsuario.toLowerCase().contains(queryLower) ||
              usuario.email.toLowerCase().contains(queryLower) ||
              usuario.rol.toLowerCase().contains(queryLower);
        }).toList();
      }
    });
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

                // Barra de búsqueda
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterUsuarios,
                    decoration: InputDecoration(
                      hintText: 'Buscar usuarios...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterUsuarios('');
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
}
