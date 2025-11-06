import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:proyecto_santi/models/usuario.dart';
import 'package:proyecto_santi/services/usuario_service.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import 'package:intl/intl.dart';

/// Vista CRUD para gestionar Usuarios del sistema
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
  String _searchQuery = '';
  
  final isDesktop = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  @override
  void initState() {
    super.initState();
    _loadUsuarios();
  }

  Future<void> _loadUsuarios() async {
    setState(() => _isLoading = true);
    try {
      final usuarios = await _usuarioService.fetchUsuarios();
      setState(() {
        _usuarios = usuarios;
        _filteredUsuarios = usuarios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar usuarios: $e')),
        );
      }
    }
  }

  void _filterUsuarios(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredUsuarios = _usuarios;
      } else {
        _filteredUsuarios = _usuarios.where((usuario) {
          final nombreLower = usuario.nombreUsuario.toLowerCase();
          final emailLower = usuario.email.toLowerCase();
          final rolLower = usuario.rol.toLowerCase();
          final queryLower = query.toLowerCase();
          return nombreLower.contains(queryLower) ||
              emailLower.contains(queryLower) ||
              rolLower.contains(queryLower);
        }).toList();
      }
    });
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
        content: Text('¿Está seguro de que desea eliminar al usuario "${usuario.nombreUsuario}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
            SnackBar(content: Text('Error al eliminar usuario: $e')),
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
          SnackBar(
            content: Text(usuario.activo ? 'Usuario desactivado' : 'Usuario activado'),
          ),
        );
      }
      await _loadUsuarios();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar estado: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      body: Stack(
        children: [
          isDark 
            ? GradientBackgroundDark(child: Container()) 
            : GradientBackgroundLight(child: Container()),
          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Gestión de Usuarios',
                              style: TextStyle(
                                fontSize: isMobile ? 18.sp : 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!isMobile)
                            ElevatedButton.icon(
                              onPressed: () => _showUsuarioDialog(),
                              icon: Icon(Icons.add),
                              label: Text('Nuevo Usuario'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF1976d2),
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Barra de búsqueda
                      TextField(
                        onChanged: _filterUsuarios,
                        decoration: InputDecoration(
                          hintText: 'Buscar usuarios...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: isMobile ? 8 : 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _filteredUsuarios.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isEmpty
                                        ? 'No hay usuarios registrados'
                                        : 'No se encontraron usuarios',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : isMobile
                              ? _buildMobileList()
                              : _buildDesktopTable(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () => _showUsuarioDialog(),
              backgroundColor: Color(0xFF1976d2),
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: _filteredUsuarios.length,
      itemBuilder: (context, index) {
        final usuario = _filteredUsuarios[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRolColor(usuario.rol),
              child: Icon(
                usuario.activo ? Icons.person : Icons.person_off,
                color: Colors.white,
              ),
            ),
            title: Text(
              usuario.nombreUsuario,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
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
                      ),
                      SizedBox(width: 8),
                      Text(usuario.activo ? 'Desactivar' : 'Activar'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showUsuarioDialog(usuario: usuario);
                    break;
                  case 'toggle':
                    _toggleActivo(usuario);
                    break;
                  case 'delete':
                    _deleteUsuario(usuario);
                    break;
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Card(
        child: DataTable(
          columns: [
            DataColumn(label: Text('Usuario')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Rol')),
            DataColumn(label: Text('Estado')),
            DataColumn(label: Text('Último acceso')),
            DataColumn(label: Text('Acciones')),
          ],
          rows: _filteredUsuarios.map((usuario) {
            return DataRow(
              cells: [
                DataCell(Text(usuario.nombreUsuario)),
                DataCell(Text(usuario.email)),
                DataCell(_buildRolChip(usuario.rol)),
                DataCell(_buildStatusChip(usuario.activo)),
                DataCell(Text(
                  usuario.ultimoAcceso != null
                      ? DateFormat('dd/MM/yyyy HH:mm').format(usuario.ultimoAcceso!)
                      : 'Nunca',
                )),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, size: 20),
                        onPressed: () => _showUsuarioDialog(usuario: usuario),
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: Icon(
                          usuario.activo ? Icons.block : Icons.check_circle,
                          size: 20,
                          color: usuario.activo ? Colors.orange : Colors.green,
                        ),
                        onPressed: () => _toggleActivo(usuario),
                        tooltip: usuario.activo ? 'Desactivar' : 'Activar',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, size: 20, color: Colors.red),
                        onPressed: () => _deleteUsuario(usuario),
                        tooltip: 'Eliminar',
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getRolColor(rol).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getRolColor(rol)),
      ),
      child: Text(
        rol,
        style: TextStyle(
          color: _getRolColor(rol),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool activo) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: activo ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: activo ? Colors.green : Colors.red),
      ),
      child: Text(
        activo ? 'Activo' : 'Inactivo',
        style: TextStyle(
          color: activo ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getRolColor(String rol) {
    switch (rol.toLowerCase()) {
      case 'admin':
      case 'administrador':
        return Colors.red;
      case 'coordinador':
        return Colors.blue;
      case 'profesor':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

// Dialog para crear/editar usuario
class _UsuarioDialog extends StatefulWidget {
  final Usuario? usuario;
  final Function(Map<String, dynamic>) onSave;

  const _UsuarioDialog({
    this.usuario,
    required this.onSave,
  });

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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AlertDialog(
      title: Text(widget.usuario == null ? 'Nuevo Usuario' : 'Editar Usuario'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre de usuario',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un nombre de usuario';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un email';
                  }
                  if (!value.contains('@')) {
                    return 'Ingrese un email válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: widget.usuario == null ? 'Contraseña' : 'Nueva contraseña (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (widget.usuario == null && (value == null || value.isEmpty)) {
                    return 'Ingrese una contraseña';
                  }
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRol,
                decoration: InputDecoration(
                  labelText: 'Rol',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                items: _roles.map((rol) {
                  return DropdownMenuItem(
                    value: rol,
                    child: Text(rol),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedRol = value!);
                },
              ),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text('Usuario activo'),
                value: _activo,
                onChanged: (value) {
                  setState(() => _activo = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final data = {
                'nombreUsuario': _nombreController.text,
                'email': _emailController.text,
                'rol': _selectedRol,
                'activo': _activo,
              };

              if (_passwordController.text.isNotEmpty) {
                data['password'] = _passwordController.text;
              }

              widget.onSave(data);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1976d2),
            foregroundColor: Colors.white,
          ),
          child: Text(widget.usuario == null ? 'Crear' : 'Guardar'),
        ),
      ],
    );
  }
}
