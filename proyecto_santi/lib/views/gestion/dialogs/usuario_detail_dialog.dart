import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:proyecto_santi/models/usuario.dart';
import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/services/usuario_service.dart';
import 'package:proyecto_santi/services/profesor_service.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/tema/app_colors.dart';

/// Diálogo responsive para crear/editar usuarios
/// Similar al estilo de ActivityDetailView
class UsuarioDetailDialog extends StatefulWidget {
  final Usuario? usuario; // null = crear nuevo
  final VoidCallback onSaved;

  const UsuarioDetailDialog({
    Key? key,
    this.usuario,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<UsuarioDetailDialog> createState() => _UsuarioDetailDialogState();
}

class _UsuarioDetailDialogState extends State<UsuarioDetailDialog> {
  final _formKey = GlobalKey<FormState>();
  final UsuarioService _usuarioService = UsuarioService(ApiService());
  final ProfesorService _profesorService = ProfesorService(ApiService());
  
  // Controllers
  late TextEditingController _nombreUsuarioController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  
  // Datos del formulario
  String _selectedRol = 'Usuario';
  bool _activo = true;
  Profesor? _profesorSeleccionado;
  List<Profesor> _profesores = [];
  bool _isLoadingProfesores = true;
  bool _isSaving = false;
  
  final List<String> _roles = ['Administrador', 'Coordinador', 'Profesor', 'Usuario'];
  
  bool get isDesktop {
    if (kIsWeb) return true;
    try {
      return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    } catch (e) {
      return false;
    }
  }
  
  bool get isEditing => widget.usuario != null;

  @override
  void initState() {
    super.initState();
    _nombreUsuarioController = TextEditingController(text: widget.usuario?.nombreUsuario ?? '');
    _emailController = TextEditingController(text: widget.usuario?.email ?? '');
    _passwordController = TextEditingController();
    _selectedRol = widget.usuario?.rol ?? 'Usuario';
    _activo = widget.usuario?.activo ?? true;
    _loadProfesores();
  }

  @override
  void dispose() {
    _nombreUsuarioController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfesores() async {
    try {
      final profesores = await _profesorService.fetchProfesores();
      setState(() {
        _profesores = profesores;
        _isLoadingProfesores = false;
        
        // Si estamos editando y hay un profesorUuid, preseleccionar el profesor
        if (isEditing && widget.usuario!.profesorUuid != null) {
          _profesorSeleccionado = _profesores.firstWhere(
            (p) => p.uuid == widget.usuario!.profesorUuid,
            orElse: () => _profesores.first,
          );
        }
      });
    } catch (e) {
      setState(() => _isLoadingProfesores = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar profesores: $e')),
        );
      }
    }
  }

  Future<void> _saveUsuario() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      if (isEditing) {
        // Al editar, actualizar datos del usuario (sin password)
        final data = {
          'nombreUsuario': _nombreUsuarioController.text.trim(),
          'email': _emailController.text.trim(),
          'rol': _selectedRol,
          'activo': _activo,
          'profesorUuid': _profesorSeleccionado?.uuid,
        };
        
        await _usuarioService.updateUsuario(widget.usuario!.id, data);
        
        // Si se proporcionó una nueva contraseña, cambiarla por separado
        if (_passwordController.text.isNotEmpty) {
          await _usuarioService.changePassword(
            widget.usuario!.id,
            _passwordController.text.trim(),
          );
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Usuario actualizado correctamente')),
          );
        }
      } else {
        // Al crear, incluir password en los datos
        final data = {
          'nombreUsuario': _nombreUsuarioController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'rol': _selectedRol,
          'activo': _activo,
          'profesorUuid': _profesorSeleccionado?.uuid,
        };
        
        await _usuarioService.createUsuario(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Usuario creado correctamente')),
          );
        }
      }
      
      widget.onSaved();
      Navigator.of(context).pop();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 24 : 40,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 900 : double.infinity,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Color(0xFF1a1a2e),
                    Color(0xFF16213e),
                  ]
                : [
                    Colors.white,
                    Colors.grey[50]!,
                  ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(isDark, isMobile),
              Flexible(
                child: _isLoadingProfesores
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(isMobile ? 16 : 24),
                        child: Form(
                          key: _formKey,
                          child: isDesktop && !isMobile
                              ? _buildDesktopLayout(isDark)
                              : _buildMobileLayout(isDark),
                        ),
                      ),
              ),
              _buildFooter(isDark, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEditing ? Icons.edit_rounded : Icons.person_add_rounded,
              color: Colors.white,
              size: isMobile ? 24 : 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Editar Usuario' : 'Nuevo Usuario',
                  style: TextStyle(
                    fontSize: isMobile ? 20.sp : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (isEditing) ...[
                  SizedBox(height: 4),
                  Text(
                    widget.usuario!.nombreUsuario,
                    style: TextStyle(
                      fontSize: isMobile ? 14.sp : 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila 1: Nombre de usuario y Email
        Row(
          children: [
            Expanded(child: _buildNombreUsuarioField(isDark)),
            SizedBox(width: 16),
            Expanded(child: _buildEmailField(isDark)),
          ],
        ),
        SizedBox(height: 20),
        
        // Fila 2: Contraseña y Rol
        Row(
          children: [
            Expanded(child: _buildPasswordField(isDark)),
            SizedBox(width: 16),
            Expanded(child: _buildRolField(isDark)),
          ],
        ),
        SizedBox(height: 20),
        
        // Fila 3: Profesor asociado
        _buildProfesorField(isDark),
        SizedBox(height: 20),
        
        // Fila 4: Estado activo
        _buildActivoSwitch(isDark),
      ],
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNombreUsuarioField(isDark),
        SizedBox(height: 16),
        _buildEmailField(isDark),
        SizedBox(height: 16),
        _buildPasswordField(isDark),
        SizedBox(height: 16),
        _buildRolField(isDark),
        SizedBox(height: 16),
        _buildProfesorField(isDark),
        SizedBox(height: 16),
        _buildActivoSwitch(isDark),
      ],
    );
  }

  Widget _buildNombreUsuarioField(bool isDark) {
    return _buildStyledField(
      label: 'Nombre de Usuario',
      icon: Icons.person_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _nombreUsuarioController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: 'Ingrese nombre de usuario',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'El nombre de usuario es requerido';
          }
          if (value.trim().length < 3) {
            return 'Mínimo 3 caracteres';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildEmailField(bool isDark) {
    return _buildStyledField(
      label: 'Email',
      icon: Icons.email_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: 'correo@ejemplo.com',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value)) {
              return 'Email inválido';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(bool isDark) {
    return _buildStyledField(
      label: isEditing ? 'Nueva Contraseña (opcional)' : 'Contraseña',
      icon: Icons.lock_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _passwordController,
        obscureText: true,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: isEditing ? 'Dejar vacío para no cambiar' : 'Ingrese contraseña',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) {
          if (!isEditing && (value == null || value.isEmpty)) {
            return 'La contraseña es requerida';
          }
          if (value != null && value.isNotEmpty && value.length < 6) {
            return 'Mínimo 6 caracteres';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRolField(bool isDark) {
    return _buildStyledField(
      label: 'Rol del Usuario',
      icon: Icons.badge_rounded,
      isDark: isDark,
      child: DropdownButtonFormField<String>(
        value: _selectedRol,
        dropdownColor: isDark ? Color(0xFF1a1a2e) : Colors.white,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white70 : Colors.black54),
        items: _roles.map((rol) {
          return DropdownMenuItem(
            value: rol,
            child: Row(
              children: [
                _getRolIcon(rol),
                SizedBox(width: 8),
                Text(rol),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedRol = value!),
      ),
    );
  }

  Widget _buildProfesorField(bool isDark) {
    return _buildStyledField(
      label: 'Profesor Asociado (opcional)',
      icon: Icons.school_rounded,
      isDark: isDark,
      child: DropdownButtonFormField<Profesor?>(
        value: _profesorSeleccionado,
        dropdownColor: isDark ? Color(0xFF1a1a2e) : Colors.white,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white70 : Colors.black54),
        hint: Text(
          'Seleccione un profesor',
          style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
        ),
        items: [
          DropdownMenuItem<Profesor?>(
            value: null,
            child: Text('Sin profesor asociado'),
          ),
          ..._profesores.map((profesor) {
            return DropdownMenuItem<Profesor>(
              value: profesor,
              child: Text('${profesor.nombre} ${profesor.apellidos}'),
            );
          }).toList(),
        ],
        onChanged: (value) => setState(() => _profesorSeleccionado = value),
      ),
    );
  }

  Widget _buildActivoSwitch(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _activo ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _activo ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: _activo ? Colors.green : Colors.grey,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado del Usuario',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _activo ? 'Usuario activo' : 'Usuario inactivo',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _activo,
            onChanged: (value) => setState(() => _activo = value),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildStyledField({
    required String label,
    required IconData icon,
    required bool isDark,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
            ),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildFooter(bool isDark, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveUsuario,
            icon: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(isEditing ? Icons.save_rounded : Icons.add_rounded),
            label: Text(
              isEditing ? 'Guardar Cambios' : 'Crear Usuario',
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Icon _getRolIcon(String rol) {
    final rolLower = rol.toLowerCase();
    if (rolLower == 'admin' || rolLower == 'administrador') {
      return Icon(Icons.admin_panel_settings_rounded, color: Colors.red, size: 20);
    } else if (rolLower == 'coordinador') {
      return Icon(Icons.supervisor_account_rounded, color: AppColors.primary, size: 20);
    } else if (rolLower == 'profesor') {
      return Icon(Icons.school_rounded, color: Colors.green, size: 20);
    } else {
      return Icon(Icons.person_rounded, color: Colors.grey, size: 20);
    }
  }
}
