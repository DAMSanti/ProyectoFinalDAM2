class EmpresaTransporte {
  final int id;
  final String nombre;
  final String cif;
  final String? direccion;
  final String? cp;
  final String? localidad;
  final String? contacto;

  EmpresaTransporte({
    required this.id,
    required this.nombre,
    required this.cif,
    this.direccion,
    this.cp,
    this.localidad,
    this.contacto,
  });

  factory EmpresaTransporte.fromJson(Map<String, dynamic> json) {
    return EmpresaTransporte(
      id: json['id'] ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      cif: json['cif']?.toString() ?? '',
      direccion: json['direccion']?.toString(),
      cp: json['cp']?.toString(),
      localidad: json['localidad']?.toString(),
      contacto: json['contacto']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'cif': cif,
      'direccion': direccion,
      'cp': cp,
      'localidad': localidad,
      'contacto': contacto,
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
