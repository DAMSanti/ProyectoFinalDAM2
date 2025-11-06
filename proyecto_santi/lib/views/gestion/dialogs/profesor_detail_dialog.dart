import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/models/departamento.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/tema/app_colors.dart';

class ProfesorDetailDialog extends StatefulWidget {
  final Profesor? profesor;
  final VoidCallback onSaved;

  const ProfesorDetailDialog({
    Key? key,
    this.profesor,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<ProfesorDetailDialog> createState() => _ProfesorDetailDialogState();
}

class _ProfesorDetailDialogState extends State<ProfesorDetailDialog> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  late final ProfesorService _profesorService;
  late final CatalogoService _catalogoService;
  
  // Controllers
  late final TextEditingController _dniController;
  late final TextEditingController _nombreController;
  late final TextEditingController _apellidosController;
  late final TextEditingController _correoController;
  late final TextEditingController _passwordController;
  
  String? _rolSeleccionado;
  int? _departamentoSeleccionado;
  bool _activo = true;
  bool _esJefeDep = false;
  bool _isLoading = false;
  
  List<Departamento> _departamentos = [];

  // Roles según la base de datos
  final List<Map<String, String>> _roles = [
    {'value': 'PROF', 'label': 'Profesor'},
    {'value': 'ED', 'label': 'Equipo Directivo'},
    {'value': 'ADM', 'label': 'Administrador'},
  ];

  @override
  void initState() {
    super.initState();
    _profesorService = ProfesorService(_apiService);
    _catalogoService = CatalogoService(_apiService);
    
    // Inicializar controllers con valores existentes o vacíos
    _dniController = TextEditingController(text: widget.profesor?.dni ?? '');
    _nombreController = TextEditingController(text: widget.profesor?.nombre ?? '');
    _apellidosController = TextEditingController(text: widget.profesor?.apellidos ?? '');
    _correoController = TextEditingController(text: widget.profesor?.correo ?? '');
    _passwordController = TextEditingController();
    
    // Validar que el rol exista en la lista de valores permitidos
    if (widget.profesor != null && widget.profesor!.rol.isNotEmpty) {
      final rolValido = _roles.any((r) => r['value'] == widget.profesor!.rol);
      _rolSeleccionado = rolValido ? widget.profesor!.rol : 'PROF';
    } else {
      _rolSeleccionado = 'PROF';
    }
    
    _departamentoSeleccionado = widget.profesor?.depart?.id;
    _activo = widget.profesor?.activo == 1;
    _esJefeDep = widget.profesor?.esJefeDep == 1;
    
    _loadDepartamentos();
  }

  @override
  void dispose() {
    _dniController.dispose();
    _nombreController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartamentos() async {
    try {
      final departamentos = await _catalogoService.fetchDepartamentos();
      if (mounted) {
        setState(() {
          _departamentos = departamentos;
        });
      }
    } catch (e) {
      print('Error loading departamentos: $e');
    }
  }

  Future<void> _saveProfesor() async {
    if (!_formKey.currentState!.validate()) return;

    if (_departamentoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un departamento'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Si es nuevo profesor, la contraseña es obligatoria
    if (widget.profesor == null) {
      if (_passwordController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La contraseña es obligatoria para nuevos profesores'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'dni': _dniController.text.trim(),
        'nombre': _nombreController.text.trim(),
        'apellidos': _apellidosController.text.trim(),
        'correo': _correoController.text.trim(),
        'rol': _rolSeleccionado,
        'activo': _activo ? 1 : 0,
        'esJefeDep': _esJefeDep ? 1 : 0,
        'departId': _departamentoSeleccionado,
      };

      // Solo incluir password al crear (no al editar)
      if (widget.profesor == null && _passwordController.text.trim().isNotEmpty) {
        data['password'] = _passwordController.text.trim();
      }

      if (widget.profesor != null) {
        // Actualizar
        data['uuid'] = widget.profesor!.uuid;
        final profesor = Profesor.fromJson(data);
        await _profesorService.updateProfesor(widget.profesor!.uuid, profesor);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profesor actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Crear
        final profesor = Profesor.fromJson(data);
        await _profesorService.createProfesor(profesor);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profesor creado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      widget.onSaved();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
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
    final isDesktop = screenWidth > 900;

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
                    const Color(0xFF1a1a2e),
                    const Color(0xFF16213e),
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
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header con gradiente
              _buildHeader(isDark, isMobile),
              // Contenido con scroll
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Form(
                    key: _formKey,
                    child: isDesktop && !isMobile
                        ? _buildDesktopLayout(isDark)
                        : _buildMobileLayout(isDark),
                  ),
                ),
              ),
              // Footer con botones
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
              Icons.person_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              widget.profesor != null ? 'Editar Profesor' : 'Nuevo Profesor',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 20.sp : 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey[100],
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[700],
                fontSize: isMobile ? 14.sp : 16.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveProfesor,
            icon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.save_rounded, size: isMobile ? 18 : 20),
            label: Text(
              _isLoading ? 'Guardando...' : 'Guardar',
              style: TextStyle(fontSize: isMobile ? 14.sp : 16.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 24,
                vertical: isMobile ? 10 : 12,
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

  Widget _buildDesktopLayout(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila 1: DNI, Nombre, Apellidos
        Row(
          children: [
            Expanded(child: _buildDniField(isDark)),
            SizedBox(width: 16.w),
            Expanded(child: _buildNombreField(isDark)),
            SizedBox(width: 16.w),
            Expanded(child: _buildApellidosField(isDark)),
          ],
        ),
        SizedBox(height: 16.h),
        // Fila 2: Correo y Contraseña (solo al crear)
        if (widget.profesor == null)
          Row(
            children: [
              Expanded(flex: 2, child: _buildCorreoField(isDark)),
              SizedBox(width: 16.w),
              Expanded(child: _buildPasswordField(isDark)),
            ],
          )
        else
          _buildCorreoField(isDark),
        SizedBox(height: 16.h),
        // Fila 3: Rol y Departamento
        Row(
          children: [
            Expanded(child: _buildRolField(isDark)),
            SizedBox(width: 16.w),
            Expanded(child: _buildDepartamentoField(isDark)),
          ],
        ),
        SizedBox(height: 16.h),
        // Fila 4: Estados (Activo y Jefe Dep)
        Row(
          children: [
            Expanded(child: _buildActivoField(isDark)),
            SizedBox(width: 16.w),
            Expanded(child: _buildJefeDepField(isDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return Column(
      children: [
        _buildDniField(isDark),
        SizedBox(height: 16.h),
        _buildNombreField(isDark),
        SizedBox(height: 16.h),
        _buildApellidosField(isDark),
        SizedBox(height: 16.h),
        _buildCorreoField(isDark),
        SizedBox(height: 16.h),
        // Contraseña solo al crear
        if (widget.profesor == null) ...[
          _buildPasswordField(isDark),
          SizedBox(height: 16.h),
        ],
        _buildRolField(isDark),
        SizedBox(height: 16.h),
        _buildDepartamentoField(isDark),
        SizedBox(height: 16.h),
        _buildActivoField(isDark),
        SizedBox(height: 16.h),
        _buildJefeDepField(isDark),
      ],
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
            Icon(icon, size: 18, color: AppColors.primary),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
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

  Widget _buildDniField(bool isDark) {
    return _buildStyledField(
      label: 'DNI *',
      icon: Icons.badge_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _dniController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        maxLength: 9,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          hintText: '12345678A',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          counterText: '',
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'El DNI es obligatorio';
          }
          if (value.trim().length != 9) {
            return 'Debe tener 9 caracteres';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildNombreField(bool isDark) {
    return _buildStyledField(
      label: 'Nombre *',
      icon: Icons.person_outline_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _nombreController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        maxLength: 25,
        decoration: InputDecoration(
          hintText: 'Juan',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          counterText: '',
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'El nombre es obligatorio';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildApellidosField(bool isDark) {
    return _buildStyledField(
      label: 'Apellidos *',
      icon: Icons.person_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _apellidosController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        maxLength: 45,
        decoration: InputDecoration(
          hintText: 'García López',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          counterText: '',
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Los apellidos son obligatorios';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCorreoField(bool isDark) {
    return _buildStyledField(
      label: 'Correo Electrónico *',
      icon: Icons.email_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _correoController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'profesor@educantabria.es',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'El correo es obligatorio';
          }
          if (!value.contains('@')) {
            return 'Correo no válido';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(bool isDark) {
    return _buildStyledField(
      label: widget.profesor != null ? 'Contraseña (dejar vacío para no cambiar)' : 'Contraseña *',
      icon: Icons.lock_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _passwordController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        obscureText: true,
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildRolField(bool isDark) {
    return _buildStyledField(
      label: 'Rol *',
      icon: Icons.admin_panel_settings_rounded,
      isDark: isDark,
      child: DropdownButtonFormField<String>(
        value: _rolSeleccionado,
        dropdownColor: isDark ? Colors.grey[800] : Colors.white,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        isExpanded: true,
        decoration: InputDecoration(
          hintText: 'Seleccionar rol',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: _roles.map((rol) {
          return DropdownMenuItem<String>(
            value: rol['value']!,
            child: Text(
              rol['label']!,
              style: TextStyle(fontSize: 14.sp),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _rolSeleccionado = value;
          });
        },
      ),
    );
  }

  Widget _buildDepartamentoField(bool isDark) {
    return _buildStyledField(
      label: 'Departamento *',
      icon: Icons.business_rounded,
      isDark: isDark,
      child: DropdownButtonFormField<int>(
        value: _departamentoSeleccionado,
        dropdownColor: isDark ? Colors.grey[800] : Colors.white,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        isExpanded: true,
        decoration: InputDecoration(
          hintText: 'Seleccionar departamento',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: _departamentos.map((depto) {
          return DropdownMenuItem<int>(
            value: depto.id,
            child: Text(
              depto.nombre,
              style: TextStyle(fontSize: 14.sp),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _departamentoSeleccionado = value;
          });
        },
      ),
    );
  }

  Widget _buildActivoField(bool isDark) {
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
          Icon(
            _activo ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: _activo ? Colors.green : Colors.red,
            size: 24,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Profesor Activo',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Switch(
            value: _activo,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                _activo = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildJefeDepField(bool isDark) {
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
          Icon(
            Icons.star_rounded,
            color: _esJefeDep ? Colors.amber : Colors.grey,
            size: 24,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Jefe Departamento',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Switch(
            value: _esJefeDep,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                _esJefeDep = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
