class Alojamiento {
  final int id;
  final String nombre;
  final String? direccion;
  final String? ciudad;
  final String? codigoPostal;
  final String? provincia;
  final String? telefono;
  final String? email;
  final String? web;
  final String? tipoAlojamiento;
  final int? numeroHabitaciones;
  final int? capacidadTotal;
  final double? precioPorNoche;
  final String? servicios;
  final String? observaciones;
  final bool activo;
  final DateTime fechaCreacion;
  final double? latitud;
  final double? longitud;

  Alojamiento({
    required this.id,
    required this.nombre,
    this.direccion,
    this.ciudad,
    this.codigoPostal,
    this.provincia,
    this.telefono,
    this.email,
    this.web,
    this.tipoAlojamiento,
    this.numeroHabitaciones,
    this.capacidadTotal,
    this.precioPorNoche,
    this.servicios,
    this.observaciones,
    required this.activo,
    required this.fechaCreacion,
    this.latitud,
    this.longitud,
  });

  factory Alojamiento.fromJson(Map<String, dynamic> json) {
    return Alojamiento(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String?,
      ciudad: json['ciudad'] as String?,
      codigoPostal: json['codigoPostal'] as String?,
      provincia: json['provincia'] as String?,
      telefono: json['telefono'] as String?,
      email: json['email'] as String?,
      web: json['web'] as String?,
      tipoAlojamiento: json['tipoAlojamiento'] as String?,
      numeroHabitaciones: json['numeroHabitaciones'] as int?,
      capacidadTotal: json['capacidadTotal'] as int?,
      precioPorNoche: (json['precioPorNoche'] as num?)?.toDouble(),
      servicios: json['servicios'] as String?,
      observaciones: json['observaciones'] as String?,
      activo: json['activo'] as bool? ?? true,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'ciudad': ciudad,
      'codigoPostal': codigoPostal,
      'provincia': provincia,
      'telefono': telefono,
      'email': email,
      'web': web,
      'tipoAlojamiento': tipoAlojamiento,
      'numeroHabitaciones': numeroHabitaciones,
      'capacidadTotal': capacidadTotal,
      'precioPorNoche': precioPorNoche,
      'servicios': servicios,
      'observaciones': observaciones,
      'activo': activo,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'latitud': latitud,
      'longitud': longitud,
    };
  }

  Alojamiento copyWith({
    int? id,
    String? nombre,
    String? direccion,
    String? ciudad,
    String? codigoPostal,
    String? provincia,
    String? telefono,
    String? email,
    String? web,
    String? tipoAlojamiento,
    int? numeroHabitaciones,
    int? capacidadTotal,
    double? precioPorNoche,
    String? servicios,
    String? observaciones,
    bool? activo,
    DateTime? fechaCreacion,
    double? latitud,
    double? longitud,
  }) {
    return Alojamiento(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      ciudad: ciudad ?? this.ciudad,
      codigoPostal: codigoPostal ?? this.codigoPostal,
      provincia: provincia ?? this.provincia,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      web: web ?? this.web,
      tipoAlojamiento: tipoAlojamiento ?? this.tipoAlojamiento,
      numeroHabitaciones: numeroHabitaciones ?? this.numeroHabitaciones,
      capacidadTotal: capacidadTotal ?? this.capacidadTotal,
      precioPorNoche: precioPorNoche ?? this.precioPorNoche,
      servicios: servicios ?? this.servicios,
      observaciones: observaciones ?? this.observaciones,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
    );
  }

  // Método auxiliar para obtener la dirección completa
  String get direccionCompleta {
    final partes = <String>[];
    if (direccion != null && direccion!.isNotEmpty) partes.add(direccion!);
    if (codigoPostal != null && codigoPostal!.isNotEmpty) partes.add(codigoPostal!);
    if (ciudad != null && ciudad!.isNotEmpty) partes.add(ciudad!);
    if (provincia != null && provincia!.isNotEmpty) partes.add(provincia!);
    return partes.join(', ');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Alojamiento && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
