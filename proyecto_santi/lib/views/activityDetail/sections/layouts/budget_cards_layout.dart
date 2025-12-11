import 'package:flutter/material.dart';
import '../../widgets/budget/budget_card.dart';
import 'package:proyecto_santi/tema/app_colors.dart';
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
    Key? key,
    required this.isMobile,
    required this.isMobileLandscape,
    required this.isWeb,
    required this.presupuesto,
    required this.costoReal,
    required this.costoPorAlumno,
    required this.editandoPresupuesto,
    required this.presupuestoController,
    required this.onEditPresupuesto,
  }) : super(key: key);
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
  Widget _buildDesktopLayout() {
    return Column(
      children: [
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