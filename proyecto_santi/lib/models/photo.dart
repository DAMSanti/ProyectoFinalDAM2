import 'actividad.dart';

class Photo {
  final int id;
  final String? urlFoto;
  String descripcion;
  final Actividad actividad;

  Photo({
    required this.id,
    required this.urlFoto,
    required this.descripcion,
    required this.actividad,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      urlFoto: json['urlFoto'],
      descripcion: json['descripcion'],
      actividad: Actividad.fromJson(json['actividad']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'urlFoto': urlFoto,
      'descripcion': descripcion,
      'actividad': actividad.toJson(),
    };
  }
}
