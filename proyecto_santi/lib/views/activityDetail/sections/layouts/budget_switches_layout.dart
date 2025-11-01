import 'package:flutter/material.dart';
import '../../widgets/budget/budget_toggle_switch.dart';
import 'package:proyecto_santi/tema/app_colors.dart';

/// Widget que maneja el layout responsive de los switches de transporte y alojamiento.
/// 
/// Muestra dos switches que permiten activar/desactivar:
/// - Transporte requerido
/// - Alojamiento requerido
/// 
/// Layout:
/// - Mobile portrait: columna vertical
/// - Otros (landscape, desktop): fila horizontal
class BudgetSwitchesLayout extends StatelessWidget {
  final bool isMobile;
  final bool isPortrait;
  final bool isWeb;
  final bool transporteReq;
  final bool alojamientoReq;
  final Function(bool) onTransporteChanged;
  final Function(bool) onAlojamientoChanged;

  const BudgetSwitchesLayout({
    Key? key,
    required this.isMobile,
    required this.isPortrait,
    required this.isWeb,
    required this.transporteReq,
    required this.alojamientoReq,
    required this.onTransporteChanged,
    required this.onAlojamientoChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // En móvil portrait: columna; en otros casos: fila
    if (isMobile && isPortrait) {
      return Column(
        children: [
          BudgetToggleSwitchWidget(
            label: 'Transporte',
            icon: Icons.directions_bus,
            color: AppColors.tipoComplementaria,
            value: transporteReq,
            isWeb: isWeb,
            onChanged: onTransporteChanged,
          ),
          SizedBox(height: 10),
          BudgetToggleSwitchWidget(
            label: 'Alojamiento',
            icon: Icons.hotel,
            color: AppColors.presupuestoAlojamiento,
            value: alojamientoReq,
            isWeb: isWeb,
            onChanged: onAlojamientoChanged,
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: BudgetToggleSwitchWidget(
              label: 'Transporte',
              icon: Icons.directions_bus,
              color: AppColors.tipoComplementaria,
              value: transporteReq,
              isWeb: isWeb,
              onChanged: onTransporteChanged,
            ),
          ),
          SizedBox(width: isMobile ? 10 : 16),
          Expanded(
            child: BudgetToggleSwitchWidget(
              label: 'Alojamiento',
              icon: Icons.hotel,
              color: AppColors.presupuestoAlojamiento,
              value: alojamientoReq,
              isWeb: isWeb,
              onChanged: onAlojamientoChanged,
            ),
          ),
        ],
      );
    }
  }
}
