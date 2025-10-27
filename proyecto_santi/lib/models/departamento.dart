class Departamento {
  final int id;
  final String? codigo;
  final String nombre;
  final String? descripcion;

  Departamento({
    required this.id,
    this.codigo,
    required this.nombre,
    this.descripcion,
  });

  factory Departamento.fromJson(Map<String, dynamic> json) {
    return Departamento(
      id: json['id'] ?? json['Id'],
      codigo: json['codigo'],
      nombre: json['nombre'] ?? json['Nombre'],
      descripcion: json['descripcion'] ?? json['Descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}
