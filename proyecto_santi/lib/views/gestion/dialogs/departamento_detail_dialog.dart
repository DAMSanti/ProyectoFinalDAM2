import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proyecto_santi/models/departamento.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/tema/app_colors.dart';

class DepartamentoDetailDialog extends StatefulWidget {
  final Departamento? departamento;
  final VoidCallback onSaved;

  const DepartamentoDetailDialog({
    Key? key,
    this.departamento,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<DepartamentoDetailDialog> createState() => _DepartamentoDetailDialogState();
}

class _DepartamentoDetailDialogState extends State<DepartamentoDetailDialog> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  late final CatalogoService _catalogoService;
  
  // Controllers
  late final TextEditingController _codigoController;
  late final TextEditingController _nombreController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _catalogoService = CatalogoService(_apiService);
    
    // Inicializar controllers con valores existentes o vacíos
    _codigoController = TextEditingController(text: widget.departamento?.codigo ?? '');
    _nombreController = TextEditingController(text: widget.departamento?.nombre ?? '');
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _saveDepartamento() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'codigo': _codigoController.text.trim(),
        'nombre': _nombreController.text.trim(),
      };

      if (widget.departamento != null) {
        // Actualizar
        await _catalogoService.updateDepartamento(widget.departamento!.id, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Departamento actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Crear
        await _catalogoService.createDepartamento(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Departamento creado correctamente'),
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
              Icons.business_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              widget.departamento != null ? 'Editar Departamento' : 'Nuevo Departamento',
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
            onPressed: _isLoading ? null : _saveDepartamento,
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildCodigoField(isDark)),
        SizedBox(width: 16.w),
        Expanded(flex: 2, child: _buildNombreField(isDark)),
      ],
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return Column(
      children: [
        _buildCodigoField(isDark),
        SizedBox(height: 16.h),
        _buildNombreField(isDark),
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

  Widget _buildCodigoField(bool isDark) {
    return _buildStyledField(
      label: 'Código *',
      icon: Icons.tag_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _codigoController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        maxLength: 3,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          hintText: 'Ej: INF',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          counterText: '',
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'El código es obligatorio';
          }
          if (value.trim().length > 3) {
            return 'Máximo 3 caracteres';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildNombreField(bool isDark) {
    return _buildStyledField(
      label: 'Nombre del Departamento *',
      icon: Icons.business_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _nombreController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: 'Ej: Informática',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
}
