class EmpresaTransporte {
  final int id;
  final String nombre;
  final String? cif;
  final String? telefono;
  final String? email;
  final String? direccion;

  EmpresaTransporte({
    required this.id,
    required this.nombre,
    this.cif,
    this.telefono,
    this.email,
    this.direccion,
  });

  factory EmpresaTransporte.fromJson(Map<String, dynamic> json) {
    return EmpresaTransporte(
      id: json['id'] ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      cif: json['cif']?.toString(),
      telefono: json['telefono']?.toString(),
      email: json['email']?.toString(),
      direccion: json['direccion']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'cif': cif,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
    };
  }

  @override
  String toString() {
    return nombre;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmpresaTransporte &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
