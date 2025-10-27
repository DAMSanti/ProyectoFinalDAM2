import 'package:proyecto_santi/models/Profesor.dart';

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
  final double? importePorAlumno;
  double? latitud;
  double? longitud;

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
    this.importePorAlumno,
    this.latitud,
    this.longitud,
  });

  factory Actividad.fromJson(Map<String, dynamic> json) {
    // Mapear desde la API de C# ACEXAPI
    final now = DateTime.now().toIso8601String();
    
    // Parsear el solicitante si viene en el JSON
    Profesor? solicitante;
    if (json['solicitante'] != null) {
      solicitante = Profesor.fromJson(json['solicitante']);
    }
    
    return Actividad(
      id: json['id'] ?? 0,
      titulo: json['nombre']?.toString() ?? json['titulo']?.toString() ?? 'Sin título',
      tipo: json['tipo']?.toString() ?? 'Actividad',
      descripcion: json['descripcion']?.toString(),
      fini: json['fechaInicio']?.toString() ?? json['fini']?.toString() ?? now,
      ffin: json['fechaFin']?.toString() ?? json['ffin']?.toString() ?? now,
      hini: json['hini']?.toString() ?? '00:00',
      hfin: json['hfin']?.toString() ?? '00:00',
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
      importePorAlumno: (json['presupuestoEstimado'] as num?)?.toDouble() ?? (json['importePorAlumno'] as num?)?.toDouble(),
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'tipo': tipo,
      'descripcion': descripcion,
      'fini': fini,
      'ffin': ffin,
      'hini': hini,
      'hfin': hfin,
      'previstaIni': previstaIni,
      'transporteReq': transporteReq,
      'comentTransporte': comentTransporte,
      'alojamientoReq': alojamientoReq,
      'comentAlojamiento': comentAlojamiento,
      'comentarios': comentarios,
      'estado': estado,
      'comentEstado': comentEstado,
      'incidencias': incidencias,
      'urlFolleto': urlFolleto,
      'solicitante': solicitante?.toJson(),
      'importePorAlumno': importePorAlumno,
      'latitud': latitud,
      'longitud': longitud,
    };
  }
}