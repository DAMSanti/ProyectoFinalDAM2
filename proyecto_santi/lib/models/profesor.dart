import 'package:proyecto_santi/models/departamento.dart';

class Profesor {
  final String uuid;
  final String dni;
  final String nombre;
  final String apellidos;
  final String correo;
  final String password;
  final String rol;
  final int activo;
  final String? urlFoto;
  final int esJefeDep;
  final Departamento depart;

  Profesor({
    required this.uuid,
    required this.dni,
    required this.nombre,
    required this.apellidos,
    required this.correo,
    required this.password,
    required this.rol,
    required this.activo,
    this.urlFoto,
    required this.esJefeDep,
    required this.depart,
  });

  factory Profesor.fromJson(Map<String, dynamic> json) {
    return Profesor(
      uuid: json['uuid'],
      dni: json['dni'],
      nombre: json['nombre'],
      apellidos: json['apellidos'],
      correo: json['correo'],
      password: json['password'],
      rol: json['rol'],
      activo: json['activo'],
      urlFoto: json['urlFoto'],
      esJefeDep: json['esJefeDep'],
      depart: Departamento.fromJson(json['depart']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'dni': dni,
      'nombre': nombre,
      'apellidos': apellidos,
      'correo': correo,
      'password': password,
      'rol': rol,
      'activo': activo,
      'urlFoto': urlFoto,
      'esJefeDep': esJefeDep,
      'depart': depart.toJson(),
    };
  }
}
