/// Modelo de Usuario para la gestión de usuarios del sistema
class Usuario {
  final String id;
  final String nombreUsuario;
  final String email;
  final String rol;
  final bool activo;
  final DateTime? fechaCreacion;
  final DateTime? ultimoAcceso;

  Usuario({
    required this.id,
    required this.nombreUsuario,
    required this.email,
    required this.rol,
    this.activo = true,
    this.fechaCreacion,
    this.ultimoAcceso,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id']?.toString() ?? '',
      nombreUsuario: json['nombreUsuario']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      rol: json['rol']?.toString() ?? 'Usuario',
      activo: json['activo'] == true || json['activo'] == 1,
      fechaCreacion: json['fechaCreacion'] != null 
          ? DateTime.tryParse(json['fechaCreacion'].toString())
          : null,
      ultimoAcceso: json['ultimoAcceso'] != null
          ? DateTime.tryParse(json['ultimoAcceso'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreUsuario': nombreUsuario,
      'email': email,
      'rol': rol,
      'activo': activo,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
      'ultimoAcceso': ultimoAcceso?.toIso8601String(),
    };
  }

  Usuario copyWith({
    String? id,
    String? nombreUsuario,
    String? email,
    String? rol,
    bool? activo,
    DateTime? fechaCreacion,
    DateTime? ultimoAcceso,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      ultimoAcceso: ultimoAcceso ?? this.ultimoAcceso,
    );
  }

  @override
  String toString() {
    return 'Usuario(id: $id, nombreUsuario: $nombreUsuario, email: $email, rol: $rol, activo: $activo)';
  }
}
