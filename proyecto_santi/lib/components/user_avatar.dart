import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/config.dart';

/// Widget de avatar de usuario que muestra la foto o las iniciales
class UserAvatar extends StatelessWidget {
  final Profesor? user;
  final double size;
  final double fontSize;

  const UserAvatar({
    super.key,
    required this.user,
    this.size = 40,
    this.fontSize = 16,
  });

  /// Obtiene las iniciales del nombre del usuario
  String _getInitials() {
    if (user == null) return '?';
    
    String initials = '';
    
    // Primera letra del nombre
    if (user!.nombre.isNotEmpty) {
      initials += user!.nombre[0].toUpperCase();
    }
    
    // Primera letra del apellido
    if (user!.apellidos.isNotEmpty) {
      initials += user!.apellidos[0].toUpperCase();
    }
    
    return initials.isNotEmpty ? initials : '?';
  }

  /// Construye la URL completa de la foto
  String? _getPhotoUrl() {
    if (user?.urlFoto == null || user!.urlFoto!.isEmpty) {
      return null;
    }
    
    // Si ya es una URL completa, devolverla tal cual
    if (user!.urlFoto!.startsWith('http')) {
      return user!.urlFoto;
    }
    
    // Si es una ruta relativa, construir la URL completa usando AppConfig
    final baseUrl = AppConfig.imagenesBaseUrl;
    return '$baseUrl/${user!.urlFoto}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final photoUrl = _getPhotoUrl();

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: isDark 
          ? Color(0xFF1976d2).withValues(alpha: 0.3)
          : Color(0xFF1976d2).withValues(alpha: 0.2),
      backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
      child: photoUrl == null
          ? Text(
              _getInitials(),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Color(0xFF1976d2),
              ),
            )
          : null,
      onBackgroundImageError: photoUrl != null
          ? (exception, stackTrace) {
              // Si falla la carga de la imagen, se mostrará el child (iniciales)
              print('[UserAvatar] Error cargando foto: $exception');
            }
          : null,
    );
  }
}
