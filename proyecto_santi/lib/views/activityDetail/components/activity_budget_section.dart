import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/actividad.dart';
import '../../../models/alojamiento.dart';
import '../../../models/empresa_transporte.dart';
import '../../../services/actividad_service.dart';

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

  @override
  void initState() {
    super.initState();
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
    
    // Calcular valores - usar los valores locales si están disponibles
    final presupuesto = _presupuestoEstimadoLocal ?? widget.actividad.presupuestoEstimado ?? 0.0;
    final precioTransporte = _precioTransporteLocal ?? widget.actividad.precioTransporte ?? 0.0;
    final empresaTransporte = _empresaTransporteLocal ?? widget.actividad.empresaTransporte;
    
    final precioAlojamiento = _precioAlojamientoLocal ?? 0.0; // El precio se guarda localmente
    final costoReal = precioTransporte + precioAlojamiento; // Coste real = suma de transporte + alojamiento
    final costoPorAlumno = widget.totalAlumnosParticipantes > 0 
        ? costoReal / widget.totalAlumnosParticipantes 
        : 0.0;
    
    return Container(
      constraints: BoxConstraints(minHeight: 500),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Presupuesto y Gastos',
            style: TextStyle(
              fontSize: !isWeb ? 14.dg : 5.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976d2),
            ),
          ),
          SizedBox(height: 20),
          
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
            SizedBox(height: 20),
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
          SizedBox(height: 20),
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
            SizedBox(height: 20),
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
          
          // Secciones expandibles de Transporte y Alojamiento (detalles completos)
          if (_transporteReq || _alojamientoReq) ...[
            SizedBox(height: 12),
            Row(
              children: [
                if (_transporteReq)
                  Expanded(
                    child: _buildTransporteSection(context, isWeb, _transporteReq, precioTransporte),
                  ),
                if (_transporteReq && _alojamientoReq)
                  SizedBox(width: 16),
                if (_alojamientoReq)
                  Expanded(
                    child: _buildAlojamientoSection(context, isWeb, _alojamientoReq, precioAlojamiento),
                  ),
              ],
            ),
          ],
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: value ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value ? color.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: value ? color : Colors.grey,
            size: !isWeb ? 18.dg : 6.sp,
          ),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: !isWeb ? 13.dg : 5.sp,
                fontWeight: FontWeight.w600,
                color: value ? color : Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 4),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icono,
                    color: color,
                    size: !isWeb ? 24.dg : 7.sp,
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
              if (showEdit && widget.isAdminOrSolicitante)
                IconButton(
                  icon: Icon(
                    (_editandoPresupuesto && titulo == 'Presupuesto Estimado') || 
                    (_editandoTransporte && titulo == 'Transporte') ||
                    (_editandoAlojamiento && titulo == 'Alojamiento')
                      ? Icons.check 
                      : Icons.edit, 
                    size: !isWeb ? 16.dg : 5.sp
                  ),
                  color: ((_editandoPresupuesto && titulo == 'Presupuesto Estimado') || 
                          (_editandoTransporte && titulo == 'Transporte') ||
                          (_editandoAlojamiento && titulo == 'Alojamiento'))
                    ? Colors.green 
                    : Colors.grey[600],
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
          SizedBox(height: 12),
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

  /// Widget para mostrar la sección de transporte con detalles
  Widget _buildTransporteSection(BuildContext context, bool isWeb, bool requiereTransporte, double precioTransporte) {
    if (!requiereTransporte) return SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.1),
            Colors.purple.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bus,
            color: Colors.purple,
            size: !isWeb ? 24.dg : 7.sp,
          ),
          SizedBox(width: 12),
          if (widget.isAdminOrSolicitante)
            OutlinedButton.icon(
              onPressed: () => _mostrarDialogoSolicitarPresupuestosTransporte(context),
              icon: Icon(Icons.send, size: !isWeb ? 16.dg : 5.sp),
              label: Text(
                'Solicitar Presupuestos',
                style: TextStyle(fontSize: !isWeb ? 11.dg : 4.sp),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.purple,
                side: BorderSide(color: Colors.purple.withOpacity(0.5), width: 2),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              ),
            ),
        ],
      ),
    );
  }

  /// Widget para mostrar la sección de alojamiento con detalles
  Widget _buildAlojamientoSection(BuildContext context, bool isWeb, bool requiereAlojamiento, double precioAlojamiento) {
    if (!requiereAlojamiento) return SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal.withOpacity(0.1),
            Colors.teal.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.teal.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.hotel,
            color: Colors.teal,
            size: !isWeb ? 24.dg : 7.sp,
          ),
          SizedBox(width: 12),
          if (widget.isAdminOrSolicitante)
            OutlinedButton.icon(
              onPressed: () => _mostrarDialogoSolicitarPresupuestosAlojamiento(context),
              icon: Icon(Icons.send, size: !isWeb ? 16.dg : 5.sp),
              label: Text(
                'Solicitar Presupuestos',
                style: TextStyle(fontSize: !isWeb ? 11.dg : 4.sp),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.teal,
                side: BorderSide(color: Colors.teal.withOpacity(0.5), width: 2),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              ),
            ),
        ],
      ),
    );
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
