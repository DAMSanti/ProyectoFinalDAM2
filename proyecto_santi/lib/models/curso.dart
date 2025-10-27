class Curso {
  final int id;
  final String nombre;
  final String? nivel;
  final bool activo;

  Curso({
    required this.id,
    required this.nombre,
    this.nivel,
    this.activo = true,
  });

  factory Curso.fromJson(Map<String, dynamic> json) {
    return Curso(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      nivel: json['nivel'],
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'nivel': nivel,
      'activo': activo,
    };
  }
}
