import 'actividad.dart';
import 'package:proyecto_santi/config.dart';

class Photo {
  final int id;
  final String? urlFoto;
  String descripcion;
  final Actividad? actividad;
  final int? actividadId;

  Photo({
    required this.id,
    required this.urlFoto,
    required this.descripcion,
    this.actividad,
    this.actividadId,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    String? photoUrl;
    
    // Manejar tanto 'urlFoto' como 'url'
    final urlField = json['urlFoto'] ?? json['url'];
    
    if (urlField != null) {
      final urlString = urlField as String;
      
      // Si la URL ya es completa (empieza con http), usarla directamente
      if (urlString.startsWith('http://') || urlString.startsWith('https://')) {
        photoUrl = urlString;
      } else {
        // Si es una ruta relativa que empieza con /uploads, usar imagenesBaseUrl
        if (urlString.startsWith('/uploads') || urlString.startsWith('uploads')) {
          // Eliminar la barra inicial y 'uploads/' si existe
          String relativePath = urlString.startsWith('/') ? urlString.substring(1) : urlString;
          if (relativePath.startsWith('uploads/')) {
            relativePath = relativePath.substring(8); // Quitar 'uploads/'
          }
          photoUrl = '${AppConfig.imagenesBaseUrl}/$relativePath';
        } else {
          // Para otras rutas, usar apiBaseUrl
          final relativePath = urlString.startsWith('/') ? urlString.substring(1) : urlString;
          photoUrl = '${AppConfig.apiBaseUrl}/$relativePath';
        }
      }
    }

    // Manejar actividad opcional
    Actividad? actividadObj;
    int? actId;
    
    if (json['actividad'] != null) {
      actividadObj = Actividad.fromJson(json['actividad']);
      actId = actividadObj.id;
    } else if (json['actividadId'] != null) {
      actId = json['actividadId'];
    }

    return Photo(
      id: json['id'],
      urlFoto: photoUrl,
      descripcion: json['descripcion'] ?? '',
      actividad: actividadObj,
      actividadId: actId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'urlFoto': urlFoto,
      'descripcion': descripcion,
      if (actividad != null) 'actividad': actividad!.toJson(),
      if (actividadId != null) 'actividadId': actividadId,
    };
  }
}
