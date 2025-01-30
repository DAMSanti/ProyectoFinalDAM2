class Departamento {
  final int id;
  final String codigo;
  final String nombre;

  Departamento({
    required this.id,
    required this.codigo,
    required this.nombre,
  });

  factory Departamento.fromJson(Map<String, dynamic> json) {
    return Departamento(
      id: json['id'],
      codigo: json['codigo'],
      nombre: json['nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
    };
  }
}
