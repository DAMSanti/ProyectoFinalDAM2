import 'package:proyecto_santi/models/curso.dart';

class Grupo {
  final int id;
  final String nombre;
  final int numeroAlumnos;
  final int cursoId;
  final Curso? curso;

  Grupo({
    required this.id,
    required this.nombre,
    required this.numeroAlumnos,
    required this.cursoId,
    this.curso,
  });

  factory Grupo.fromJson(Map<String, dynamic> json) {
    return Grupo(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      numeroAlumnos: json['numeroAlumnos'] ?? 0,
      cursoId: json['cursoId'],
      curso: json['curso'] != null ? Curso.fromJson(json['curso']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'numeroAlumnos': numeroAlumnos,
      'cursoId': cursoId,
      'curso': curso?.toJson(),
    };
  }
}
