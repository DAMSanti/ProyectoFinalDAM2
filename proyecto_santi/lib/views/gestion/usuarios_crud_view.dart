import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:proyecto_santi/models/usuario.dart';
import 'package:proyecto_santi/services/usuario_service.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import 'package:proyecto_santi/tema/app_colors.dart';
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
                // Header simple
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                      Expanded(
                        child: Text(
                          'Usuarios',
                          style: TextStyle(
                            fontSize: isMobile ? 24.sp : 28,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.primary,
                          ),
                        ),
                      ),
                      if (!isMobile)
                        ElevatedButton.icon(
                          onPressed: () => _showUsuarioDialog(),
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

                // Lista/Tabla
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _filteredUsuarios.isEmpty
                          ? Center(
                              child: Text(
                                'No se encontraron usuarios',
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : AppColors.textLight,
                                ),
                              ),
                            )
                          : isMobile
                              ? _buildMobileList(isDark)
                              : _buildDesktopTable(isDark),
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

  Widget _buildMobileList(bool isDark) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _filteredUsuarios.length,
      itemBuilder: (context, index) {
        final usuario = _filteredUsuarios[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          color: isDark ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRolColor(usuario.rol).withOpacity(0.2),
              child: Text(
                usuario.nombreUsuario[0].toUpperCase(),
                style: TextStyle(
                  color: _getRolColor(usuario.rol),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              usuario.nombreUsuario,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(usuario.email),
                SizedBox(height: 4),
                Row(
                  children: [
                    _buildRolChip(usuario.rol),
                    SizedBox(width: 8),
                    _buildStatusChip(usuario.activo),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              icon: Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.edit, size: 20),
                    title: Text('Editar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onTap: () => Future.delayed(
                    Duration(milliseconds: 100),
                    () => _showUsuarioDialog(usuario: usuario),
                  ),
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(
                      usuario.activo ? Icons.block : Icons.check_circle,
                      size: 20,
                    ),
                    title: Text(usuario.activo ? 'Desactivar' : 'Activar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onTap: () => Future.delayed(
                    Duration(milliseconds: 100),
                    () => _toggleActivo(usuario),
                  ),
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.delete, size: 20, color: Colors.red),
                    title: Text('Eliminar', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onTap: () => Future.delayed(
                    Duration(milliseconds: 100),
                    () => _deleteUsuario(usuario),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Card(
        color: isDark ? Colors.grey[850] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            isDark ? Colors.grey[800] : Colors.grey[100],
          ),
          columns: [
            DataColumn(label: Text('Usuario', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Rol', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _filteredUsuarios.map((usuario) {
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getRolColor(usuario.rol).withOpacity(0.2),
                        child: Text(
                          usuario.nombreUsuario[0].toUpperCase(),
                          style: TextStyle(
                            color: _getRolColor(usuario.rol),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(usuario.nombreUsuario),
                    ],
                  ),
                ),
                DataCell(Text(usuario.email)),
                DataCell(_buildRolChip(usuario.rol)),
                DataCell(_buildStatusChip(usuario.activo)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, size: 20),
                        color: AppColors.primary,
                        onPressed: () => _showUsuarioDialog(usuario: usuario),
                      ),
                      IconButton(
                        icon: Icon(
                          usuario.activo ? Icons.block : Icons.check_circle,
                          size: 20,
                        ),
                        color: usuario.activo ? Colors.orange : Colors.green,
                        onPressed: () => _toggleActivo(usuario),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, size: 20),
                        color: Colors.red,
                        onPressed: () => _deleteUsuario(usuario),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
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
      builder: (context) => _UsuarioDialog(
        usuario: usuario,
        onSave: (usuarioData) async {
          try {
            if (usuario == null) {
              await _usuarioService.createUsuario(usuarioData);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Usuario creado correctamente')),
                );
              }
            } else {
              await _usuarioService.updateUsuario(usuario.id, usuarioData);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Usuario actualizado correctamente')),
                );
              }
            }
            await _loadUsuarios();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        },
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

// Dialog para crear/editar usuario
class _UsuarioDialog extends StatefulWidget {
  final Usuario? usuario;
  final Function(Map<String, dynamic>) onSave;

  const _UsuarioDialog({required this.usuario, required this.onSave});

  @override
  State<_UsuarioDialog> createState() => _UsuarioDialogState();
}

class _UsuarioDialogState extends State<_UsuarioDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String _selectedRol = 'Usuario';
  bool _activo = true;

  final List<String> _roles = ['Admin', 'Coordinador', 'Profesor', 'Usuario'];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.usuario?.nombreUsuario ?? '');
    _emailController = TextEditingController(text: widget.usuario?.email ?? '');
    _passwordController = TextEditingController();
    _selectedRol = widget.usuario?.rol ?? 'Usuario';
    _activo = widget.usuario?.activo ?? true;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.usuario != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEdit ? 'Editar Usuario' : 'Nuevo Usuario',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre de Usuario',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) => value?.isEmpty == true ? 'Campo requerido' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: isEdit ? 'Nueva Contraseña (opcional)' : 'Contraseña',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (!isEdit && (value?.isEmpty == true)) {
                    return 'Campo requerido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRol,
                decoration: InputDecoration(
                  labelText: 'Rol',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: _roles.map((rol) => DropdownMenuItem(value: rol, child: Text(rol))).toList(),
                onChanged: (value) => setState(() => _selectedRol = value!),
              ),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text('Usuario Activo'),
                value: _activo,
                onChanged: (value) => setState(() => _activo = value),
                activeColor: AppColors.primary,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final data = {
                          'nombreUsuario': _nombreController.text,
                          'rol': _selectedRol,
                          'activo': _activo,
                        };
                        if (_emailController.text.isNotEmpty) {
                          data['email'] = _emailController.text;
                        }
                        if (_passwordController.text.isNotEmpty) {
                          data['password'] = _passwordController.text;
                        }
                        widget.onSave(data);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text(isEdit ? 'Guardar' : 'Crear'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
