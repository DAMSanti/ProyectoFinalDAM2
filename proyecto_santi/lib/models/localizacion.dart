class Localizacion {
  final int id;
  final String nombre;
  final String? direccion;
  final String? ciudad;
  final String? provincia;
  final String? codigoPostal;
  final double? latitud;
  final double? longitud;
  final bool esPrincipal;
  final String? icono; // Nombre del icono de Material Icons

  Localizacion({
    required this.id,
    required this.nombre,
    this.direccion,
    this.ciudad,
    this.provincia,
    this.codigoPostal,
    this.latitud,
    this.longitud,
    this.esPrincipal = false,
    this.icono,
  });

  factory Localizacion.fromJson(Map<String, dynamic> json) {
    return Localizacion(
      id: json['id'] as int,
      nombre: json['nombre']?.toString() ?? '',
      direccion: json['direccion']?.toString(),
      ciudad: json['ciudad']?.toString(),
      provincia: json['provincia']?.toString(),
      codigoPostal: json['codigoPostal']?.toString(),
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
      esPrincipal: json['esPrincipal'] as bool? ?? false,
      icono: json['icono']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'ciudad': ciudad,
      'provincia': provincia,
      'codigoPostal': codigoPostal,
      'latitud': latitud,
      'longitud': longitud,
      'esPrincipal': esPrincipal,
      'icono': icono,
    };
  }

  String get direccionCompleta {
    final partes = <String>[];
    if (direccion != null && direccion!.isNotEmpty) partes.add(direccion!);
    if (ciudad != null && ciudad!.isNotEmpty) partes.add(ciudad!);
    if (provincia != null && provincia!.isNotEmpty) partes.add(provincia!);
    if (codigoPostal != null && codigoPostal!.isNotEmpty) partes.add(codigoPostal!);
    return partes.join(', ');
  }
}
