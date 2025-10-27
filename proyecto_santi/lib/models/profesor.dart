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
  final Departamento? depart;

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
    this.depart,
  });

  factory Profesor.fromJson(Map<String, dynamic> json) {
    // Soportar tanto el formato antiguo como el nuevo (ProfesorSimpleDto de la API)
    
    // Si viene el formato simple de la API (ProfesorSimpleDto)
    if (json.containsKey('email') && !json.containsKey('correo')) {
      return Profesor(
        uuid: json['id']?.toString() ?? '',
        dni: '',
        nombre: json['nombre'] ?? '',
        apellidos: json['apellidos'] ?? '',
        correo: json['email'] ?? '',
        password: '',
        rol: 'Profesor',
        activo: 1,
        urlFoto: json['fotoUrl'],
        esJefeDep: 0,
        depart: null,
      );
    }
    
    // Formato completo original
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
      depart: json['depart'] != null ? Departamento.fromJson(json['depart']) : null,
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
      'depart': depart?.toJson(),
    };
  }
}
