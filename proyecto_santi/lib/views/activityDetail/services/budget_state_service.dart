import 'package:flutter/material.dart';
import '../../../models/actividad.dart';
import '../../../models/alojamiento.dart';
import '../../../models/empresa_transporte.dart';
import '../../../models/gasto_personalizado.dart';
import '../../../services/gasto_personalizado_service.dart';
import '../../../services/api_service.dart';
class BudgetStateService {
  bool transporteReq = false;
  bool alojamientoReq = false;
  bool editandoPresupuesto = false;
  final TextEditingController presupuestoController = TextEditingController();
  double? presupuestoEstimadoLocal;
  bool editandoTransporte = false;
  final TextEditingController precioTransporteController = TextEditingController();
  double? precioTransporteLocal;
  EmpresaTransporte? empresaTransporteLocal;
  List<EmpresaTransporte> empresasDisponibles = [];
  bool cargandoEmpresas = false;
  bool editandoAlojamiento = false;
  final TextEditingController precioAlojamientoController = TextEditingController();
  double? precioAlojamientoLocal;
  Alojamiento? alojamientoLocal;
  List<Alojamiento> alojamientosDisponibles = [];
  bool cargandoAlojamientos = false;
  List<GastoPersonalizado> gastosPersonalizados = [];
  bool cargandoGastos = false;
  late GastoPersonalizadoService gastoService;
  BudgetStateService() {
    gastoService = GastoPersonalizadoService(ApiService());
  }
  void initializeFromActivity(Actividad actividad) {
    transporteReq = actividad.transporteReq == 1;
    alojamientoReq = actividad.alojamientoReq == 1;
    presupuestoEstimadoLocal = actividad.presupuestoEstimado;
    precioTransporteLocal = actividad.precioTransporte;
    empresaTransporteLocal = actividad.empresaTransporte;
    precioAlojamientoLocal = actividad.precioAlojamiento ?? 0.0;
    alojamientoLocal = actividad.alojamiento;
  }
  Future<void> cargarGastos(int? actividadId, VoidCallback onUpdate) async {
    if (actividadId == null) return;
    cargandoGastos = true;
    onUpdate();
    try {
      gastosPersonalizados = await gastoService.fetchGastosByActividad(actividadId);
    } catch (e) {
      print('Error al cargar gastos personalizados: $e');
      gastosPersonalizados = [];
    } finally {
      cargandoGastos = false;
      onUpdate();
    }
  }
  double calcularPresupuestoTotal() {
    double total = presupuestoEstimadoLocal ?? 0.0;
    if (transporteReq && precioTransporteLocal != null) {
      total += precioTransporteLocal!;
    }
    if (alojamientoReq && precioAlojamientoLocal != null) {
      total += precioAlojamientoLocal!;
    }
    for (var gasto in gastosPersonalizados) {
      total += gasto.cantidad;
    }
    return total;
  }
  double? calcularCostePorAlumno(int totalAlumnos) {
    if (totalAlumnos == 0) return null;
    return calcularPresupuestoTotal() / totalAlumnos;
  }
  void dispose() {
    presupuestoController.dispose();
    precioTransporteController.dispose();
    precioAlojamientoController.dispose();
  }
}