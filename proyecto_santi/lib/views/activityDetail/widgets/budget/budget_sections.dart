import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/alojamiento.dart';
import 'package:proyecto_santi/models/empresa_transporte.dart';
import 'package:proyecto_santi/models/gasto_personalizado.dart';
import 'package:proyecto_santi/tema/app_colors.dart';
import 'budget_card.dart';
import 'gastos_varios_card.dart';

/// Widgets auxiliares para la secci�n de presupuesto

/// Tarjetas de resumen de presupuesto (estimado y real)
class BudgetSummaryCards extends StatelessWidget {
  final double presupuesto;
  final double costoReal;
  final bool isEditing;
  final bool isWeb;
  final bool isDark;
  final bool isAdmin;
  final TextEditingController? controller;
  final VoidCallback? onEdit;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;

  const BudgetSummaryCards({
    Key? key,
    required this.presupuesto,
    required this.costoReal,
    required this.isEditing,
    required this.isWeb,
    required this.isDark,
    required this.isAdmin,
    this.controller,
    this.onEdit,
    this.onSave,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: BudgetCardWidget(
              titulo: 'Presupuesto Estimado',
              valor: presupuesto,
              icono: Icons.calculate_rounded,
              color: Color(0xFF1976d2),
              width: double.infinity,
              isWeb: isWeb,
              showEdit: isAdmin,
              isEditing: isEditing,
              controller: controller,
              onEditPressed: onEdit,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: BudgetCardWidget(
              titulo: 'Coste Real',
              valor: costoReal,
              icono: Icons.receipt_long_rounded,
              color: Colors.green,
              width: double.infinity,
              isWeb: isWeb,
            ),
          ),
        ],
      ),
    );
  }
}

/// Secci�n de transporte (tarjeta + detalles)
class TransporteSection extends StatelessWidget {
  final bool transporteReq;
  final bool isEditing;
  final bool isAdmin;
  final bool isWeb;
  final bool isDark;
  final double? precioTransporte;
  final EmpresaTransporte? empresa;
  final List<EmpresaTransporte> empresasDisponibles;
  final bool cargandoEmpresas;
  final TextEditingController? precioController;
  final VoidCallback? onEdit;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final Function(EmpresaTransporte?)? onEmpresaChanged;
  final VoidCallback? onSolicitarPresupuesto;

  const TransporteSection({
    Key? key,
    required this.transporteReq,
    required this.isEditing,
    required this.isAdmin,
    required this.isWeb,
    required this.isDark,
    this.precioTransporte,
    this.empresa,
    required this.empresasDisponibles,
    required this.cargandoEmpresas,
    this.precioController,
    this.onEdit,
    this.onSave,
    this.onCancel,
    this.onEmpresaChanged,
    this.onSolicitarPresupuesto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!transporteReq) return SizedBox.shrink();

    return Column(
      children: [
        SizedBox(height: 16),
        BudgetCardWidget(
          titulo: 'Transporte',
          valor: precioTransporte ?? 0.0,
          icono: Icons.directions_bus_rounded,
          color: Colors.purple,
          width: double.infinity,
          isWeb: isWeb,
          showEdit: isAdmin,
          isEditing: isEditing,
          controller: precioController,
          onEditPressed: onEdit,
          empresaTransporte: empresa,
          empresasDisponibles: empresasDisponibles,
          onEmpresaChanged: onEmpresaChanged,
          cargandoEmpresas: cargandoEmpresas,
        ),
        if (empresa != null || isEditing) ...[
          SizedBox(height: 12),
          _buildTransporteDetails(),
        ],
      ],
    );
  }

  Widget _buildTransporteDetails() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business_rounded, size: 16, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                'Empresa de Transporte',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (isEditing) ...[
            if (cargandoEmpresas)
              Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<EmpresaTransporte>(
                value: empresa,
                decoration: InputDecoration(
                  labelText: 'Seleccionar empresa',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.8),
                ),
                items: empresasDisponibles.map((emp) {
                  return DropdownMenuItem(
                    value: emp,
                    child: Text(
                      '${emp.nombre}${emp.telefono != null ? " - ${emp.telefono}" : ""}',
                      style: TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
                onChanged: onEmpresaChanged,
              ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: onSolicitarPresupuesto,
              icon: Icon(Icons.email_rounded, size: 16),
              label: Text('Solicitar Presupuesto', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tipoComplementaria,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 36),
              ),
            ),
          ] else if (empresa != null) ...[
            _buildEmpresaInfo('Nombre', empresa!.nombre),
            if (empresa!.cif != null) _buildEmpresaInfo('CIF', empresa!.cif!),
            if (empresa!.telefono != null) _buildEmpresaInfo('Teléfono', empresa!.telefono!),
            if (empresa!.email != null) _buildEmpresaInfo('Email', empresa!.email!),
            if (empresa!.direccion != null) _buildEmpresaInfo('Dirección', empresa!.direccion!),
          ] else
            Text(
              'No hay empresa seleccionada',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpresaInfo(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Secci�n de alojamiento (tarjeta + detalles)
class AlojamientoSection extends StatelessWidget {
  final bool alojamientoReq;
  final bool isEditing;
  final bool isAdmin;
  final bool isWeb;
  final bool isDark;
  final double? precioAlojamiento;
  final Alojamiento? alojamiento;
  final List<Alojamiento> alojamientosDisponibles;
  final bool cargandoAlojamientos;
  final TextEditingController? precioController;
  final VoidCallback? onEdit;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final Function(Alojamiento?)? onAlojamientoChanged;
  final VoidCallback? onSolicitarPresupuesto;

  const AlojamientoSection({
    Key? key,
    required this.alojamientoReq,
    required this.isEditing,
    required this.isAdmin,
    required this.isWeb,
    required this.isDark,
    this.precioAlojamiento,
    this.alojamiento,
    required this.alojamientosDisponibles,
    required this.cargandoAlojamientos,
    this.precioController,
    this.onEdit,
    this.onSave,
    this.onCancel,
    this.onAlojamientoChanged,
    this.onSolicitarPresupuesto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!alojamientoReq) return SizedBox.shrink();

    return Column(
      children: [
        SizedBox(height: 16),
        BudgetCardWidget(
          titulo: 'Alojamiento',
          valor: precioAlojamiento ?? 0.0,
          icono: Icons.hotel_rounded,
          color: Colors.teal,
          width: double.infinity,
          isWeb: isWeb,
          showEdit: isAdmin,
          isEditing: isEditing,
          controller: precioController,
          onEditPressed: onEdit,
          alojamiento: alojamiento,
          alojamientosDisponibles: alojamientosDisponibles,
          onAlojamientoChanged: onAlojamientoChanged,
          cargandoAlojamientos: cargandoAlojamientos,
        ),
        if (alojamiento != null || isEditing) ...[
          SizedBox(height: 12),
          _buildAlojamientoDetails(),
        ],
      ],
    );
  }

  Widget _buildAlojamientoDetails() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.teal.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.hotel_rounded, size: 16, color: Colors.teal),
              SizedBox(width: 8),
              Text(
                'Informaci�n del Alojamiento',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (isEditing) ...[
            if (cargandoAlojamientos)
              Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<Alojamiento>(
                value: alojamiento,
                decoration: InputDecoration(
                  labelText: 'Seleccionar alojamiento',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.8),
                ),
                items: alojamientosDisponibles.map((aloj) {
                  return DropdownMenuItem(
                    value: aloj,
                    child: Text(
                      '${aloj.nombre}${aloj.activo ? '' : ' (Inactivo)'}',
                      style: TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
                onChanged: onAlojamientoChanged,
              ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: onSolicitarPresupuesto,
              icon: Icon(Icons.email_rounded, size: 16),
              label: Text('Solicitar Presupuesto', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.presupuestoAlojamiento,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 36),
              ),
            ),
          ] else if (alojamiento != null) ...[
            _buildAlojamientoInfo('Nombre', alojamiento!.nombre),
            if (alojamiento!.direccion != null) 
              _buildAlojamientoInfo('Direcci�n', alojamiento!.direccion!),
            if (alojamiento!.telefono != null) 
              _buildAlojamientoInfo('Tel�fono', alojamiento!.telefono!),
            if (alojamiento!.email != null) 
              _buildAlojamientoInfo('Email', alojamiento!.email!),
            if (alojamiento!.web != null) 
              _buildAlojamientoInfo('Web', alojamiento!.web!),
          ] else
            Text(
              'No hay alojamiento seleccionado',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlojamientoInfo(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de coste por alumno
class CostoPorAlumnoCard extends StatelessWidget {
  final double costoPorAlumno;
  final bool isWeb;
  final bool isDark;

  const CostoPorAlumnoCard({
    Key? key,
    required this.costoPorAlumno,
    required this.isWeb,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: isWeb ? 20 : 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coste por Alumno',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: isWeb ? 11 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${costoPorAlumno.toStringAsFixed(2)} �',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isWeb ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
