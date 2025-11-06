import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proyecto_santi/models/alojamiento.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/tema/app_colors.dart';

class AlojamientoDetailDialog extends StatefulWidget {
  final Alojamiento? alojamiento;
  final VoidCallback onSaved;

  const AlojamientoDetailDialog({
    Key? key,
    this.alojamiento,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<AlojamientoDetailDialog> createState() => _AlojamientoDetailDialogState();
}

class _AlojamientoDetailDialogState extends State<AlojamientoDetailDialog> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  late final ActividadService _actividadService;
  
  // Controllers
  late final TextEditingController _nombreController;
  late final TextEditingController _direccionController;
  late final TextEditingController _ciudadController;
  late final TextEditingController _cpController;
  late final TextEditingController _provinciaController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _emailController;
  late final TextEditingController _webController;
  late final TextEditingController _numeroHabitacionesController;
  late final TextEditingController _capacidadTotalController;
  late final TextEditingController _precioPorNocheController;
  late final TextEditingController _serviciosController;
  late final TextEditingController _observacionesController;
  
  String? _tipoAlojamientoSeleccionado;
  bool _isLoading = false;

  // Tipos de alojamiento según la base de datos
  final List<String> _tiposAlojamiento = [
    'Hotel',
    'Hostal',
    'Albergue',
    'Casa Rural',
    'Apartamento',
    'Residencia',
    'Camping',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _actividadService = ActividadService(_apiService);
    
    // Inicializar controllers con valores existentes o vacíos
    _nombreController = TextEditingController(text: widget.alojamiento?.nombre ?? '');
    _direccionController = TextEditingController(text: widget.alojamiento?.direccion ?? '');
    _ciudadController = TextEditingController(text: widget.alojamiento?.ciudad ?? '');
    _cpController = TextEditingController(text: widget.alojamiento?.codigoPostal ?? '');
    _provinciaController = TextEditingController(text: widget.alojamiento?.provincia ?? '');
    _telefonoController = TextEditingController(text: widget.alojamiento?.telefono ?? '');
    _emailController = TextEditingController(text: widget.alojamiento?.email ?? '');
    _webController = TextEditingController(text: widget.alojamiento?.web ?? '');
    _numeroHabitacionesController = TextEditingController(
      text: widget.alojamiento?.numeroHabitaciones?.toString() ?? ''
    );
    _capacidadTotalController = TextEditingController(
      text: widget.alojamiento?.capacidadTotal?.toString() ?? ''
    );
    _precioPorNocheController = TextEditingController(
      text: widget.alojamiento?.precioPorNoche?.toString() ?? ''
    );
    _serviciosController = TextEditingController(text: widget.alojamiento?.servicios ?? '');
    _observacionesController = TextEditingController(text: widget.alojamiento?.observaciones ?? '');
    
    _tipoAlojamientoSeleccionado = widget.alojamiento?.tipoAlojamiento;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    _cpController.dispose();
    _provinciaController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _webController.dispose();
    _numeroHabitacionesController.dispose();
    _capacidadTotalController.dispose();
    _precioPorNocheController.dispose();
    _serviciosController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _saveAlojamiento() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'nombre': _nombreController.text.trim(),
        'direccion': _direccionController.text.trim().isEmpty ? null : _direccionController.text.trim(),
        'ciudad': _ciudadController.text.trim().isEmpty ? null : _ciudadController.text.trim(),
        'codigoPostal': _cpController.text.trim().isEmpty ? null : _cpController.text.trim(),
        'provincia': _provinciaController.text.trim().isEmpty ? null : _provinciaController.text.trim(),
        'telefono': _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'web': _webController.text.trim().isEmpty ? null : _webController.text.trim(),
        'tipoAlojamiento': _tipoAlojamientoSeleccionado,
        'numeroHabitaciones': _numeroHabitacionesController.text.trim().isEmpty 
            ? null 
            : int.tryParse(_numeroHabitacionesController.text.trim()),
        'capacidadTotal': _capacidadTotalController.text.trim().isEmpty 
            ? null 
            : int.tryParse(_capacidadTotalController.text.trim()),
        'precioPorNoche': _precioPorNocheController.text.trim().isEmpty 
            ? null 
            : double.tryParse(_precioPorNocheController.text.trim()),
        'servicios': _serviciosController.text.trim().isEmpty ? null : _serviciosController.text.trim(),
        'observaciones': _observacionesController.text.trim().isEmpty ? null : _observacionesController.text.trim(),
        'activo': true,
      };

      if (widget.alojamiento != null) {
        // Actualizar
        await _actividadService.updateAlojamiento(widget.alojamiento!.id, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alojamiento actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Crear
        await _actividadService.createAlojamiento(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alojamiento creado correctamente'),
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
              Icons.hotel_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              widget.alojamiento != null ? 'Editar Alojamiento' : 'Nuevo Alojamiento',
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
            onPressed: _isLoading ? null : _saveAlojamiento,
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
        // Fila 1: Nombre y Tipo
        Row(
          children: [
            Expanded(flex: 2, child: _buildNombreField(isDark)),
            SizedBox(width: 16.w),
            Expanded(child: _buildTipoAlojamientoField(isDark)),
          ],
        ),
        SizedBox(height: 16.h),
        // Fila 2: Dirección
        _buildDireccionField(isDark),
        SizedBox(height: 16.h),
        // Fila 3: Ciudad, CP, Provincia
        Row(
          children: [
            Expanded(child: _buildCiudadField(isDark)),
            SizedBox(width: 16.w),
            Expanded(child: _buildCPField(isDark)),
            SizedBox(width: 16.w),
            Expanded(child: _buildProvinciaField(isDark)),
          ],
        ),
        SizedBox(height: 16.h),
        // Fila 4: Teléfono, Email, Web
        Row(
          children: [
            Expanded(child: _buildTelefonoField(isDark)),
            SizedBox(width: 16.w),
            Expanded(child: _buildEmailField(isDark)),
            SizedBox(width: 16.w),
            Expanded(child: _buildWebField(isDark)),
          ],
        ),
        SizedBox(height: 16.h),
        // Fila 5: Número Habitaciones, Capacidad Total, Precio
        Row(
          children: [
            Expanded(child: _buildNumeroHabitacionesField(isDark)),
            SizedBox(width: 16.w),
            Expanded(child: _buildCapacidadTotalField(isDark)),
            SizedBox(width: 16.w),
            Expanded(child: _buildPrecioPorNocheField(isDark)),
          ],
        ),
        SizedBox(height: 16.h),
        // Fila 6: Servicios
        _buildServiciosField(isDark),
        SizedBox(height: 16.h),
        // Fila 7: Observaciones
        _buildObservacionesField(isDark),
      ],
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return Column(
      children: [
        _buildNombreField(isDark),
        SizedBox(height: 16.h),
        _buildTipoAlojamientoField(isDark),
        SizedBox(height: 16.h),
        _buildDireccionField(isDark),
        SizedBox(height: 16.h),
        _buildCiudadField(isDark),
        SizedBox(height: 16.h),
        _buildCPField(isDark),
        SizedBox(height: 16.h),
        _buildProvinciaField(isDark),
        SizedBox(height: 16.h),
        _buildTelefonoField(isDark),
        SizedBox(height: 16.h),
        _buildEmailField(isDark),
        SizedBox(height: 16.h),
        _buildWebField(isDark),
        SizedBox(height: 16.h),
        _buildNumeroHabitacionesField(isDark),
        SizedBox(height: 16.h),
        _buildCapacidadTotalField(isDark),
        SizedBox(height: 16.h),
        _buildPrecioPorNocheField(isDark),
        SizedBox(height: 16.h),
        _buildServiciosField(isDark),
        SizedBox(height: 16.h),
        _buildObservacionesField(isDark),
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
      label: 'Nombre *',
      icon: Icons.hotel_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _nombreController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: 'Ej: Hotel Escolar Madrid',
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

  Widget _buildTipoAlojamientoField(bool isDark) {
    return _buildStyledField(
      label: 'Tipo de Alojamiento (opcional)',
      icon: Icons.category_rounded,
      isDark: isDark,
      child: DropdownButtonFormField<String>(
        value: _tipoAlojamientoSeleccionado,
        dropdownColor: isDark ? Colors.grey[800] : Colors.white,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: 'Seleccionar tipo',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: _tiposAlojamiento.map((tipo) {
          return DropdownMenuItem(
            value: tipo,
            child: Text(tipo),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _tipoAlojamientoSeleccionado = value;
          });
        },
      ),
    );
  }

  Widget _buildDireccionField(bool isDark) {
    return _buildStyledField(
      label: 'Dirección (opcional)',
      icon: Icons.location_on_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _direccionController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: 'Ej: Calle Gran Vía 28',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCiudadField(bool isDark) {
    return _buildStyledField(
      label: 'Ciudad (opcional)',
      icon: Icons.location_city_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _ciudadController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: 'Ej: Madrid',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCPField(bool isDark) {
    return _buildStyledField(
      label: 'Código Postal (opcional)',
      icon: Icons.markunread_mailbox_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _cpController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        keyboardType: TextInputType.number,
        maxLength: 10,
        decoration: InputDecoration(
          hintText: '28001',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          counterText: '',
        ),
      ),
    );
  }

  Widget _buildProvinciaField(bool isDark) {
    return _buildStyledField(
      label: 'Provincia (opcional)',
      icon: Icons.map_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _provinciaController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: 'Ej: Madrid',
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
          hintText: 'Ej: 910123456',
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
          hintText: 'ejemplo@hotel.com',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) {
          if (value != null && value.isNotEmpty && !value.contains('@')) {
            return 'Email inválido';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildWebField(bool isDark) {
    return _buildStyledField(
      label: 'Web (opcional)',
      icon: Icons.language_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _webController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        keyboardType: TextInputType.url,
        decoration: InputDecoration(
          hintText: 'www.hotel.com',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildNumeroHabitacionesField(bool isDark) {
    return _buildStyledField(
      label: 'Nº Habitaciones (opcional)',
      icon: Icons.meeting_room_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _numeroHabitacionesController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCapacidadTotalField(bool isDark) {
    return _buildStyledField(
      label: 'Capacidad Total (opcional)',
      icon: Icons.people_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _capacidadTotalController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: '0 personas',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildPrecioPorNocheField(bool isDark) {
    return _buildStyledField(
      label: 'Precio por Noche (opcional)',
      icon: Icons.euro_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _precioPorNocheController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        decoration: InputDecoration(
          hintText: '0.00 €',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildServiciosField(bool isDark) {
    return _buildStyledField(
      label: 'Servicios (opcional)',
      icon: Icons.room_service_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _serviciosController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        maxLines: 2,
        decoration: InputDecoration(
          hintText: 'WiFi, Desayuno incluido, Parking, etc.',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildObservacionesField(bool isDark) {
    return _buildStyledField(
      label: 'Observaciones (opcional)',
      icon: Icons.note_rounded,
      isDark: isDark,
      child: TextFormField(
        controller: _observacionesController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Comentarios adicionales...',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
