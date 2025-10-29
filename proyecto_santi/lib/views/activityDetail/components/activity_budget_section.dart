import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/actividad.dart';
import '../../../models/alojamiento.dart';
import '../../../models/empresa_transporte.dart';
import '../../../models/gasto_personalizado.dart';
import '../../../services/actividad_service.dart';
import '../../../services/gasto_personalizado_service.dart';
import '../../../services/api_service.dart';

/// Widget para mostrar y gestionar el presupuesto de una actividad.
/// 
/// Muestra:
/// - Switches para activar/desactivar transporte y alojamiento
/// - Tarjetas de Presupuesto Estimado y Coste Real
/// - Tarjetas de Transporte y Alojamiento (condicionales)
/// - Secciones detalladas de Transporte y Alojamiento
/// - Coste por Alumno
class ActivityBudgetSection extends StatefulWidget {
  final Actividad actividad;
  final bool isAdminOrSolicitante;
  final int totalAlumnosParticipantes;
  final Function(Map<String, dynamic>)? onBudgetChanged;
  final ActividadService actividadService;

  const ActivityBudgetSection({
    Key? key,
    required this.actividad,
    required this.isAdminOrSolicitante,
    required this.totalAlumnosParticipantes,
    required this.actividadService,
    this.onBudgetChanged,
  }) : super(key: key);

  @override
  State<ActivityBudgetSection> createState() => _ActivityBudgetSectionState();
}

class _ActivityBudgetSectionState extends State<ActivityBudgetSection> {
  // Variables para switches de transporte y alojamiento
  bool _transporteReq = false;
  bool _alojamientoReq = false;
  
  // Variables para edición de presupuesto
  bool _editandoPresupuesto = false;
  final TextEditingController _presupuestoController = TextEditingController();
  double? _presupuestoEstimadoLocal; // Copia local del presupuesto
  
  // Variables para edición de transporte
  bool _editandoTransporte = false;
  final TextEditingController _precioTransporteController = TextEditingController();
  double? _precioTransporteLocal;
  EmpresaTransporte? _empresaTransporteLocal;
  List<EmpresaTransporte> _empresasDisponibles = [];
  bool _cargandoEmpresas = false;

  // Variables para edición de alojamiento
  bool _editandoAlojamiento = false;
  final TextEditingController _precioAlojamientoController = TextEditingController();
  double? _precioAlojamientoLocal;
  Alojamiento? _alojamientoLocal;
  List<Alojamiento> _alojamientosDisponibles = [];
  bool _cargandoAlojamientos = false;

  // Variables para gastos personalizados
  List<GastoPersonalizado> _gastosPersonalizados = [];
  final TextEditingController _conceptoController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  bool _cargandoGastos = false;
  late GastoPersonalizadoService _gastoService;

  @override
  void initState() {
    super.initState();
    // Inicializar servicio de gastos
    _gastoService = GastoPersonalizadoService(ApiService());
    // Inicializar switches desde la actividad (convertir int a bool)
    _transporteReq = widget.actividad.transporteReq == 1;
    _alojamientoReq = widget.actividad.alojamientoReq == 1;
    // Inicializar presupuesto local
    _presupuestoEstimadoLocal = widget.actividad.presupuestoEstimado;
    // Inicializar transporte local
    _precioTransporteLocal = widget.actividad.precioTransporte;
    _empresaTransporteLocal = widget.actividad.empresaTransporte;
    // Inicializar alojamiento local
    _precioAlojamientoLocal = widget.actividad.precioAlojamiento ?? 0.0;
    _alojamientoLocal = widget.actividad.alojamiento;
    // Cargar gastos personalizados
    _cargarGastos();
  }

  /// Carga los gastos personalizados de la actividad
  Future<void> _cargarGastos() async {
    if (widget.actividad.id == null) return;
    
    setState(() {
      _cargandoGastos = true;
    });
    
    try {
      final gastos = await _gastoService.fetchGastosByActividad(widget.actividad.id!);
      if (mounted) {
        setState(() {
          _gastosPersonalizados = gastos;
          _cargandoGastos = false;
        });
      }
    } catch (e) {
      print('[GASTOS ERROR] Error al cargar gastos: $e');
      if (mounted) {
        setState(() {
          // Inicializar con lista vacía si hay error (tabla puede no existir aún)
          _gastosPersonalizados = [];
          _cargandoGastos = false;
        });
      }
    }
  }

  @override
  void didUpdateWidget(ActivityBudgetSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Actualizar switches si la actividad cambió (por ejemplo, después de guardar o revertir)
    if (oldWidget.actividad.transporteReq != widget.actividad.transporteReq) {
      setState(() {
        _transporteReq = widget.actividad.transporteReq == 1;
      });
    }
    if (oldWidget.actividad.alojamientoReq != widget.actividad.alojamientoReq) {
      setState(() {
        _alojamientoReq = widget.actividad.alojamientoReq == 1;
      });
    }
    
    // Actualizar valores locales de transporte si cambiaron (por ejemplo, después de revertir)
    // PERO: no sobrescribir con null y no sobrescribir si hay cambios locales pendientes
    if (oldWidget.actividad.precioTransporte != widget.actividad.precioTransporte ||
        oldWidget.actividad.empresaTransporte != widget.actividad.empresaTransporte) {
      
      // Solo actualizar si:
      // 1. NO estamos en modo edición
      // 2. El nuevo valor NO es null (no sobrescribir con null)
      // 3. NO hay cambios locales pendientes diferentes
      final tieneValorLocalDiferente = _empresaTransporteLocal != null && 
                                       _empresaTransporteLocal != widget.actividad.empresaTransporte;
      
      if (!_editandoTransporte && 
          widget.actividad.empresaTransporte != null && 
          !tieneValorLocalDiferente) {
        setState(() {
          _precioTransporteLocal = widget.actividad.precioTransporte;
          _empresaTransporteLocal = widget.actividad.empresaTransporte;
        });
      }
    }
    
    // Actualizar valores locales de alojamiento si cambiaron
    if (oldWidget.actividad.alojamiento != widget.actividad.alojamiento) {
      
      // Solo actualizar si:
      // 1. NO estamos en modo edición
      // 2. El nuevo valor NO es null (no sobrescribir con null)
      // 3. NO hay cambios locales pendientes diferentes
      final tieneValorLocalDiferente = _alojamientoLocal != null && 
                                       _alojamientoLocal != widget.actividad.alojamiento;
      
      if (!_editandoAlojamiento && 
          widget.actividad.alojamiento != null && 
          !tieneValorLocalDiferente) {
        setState(() {
          _precioAlojamientoLocal = widget.actividad.precioAlojamiento ?? 0.0;
          _alojamientoLocal = widget.actividad.alojamiento;
        });
      }
    }
    
    // Actualizar presupuesto local si cambió
    if (oldWidget.actividad.presupuestoEstimado != widget.actividad.presupuestoEstimado) {
      setState(() {
        _presupuestoEstimadoLocal = widget.actividad.presupuestoEstimado;
        _editandoPresupuesto = false; // Salir del modo edición si estaba activo
      });
    }
  }

  @override
  void dispose() {
    _presupuestoController.dispose();
    _precioTransporteController.dispose();
    _precioAlojamientoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Calcular valores - usar los valores locales si están disponibles
    final presupuesto = _presupuestoEstimadoLocal ?? widget.actividad.presupuestoEstimado ?? 0.0;
    final precioTransporte = _precioTransporteLocal ?? widget.actividad.precioTransporte ?? 0.0;
    final empresaTransporte = _empresaTransporteLocal ?? widget.actividad.empresaTransporte;
    
    final precioAlojamiento = _precioAlojamientoLocal ?? 0.0; // El precio se guarda localmente
    
    // Calcular total de gastos personalizados
    final totalGastosPersonalizados = _gastosPersonalizados.fold<double>(
      0.0,
      (sum, gasto) => sum + gasto.cantidad,
    );
    
    // Coste real = suma solo de los servicios activados (switches en true) + gastos personalizados
    final costoReal = (_transporteReq ? precioTransporte : 0.0) + 
        (_alojamientoReq ? precioAlojamiento : 0.0) + 
        totalGastosPersonalizados;
    final costoPorAlumno = widget.totalAlumnosParticipantes > 0 
        ? costoReal / widget.totalAlumnosParticipantes 
        : 0.0;
    
    return Container(
      constraints: BoxConstraints(minHeight: 500),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
            ? const [
                Color.fromRGBO(25, 118, 210, 0.25),
                Color.fromRGBO(21, 101, 192, 0.20),
              ]
            : const [
                Color.fromRGBO(187, 222, 251, 0.85),
                Color.fromRGBO(144, 202, 249, 0.75),
              ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
            ? const Color.fromRGBO(255, 255, 255, 0.1) 
            : const Color.fromRGBO(0, 0, 0, 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? const Color.fromRGBO(0, 0, 0, 0.4) 
              : const Color.fromRGBO(0, 0, 0, 0.15),
            offset: const Offset(0, 4),
            blurRadius: 12.0,
            spreadRadius: -1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(25, 118, 210, 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Color(0xFF1976d2),
                  size: !isWeb ? 18.dg : 6.sp,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Presupuesto y Gastos',
                style: TextStyle(
                  fontSize: !isWeb ? 16.dg : 5.5.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976d2),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Switches para activar/desactivar Transporte y Alojamiento
          if (widget.isAdminOrSolicitante) ...[
            Row(
              children: [
                Expanded(
                  child: _buildToggleSwitch(
                    context,
                    'Transporte',
                    Icons.directions_bus,
                    Colors.purple,
                    _transporteReq,
                    isWeb,
                    onChanged: (value) {
                      setState(() {
                        _transporteReq = value;
                      });
                      // Notificar cambios al padre con los nuevos valores
                      widget.onBudgetChanged?.call({
                        'transporteReq': value ? 1 : 0,
                        'alojamientoReq': _alojamientoReq ? 1 : 0,
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildToggleSwitch(
                    context,
                    'Alojamiento',
                    Icons.hotel,
                    Colors.teal,
                    _alojamientoReq,
                    isWeb,
                    onChanged: (value) {
                      setState(() {
                        _alojamientoReq = value;
                      });
                      // Notificar cambios al padre con los nuevos valores
                      widget.onBudgetChanged?.call({
                        'transporteReq': _transporteReq ? 1 : 0,
                        'alojamientoReq': value ? 1 : 0,
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
          
          // Fila superior: Presupuesto Estimado y Coste Real lado a lado
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildPresupuestoCard(
                    context,
                    'Presupuesto Estimado',
                    presupuesto,
                    Icons.account_balance_wallet,
                    Colors.blue,
                    double.infinity,
                    isWeb,
                    showEdit: true,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildPresupuestoCard(
                    context,
                    'Coste Real',
                    costoReal,
                    Icons.euro,
                    costoReal > presupuesto ? Colors.red : Colors.green,
                    double.infinity,
                    isWeb,
                  ),
                ),
              ],
            ),
          ),
          
          // Coste por Alumno justo debajo
          SizedBox(height: 10),
          _buildPresupuestoCard(
            context,
            'Coste por Alumno',
            costoPorAlumno,
            Icons.person,
            Colors.orange,
            double.infinity,
            isWeb,
          ),
          
          // Mostrar tarjetas de Transporte y Alojamiento si están activos
          if (_transporteReq || _alojamientoReq) ...[
            SizedBox(height: 10),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_transporteReq)
                    Expanded(
                      child: _buildPresupuestoCard(
                        context,
                        'Transporte',
                        precioTransporte,
                        Icons.directions_bus,
                        Colors.purple,
                        double.infinity,
                        isWeb,
                        showEdit: true,
                        empresaTransporte: empresaTransporte,
                      ),
                    ),
                  if (_transporteReq && _alojamientoReq)
                    SizedBox(width: 16),
                  if (_alojamientoReq)
                    Expanded(
                      child: _buildPresupuestoCard(
                        context,
                        'Alojamiento',
                        precioAlojamiento,
                        Icons.hotel,
                        Colors.teal,
                        double.infinity,
                        isWeb,
                        showEdit: true,
                      ),
                    ),
                ],
              ),
            ),
          ],
          
          // Botones de Solicitar Presupuestos (Transporte y Alojamiento)
          if (widget.isAdminOrSolicitante && (_transporteReq || _alojamientoReq)) ...[
            SizedBox(height: 10),
            Row(
              children: [
                if (_transporteReq)
                  Expanded(
                    child: InkWell(
                      onTap: () => _mostrarDialogoSolicitarPresupuestosTransporte(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.purple.withOpacity(0.85),
                              Colors.purple.withOpacity(0.65),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.4),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, color: Colors.white, size: !isWeb ? 16.dg : 5.sp),
                            SizedBox(width: 8),
                            Text(
                              'Solicitar Presupuestos',
                              style: TextStyle(
                                fontSize: !isWeb ? 12.dg : 4.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_transporteReq && _alojamientoReq)
                  SizedBox(width: 16),
                if (_alojamientoReq)
                  Expanded(
                    child: InkWell(
                      onTap: () => _mostrarDialogoSolicitarPresupuestosAlojamiento(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.teal.withOpacity(0.85),
                              Colors.teal.withOpacity(0.65),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.4),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, color: Colors.white, size: !isWeb ? 16.dg : 5.sp),
                            SizedBox(width: 8),
                            Text(
                              'Solicitar Presupuestos',
                              style: TextStyle(
                                fontSize: !isWeb ? 12.dg : 4.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          
          // Card de Gastos Varios
          SizedBox(height: 10),
          _buildGastosVariosCard(context, isWeb),
        ],
      ),
    );
  }

  /// Widget para mostrar un switch de activación (Transporte o Alojamiento)
  Widget _buildToggleSwitch(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    bool value,
    bool isWeb, {
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: value 
            ? [
                color.withOpacity(0.25),
                color.withOpacity(0.15),
              ]
            : [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1),
              ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? color.withOpacity(0.5) : Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: value ? [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ] : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: value
                    ? LinearGradient(
                        colors: [
                          color.withOpacity(0.8),
                          color.withOpacity(0.6),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          Colors.grey.withOpacity(0.3),
                          Colors.grey.withOpacity(0.2),
                        ],
                      ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: value ? Colors.white : Colors.grey[600],
                  size: !isWeb ? 20.dg : 6.sp,
                ),
              ),
              SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: !isWeb ? 14.dg : 5.sp,
                  fontWeight: FontWeight.bold,
                  color: value ? color : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: color,
              activeTrackColor: color.withOpacity(0.5),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[300],
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget para mostrar una tarjeta de presupuesto
  Widget _buildPresupuestoCard(
    BuildContext context,
    String titulo,
    double valor,
    IconData icono,
    Color color,
    double width,
    bool isWeb, {
    String? subtitle,
    bool showEdit = false,
    EmpresaTransporte? empresaTransporte,
  }) {
    return Container(
      width: width > 600 ? width : double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Solo mostrar título con icono si NO es "Coste por Alumno"
          if (titulo != 'Coste por Alumno')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withOpacity(0.8),
                              color.withOpacity(0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          icono,
                          color: Colors.white,
                          size: !isWeb ? 22.dg : 7.sp,
                        ),
                      ),
                      SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          titulo,
                          style: TextStyle(
                            fontSize: !isWeb ? 14.dg : 4.5.sp,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showEdit && widget.isAdminOrSolicitante)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: ((_editandoPresupuesto && titulo == 'Presupuesto Estimado') || 
                              (_editandoTransporte && titulo == 'Transporte') ||
                              (_editandoAlojamiento && titulo == 'Alojamiento'))
                        ? [Colors.green.withOpacity(0.2), Colors.green.withOpacity(0.1)]
                        : [Colors.grey.withOpacity(0.2), Colors.grey.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      (_editandoPresupuesto && titulo == 'Presupuesto Estimado') || 
                      (_editandoTransporte && titulo == 'Transporte') ||
                      (_editandoAlojamiento && titulo == 'Alojamiento')
                        ? Icons.check_circle 
                        : Icons.edit_rounded, 
                      size: !isWeb ? 20.dg : 6.sp
                    ),
                    color: ((_editandoPresupuesto && titulo == 'Presupuesto Estimado') || 
                            (_editandoTransporte && titulo == 'Transporte') ||
                            (_editandoAlojamiento && titulo == 'Alojamiento'))
                      ? Colors.green[700]
                      : color,
                    onPressed: () async {
                    if (titulo == 'Presupuesto Estimado') {
                      if (_editandoPresupuesto) {
                        // Guardar cambios
                        final nuevoPresupuesto = double.tryParse(_presupuestoController.text);
                        if (nuevoPresupuesto != null && nuevoPresupuesto >= 0) {
                          if (mounted) {
                            setState(() {
                              _editandoPresupuesto = false;
                              _presupuestoEstimadoLocal = nuevoPresupuesto; // Guardar localmente
                            });
                          }
                          // Notificar cambio al padre
                          widget.onBudgetChanged?.call({
                            'presupuestoEstimado': nuevoPresupuesto,
                            'transporteReq': _transporteReq ? 1 : 0,
                            'alojamientoReq': _alojamientoReq ? 1 : 0,
                          });
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Por favor, introduce un valor válido')),
                            );
                          }
                        }
                      } else {
                        // Activar modo edición
                        if (mounted) {
                          setState(() {
                            _editandoPresupuesto = true;
                            _presupuestoController.text = valor.toStringAsFixed(2);
                          });
                        }
                      }
                    } else if (titulo == 'Transporte') {
                      if (_editandoTransporte) {
                        // Guardar cambios de transporte
                        final nuevoPrecio = double.tryParse(_precioTransporteController.text);
                        if (nuevoPrecio != null && nuevoPrecio >= 0) {
                          // Capturar la empresa seleccionada ANTES del setState
                          final empresaSeleccionada = _empresaTransporteLocal;
                          
                          if (mounted) {
                            setState(() {
                              _editandoTransporte = false;
                              _precioTransporteLocal = nuevoPrecio;
                              // Asegurar que la empresa seleccionada se mantiene
                              _empresaTransporteLocal = empresaSeleccionada;
                            });
                          }
                          print('[BUDGET] Después de setState:');
                          print('[BUDGET]   - _editandoTransporte: $_editandoTransporte');
                          print('[BUDGET]   - _precioTransporteLocal: $_precioTransporteLocal');
                          print('[BUDGET]   - _empresaTransporteLocal: ${_empresaTransporteLocal?.nombre}');
                          
                          // Notificar cambio al padre
                          print('[BUDGET] Guardando cambios de transporte:');
                          print('[BUDGET]   - Precio: $nuevoPrecio');
                          print('[BUDGET]   - Empresa ID: ${empresaSeleccionada?.id}');
                          print('[BUDGET]   - Empresa nombre: ${empresaSeleccionada?.nombre}');
                          widget.onBudgetChanged?.call({
                            'precioTransporte': nuevoPrecio,
                            'empresaTransporteId': empresaSeleccionada?.id,
                            'transporteReq': _transporteReq ? 1 : 0,
                            'alojamientoReq': _alojamientoReq ? 1 : 0,
                          });
                          print('[BUDGET] Cambios notificados al padre');
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Por favor, introduce un valor válido')),
                            );
                          }
                        }
                      } else {
                        // Activar modo edición y cargar empresas
                        if (mounted) {
                          setState(() {
                            _editandoTransporte = true;
                            _precioTransporteController.text = valor.toStringAsFixed(2);
                            _cargandoEmpresas = true;
                          });
                        }
                        // Cargar empresas de transporte
                        try {
                          print('[BUDGET] Cargando empresas de transporte...');
                          final empresas = await widget.actividadService.fetchEmpresasTransporte();
                          print('[BUDGET] Empresas cargadas: ${empresas.length}');
                          for (var empresa in empresas) {
                            print('[BUDGET]   - ${empresa.nombre} (ID: ${empresa.id})');
                          }
                          
                          // Si ya hay una empresa seleccionada, encontrarla en la lista cargada
                          if (_empresaTransporteLocal != null && mounted) {
                            final empresaEncontrada = empresas.firstWhere(
                              (e) => e.id == _empresaTransporteLocal!.id,
                              orElse: () => _empresaTransporteLocal!,
                            );
                            setState(() {
                              _empresasDisponibles = empresas;
                              _empresaTransporteLocal = empresaEncontrada; // Usar la instancia de la lista
                              _cargandoEmpresas = false;
                            });
                            print('[BUDGET] Empresa actual sincronizada: ${_empresaTransporteLocal?.nombre} (ID: ${_empresaTransporteLocal?.id})');
                          } else if (mounted) {
                            setState(() {
                              _empresasDisponibles = empresas;
                              _cargandoEmpresas = false;
                            });
                          }
                        } catch (e) {
                          print('[BUDGET ERROR] Error al cargar empresas: $e');
                          if (mounted) {
                            setState(() {
                              _cargandoEmpresas = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error al cargar empresas: $e')),
                            );
                          }
                        }
                      }
                    } else if (titulo == 'Alojamiento') {
                      // Lógica de edición de Alojamiento
                      if (_editandoAlojamiento) {
                        // Guardar cambios
                        final nuevoPrecio = double.tryParse(_precioAlojamientoController.text);
                        final alojamientoSeleccionado = _alojamientoLocal;
                        
                        if (nuevoPrecio != null && nuevoPrecio >= 0) {
                          setState(() {
                            _editandoAlojamiento = false;
                            _precioAlojamientoLocal = nuevoPrecio;
                            _alojamientoLocal = alojamientoSeleccionado;
                          });
                          
                          print('[BUDGET] Después de setState:');
                          print('[BUDGET]   - _editandoAlojamiento: $_editandoAlojamiento');
                          print('[BUDGET]   - _precioAlojamientoLocal: $_precioAlojamientoLocal');
                          print('[BUDGET]   - _alojamientoLocal: ${_alojamientoLocal?.nombre}');
                          
                          print('[BUDGET] Guardando cambios de alojamiento:');
                          print('[BUDGET]   - Precio: $nuevoPrecio');
                          print('[BUDGET]   - Alojamiento ID: ${alojamientoSeleccionado?.id}');
                          print('[BUDGET]   - Alojamiento nombre: ${alojamientoSeleccionado?.nombre}');
                          widget.onBudgetChanged?.call({
                            'precioAlojamiento': nuevoPrecio,
                            'alojamientoId': alojamientoSeleccionado?.id,
                            'transporteReq': _transporteReq ? 1 : 0,
                            'alojamientoReq': _alojamientoReq ? 1 : 0,
                          });
                          print('[BUDGET] Cambios notificados al padre');
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Por favor, introduce un valor válido')),
                            );
                          }
                        }
                      } else {
                        // Activar modo edición y cargar alojamientos
                        print('[BUDGET] Entrando en modo edición de alojamiento...');
                        print('[BUDGET] showEdit para Alojamiento: ${showEdit}');
                        if (mounted) {
                          setState(() {
                            _editandoAlojamiento = true;
                            _precioAlojamientoController.text = valor.toStringAsFixed(2);
                            _cargandoAlojamientos = true;
                          });
                        }
                        // Cargar alojamientos
                        try {
                          print('[BUDGET] Cargando alojamientos...');
                          final alojamientos = await widget.actividadService.fetchAlojamientos();
                          print('[BUDGET] Alojamientos cargados: ${alojamientos.length}');
                          for (var alojamiento in alojamientos) {
                            print('[BUDGET]   - ${alojamiento.nombre} (ID: ${alojamiento.id})');
                          }
                          
                          // Si ya hay un alojamiento seleccionado, encontrarlo en la lista cargada
                          if (_alojamientoLocal != null && mounted) {
                            final alojamientoEncontrado = alojamientos.firstWhere(
                              (a) => a.id == _alojamientoLocal!.id,
                              orElse: () => _alojamientoLocal!,
                            );
                            setState(() {
                              _alojamientosDisponibles = alojamientos;
                              _alojamientoLocal = alojamientoEncontrado; // Usar la instancia de la lista
                              _cargandoAlojamientos = false;
                            });
                            print('[BUDGET] Alojamiento actual sincronizado: ${_alojamientoLocal?.nombre} (ID: ${_alojamientoLocal?.id})');
                          } else if (mounted) {
                            setState(() {
                              _alojamientosDisponibles = alojamientos;
                              _cargandoAlojamientos = false;
                            });
                            print('[BUDGET] Alojamientos disponibles actualizados: ${_alojamientosDisponibles.length}');
                          }
                        } catch (e) {
                          print('[BUDGET ERROR] Error al cargar alojamientos: $e');
                          if (mounted) {
                            setState(() {
                              _cargandoAlojamientos = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error al cargar alojamientos: $e')),
                            );
                          }
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Edición de $titulo - Próximamente')),
                      );
                    }
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: !isWeb ? 10.dg : 3.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
          // Solo agregar espacio vertical si NO es "Coste por Alumno"
          if (titulo != 'Coste por Alumno')
            SizedBox(height: 8), // Reducido de 12 a 8
          // Mostrar TextField si está en modo edición y es el presupuesto estimado
          if (_editandoPresupuesto && titulo == 'Presupuesto Estimado')
            TextField(
              controller: _presupuestoController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontSize: !isWeb ? 16.dg : 5.5.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              decoration: InputDecoration(
                suffix: Text(
                  '€',
                  style: TextStyle(
                    fontSize: !isWeb ? 16.dg : 5.5.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: color),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: color, width: 2),
                ),
              ),
              autofocus: true,
              onSubmitted: (value) {
                // Guardar al presionar Enter
                final nuevoPresupuesto = double.tryParse(value);
                if (nuevoPresupuesto != null && nuevoPresupuesto >= 0) {
                  setState(() {
                    _editandoPresupuesto = false;
                    _presupuestoEstimadoLocal = nuevoPresupuesto; // Guardar localmente
                  });
                  widget.onBudgetChanged?.call({
                    'presupuestoEstimado': nuevoPresupuesto,
                    'transporteReq': _transporteReq ? 1 : 0,
                    'alojamientoReq': _alojamientoReq ? 1 : 0,
                  });
                }
              },
            )
          // Campos de edición para Transporte
          else if (_editandoTransporte && titulo == 'Transporte')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Campo de precio a la izquierda
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _precioTransporteController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: !isWeb ? 16.dg : 5.5.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    decoration: InputDecoration(
                      suffix: Text(
                        '€',
                        style: TextStyle(
                          fontSize: !isWeb ? 16.dg : 5.5.sp,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: color),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: color, width: 2),
                      ),
                    ),
                    autofocus: true,
                  ),
                ),
                SizedBox(width: 16),
                // Dropdown de empresa a la derecha
                Expanded(
                  flex: 3,
                  child: _cargandoEmpresas
                    ? Center(child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: color,
                        ),
                      ))
                    : Container(
                        padding: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: color, width: 1),
                          ),
                        ),
                        child: DropdownButton<EmpresaTransporte>(
                          value: _empresaTransporteLocal,
                          isExpanded: true,
                          underline: SizedBox(), // Quitar la línea por defecto
                          hint: Text(
                            'Sin selección',
                            style: TextStyle(
                              fontSize: !isWeb ? 12.dg : 4.sp,
                              color: color, // Cambiar a morado
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: color,
                          ),
                          selectedItemBuilder: (BuildContext context) {
                            return _empresasDisponibles.map((empresa) {
                              return Text(
                                empresa.nombre,
                                style: TextStyle(
                                  fontSize: !isWeb ? 12.dg : 4.sp,
                                  color: color, // Texto seleccionado en morado
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            }).toList();
                          },
                          items: _empresasDisponibles.isEmpty 
                            ? [
                                DropdownMenuItem<EmpresaTransporte>(
                                  value: null,
                                  child: Text(
                                    'No hay empresas disponibles',
                                    style: TextStyle(
                                      fontSize: !isWeb ? 12.dg : 4.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                )
                              ]
                            : () {
                                // Eliminar duplicados basándose en el ID
                                final idsVistos = <int>{};
                                final empresasUnicas = <EmpresaTransporte>[];
                                for (var empresa in _empresasDisponibles) {
                                  if (!idsVistos.contains(empresa.id)) {
                                    idsVistos.add(empresa.id);
                                    empresasUnicas.add(empresa);
                                  }
                                }
                                print('[BUDGET] Empresas únicas para dropdown: ${empresasUnicas.length}');
                                print('[BUDGET] Empresa seleccionada value: ${_empresaTransporteLocal?.nombre} (ID: ${_empresaTransporteLocal?.id})');
                                // Verificar si la empresa seleccionada está en la lista
                                if (_empresaTransporteLocal != null) {
                                  final encontrada = empresasUnicas.any((e) => e.id == _empresaTransporteLocal!.id);
                                  print('[BUDGET] ¿Empresa seleccionada está en lista única? $encontrada');
                                }
                                return empresasUnicas.map((empresa) {
                                  return DropdownMenuItem<EmpresaTransporte>(
                                    value: empresa,
                                    child: Text(
                                      empresa.nombre,
                                      style: TextStyle(
                                        fontSize: !isWeb ? 12.dg : 4.sp,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  );
                                }).toList();
                              }(),
                          onChanged: (EmpresaTransporte? nuevaEmpresa) {
                            if (mounted) {
                              setState(() {
                                _empresaTransporteLocal = nuevaEmpresa;
                              });
                            }
                            print('[BUDGET] Empresa seleccionada: ${nuevaEmpresa?.nombre}');
                          },
                        ),
                      ),
                ),
              ],
            )
          // Campos de edición para Alojamiento
          else if (_editandoAlojamiento && titulo == 'Alojamiento')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Campo de precio a la izquierda
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _precioAlojamientoController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: !isWeb ? 16.dg : 5.5.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    decoration: InputDecoration(
                      suffix: Text(
                        '€',
                        style: TextStyle(
                          fontSize: !isWeb ? 16.dg : 5.5.sp,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: color),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: color, width: 2),
                      ),
                    ),
                    autofocus: true,
                  ),
                ),
                SizedBox(width: 16),
                // Dropdown de alojamiento a la derecha
                Expanded(
                  flex: 3,
                  child: _cargandoAlojamientos
                    ? Center(child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: color,
                        ),
                      ))
                    : Builder(
                        builder: (context) {
                          print('[BUDGET DROPDOWN BUILD] _alojamientosDisponibles.length: ${_alojamientosDisponibles.length}');
                          print('[BUDGET DROPDOWN BUILD] _alojamientoLocal: ${_alojamientoLocal?.nombre}');
                          return Container(
                        padding: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: color, width: 1),
                          ),
                        ),
                        child: DropdownButton<Alojamiento>(
                          value: _alojamientoLocal,
                          isExpanded: true,
                          underline: SizedBox(),
                          hint: Text(
                            'Seleccione alojamiento',
                            style: TextStyle(
                              fontSize: !isWeb ? 12.dg : 4.sp,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: color,
                          ),
                          items: _alojamientosDisponibles.isEmpty 
                            ? [
                                DropdownMenuItem<Alojamiento>(
                                  value: null,
                                  child: Text(
                                    'Cargando alojamientos...',
                                    style: TextStyle(
                                      fontSize: !isWeb ? 12.dg : 4.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                )
                              ]
                            : () {
                                // Eliminar duplicados basándose en el ID
                                final idsVistos = <int>{};
                                final alojamientosUnicos = <Alojamiento>[];
                                for (var alojamiento in _alojamientosDisponibles) {
                                  if (!idsVistos.contains(alojamiento.id)) {
                                    idsVistos.add(alojamiento.id);
                                    alojamientosUnicos.add(alojamiento);
                                  }
                                }
                                print('[BUDGET] Alojamientos únicos para dropdown: ${alojamientosUnicos.length}');
                                print('[BUDGET] Alojamiento seleccionado value: ${_alojamientoLocal?.nombre} (ID: ${_alojamientoLocal?.id})');
                                // Verificar si el alojamiento seleccionado está en la lista
                                if (_alojamientoLocal != null) {
                                  final encontrado = alojamientosUnicos.any((a) => a.id == _alojamientoLocal!.id);
                                  print('[BUDGET] ¿Alojamiento seleccionado está en lista única? $encontrado');
                                }
                                
                                // Crear lista de items con opción "Sin selección" al inicio
                                final items = <DropdownMenuItem<Alojamiento>>[
                                  DropdownMenuItem<Alojamiento>(
                                    value: null,
                                    child: Text(
                                      'Sin selección',
                                      style: TextStyle(
                                        fontSize: !isWeb ? 12.dg : 4.sp,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ];
                                
                                // Añadir los alojamientos disponibles
                                items.addAll(alojamientosUnicos.map((alojamiento) {
                                  return DropdownMenuItem<Alojamiento>(
                                    value: alojamiento,
                                    child: Text(
                                      alojamiento.nombre,
                                      style: TextStyle(
                                        fontSize: !isWeb ? 12.dg : 4.sp,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  );
                                }).toList());
                                
                                return items;
                              }(),
                          onChanged: (Alojamiento? nuevoAlojamiento) {
                            if (mounted) {
                              setState(() {
                                _alojamientoLocal = nuevoAlojamiento;
                              });
                              // Notificar cambio al padre
                              widget.onBudgetChanged?.call({
                                'alojamientoId': nuevoAlojamiento?.id,
                                'alojamiento': nuevoAlojamiento,
                              });
                            }
                            print('[BUDGET] Alojamiento seleccionado: ${nuevoAlojamiento?.nombre} (ID: ${nuevoAlojamiento?.id})');
                          },
                        ),
                          );
                        },
                      ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Si es "Coste por Alumno", mostrar icono, título y valor en la misma línea
                if (titulo == 'Coste por Alumno')
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              icono,
                              color: color,
                              size: !isWeb ? 20.dg : 6.sp,
                            ),
                            SizedBox(width: 8),
                            Text(
                              titulo,
                              style: TextStyle(
                                fontSize: !isWeb ? 13.dg : 4.5.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${valor.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontSize: !isWeb ? 16.dg : 5.5.sp,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    '${valor.toStringAsFixed(2)} €',
                    style: TextStyle(
                      fontSize: !isWeb ? 16.dg : 5.5.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                // Mostrar empresa de transporte si es la tarjeta de Transporte
                if (titulo == 'Transporte')
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        empresaTransporte?.nombre ?? 'Sin selección',
                        style: TextStyle(
                          fontSize: !isWeb ? 12.dg : 4.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                // Mostrar alojamiento si es la tarjeta de Alojamiento
                if (titulo == 'Alojamiento')
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        _alojamientoLocal?.nombre ?? 'Sin selección',
                        style: TextStyle(
                          fontSize: !isWeb ? 12.dg : 4.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  /// Widget para la card de gastos varios
  Widget _buildGastosVariosCard(BuildContext context, bool isWeb) {
    // Calcular total de gastos personalizados
    final totalGastos = _gastosPersonalizados.fold<double>(
      0.0, 
      (sum, gasto) => sum + gasto.cantidad
    );
    
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.amber.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.2),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con título y botón agregar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.amber.withOpacity(0.8),
                          Colors.amber.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: !isWeb ? 22.dg : 7.sp,
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gastos Varios',
                        style: TextStyle(
                          fontSize: !isWeb ? 14.dg : 4.5.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                      if (totalGastos > 0)
                        Text(
                          '${totalGastos.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontSize: !isWeb ? 16.dg : 5.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (widget.isAdminOrSolicitante)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withOpacity(0.8),
                        Colors.amber.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.add_circle_rounded, color: Colors.white),
                    onPressed: () => _mostrarDialogoAgregarGasto(context),
                    tooltip: 'Agregar gasto',
                  ),
                ),
            ],
          ),
          
          if (_cargandoGastos)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Colors.amber),
              ),
            )
          else if (_gastosPersonalizados.isEmpty)
            Container(
              margin: EdgeInsets.only(top: 16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      color: Colors.amber.withOpacity(0.5),
                      size: !isWeb ? 40.dg : 12.sp,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No hay gastos personalizados',
                      style: TextStyle(
                        fontSize: !isWeb ? 12.dg : 4.sp,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              margin: EdgeInsets.only(top: 12),
              constraints: BoxConstraints(
                maxHeight: _gastosPersonalizados.length > 5 ? 300 : double.infinity,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: _gastosPersonalizados.length > 5 
                    ? AlwaysScrollableScrollPhysics() 
                    : NeverScrollableScrollPhysics(),
                itemCount: _gastosPersonalizados.length,
                itemBuilder: (context, index) {
                  final gasto = _gastosPersonalizados[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.amber.withOpacity(0.15),
                          Colors.amber.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.withOpacity(0.6),
                                Colors.amber.withOpacity(0.4),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.receipt_rounded, 
                            color: Colors.white, 
                            size: !isWeb ? 18.dg : 5.sp
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            gasto.concepto,
                            style: TextStyle(
                              fontSize: !isWeb ? 13.dg : 4.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Text(
                          '${gasto.cantidad.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontSize: !isWeb ? 14.dg : 4.5.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                        if (widget.isAdminOrSolicitante) ...[
                          SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.delete_rounded, color: Colors.red[700], size: !isWeb ? 18.dg : 5.sp),
                              onPressed: () => _eliminarGasto(gasto),
                              padding: EdgeInsets.all(6),
                              constraints: BoxConstraints(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  /// Muestra diálogo para agregar un nuevo gasto
  Future<void> _mostrarDialogoAgregarGasto(BuildContext context) async {
    _conceptoController.clear();
    _cantidadController.clear();
    
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Gasto Personalizado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _conceptoController,
                decoration: InputDecoration(
                  labelText: 'Concepto',
                  hintText: 'Ej: Material didáctico, entradas...',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _cantidadController,
                decoration: InputDecoration(
                  labelText: 'Cantidad (€)',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                  prefixText: '€ ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final concepto = _conceptoController.text.trim();
                final cantidadStr = _cantidadController.text.trim();
                
                if (concepto.isEmpty || cantidadStr.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor completa todos los campos')),
                  );
                  return;
                }
                
                final cantidad = double.tryParse(cantidadStr);
                if (cantidad == null || cantidad <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ingresa una cantidad válida')),
                  );
                  return;
                }
                
                Navigator.of(context).pop();
                _agregarGasto(concepto, cantidad);
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  /// Agrega un nuevo gasto personalizado (solo localmente, se guarda al hacer click en Guardar)
  void _agregarGasto(String concepto, double cantidad) {
    final nuevoGasto = GastoPersonalizado(
      id: -(DateTime.now().millisecondsSinceEpoch), // ID temporal negativo
      actividadId: widget.actividad.id,
      concepto: concepto,
      cantidad: cantidad,
      fechaCreacion: DateTime.now(),
    );
    
    setState(() {
      _gastosPersonalizados.add(nuevoGasto);
    });
    
    // Notificar al padre que hubo cambios en el presupuesto
    widget.onBudgetChanged?.call({
      'budgetChanged': true,
      'gastosPersonalizados': _gastosPersonalizados,
    });
  }

  /// Elimina un gasto personalizado (solo localmente, se guarda al hacer click en Guardar)
  Future<void> _eliminarGasto(GastoPersonalizado gasto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Gasto'),
          content: Text('¿Estás seguro de que deseas eliminar "${gasto.concepto}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
    
    if (confirmar == true) {
      setState(() {
        _gastosPersonalizados.remove(gasto);
      });
      
      // Notificar al padre que hubo cambios en el presupuesto
      widget.onBudgetChanged?.call({
        'budgetChanged': true,
        'gastosPersonalizados': _gastosPersonalizados,
      });
    }
  }

  // ============================================================================
  // Métodos para diálogos de gestión de presupuestos (Placeholders)
  // ============================================================================
  
  void _mostrarDialogoEditarTransporte(BuildContext context) {
    // TODO: Implementar diálogo para editar transporte
    // - Seleccionar empresa de transporte (de la BD)
    // - Editar precio del transporte
    // - Agregar comentarios
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Transporte'),
        content: Text('Funcionalidad en desarrollo.\n\nAquí podrás:\n• Seleccionar empresa de transporte\n• Editar precio\n• Agregar comentarios'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEditarAlojamiento(BuildContext context) {
    // TODO: Implementar diálogo para editar alojamiento
    // - Seleccionar alojamiento (de la BD)
    // - Editar precio por noche
    // - Agregar comentarios
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Alojamiento'),
        content: Text('Funcionalidad en desarrollo.\n\nAquí podrás:\n• Seleccionar alojamiento\n• Editar precio por noche\n• Agregar comentarios'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoSolicitarPresupuestosTransporte(BuildContext context) {
    // TODO: Implementar diálogo para solicitar presupuestos de transporte
    // - Formulario para enviar email a empresas de transporte
    // - Debe solicitar mínimo 3 presupuestos
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Solicitar Presupuestos de Transporte'),
        content: Text('Funcionalidad en desarrollo.\n\nAquí podrás:\n• Enviar solicitud a empresas de transporte\n• Solicitar mínimo 3 presupuestos\n• Ver historial de presupuestos recibidos'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoSolicitarPresupuestosAlojamiento(BuildContext context) {
    // TODO: Implementar diálogo para solicitar presupuestos de alojamiento
    // - Formulario para enviar email a alojamientos
    // - Debe solicitar mínimo 3 presupuestos
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Solicitar Presupuestos de Alojamiento'),
        content: Text('Funcionalidad en desarrollo.\n\nAquí podrás:\n• Enviar solicitud a alojamientos\n• Solicitar mínimo 3 presupuestos\n• Ver historial de presupuestos recibidos'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
