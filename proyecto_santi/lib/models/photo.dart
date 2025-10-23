import 'actividad.dart';
import 'package:proyecto_santi/config.dart';

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
    String? photoUrl;
    
    if (json['urlFoto'] != null) {
      // Extrae el nombre del archivo desde la ruta del sistema
      final urlFotoOriginal = json['urlFoto'] as String;
      final imageName = urlFotoOriginal
          .substring(urlFotoOriginal.lastIndexOf("\\") + 1)
          .replaceAll(" ", "_");
      final activityId = json['actividad']['id'];

      // Construye la URL completa
      photoUrl = '${AppConfig.imagenesBaseUrl}/actividad/$activityId/$imageName';
    }

    return Photo(
      id: json['id'],
      urlFoto: photoUrl,
      descripcion: json['descripcion'] ?? '',
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
