import 'package:flutter/material.dart';
import '../../../models/actividad.dart';
import '../../../models/alojamiento.dart';
import '../../../models/empresa_transporte.dart';
import '../../../models/gasto_personalizado.dart';
import '../../../services/gasto_personalizado_service.dart';
import '../../../services/api_service.dart';

/// Servicio para manejar el estado del presupuesto de una actividad
class BudgetStateService {
  // Variables para switches de transporte y alojamiento
  bool transporteReq = false;
  bool alojamientoReq = false;
  
  // Variables para edición de presupuesto
  bool editandoPresupuesto = false;
  final TextEditingController presupuestoController = TextEditingController();
  double? presupuestoEstimadoLocal;
  
  // Variables para edición de transporte
  bool editandoTransporte = false;
  final TextEditingController precioTransporteController = TextEditingController();
  double? precioTransporteLocal;
  EmpresaTransporte? empresaTransporteLocal;
  List<EmpresaTransporte> empresasDisponibles = [];
  bool cargandoEmpresas = false;

  // Variables para edición de alojamiento
  bool editandoAlojamiento = false;
  final TextEditingController precioAlojamientoController = TextEditingController();
  double? precioAlojamientoLocal;
  Alojamiento? alojamientoLocal;
  List<Alojamiento> alojamientosDisponibles = [];
  bool cargandoAlojamientos = false;

  // Variables para gastos personalizados
  List<GastoPersonalizado> gastosPersonalizados = [];
  bool cargandoGastos = false;
  late GastoPersonalizadoService gastoService;

  BudgetStateService() {
    gastoService = GastoPersonalizadoService(ApiService());
  }

  /// Inicializa el estado desde una actividad
  void initializeFromActivity(Actividad actividad) {
    transporteReq = actividad.transporteReq == 1;
    alojamientoReq = actividad.alojamientoReq == 1;
    presupuestoEstimadoLocal = actividad.presupuestoEstimado;
    precioTransporteLocal = actividad.precioTransporte;
    empresaTransporteLocal = actividad.empresaTransporte;
    precioAlojamientoLocal = actividad.precioAlojamiento ?? 0.0;
    alojamientoLocal = actividad.alojamiento;
  }

  /// Carga los gastos personalizados de la actividad
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

  /// Calcula el presupuesto total
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

  /// Calcula el coste por alumno
  double? calcularCostePorAlumno(int totalAlumnos) {
    if (totalAlumnos == 0) return null;
    return calcularPresupuestoTotal() / totalAlumnos;
  }

  /// Limpia los recursos
  void dispose() {
    presupuestoController.dispose();
    precioTransporteController.dispose();
    precioAlojamientoController.dispose();
  }
}
