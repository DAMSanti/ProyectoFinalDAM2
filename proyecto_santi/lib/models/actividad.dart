import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/models/localizacion.dart';
import 'package:proyecto_santi/models/alojamiento.dart';
import 'package:proyecto_santi/models/empresa_transporte.dart';
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
  final double? precioTransporte;
  final EmpresaTransporte? empresaTransporte;
  final int alojamientoReq;
  final String? comentAlojamiento;
  final double? precioAlojamiento;
  final Alojamiento? alojamiento;
  final String? comentarios;
  final String estado;
  final String? comentEstado;
  final String? incidencias;
  final String? urlFolleto;
  final Profesor? solicitante;
  final Profesor? responsable;
  final Localizacion? localizacion;
  final List<Localizacion> localizaciones;
  final double? importePorAlumno;
  final double? presupuestoEstimado;
  final double? costoReal;
  final List<String> profesoresParticipantesIds;
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
    this.precioTransporte,
    this.empresaTransporte,
    required this.alojamientoReq,
    this.comentAlojamiento,
    this.precioAlojamiento,
    this.alojamiento,
    this.comentarios,
    required this.estado,
    this.comentEstado,
    this.incidencias,
    this.urlFolleto,
    this.solicitante,
    this.responsable,
    this.localizacion,
    this.localizaciones = const [],
    this.importePorAlumno,
    this.presupuestoEstimado,
    this.costoReal,
    this.profesoresParticipantesIds = const [],
  });
  factory Actividad.fromJson(Map<String, dynamic> json) {
    Profesor? solicitante;
    if (json['solicitante'] != null) {
      solicitante = Profesor.fromJson(json['solicitante']);
    }
    Profesor? responsable;
    if (json['responsable'] != null) {
      responsable = Profesor.fromJson(json['responsable']);
    }
    Alojamiento? alojamiento;
    if (json['alojamiento'] != null && json['alojamiento'] is Map) {
      alojamiento = Alojamiento.fromJson(json['alojamiento']);
    }
    Localizacion? localizacion;
    if (json['localizacion'] != null && json['localizacion'] is Map) {
      localizacion = Localizacion.fromJson(json['localizacion']);
    }
    List<Localizacion> localizaciones = [];
    if (json['localizaciones'] != null && json['localizaciones'] is List) {
      localizaciones = (json['localizaciones'] as List)
          .map((loc) => Localizacion.fromJson(loc))
          .toList();
    }
    EmpresaTransporte? empresaTransporte;
    if (json['empresaTransporte'] != null && json['empresaTransporte'] is Map) {
      empresaTransporte = EmpresaTransporte.fromJson(json['empresaTransporte']);
    } else if (json['empTransporteId'] != null && json['empTransporteNombre'] != null) {
      empresaTransporte = EmpresaTransporte(
        id: json['empTransporteId'] as int,
        nombre: json['empTransporteNombre'] as String,
        cif: '', 
      );
    }
    DateTime? fechaInicio;
    DateTime? fechaFin;
    if (json['fechaInicio'] != null) {
      fechaInicio = DateTime.parse(json['fechaInicio'].toString());
    } else if (json['fini'] != null) {
      fechaInicio = DateTime.parse(json['fini'].toString());
    }
    if (json['fechaFin'] != null) {
      try {
        fechaFin = DateTime.parse(json['fechaFin'].toString());
      } catch (e) {
      }
    } else if (json['ffin'] != null) {
      try {
        fechaFin = DateTime.parse(json['ffin'].toString());
      } catch (e) {
      }
    }
    if (fechaInicio == null) {
      fechaInicio = DateTime.now();
    }
    if (fechaFin == null) {
      fechaFin = fechaInicio; 
    }
    final fechaInicioStr = '${fechaInicio.year.toString().padLeft(4, '0')}-'
        '${fechaInicio.month.toString().padLeft(2, '0')}-'
        '${fechaInicio.day.toString().padLeft(2, '0')}T00:00:00';
    final fechaFinStr = '${fechaFin.year.toString().padLeft(4, '0')}-'
        '${fechaFin.month.toString().padLeft(2, '0')}-'
        '${fechaFin.day.toString().padLeft(2, '0')}T00:00:00';
    String horaInicio = json['hini']?.toString() ?? 
        '${fechaInicio.hour.toString().padLeft(2, '0')}:${fechaInicio.minute.toString().padLeft(2, '0')}';
    String horaFin = json['hfin']?.toString() ?? 
        '${fechaFin.hour.toString().padLeft(2, '0')}:${fechaFin.minute.toString().padLeft(2, '0')}';
    return Actividad(
      id: json['id'] ?? 0,
      titulo: json['nombre']?.toString() ?? json['titulo']?.toString() ?? 'Sin título',
      tipo: json['tipo']?.toString() ?? 'Complementaria',
      descripcion: json['descripcion']?.toString(),
      fini: fechaInicioStr,
      ffin: fechaFinStr,
      hini: horaInicio,
      hfin: horaFin,
      previstaIni: json['previstaIni'] as int? ?? 0,
      transporteReq: json['transporteReq'] as int? ?? 0,
      comentTransporte: json['comentTransporte']?.toString(),
      precioTransporte: (json['precioTransporte'] as num?)?.toDouble(),
      empresaTransporte: empresaTransporte,
      alojamientoReq: json['alojamientoReq'] as int? ?? 0,
      comentAlojamiento: json['comentAlojamiento']?.toString(),
      precioAlojamiento: (json['precioAlojamiento'] as num?)?.toDouble(),
      alojamiento: alojamiento, 
      comentarios: json['comentarios']?.toString(),
      estado: json['estado']?.toString() ?? 'Pendiente',
      comentEstado: json['comentEstado']?.toString(),
      incidencias: json['incidencias']?.toString(),
      urlFolleto: json['folletoUrl']?.toString() ?? json['urlFolleto']?.toString(),
      solicitante: solicitante,
      responsable: responsable,
      localizacion: localizacion,
      localizaciones: localizaciones,
      importePorAlumno: (json['presupuestoEstimado'] as num?)?.toDouble() ?? (json['importePorAlumno'] as num?)?.toDouble(),
      presupuestoEstimado: (json['presupuestoEstimado'] as num?)?.toDouble(),
      costoReal: (json['costoReal'] as num?)?.toDouble(),
      profesoresParticipantesIds: json['profesoresParticipantesIds'] != null
          ? List<String>.from(json['profesoresParticipantesIds'].map((x) => x.toString()))
          : [],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': titulo, 
      'tipo': tipo,
      'descripcion': descripcion,
      'fechaInicio': fini, 
      'fechaFin': ffin, 
      'hini': hini,
      'hfin': hfin,
      'previstaIni': previstaIni,
      'transporteReq': transporteReq,
      'comentTransporte': comentTransporte,
      'precioTransporte': precioTransporte,
      'empresaTransporteId': empresaTransporte?.id, 
      'alojamientoReq': alojamientoReq,
      'comentAlojamiento': comentAlojamiento,
      'precioAlojamiento': precioAlojamiento,
      'alojamientoId': alojamiento?.id, 
      'comentarios': comentarios,
      'estado': estado, 
      'comentEstado': comentEstado,
      'incidencias': incidencias,
      'folletoUrl': urlFolleto, 
      'responsableId': responsable?.uuid, 
      'solicitanteId': solicitante?.uuid, 
      'localizacionId': localizacion?.id, 
      'presupuestoEstimado': presupuestoEstimado ?? importePorAlumno,
      'costoReal': costoReal,
    };
  }
}