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
    final baseUrl = 'http://4.233.223.75:8080/imagenes/actividad/';
    final imageName = json['urlFoto'].substring(json['urlFoto'].lastIndexOf("\\") + 1).replaceAll(" ", "_");
    final activityId = json['actividad']['id'];

    return Photo(
      id: json['id'],
      urlFoto: '$baseUrl$activityId/$imageName',
      descripcion: json['descripcion'],
      actividad: Actividad.fromJson(json['actividad']),
    );
  }
// $baseUrl${json['activityId']}/$imageNameAfterLastSlash
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'urlFoto': urlFoto,
      'descripcion': descripcion,
      'actividad': actividad.toJson(),
    };
  }
}
