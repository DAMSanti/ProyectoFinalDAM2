import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/gasto_personalizado.dart';

// Importar funciones de diálogos individuales
import 'add_custom_expense_dialog.dart' as add_expense;
import 'delete_custom_expense_dialog.dart' as delete_expense;
import 'budget_request_dialogs.dart' as budget_requests;

/// Helpers para mostrar diálogos de presupuesto
/// 
/// Este archivo agrupa las funciones de diálogos individuales
/// para mantener la compatibilidad con el código existente.
class BudgetDialogs {
  /// Muestra diálogo para agregar un nuevo gasto personalizado
  static Future<Map<String, dynamic>?> mostrarDialogoAgregarGasto(
    BuildContext context,
  ) => add_expense.mostrarDialogoAgregarGasto(context);

  /// Confirma eliminación de un gasto
  static Future<bool> confirmarEliminarGasto(
    BuildContext context,
    GastoPersonalizado gasto,
  ) => delete_expense.confirmarEliminarGasto(context, gasto);

  /// Muestra diálogo informativo sobre solicitud de presupuesto de transporte
  static void mostrarDialogoSolicitarPresupuestosTransporte(BuildContext context) =>
      budget_requests.mostrarDialogoSolicitarPresupuestosTransporte(context);

  /// Muestra diálogo informativo sobre solicitud de presupuesto de alojamiento
  static void mostrarDialogoSolicitarPresupuestosAlojamiento(BuildContext context) =>
      budget_requests.mostrarDialogoSolicitarPresupuestosAlojamiento(context);
}
