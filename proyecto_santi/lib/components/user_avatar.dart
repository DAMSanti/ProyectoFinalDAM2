import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/config.dart';
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
  String _getInitials() {
    if (user == null) return '?';
    String initials = '';
    if (user!.nombre.isNotEmpty) {
      initials += user!.nombre[0].toUpperCase();
    }
    if (user!.apellidos.isNotEmpty) {
      initials += user!.apellidos[0].toUpperCase();
    }
    return initials.isNotEmpty ? initials : '?';
  }
  String? _getPhotoUrl() {
    if (user?.urlFoto == null || user!.urlFoto!.isEmpty) {
      return null;
    }
    if (user!.urlFoto!.startsWith('http')) {
      return user!.urlFoto;
    }
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
              print('[UserAvatar] Error cargando foto: $exception');
            }
          : null,
    );
  }
}