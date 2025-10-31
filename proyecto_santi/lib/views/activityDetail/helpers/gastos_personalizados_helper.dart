import 'package:flutter/material.dart';
import '../../../models/gasto_personalizado.dart';
import '../services/budget_state_service.dart';

/// Helper para gestionar gastos personalizados
class GastosPersonalizadosHelper {
  /// Muestra diálogo para agregar un gasto personalizado
  static Future<void> mostrarDialogoAgregarGasto(
    BuildContext context,
    Function(String, double) onAgregar,
  ) async {
    final conceptoController = TextEditingController();
    final cantidadController = TextEditingController();
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Gasto Personalizado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: conceptoController,
                decoration: InputDecoration(
                  labelText: 'Concepto',
                  hintText: 'Ej: Material didáctico',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: cantidadController,
                decoration: InputDecoration(
                  labelText: 'Cantidad (€)',
                  hintText: 'Ej: 50.00',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Agregar'),
              onPressed: () {
                final concepto = conceptoController.text.trim();
                final cantidadStr = cantidadController.text.trim();
                
                if (concepto.isEmpty || cantidadStr.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor completa todos los campos')),
                  );
                  return;
                }
                
                final cantidad = double.tryParse(cantidadStr);
                if (cantidad == null || cantidad <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('La cantidad debe ser un número válido mayor a 0')),
                  );
                  return;
                }
                
                Navigator.of(context).pop();
                onAgregar(concepto, cantidad);
              },
            ),
          ],
        );
      },
    );
  }

  /// Agrega un gasto personalizado
  static Future<void> agregarGasto(
    BuildContext context,
    BudgetStateService budgetState,
    int actividadId,
    String concepto,
    double cantidad,
    VoidCallback onUpdate,
  ) async {
    try {
      final nuevoGasto = GastoPersonalizado(
        id: 0,
        actividadId: actividadId,
        concepto: concepto,
        cantidad: cantidad,
      );

      final gastoCreado = await budgetState.gastoService.createGasto(nuevoGasto);
      if (gastoCreado != null) {
        budgetState.gastosPersonalizados.add(gastoCreado);
        onUpdate();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gasto agregado correctamente')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar gasto: $e')),
        );
      }
    }
  }

  /// Elimina un gasto personalizado
  static Future<void> eliminarGasto(
    BuildContext context,
    BudgetStateService budgetState,
    GastoPersonalizado gasto,
    VoidCallback onUpdate,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar este gasto?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Eliminar'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      if (gasto.id != null) {
        await budgetState.gastoService.deleteGasto(gasto.id!);
      }
      budgetState.gastosPersonalizados.remove(gasto);
      onUpdate();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gasto eliminado correctamente')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar gasto: $e')),
        );
      }
    }
  }

  /// Muestra diálogo para solicitar presupuestos de transporte
  static void mostrarDialogoSolicitarPresupuestosTransporte(BuildContext context) {
    // TODO: Implementar lógica de solicitud de presupuestos
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Funcionalidad en desarrollo')),
    );
  }

  /// Muestra diálogo para solicitar presupuestos de alojamiento
  static void mostrarDialogoSolicitarPresupuestosAlojamiento(BuildContext context) {
    // TODO: Implementar lógica de solicitud de presupuestos
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Funcionalidad en desarrollo')),
    );
  }
}
