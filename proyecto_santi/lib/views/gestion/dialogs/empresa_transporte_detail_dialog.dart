import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:proyecto_santi/models/empresa_transporte.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/tema/app_colors.dart';

/// Diálogo responsive para crear/editar empresas de transporte
/// Similar al estilo de UsuarioDetailDialog
class EmpresaTransporteDetailDialog extends StatefulWidget {
  final EmpresaTransporte? empresa; // null = crear nueva
  final VoidCallback onSaved;

  const EmpresaTransporteDetailDialog({
    Key? key,
    this.empresa,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<EmpresaTransporteDetailDialog> createState() => _EmpresaTransporteDetailDialogState();
}

class _EmpresaTransporteDetailDialogState extends State<EmpresaTransporteDetailDialog> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  late final ActividadService _actividadService;
  
  // Controllers
  late TextEditingController _nombreController;
  late TextEditingController _cifController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;
  late TextEditingController _direccionController;
  
  bool _isSaving = false;
  
  bool get isDesktop {
    if (kIsWeb) return true;
    try {
      return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    } catch (e) {
      return false;
    }
  }
  
  bool get isEditing => widget.empresa != null;

  @override
  void initState() {
    super.initState();
    _actividadService = ActividadService(_apiService);
    _nombreController = TextEditingController(text: widget.empresa?.nombre ?? '');
    _cifController = TextEditingController(text: widget.empresa?.cif ?? '');
    _telefonoController = TextEditingController(text: widget.empresa?.telefono ?? '');
    _emailController = TextEditingController(text: widget.empresa?.email ?? '');
    _direccionController = TextEditingController(text: widget.empresa?.direccion ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cifController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _saveEmpresa() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final data = {
        'nombre': _nombreController.text.trim(),
        'cif': _cifController.text.trim().isEmpty ? null : _cifController.text.trim(),
        'telefono': _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'direccion': _direccionController.text.trim().isEmpty ? null : _direccionController.text.trim(),
      };
      
      if (isEditing) {
        await _actividadService.updateEmpresaTransporte(widget.empresa!.id, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Empresa actualizada correctamente')),
          );
        }
      } else {
        await _actividadService.createEmpresaTransporte(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Empresa creada correctamente')),
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
              isEditing ? Icons.edit_rounded : Icons.add_business_rounded,
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
                  isEditing ? 'Editar Empresa de Transporte' : 'Nueva Empresa de Transporte',
                  style: TextStyle(
                    fontSize: isMobile ? 18.sp : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (isEditing) ...[
                  SizedBox(height: 4),
                  Text(
                    widget.empresa!.nombre,
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
        // Fila 1: Nombre y CIF
        Row(
          children: [
            Expanded(child: _buildNombreField(isDark)),
            SizedBox(width: 16),
            Expanded(child: _buildCIFField(isDark)),
          ],
        ),
        SizedBox(height: 20),
        
        // Fila 2: Teléfono y Email
        Row(
          children: [
            Expanded(child: _buildTelefonoField(isDark)),
            SizedBox(width: 16),
            Expanded(child: _buildEmailField(isDark)),
          ],
        ),
        SizedBox(height: 20),
        
        // Fila 3: Dirección
        _buildDireccionField(isDark),
      ],
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNombreField(isDark),
        SizedBox(height: 16),
        _buildCIFField(isDark),
        SizedBox(height: 16),
        _buildTelefonoField(isDark),
        SizedBox(height: 16),
        _buildEmailField(isDark),
        SizedBox(height: 16),
        _buildDireccionField(isDark),
      ],
    );
  }

  Widget _buildNombreField(bool isDark) {
    return _buildStyledField(
      label: 'Nombre de la Empresa',
      icon: Icons.business_rounded,
      isDark: isDark,
      isRequired: true,
      child: TextFormField(
        controller: _nombreController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: 'Ej: Transportes García S.L.',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'El nombre es requerido';
          }
          if (value.trim().length < 3) {
            return 'Mínimo 3 caracteres';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCIFField(bool isDark) {
    return _buildStyledField(
      label: 'CIF (opcional)',
      icon: Icons.badge_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _cifController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          hintText: 'Ej: B12345678',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTelefonoField(bool isDark) {
    return _buildStyledField(
      label: 'Teléfono (opcional)',
      icon: Icons.phone_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _telefonoController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          hintText: 'Ej: 912 345 678',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildEmailField(bool isDark) {
    return _buildStyledField(
      label: 'Email (opcional)',
      icon: Icons.email_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _emailController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'empresa@ejemplo.com',
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

  Widget _buildDireccionField(bool isDark) {
    return _buildStyledField(
      label: 'Dirección Completa (opcional)',
      icon: Icons.location_on_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _direccionController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        maxLines: 2,
        decoration: InputDecoration(
          hintText: 'Ej: Calle Mayor 123, 28001 Madrid',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildStyledField({
    required String label,
    required IconData icon,
    required bool isDark,
    required Widget child,
    bool isRequired = false,
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
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
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
            onPressed: _isSaving ? null : _saveEmpresa,
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
              isEditing ? 'Guardar Cambios' : 'Crear Empresa',
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
}
