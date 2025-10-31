import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../models/actividad.dart';
import '../../../models/alojamiento.dart';
import '../../../models/empresa_transporte.dart';
import '../../../models/gasto_personalizado.dart';
import '../../../services/actividad_service.dart';
import '../../../services/gasto_personalizado_service.dart';
import '../../../services/api_service.dart';
import '../widgets/budget/budget_toggle_switch.dart';
import '../widgets/budget/gastos_varios_card.dart';
import '../widgets/budget/budget_card.dart';
import '../widgets/budget/budget_sections.dart';
import '../dialogs/budget_dialogs.dart';
import '../helpers/budget_edit_helpers.dart';

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

  /// Maneja la edición del presupuesto estimado
  void _handleEditPresupuesto() async {
    await BudgetEditHandlers.handleEditPresupuesto(
      context: context,
      editando: _editandoPresupuesto,
      controller: _presupuestoController,
      presupuestoActual: _presupuestoEstimadoLocal,
      onStateChanged: (editando, presupuesto) {
        if (mounted) {
          setState(() {
            _editandoPresupuesto = editando;
            if (presupuesto != null) {
              _presupuestoEstimadoLocal = presupuesto;
            }
          });
        }
      },
      onBudgetChanged: (data) => widget.onBudgetChanged?.call(data),
      transporteReq: _transporteReq,
      alojamientoReq: _alojamientoReq,
    );
  }

  /// Maneja la edición del precio de transporte
  void _handleEditTransporte() async {
    await BudgetEditHandlers.handleEditTransporte(
      context: context,
      editando: _editandoTransporte,
      controller: _precioTransporteController,
      precioActual: _precioTransporteLocal,
      empresaActual: _empresaTransporteLocal,
      actividadService: widget.actividadService,
      onStateChanged: (editando, precio, empresa, empresas, cargando) {
        if (mounted) {
          setState(() {
            _editandoTransporte = editando;
            if (precio != null) _precioTransporteLocal = precio;
            if (empresa != null) _empresaTransporteLocal = empresa;
            _empresasDisponibles = empresas;
            _cargandoEmpresas = cargando;
          });
        }
      },
      onBudgetChanged: (data) => widget.onBudgetChanged?.call(data),
      transporteReq: _transporteReq,
      alojamientoReq: _alojamientoReq,
    );
  }

  /// Maneja la edición del precio de alojamiento
  void _handleEditAlojamiento() async {
    await BudgetEditHandlers.handleEditAlojamiento(
      context: context,
      editando: _editandoAlojamiento,
      controller: _precioAlojamientoController,
      precioActual: _precioAlojamientoLocal,
      alojamientoActual: _alojamientoLocal,
      actividadService: widget.actividadService,
      onStateChanged: (editando, precio, alojamiento, alojamientos, cargando) {
        if (mounted) {
          setState(() {
            _editandoAlojamiento = editando;
            if (precio != null) _precioAlojamientoLocal = precio;
            if (alojamiento != null) _alojamientoLocal = alojamiento;
            _alojamientosDisponibles = alojamientos;
            _cargandoAlojamientos = cargando;
          });
        }
      },
      onBudgetChanged: (data) => widget.onBudgetChanged?.call(data),
      transporteReq: _transporteReq,
      alojamientoReq: _alojamientoReq,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Calcular valores - usar los valores locales si están disponibles
    final presupuesto = _presupuestoEstimadoLocal ?? widget.actividad.presupuestoEstimado ?? 0.0;
    final precioTransporte = _precioTransporteLocal ?? widget.actividad.precioTransporte ?? 0.0;
    
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
                  size: isWeb ? 18 : 20.0,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Presupuesto y Gastos',
                style: TextStyle(
                  fontSize: isWeb ? 16 : 18.0,
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
                  child: BudgetToggleSwitchWidget(
                    label: 'Transporte',
                    icon: Icons.directions_bus,
                    color: Colors.purple,
                    value: _transporteReq,
                    isWeb: isWeb,
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
                  child: BudgetToggleSwitchWidget(
                    label: 'Alojamiento',
                    icon: Icons.hotel,
                    color: Colors.teal,
                    value: _alojamientoReq,
                    isWeb: isWeb,
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
                  child: BudgetCardWidget(
                    titulo: 'Presupuesto Estimado',
                    valor: presupuesto,
                    icono: Icons.account_balance_wallet,
                    color: Colors.blue,
                    width: double.infinity,
                    isWeb: isWeb,
                    showEdit: true,
                    isEditing: _editandoPresupuesto,
                    controller: _presupuestoController,
                    onEditPressed: _handleEditPresupuesto,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: BudgetCardWidget(
                    titulo: 'Coste Real',
                    valor: costoReal,
                    icono: Icons.euro,
                    color: costoReal > presupuesto ? Colors.red : Colors.green,
                    width: double.infinity,
                    isWeb: isWeb,
                  ),
                ),
              ],
            ),
          ),
          
          // Coste por Alumno justo debajo
          SizedBox(height: 10),
          BudgetCardWidget(
            titulo: 'Coste por Alumno',
            valor: costoPorAlumno,
            icono: Icons.person,
            color: Colors.orange,
            width: double.infinity,
            isWeb: isWeb,
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
                      child: BudgetCardWidget(
                        titulo: 'Transporte',
                        valor: precioTransporte,
                        icono: Icons.directions_bus,
                        color: Colors.purple,
                        width: double.infinity,
                        isWeb: isWeb,
                        showEdit: true,
                        isEditing: _editandoTransporte,
                        controller: _precioTransporteController,
                        empresaTransporte: _empresaTransporteLocal,
                        empresasDisponibles: _empresasDisponibles,
                        onEditPressed: _handleEditTransporte,
                        onEmpresaChanged: (empresa) {
                          setState(() {
                            _empresaTransporteLocal = empresa;
                          });
                        },
                        cargandoEmpresas: _cargandoEmpresas,
                      ),
                    ),
                  if (_transporteReq && _alojamientoReq)
                    SizedBox(width: 16),
                  if (_alojamientoReq)
                    Expanded(
                      child: BudgetCardWidget(
                        titulo: 'Alojamiento',
                        valor: precioAlojamiento,
                        icono: Icons.hotel,
                        color: Colors.teal,
                        width: double.infinity,
                        isWeb: isWeb,
                        showEdit: true,
                        isEditing: _editandoAlojamiento,
                        controller: _precioAlojamientoController,
                        alojamiento: _alojamientoLocal,
                        alojamientosDisponibles: _alojamientosDisponibles,
                        onEditPressed: _handleEditAlojamiento,
                        onAlojamientoChanged: (alojamiento) {
                          setState(() {
                            _alojamientoLocal = alojamiento;
                          });
                        },
                        cargandoAlojamientos: _cargandoAlojamientos,
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
                            Icon(Icons.send_rounded, color: Colors.white, size: isWeb ? 16 : 18.0),
                            SizedBox(width: 8),
                            Text(
                              'Solicitar Presupuestos',
                              style: TextStyle(
                                fontSize: isWeb ? 12 : 14.0,
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
                            Icon(Icons.send_rounded, color: Colors.white, size: isWeb ? 16 : 18.0),
                            SizedBox(width: 8),
                            Text(
                              'Solicitar Presupuestos',
                              style: TextStyle(
                                fontSize: isWeb ? 12 : 14.0,
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
          GastosVariosCardWidget(
            gastos: _gastosPersonalizados,
            isAdminOrSolicitante: widget.isAdminOrSolicitante,
            isLoading: _cargandoGastos,
            isWeb: isWeb,
            onAddGasto: () => _mostrarDialogoAgregarGasto(context),
            onDeleteGasto: _eliminarGasto,
          ),
        ],
      ),
    );
  }

  /// Muestra diálogo para agregar un nuevo gasto
  Future<void> _mostrarDialogoAgregarGasto(BuildContext context) async {
    final result = await BudgetDialogs.mostrarDialogoAgregarGasto(context);
    
    if (result != null) {
      _agregarGasto(result['concepto'], result['cantidad']);
    }
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
  // Métodos para diálogos de gestión de presupuestos
  // ============================================================================
  
  void _mostrarDialogoSolicitarPresupuestosTransporte(BuildContext context) {
    BudgetDialogs.mostrarDialogoSolicitarPresupuestosTransporte(context);
  }

  void _mostrarDialogoSolicitarPresupuestosAlojamiento(BuildContext context) {
    BudgetDialogs.mostrarDialogoSolicitarPresupuestosAlojamiento(context);
  }
}
