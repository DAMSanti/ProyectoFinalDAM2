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
  final Profesor solicitante;
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
    required this.solicitante,
    this.importePorAlumno,
    this.latitud,
    this.longitud,
  });

  factory Actividad.fromJson(Map<String, dynamic> json) {
    return Actividad(
      id: json['id'],
      titulo: json['titulo'],
      tipo: json['tipo'],
      descripcion: json['descripcion'],
      fini: json['fini'],
      ffin: json['ffin'],
      hini: json['hini'],
      hfin: json['hfin'],
      previstaIni: json['previstaIni'],
      transporteReq: json['transporteReq'],
      comentTransporte: json['comentTransporte'],
      alojamientoReq: json['alojamientoReq'],
      comentAlojamiento: json['comentAlojamiento'],
      comentarios: json['comentarios'],
      estado: json['estado'],
      comentEstado: json['comentEstado'],
      incidencias: json['incidencias'],
      urlFolleto: json['urlFolleto'],
      solicitante: Profesor.fromJson(json['solicitante']),
      importePorAlumno: (json['importePorAlumno'] as num?)?.toDouble(),
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
      'solicitante': solicitante.toJson(),
      'importePorAlumno': importePorAlumno,
      'latitud': latitud,
      'longitud': longitud,
    };
  }
}
