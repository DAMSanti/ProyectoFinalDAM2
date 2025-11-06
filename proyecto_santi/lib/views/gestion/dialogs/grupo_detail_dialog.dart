import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proyecto_santi/models/grupo.dart';
import 'package:proyecto_santi/models/curso.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/tema/app_colors.dart';

class GrupoDetailDialog extends StatefulWidget {
  final Grupo? grupo;
  final List<Curso> cursos;
  final VoidCallback onSaved;

  const GrupoDetailDialog({
    Key? key,
    this.grupo,
    required this.cursos,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<GrupoDetailDialog> createState() => _GrupoDetailDialogState();
}

class _GrupoDetailDialogState extends State<GrupoDetailDialog> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  late final CatalogoService _catalogoService;
  
  // Controllers
  late final TextEditingController _nombreController;
  late final TextEditingController _numeroAlumnosController;
  
  int? _cursoSeleccionado;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _catalogoService = CatalogoService(_apiService);
    
    // Inicializar controllers con valores existentes o vacíos
    _nombreController = TextEditingController(text: widget.grupo?.nombre ?? '');
    _numeroAlumnosController = TextEditingController(
      text: widget.grupo?.numeroAlumnos.toString() ?? ''
    );
    
    _cursoSeleccionado = widget.grupo?.cursoId;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _numeroAlumnosController.dispose();
    super.dispose();
  }

  Future<void> _saveGrupo() async {
    if (!_formKey.currentState!.validate()) return;

    if (_cursoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un curso'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'nombre': _nombreController.text.trim(),
        'numeroAlumnos': int.parse(_numeroAlumnosController.text.trim()),
        'cursoId': _cursoSeleccionado,
      };

      if (widget.grupo != null) {
        // Actualizar
        await _catalogoService.updateGrupo(widget.grupo!.id, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Grupo actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Crear
        await _catalogoService.createGrupo(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Grupo creado correctamente'),
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
              Icons.group_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              widget.grupo != null ? 'Editar Grupo' : 'Nuevo Grupo',
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
            onPressed: _isLoading ? null : _saveGrupo,
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
        // Fila 1: Nombre y Curso
        Row(
          children: [
            Expanded(child: _buildNombreField(isDark)),
            SizedBox(width: 16.w),
            Expanded(child: _buildCursoField(isDark)),
          ],
        ),
        SizedBox(height: 16.h),
        // Fila 2: Número de alumnos
        _buildNumeroAlumnosField(isDark),
      ],
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return Column(
      children: [
        _buildNombreField(isDark),
        SizedBox(height: 16.h),
        _buildCursoField(isDark),
        SizedBox(height: 16.h),
        _buildNumeroAlumnosField(isDark),
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

  Widget _buildNombreField(bool isDark) {
    return _buildStyledField(
      label: 'Código del Grupo *',
      icon: Icons.tag_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _nombreController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        maxLength: 8,
        decoration: InputDecoration(
          hintText: 'Ej: DAM2A',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          counterText: '',
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'El código del grupo es obligatorio';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCursoField(bool isDark) {
    return _buildStyledField(
      label: 'Curso *',
      icon: Icons.school_rounded,
      isDark: isDark,
      child: DropdownButtonFormField<int>(
        value: _cursoSeleccionado,
        dropdownColor: isDark ? Colors.grey[800] : Colors.white,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        isExpanded: true,
        decoration: InputDecoration(
          hintText: 'Seleccionar curso',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: widget.cursos.map((curso) {
          return DropdownMenuItem<int>(
            value: curso.id,
            child: Text(
              curso.titulo,
              style: TextStyle(fontSize: 14.sp),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _cursoSeleccionado = value;
          });
        },
      ),
    );
  }

  Widget _buildNumeroAlumnosField(bool isDark) {
    return _buildStyledField(
      label: 'Número de Alumnos *',
      icon: Icons.people_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _numeroAlumnosController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'El número de alumnos es obligatorio';
          }
          final numero = int.tryParse(value.trim());
          if (numero == null || numero < 0) {
            return 'Debe ser un número válido';
          }
          return null;
        },
      ),
    );
  }
}
