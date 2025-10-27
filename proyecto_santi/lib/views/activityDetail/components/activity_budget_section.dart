import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/actividad.dart';

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

  const ActivityBudgetSection({
    Key? key,
    required this.actividad,
    required this.isAdminOrSolicitante,
    required this.totalAlumnosParticipantes,
    this.onBudgetChanged,
  }) : super(key: key);

  @override
  State<ActivityBudgetSection> createState() => _ActivityBudgetSectionState();
}

class _ActivityBudgetSectionState extends State<ActivityBudgetSection> {
  // Variables para switches de transporte y alojamiento
  bool _transporteReq = false;
  bool _alojamientoReq = false;

  @override
  void initState() {
    super.initState();
    // Inicializar switches desde la actividad (convertir int a bool)
    _transporteReq = widget.actividad.transporteReq == 1;
    _alojamientoReq = widget.actividad.alojamientoReq == 1;
    print('[BUDGET] initState - transporteReq: ${widget.actividad.transporteReq} -> $_transporteReq');
    print('[BUDGET] initState - alojamientoReq: ${widget.actividad.alojamientoReq} -> $_alojamientoReq');
  }

  @override
  void didUpdateWidget(ActivityBudgetSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('[BUDGET] didUpdateWidget llamado');
    print('[BUDGET]   oldWidget.transporteReq: ${oldWidget.actividad.transporteReq}');
    print('[BUDGET]   newWidget.transporteReq: ${widget.actividad.transporteReq}');
    print('[BUDGET]   oldWidget.alojamientoReq: ${oldWidget.actividad.alojamientoReq}');
    print('[BUDGET]   newWidget.alojamientoReq: ${widget.actividad.alojamientoReq}');
    
    // Actualizar switches si la actividad cambió (por ejemplo, después de guardar)
    if (oldWidget.actividad.transporteReq != widget.actividad.transporteReq) {
      setState(() {
        _transporteReq = widget.actividad.transporteReq == 1;
      });
      print('[BUDGET]   Actualizado _transporteReq a: $_transporteReq');
    }
    if (oldWidget.actividad.alojamientoReq != widget.actividad.alojamientoReq) {
      setState(() {
        _alojamientoReq = widget.actividad.alojamientoReq == 1;
      });
      print('[BUDGET]   Actualizado _alojamientoReq a: $_alojamientoReq');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    // Calcular valores
    final presupuesto = widget.actividad.presupuestoEstimado ?? 0.0;
    final precioTransporte = widget.actividad.precioTransporte ?? 0.0;
    final precioAlojamiento = widget.actividad.alojamiento?.precioPorNoche ?? 0.0;
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
              fontSize: !isWeb ? 18.dg : 6.sp,
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
                  icon: Icon(Icons.edit, size: !isWeb ? 16.dg : 5.sp),
                  color: Colors.grey[600],
                  onPressed: () {
                    // TODO: Implementar edición de presupuesto estimado
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Edición de presupuesto - Próximamente')),
                    );
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
          Text(
            '${valor.toStringAsFixed(2)} €',
            style: TextStyle(
              fontSize: !isWeb ? 22.dg : 7.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bus,
            color: Colors.purple,
            size: !isWeb ? 32.dg : 9.sp,
          ),
          SizedBox(height: 12),
          if (widget.isAdminOrSolicitante)
            OutlinedButton.icon(
              onPressed: () => _mostrarDialogoSolicitarPresupuestosTransporte(context),
              icon: Icon(Icons.send, size: !isWeb ? 16.dg : 5.sp),
              label: Text(
                'Solicitar Presupuestos',
                style: TextStyle(fontSize: !isWeb ? 13.dg : 4.5.sp),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.purple,
                side: BorderSide(color: Colors.purple.withOpacity(0.5), width: 2),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.hotel,
            color: Colors.teal,
            size: !isWeb ? 32.dg : 9.sp,
          ),
          SizedBox(height: 12),
          if (widget.isAdminOrSolicitante)
            OutlinedButton.icon(
              onPressed: () => _mostrarDialogoSolicitarPresupuestosAlojamiento(context),
              icon: Icon(Icons.send, size: !isWeb ? 16.dg : 5.sp),
              label: Text(
                'Solicitar Presupuestos',
                style: TextStyle(fontSize: !isWeb ? 13.dg : 4.5.sp),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.teal,
                side: BorderSide(color: Colors.teal.withOpacity(0.5), width: 2),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
