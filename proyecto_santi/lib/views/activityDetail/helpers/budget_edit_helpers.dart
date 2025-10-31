import 'package:flutter/material.dart';
import '../../../../models/actividad.dart';
import '../../../../models/empresa_transporte.dart';
import '../../../../models/alojamiento.dart';
import '../../../../services/actividad_service.dart';

/// Clase helper para manejar la edición de elementos del presupuesto
class BudgetEditHandlers {
  /// Maneja la edición del presupuesto estimado
  static Future<void> handleEditPresupuesto({
    required BuildContext context,
    required bool editando,
    required TextEditingController controller,
    double? presupuestoActual,
    required Function(bool, double?) onStateChanged,
    required Function(Map<String, dynamic>) onBudgetChanged,
    required bool transporteReq,
    required bool alojamientoReq,
  }) async {
    if (editando) {
      // Guardar cambios
      final textoLimpio = controller.text.replaceAll(',', '.');
      final nuevoPresupuesto = double.tryParse(textoLimpio);
      if (nuevoPresupuesto != null && nuevoPresupuesto >= 0) {
        onStateChanged(false, nuevoPresupuesto);
        
        // Notificar cambio al padre
        onBudgetChanged({
          'presupuestoEstimado': nuevoPresupuesto,
          'transporteReq': transporteReq ? 1 : 0,
          'alojamientoReq': alojamientoReq ? 1 : 0,
        });
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Por favor, introduce un valor válido')),
          );
        }
      }
    } else {
      // Activar modo edición
      controller.text = (presupuestoActual ?? 0.0).toStringAsFixed(2);
      onStateChanged(true, presupuestoActual);
    }
  }

  /// Maneja la edición del precio de transporte
  static Future<void> handleEditTransporte({
    required BuildContext context,
    required bool editando,
    required TextEditingController controller,
    double? precioActual,
    EmpresaTransporte? empresaActual,
    required ActividadService actividadService,
    required Function(bool, double?, EmpresaTransporte?, List<EmpresaTransporte>, bool) onStateChanged,
    required Function(Map<String, dynamic>) onBudgetChanged,
    required bool transporteReq,
    required bool alojamientoReq,
  }) async {
    if (editando) {
      // Guardar cambios
      final textoLimpio = controller.text.replaceAll(',', '.');
      final nuevoPrecio = double.tryParse(textoLimpio);
      if (nuevoPrecio != null && nuevoPrecio >= 0) {
        onStateChanged(false, nuevoPrecio, empresaActual, [], false);
        
        // Notificar cambio al padre
        onBudgetChanged({
          'precioTransporte': nuevoPrecio,
          'empresaTransporteId': empresaActual?.id,
          'transporteReq': transporteReq ? 1 : 0,
          'alojamientoReq': alojamientoReq ? 1 : 0,
        });
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Por favor, introduce un valor válido')),
          );
        }
      }
    } else {
      // Activar modo edición y cargar empresas
      controller.text = (precioActual ?? 0.0).toStringAsFixed(2);
      onStateChanged(true, precioActual, empresaActual, [], true);
      
      // Cargar empresas de transporte
      try {
        final empresas = await actividadService.fetchEmpresasTransporte();
        
        if (empresaActual != null && context.mounted) {
          final empresaEncontrada = empresas.firstWhere(
            (e) => e.id == empresaActual.id,
            orElse: () => empresaActual,
          );
          onStateChanged(true, precioActual, empresaEncontrada, empresas, false);
        } else {
          if (context.mounted) {
            onStateChanged(true, precioActual, empresaActual, empresas, false);
          }
        }
      } catch (e) {
        if (context.mounted) {
          onStateChanged(true, precioActual, empresaActual, [], false);
        }
      }
    }
  }

  /// Maneja la edición del precio de alojamiento
  static Future<void> handleEditAlojamiento({
    required BuildContext context,
    required bool editando,
    required TextEditingController controller,
    double? precioActual,
    Alojamiento? alojamientoActual,
    required ActividadService actividadService,
    required Function(bool, double?, Alojamiento?, List<Alojamiento>, bool) onStateChanged,
    required Function(Map<String, dynamic>) onBudgetChanged,
    required bool transporteReq,
    required bool alojamientoReq,
  }) async {
    if (editando) {
      // Guardar cambios
      final textoLimpio = controller.text.replaceAll(',', '.');
      final nuevoPrecio = double.tryParse(textoLimpio);
      if (nuevoPrecio != null && nuevoPrecio >= 0) {
        onStateChanged(false, nuevoPrecio, alojamientoActual, [], false);
        
        // Notificar cambio al padre
        onBudgetChanged({
          'precioAlojamiento': nuevoPrecio,
          'alojamientoId': alojamientoActual?.id,
          'transporteReq': transporteReq ? 1 : 0,
          'alojamientoReq': alojamientoReq ? 1 : 0,
        });
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Por favor, introduce un valor válido')),
          );
        }
      }
    } else {
      // Activar modo edición y cargar alojamientos
      controller.text = (precioActual ?? 0.0).toStringAsFixed(2);
      onStateChanged(true, precioActual, alojamientoActual, [], true);
      
      // Cargar alojamientos disponibles
      try {
        final alojamientos = await actividadService.fetchAlojamientos();
        
        if (alojamientoActual != null && context.mounted) {
          final alojamientoEncontrado = alojamientos.firstWhere(
            (a) => a.id == alojamientoActual.id,
            orElse: () => alojamientoActual,
          );
          onStateChanged(true, precioActual, alojamientoEncontrado, alojamientos, false);
        } else {
          if (context.mounted) {
            onStateChanged(true, precioActual, alojamientoActual, alojamientos, false);
          }
        }
      } catch (e) {
        if (context.mounted) {
          onStateChanged(true, precioActual, alojamientoActual, [], false);
        }
      }
    }
  }
}
