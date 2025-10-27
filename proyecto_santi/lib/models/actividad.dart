import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/models/departamento.dart';
import 'package:proyecto_santi/models/localizacion.dart';

class Actividad {
  final int id;
  String titulo;
  final String tipo;
  String? descripcion;
  final String fini;
  final String ffin;
  final String hini;
  final String hfin;
  final int previstaIni;
  final int transporteReq;
  final String? comentTransporte;
  final int alojamientoReq;
  final String? comentAlojamiento;
  final String? comentarios;
  final String estado;
  final String? comentEstado;
  final String? incidencias;
  final String? urlFolleto;
  final Profesor? solicitante;
  final Departamento? departamento;
  final Localizacion? localizacion; // Mantener por compatibilidad con LocalizacionId en BD
  final List<Localizacion> localizaciones; // Nueva lista para múltiples localizaciones
  final double? importePorAlumno;
  final double? presupuestoEstimado;
  final double? costoReal;

  Actividad({
    required this.id,
    required this.titulo,
    required this.tipo,
    this.descripcion,
    required this.fini,
    required this.ffin,
    required this.hini,
    required this.hfin,
    required this.previstaIni,
    required this.transporteReq,
    this.comentTransporte,
    required this.alojamientoReq,
    this.comentAlojamiento,
    this.comentarios,
    required this.estado,
    this.comentEstado,
    this.incidencias,
    this.urlFolleto,
    this.solicitante,
    this.departamento,
    this.localizacion,
    this.localizaciones = const [], // Lista vacía por defecto
    this.importePorAlumno,
    this.presupuestoEstimado,
    this.costoReal,
  });

  factory Actividad.fromJson(Map<String, dynamic> json) {
    // Mapear desde la API de C# ACEXAPI
    final now = DateTime.now().toIso8601String();
    
    // Parsear el solicitante si viene en el JSON
    Profesor? solicitante;
    if (json['solicitante'] != null) {
      solicitante = Profesor.fromJson(json['solicitante']);
    }
    
    // Parsear el departamento - la API puede devolver el objeto completo o solo el nombre
    Departamento? departamento;
    if (json['departamento'] != null && json['departamento'] is Map) {
      // Viene el objeto completo desde la API antigua
      departamento = Departamento.fromJson(json['departamento']);
    } else if (json['departamentoId'] != null && json['departamentoNombre'] != null) {
      // Desde ACEXAPI - viene separado
      departamento = Departamento(
        id: json['departamentoId'],
        codigo: '', // No tenemos el código en el DTO
        nombre: json['departamentoNombre'],
      );
    }
    
    // Parsear la localización si viene en el JSON
    Localizacion? localizacion;
    if (json['localizacion'] != null && json['localizacion'] is Map) {
      localizacion = Localizacion.fromJson(json['localizacion']);
    }
    
    // Parsear la lista de localizaciones si viene en el JSON
    List<Localizacion> localizaciones = [];
    if (json['localizaciones'] != null && json['localizaciones'] is List) {
      localizaciones = (json['localizaciones'] as List)
          .map((loc) => Localizacion.fromJson(loc))
          .toList();
    }
    
    // Parsear fechas de inicio y fin
    final fechaInicioStr = json['fechaInicio']?.toString() ?? json['fini']?.toString() ?? now;
    final fechaFinStr = json['fechaFin']?.toString() ?? json['ffin']?.toString() ?? now;
    
    // Extraer horas de las fechas si no vienen por separado
    String horaInicio = json['hini']?.toString() ?? '00:00';
    String horaFin = json['hfin']?.toString() ?? '00:00';
    
    // Si hini/hfin son "00:00", intentar extraer de fechaInicio/fechaFin
    if (horaInicio == '00:00' && fechaInicioStr != now) {
      try {
        final dt = DateTime.parse(fechaInicioStr);
        horaInicio = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        // Si falla el parseo, mantener 00:00
      }
    }
    
    if (horaFin == '00:00' && fechaFinStr != now) {
      try {
        final dt = DateTime.parse(fechaFinStr);
        horaFin = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        // Si falla el parseo, mantener 00:00
      }
    }
    
    return Actividad(
      id: json['id'] ?? 0,
      titulo: json['nombre']?.toString() ?? json['titulo']?.toString() ?? 'Sin título',
      tipo: json['tipo']?.toString() ?? 'Actividad',
      descripcion: json['descripcion']?.toString(),
      fini: fechaInicioStr,
      ffin: fechaFinStr,
      hini: horaInicio,
      hfin: horaFin,
      previstaIni: json['previstaIni'] as int? ?? 0,
      transporteReq: json['transporteReq'] as int? ?? 0,
      comentTransporte: json['comentTransporte']?.toString(),
      alojamientoReq: json['alojamientoReq'] as int? ?? 0,
      comentAlojamiento: json['comentAlojamiento']?.toString(),
      comentarios: json['comentarios']?.toString(),
      estado: (json['aprobada'] == true) ? 'Aprobada' : (json['estado']?.toString() ?? 'Pendiente'),
      comentEstado: json['comentEstado']?.toString(),
      incidencias: json['incidencias']?.toString(),
      urlFolleto: json['folletoUrl']?.toString() ?? json['urlFolleto']?.toString(),
      solicitante: solicitante,
      departamento: departamento,
      localizacion: localizacion,
      localizaciones: localizaciones,
      importePorAlumno: (json['presupuestoEstimado'] as num?)?.toDouble() ?? (json['importePorAlumno'] as num?)?.toDouble(),
      presupuestoEstimado: (json['presupuestoEstimado'] as num?)?.toDouble(),
      costoReal: (json['costoReal'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': titulo, // La API espera 'nombre', no 'titulo'
      'tipo': tipo,
      'descripcion': descripcion,
      'fechaInicio': fini, // La API espera 'fechaInicio'
      'fechaFin': ffin, // La API espera 'fechaFin'
      'hini': hini,
      'hfin': hfin,
      'previstaIni': previstaIni,
      'transporteReq': transporteReq,
      'comentTransporte': comentTransporte,
      'alojamientoReq': alojamientoReq,
      'comentAlojamiento': comentAlojamiento,
      'comentarios': comentarios,
      'aprobada': estado == 'Aprobada', // La API espera 'aprobada' como bool
      'comentEstado': comentEstado,
      'incidencias': incidencias,
      'folletoUrl': urlFolleto, // La API espera 'folletoUrl'
      'solicitanteId': solicitante?.uuid, // Enviar solo el ID
      'departamentoId': departamento?.id, // Enviar solo el ID
      'localizacionId': localizacion?.id, // Enviar solo el ID
      'presupuestoEstimado': presupuestoEstimado ?? importePorAlumno,
      'costoReal': costoReal,
    };
  }
}