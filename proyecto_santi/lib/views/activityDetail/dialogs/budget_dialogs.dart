import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/gasto_personalizado.dart';
import 'add_custom_expense_dialog.dart' as add_expense;
import 'delete_custom_expense_dialog.dart' as delete_expense;
import 'budget_request_dialogs.dart' as budget_requests;
class BudgetDialogs {
  static Future<Map<String, dynamic>?> mostrarDialogoAgregarGasto(
    BuildContext context,
  ) => add_expense.mostrarDialogoAgregarGasto(context);
  static Future<bool> confirmarEliminarGasto(
    BuildContext context,
    GastoPersonalizado gasto,
  ) => delete_expense.confirmarEliminarGasto(context, gasto);
  static void mostrarDialogoSolicitarPresupuestosTransporte(BuildContext context) =>
      budget_requests.mostrarDialogoSolicitarPresupuestosTransporte(context);
  static void mostrarDialogoSolicitarPresupuestosAlojamiento(BuildContext context) =>
      budget_requests.mostrarDialogoSolicitarPresupuestosAlojamiento(context);
}