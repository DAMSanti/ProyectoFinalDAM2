import 'package:flutter/material.dart';
import '../../widgets/budget/budget_card.dart';
import 'package:proyecto_santi/tema/app_colors.dart';

/// Widget que maneja el layout responsive de las tarjetas de presupuesto.
/// 
/// Muestra tres tarjetas (Presupuesto Estimado, Coste Real, Coste por Alumno)
/// en diferentes layouts según el tamaño de pantalla:
/// - Mobile landscape: columna vertical compacta
/// - Mobile portrait: columna vertical con más espaciado
/// - Desktop: fila 2+1 (dos arriba, una abajo centrada)
class BudgetCardsLayout extends StatelessWidget {
  final bool isMobile;
  final bool isMobileLandscape;
  final bool isWeb;
  final double presupuesto;
  final double costoReal;
  final double costoPorAlumno;
  final bool editandoPresupuesto;
  final TextEditingController presupuestoController;
  final VoidCallback onEditPresupuesto;

  const BudgetCardsLayout({
    super.key,
    required this.isMobile,
    required this.isMobileLandscape,
    required this.isWeb,
    required this.presupuesto,
    required this.costoReal,
    required this.costoPorAlumno,
    required this.editandoPresupuesto,
    required this.presupuestoController,
    required this.onEditPresupuesto,
  });

  @override
  Widget build(BuildContext context) {
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
        BudgetCardWidget(
          titulo: 'Presupuesto Estimado',
          valor: presupuesto,
          icono: Icons.account_balance_wallet,
          color: Colors.blue,
          width: double.infinity,
          isWeb: isWeb,
          showEdit: true,
          isEditing: editandoPresupuesto,
          controller: presupuestoController,
          onEditPressed: onEditPresupuesto,
        ),
        SizedBox(height: 6),
        BudgetCardWidget(
          titulo: 'Coste Real',
          valor: costoReal,
          icono: Icons.euro,
          color: costoReal > presupuesto ? Colors.red : Colors.green,
          width: double.infinity,
          isWeb: isWeb,
        ),
        SizedBox(height: 6),
        BudgetCardWidget(
          titulo: 'Coste por Alumno',
          valor: costoPorAlumno,
          icono: Icons.person,
          color: AppColors.estadoPendiente,
          width: double.infinity,
          isWeb: isWeb,
        ),
      ],
    );
  }

  /// Layout para móvil en modo portrait (columna vertical con espaciado)
  Widget _buildMobilePortraitLayout() {
    return Column(
      children: [
        BudgetCardWidget(
          titulo: 'Presupuesto Estimado',
          valor: presupuesto,
          icono: Icons.account_balance_wallet,
          color: Colors.blue,
          width: double.infinity,
          isWeb: isWeb,
          showEdit: true,
          isEditing: editandoPresupuesto,
          controller: presupuestoController,
          onEditPressed: onEditPresupuesto,
        ),
        SizedBox(height: 10),
        BudgetCardWidget(
          titulo: 'Coste Real',
          valor: costoReal,
          icono: Icons.euro,
          color: costoReal > presupuesto ? Colors.red : Colors.green,
          width: double.infinity,
          isWeb: isWeb,
        ),
        SizedBox(height: 10),
        BudgetCardWidget(
          titulo: 'Coste por Alumno',
          valor: costoPorAlumno,
          icono: Icons.person,
          color: AppColors.estadoPendiente,
          width: double.infinity,
          isWeb: isWeb,
        ),
      ],
    );
  }

  /// Layout para escritorio (2 tarjetas arriba, 1 abajo centrada)
  Widget _buildDesktopLayout() {
    return Column(
      children: [
        // Fila superior: Presupuesto Estimado y Coste Real
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
                  isEditing: editandoPresupuesto,
                  controller: presupuestoController,
                  onEditPressed: onEditPresupuesto,
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
        SizedBox(height: 16),
        // Fila inferior: Coste por Alumno ocupa todo el ancho
        BudgetCardWidget(
          titulo: 'Coste por Alumno',
          valor: costoPorAlumno,
          icono: Icons.person,
          color: AppColors.estadoPendiente,
          width: double.infinity,
          isWeb: isWeb,
        ),
      ],
    );
  }
}
