import 'package:flutter/material.dart';
import '../../../../models/actividad.dart';
import '../../../../models/empresa_transporte.dart';
import '../../../../models/alojamiento.dart';
import '../../../../services/actividad_service.dart';
import 'package:proyecto_santi/tema/tema.dart';
class BudgetEditHandlers {
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
      final textoLimpio = controller.text.replaceAll(',', '.');
      final nuevoPresupuesto = double.tryParse(textoLimpio);
      if (nuevoPresupuesto != null && nuevoPresupuesto >= 0) {
        onStateChanged(false, nuevoPresupuesto);
        onBudgetChanged({
          'presupuestoEstimado': nuevoPresupuesto,
          'transporteReq': transporteReq ? 1 : 0,
          'alojamientoReq': alojamientoReq ? 1 : 0,
        });
      } else {
        if (context.mounted) {
          SnackBarHelper.show(context, 'Por favor, introduce un valor válido');
        }
      }
    } else {
      controller.text = (presupuestoActual ?? 0.0).toStringAsFixed(2);
      onStateChanged(true, presupuestoActual);
    }
  }
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
      final textoLimpio = controller.text.replaceAll(',', '.');
      final nuevoPrecio = double.tryParse(textoLimpio);
      if (nuevoPrecio != null && nuevoPrecio >= 0) {
        onStateChanged(false, nuevoPrecio, empresaActual, [], false);
        onBudgetChanged({
          'precioTransporte': nuevoPrecio,
          'empresaTransporteId': empresaActual?.id,
          'transporteReq': transporteReq ? 1 : 0,
          'alojamientoReq': alojamientoReq ? 1 : 0,
        });
      } else {
        if (context.mounted) {
          SnackBarHelper.show(context, 'Por favor, introduce un valor válido');
        }
      }
    } else {
      controller.text = (precioActual ?? 0.0).toStringAsFixed(2);
      onStateChanged(true, precioActual, empresaActual, [], true);
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
      final textoLimpio = controller.text.replaceAll(',', '.');
      final nuevoPrecio = double.tryParse(textoLimpio);
      if (nuevoPrecio != null && nuevoPrecio >= 0) {
        onStateChanged(false, nuevoPrecio, alojamientoActual, [], false);
        onBudgetChanged({
          'precioAlojamiento': nuevoPrecio,
          'alojamientoId': alojamientoActual?.id,
          'transporteReq': transporteReq ? 1 : 0,
          'alojamientoReq': alojamientoReq ? 1 : 0,
        });
      } else {
        if (context.mounted) {
          SnackBarHelper.show(context, 'Por favor, introduce un valor válido');
        }
      }
    } else {
      controller.text = (precioActual ?? 0.0).toStringAsFixed(2);
      onStateChanged(true, precioActual, alojamientoActual, [], true);
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