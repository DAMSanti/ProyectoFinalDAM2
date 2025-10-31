import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/gasto_personalizado.dart';

/// Helpers para mostrar diálogos de presupuesto

class BudgetDialogs {
  /// Muestra diálogo para agregar un nuevo gasto personalizado
  static Future<Map<String, dynamic>?> mostrarDialogoAgregarGasto(
    BuildContext context,
  ) async {
    final conceptoController = TextEditingController();
    final cantidadController = TextEditingController();
    
    final result = await showDialog<bool>(
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
                  hintText: 'Ej: Material didáctico, entradas...',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              SizedBox(height: 16),
              TextField(
                controller: cantidadController,
                decoration: InputDecoration(
                  labelText: 'Cantidad (€)',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                  prefixText: '€ ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final concepto = conceptoController.text.trim();
                final cantidadStr = cantidadController.text.trim();
                
                if (concepto.isEmpty || cantidadStr.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor completa todos los campos')),
                  );
                  return;
                }
                
                // Reemplazar coma por punto para asegurar parseo correcto
                final textoLimpio = cantidadStr.replaceAll(',', '.');
                final cantidad = double.tryParse(textoLimpio);
                if (cantidad == null || cantidad <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ingresa una cantidad válida')),
                  );
                  return;
                }
                
                Navigator.of(context).pop(true);
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
    
    if (result == true) {
      final concepto = conceptoController.text.trim();
      final cantidadStr = cantidadController.text.trim().replaceAll(',', '.');
      final cantidad = double.tryParse(cantidadStr);
      
      return {
        'concepto': concepto,
        'cantidad': cantidad,
      };
    }
    
    return null;
  }

  /// Confirma eliminación de un gasto
  static Future<bool> confirmarEliminarGasto(
    BuildContext context,
    GastoPersonalizado gasto,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text('¿Seguro que deseas eliminar el gasto "${gasto.concepto}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
    
    return result ?? false;
  }

  /// Muestra diálogo informativo sobre solicitud de presupuesto de transporte
  static void mostrarDialogoSolicitarPresupuestosTransporte(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Solicitar Presupuestos de Transporte'),
        content: Text(
          'Esta funcionalidad enviará solicitudes de presupuesto a las empresas de transporte configuradas.\n\n'
          'Próximamente disponible.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// Muestra diálogo informativo sobre solicitud de presupuesto de alojamiento
  static void mostrarDialogoSolicitarPresupuestosAlojamiento(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Solicitar Presupuestos de Alojamiento'),
        content: Text(
          'Esta funcionalidad enviará solicitudes de presupuesto a los alojamientos configurados.\n\n'
          'Próximamente disponible.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
