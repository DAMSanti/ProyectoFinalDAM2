import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proyecto_santi/models/curso.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/tema/app_colors.dart';

class CursoDetailDialog extends StatefulWidget {
  final Curso? curso;
  final VoidCallback onSaved;

  const CursoDetailDialog({
    Key? key,
    this.curso,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<CursoDetailDialog> createState() => _CursoDetailDialogState();
}

class _CursoDetailDialogState extends State<CursoDetailDialog> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  late final CatalogoService _catalogoService;
  
  // Controllers
  late final TextEditingController _codCursoController;
  late final TextEditingController _tituloController;
  
  String? _etapaSeleccionada;
  String? _nivelSeleccionado;
  bool _activo = true;
  bool _isLoading = false;

  // Etapas según la base de datos
  final List<Map<String, String>> _etapas = [
    {'value': 'ESO', 'label': 'ESO - Educación Secundaria Obligatoria'},
    {'value': 'BACH', 'label': 'BACH - Bachillerato'},
    {'value': 'FPB', 'label': 'FPB - FP Básica'},
    {'value': 'FPGM', 'label': 'FPGM - FP Grado Medio'},
    {'value': 'FPGS', 'label': 'FPGS - FP Grado Superior'},
    {'value': 'FPCE', 'label': 'FPCE - FP Curso de Especialización'},
  ];

  final List<String> _niveles = ['1', '2', '3', '4'];

  @override
  void initState() {
    super.initState();
    _catalogoService = CatalogoService(_apiService);
    
    // Inicializar controllers con valores existentes o vacíos
    _codCursoController = TextEditingController(text: widget.curso?.codCurso ?? '');
    _tituloController = TextEditingController(text: widget.curso?.titulo ?? '');
    
    // Validar que la etapa exista en la lista de valores permitidos
    if (widget.curso != null && widget.curso!.etapa.isNotEmpty) {
      final etapaValida = _etapas.any((e) => e['value'] == widget.curso!.etapa);
      _etapaSeleccionada = etapaValida ? widget.curso!.etapa : null;
    }
    
    // Validar que el nivel exista en la lista de valores permitidos
    if (widget.curso != null && widget.curso!.nivel.isNotEmpty) {
      final nivelValido = _niveles.contains(widget.curso!.nivel);
      _nivelSeleccionado = nivelValido ? widget.curso!.nivel : null;
    }
    
    _activo = widget.curso?.activo ?? true;
  }

  @override
  void dispose() {
    _codCursoController.dispose();
    _tituloController.dispose();
    super.dispose();
  }

  Future<void> _saveCurso() async {
    if (!_formKey.currentState!.validate()) return;

    if (_etapaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar una etapa'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_nivelSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un nivel'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // El backend solo acepta: nombre, nivel, activo
      // Guardamos toda la info en el campo nombre: "CODIGO - TITULO"
      final nombreCompleto = '${_codCursoController.text.trim()} - ${_tituloController.text.trim()}';
      
      final data = {
        'nombre': nombreCompleto,
        'nivel': _nivelSeleccionado,
        'activo': _activo,
      };

      if (widget.curso != null) {
        // Actualizar
        await _catalogoService.updateCurso(widget.curso!.id, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Curso actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Crear
        await _catalogoService.createCurso(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Curso creado correctamente'),
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
              Icons.school_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              widget.curso != null ? 'Editar Curso' : 'Nuevo Curso',
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
            onPressed: _isLoading ? null : _saveCurso,
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
        // Fila 1: Código y Título
        Row(
          children: [
            Expanded(child: _buildCodCursoField(isDark)),
            SizedBox(width: 16.w),
            Expanded(flex: 2, child: _buildTituloField(isDark)),
          ],
        ),
        SizedBox(height: 16.h),
        // Fila 2: Etapa y Nivel
        Row(
          children: [
            Expanded(flex: 2, child: _buildEtapaField(isDark)),
            SizedBox(width: 16.w),
            Expanded(child: _buildNivelField(isDark)),
          ],
        ),
        SizedBox(height: 16.h),
        // Fila 3: Estado activo
        _buildActivoField(isDark),
      ],
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return Column(
      children: [
        _buildCodCursoField(isDark),
        SizedBox(height: 16.h),
        _buildTituloField(isDark),
        SizedBox(height: 16.h),
        _buildEtapaField(isDark),
        SizedBox(height: 16.h),
        _buildNivelField(isDark),
        SizedBox(height: 16.h),
        _buildActivoField(isDark),
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

  Widget _buildCodCursoField(bool isDark) {
    return _buildStyledField(
      label: 'Código del Curso *',
      icon: Icons.tag_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _codCursoController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        maxLength: 8,
        decoration: InputDecoration(
          hintText: 'Ej: DAM2',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          counterText: '',
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'El código es obligatorio';
          }
          if (value.trim().length > 8) {
            return 'Máximo 8 caracteres';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTituloField(bool isDark) {
    return _buildStyledField(
      label: 'Título del Curso *',
      icon: Icons.title_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _tituloController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        maxLines: 2,
        decoration: InputDecoration(
          hintText: 'Ej: 2º FP Grado Superior de Desarrollo de Aplicaciones Multiplataforma',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'El título es obligatorio';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildEtapaField(bool isDark) {
    return _buildStyledField(
      label: 'Etapa Educativa *',
      icon: Icons.stairs_rounded,
      isDark: isDark,
      child: DropdownButtonFormField<String>(
        value: _etapaSeleccionada,
        dropdownColor: isDark ? Colors.grey[800] : Colors.white,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        isExpanded: true,
        decoration: InputDecoration(
          hintText: 'Seleccionar etapa',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: _etapas.map((etapa) {
          return DropdownMenuItem<String>(
            value: etapa['value']!,
            child: Text(
              etapa['label']!,
              style: TextStyle(fontSize: 14.sp),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _etapaSeleccionada = value;
          });
        },
      ),
    );
  }

  Widget _buildNivelField(bool isDark) {
    return _buildStyledField(
      label: 'Nivel *',
      icon: Icons.looks_one_rounded,
      isDark: isDark,
      child: DropdownButtonFormField<String>(
        value: _nivelSeleccionado,
        dropdownColor: isDark ? Colors.grey[800] : Colors.white,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        isExpanded: true,
        decoration: InputDecoration(
          hintText: 'Nivel',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: _niveles.map((nivel) {
          return DropdownMenuItem<String>(
            value: nivel,
            child: Text('Nivel $nivel'),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _nivelSeleccionado = value;
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
              'Curso Activo',
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
}
