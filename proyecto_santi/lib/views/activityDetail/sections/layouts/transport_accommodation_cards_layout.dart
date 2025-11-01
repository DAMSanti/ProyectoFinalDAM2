import 'package:flutter/material.dart';
import '../../../../models/alojamiento.dart';
import '../../../../models/empresa_transporte.dart';
import '../../widgets/budget/budget_card.dart';
import 'package:proyecto_santi/tema/app_colors.dart';

/// Widget que maneja el layout responsive de las tarjetas de transporte y alojamiento.
/// 
/// Muestra las tarjetas condicionalmente según si están activadas:
/// - Tarjeta de Transporte (si transporteReq = true)
/// - Tarjeta de Alojamiento (si alojamientoReq = true)
/// 
/// Layout:
/// - Mobile landscape: columna vertical compacta
/// - Mobile portrait: columna vertical con más espaciado
/// - Desktop: fila horizontal
class TransportAccommodationCardsLayout extends StatelessWidget {
  final bool isMobile;
  final bool isMobileLandscape;
  final bool isWeb;
  final bool transporteReq;
  final bool alojamientoReq;
  
  // Transporte
  final double precioTransporte;
  final bool editandoTransporte;
  final TextEditingController precioTransporteController;
  final EmpresaTransporte? empresaTransporteLocal;
  final List<EmpresaTransporte> empresasDisponibles;
  final VoidCallback onEditTransporte;
  final Function(EmpresaTransporte?) onEmpresaChanged;
  final bool cargandoEmpresas;
  
  // Alojamiento
  final double precioAlojamiento;
  final bool editandoAlojamiento;
  final TextEditingController precioAlojamientoController;
  final Alojamiento? alojamientoLocal;
  final List<Alojamiento> alojamientosDisponibles;
  final VoidCallback onEditAlojamiento;
  final Function(Alojamiento?) onAlojamientoChanged;
  final bool cargandoAlojamientos;

  const TransportAccommodationCardsLayout({
    Key? key,
    required this.isMobile,
    required this.isMobileLandscape,
    required this.isWeb,
    required this.transporteReq,
    required this.alojamientoReq,
    required this.precioTransporte,
    required this.editandoTransporte,
    required this.precioTransporteController,
    required this.empresaTransporteLocal,
    required this.empresasDisponibles,
    required this.onEditTransporte,
    required this.onEmpresaChanged,
    required this.cargandoEmpresas,
    required this.precioAlojamiento,
    required this.editandoAlojamiento,
    required this.precioAlojamientoController,
    required this.alojamientoLocal,
    required this.alojamientosDisponibles,
    required this.onEditAlojamiento,
    required this.onAlojamientoChanged,
    required this.cargandoAlojamientos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si ninguno está activo, no mostrar nada
    if (!transporteReq && !alojamientoReq) {
      return SizedBox.shrink();
    }

    if (isMobileLandscape) {
      return _buildMobileLandscapeLayout();
    } else if (isMobile) {
      return _buildMobilePortraitLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  /// Layout para móvil en modo landscape (columna vertical compacta)
  Widget _buildMobileLandscapeLayout() {
    return Column(
      children: [
        if (transporteReq) ...[
          BudgetCardWidget(
            titulo: 'Transporte',
            valor: precioTransporte,
            icono: Icons.directions_bus,
            color: AppColors.tipoComplementaria,
            width: double.infinity,
            isWeb: isWeb,
            showEdit: true,
            isEditing: editandoTransporte,
            controller: precioTransporteController,
            empresaTransporte: empresaTransporteLocal,
            empresasDisponibles: empresasDisponibles,
            onEditPressed: onEditTransporte,
            onEmpresaChanged: onEmpresaChanged,
            cargandoEmpresas: cargandoEmpresas,
          ),
          if (alojamientoReq) SizedBox(height: 6),
        ],
        if (alojamientoReq)
          BudgetCardWidget(
            titulo: 'Alojamiento',
            valor: precioAlojamiento,
            icono: Icons.hotel,
            color: AppColors.presupuestoAlojamiento,
            width: double.infinity,
            isWeb: isWeb,
            showEdit: true,
            isEditing: editandoAlojamiento,
            controller: precioAlojamientoController,
            alojamiento: alojamientoLocal,
            alojamientosDisponibles: alojamientosDisponibles,
            onEditPressed: onEditAlojamiento,
            onAlojamientoChanged: onAlojamientoChanged,
            cargandoAlojamientos: cargandoAlojamientos,
          ),
      ],
    );
  }

  /// Layout para móvil en modo portrait (columna vertical con espaciado)
  Widget _buildMobilePortraitLayout() {
    return Column(
      children: [
        if (transporteReq) ...[
          BudgetCardWidget(
            titulo: 'Transporte',
            valor: precioTransporte,
            icono: Icons.directions_bus,
            color: AppColors.tipoComplementaria,
            width: double.infinity,
            isWeb: isWeb,
            showEdit: true,
            isEditing: editandoTransporte,
            controller: precioTransporteController,
            empresaTransporte: empresaTransporteLocal,
            empresasDisponibles: empresasDisponibles,
            onEditPressed: onEditTransporte,
            onEmpresaChanged: onEmpresaChanged,
            cargandoEmpresas: cargandoEmpresas,
          ),
          if (alojamientoReq) SizedBox(height: 10),
        ],
        if (alojamientoReq)
          BudgetCardWidget(
            titulo: 'Alojamiento',
            valor: precioAlojamiento,
            icono: Icons.hotel,
            color: AppColors.presupuestoAlojamiento,
            width: double.infinity,
            isWeb: isWeb,
            showEdit: true,
            isEditing: editandoAlojamiento,
            controller: precioAlojamientoController,
            alojamiento: alojamientoLocal,
            alojamientosDisponibles: alojamientosDisponibles,
            onEditPressed: onEditAlojamiento,
            onAlojamientoChanged: onAlojamientoChanged,
            cargandoAlojamientos: cargandoAlojamientos,
          ),
      ],
    );
  }

  /// Layout para escritorio (fila horizontal)
  Widget _buildDesktopLayout() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (transporteReq)
            Expanded(
              child: BudgetCardWidget(
                titulo: 'Transporte',
                valor: precioTransporte,
                icono: Icons.directions_bus,
                color: AppColors.tipoComplementaria,
                width: double.infinity,
                isWeb: isWeb,
                showEdit: true,
                isEditing: editandoTransporte,
                controller: precioTransporteController,
                empresaTransporte: empresaTransporteLocal,
                empresasDisponibles: empresasDisponibles,
                onEditPressed: onEditTransporte,
                onEmpresaChanged: onEmpresaChanged,
                cargandoEmpresas: cargandoEmpresas,
              ),
            ),
          if (transporteReq && alojamientoReq) SizedBox(width: 16),
          if (alojamientoReq)
            Expanded(
              child: BudgetCardWidget(
                titulo: 'Alojamiento',
                valor: precioAlojamiento,
                icono: Icons.hotel,
                color: AppColors.presupuestoAlojamiento,
                width: double.infinity,
                isWeb: isWeb,
                showEdit: true,
                isEditing: editandoAlojamiento,
                controller: precioAlojamientoController,
                alojamiento: alojamientoLocal,
                alojamientosDisponibles: alojamientosDisponibles,
                onEditPressed: onEditAlojamiento,
                onAlojamientoChanged: onAlojamientoChanged,
                cargandoAlojamientos: cargandoAlojamientos,
              ),
            ),
        ],
      ),
    );
  }
}
