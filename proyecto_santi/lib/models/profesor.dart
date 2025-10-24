class Profesor {
  final String uuid;
  final String dni;
  final String nombre;
  final String apellidos;
  final String correo;
  final String? telefono;
  final String? fotoUrl;
  final bool activo;
  final int? departamentoId;
  final String? departamentoNombre;

  Profesor({
    required this.uuid,
    required this.dni,
    required this.nombre,
    required this.apellidos,
    required this.correo,
    this.telefono,
    this.fotoUrl,
    required this.activo,
    this.departamentoId,
    this.departamentoNombre,
  });

  factory Profesor.fromJson(Map<String, dynamic> json) {
    return Profesor(
      uuid: json['uuid'],
      dni: json['dni'] ?? '',
      nombre: json['nombre'] ?? '',
      apellidos: json['apellidos'] ?? '',
      correo: json['correo'] ?? '',
      telefono: json['telefono'],
      fotoUrl: json['fotoUrl'],
      activo: json['activo'] ?? false,
      departamentoId: json['departamentoId'],
      departamentoNombre: json['departamentoNombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'dni': dni,
      'nombre': nombre,
      'apellidos': apellidos,
      'correo': correo,
      'telefono': telefono,
      'fotoUrl': fotoUrl,
      'activo': activo,
      'departamentoId': departamentoId,
      'departamentoNombre': departamentoNombre,
    };
  }
}
