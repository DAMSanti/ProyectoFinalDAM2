/// Modelo para gastos personalizados de una actividad
class GastoPersonalizado {
  final int? id;
  final int actividadId;
  final String concepto;
  final double cantidad;
  final DateTime? fechaCreacion;

  GastoPersonalizado({
    this.id,
    required this.actividadId,
    required this.concepto,
    required this.cantidad,
    this.fechaCreacion,
  });

  /// Crea una instancia desde JSON
  factory GastoPersonalizado.fromJson(Map<String, dynamic> json) {
    return GastoPersonalizado(
      id: json['id'] as int?,
      actividadId: json['actividadId'] as int,
      concepto: json['concepto'] as String,
      cantidad: (json['cantidad'] as num).toDouble(),
      fechaCreacion: json['fechaCreacion'] != null 
          ? DateTime.parse(json['fechaCreacion'] as String)
          : null,
    );
  }

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'actividadId': actividadId,
      'concepto': concepto,
      'cantidad': cantidad,
      if (fechaCreacion != null) 'fechaCreacion': fechaCreacion!.toIso8601String(),
    };
  }

  /// Crea una copia con campos actualizados
  GastoPersonalizado copyWith({
    int? id,
    int? actividadId,
    String? concepto,
    double? cantidad,
    DateTime? fechaCreacion,
  }) {
    return GastoPersonalizado(
      id: id ?? this.id,
      actividadId: actividadId ?? this.actividadId,
      concepto: concepto ?? this.concepto,
      cantidad: cantidad ?? this.cantidad,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}
