import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:intl/intl.dart';
class ActivityFormatters {
  static String formatearFechaHora(Actividad actividad) {
    try {
      final fecha = DateTime.parse(actividad.fini);
      final partsHora = actividad.hini.split(':');
      final hora = int.tryParse(partsHora[0]) ?? 0;
      final minuto = int.tryParse(partsHora.length > 1 ? partsHora[1] : '0') ?? 0;
      final fechaHoraCompleta = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        hora,
        minuto,
      );
      return DateFormat('dd-MM-yyyy HH:mm').format(fechaHoraCompleta);
    } catch (e) {
      try {
        final fecha = DateTime.parse(actividad.fini);
        return '${DateFormat('dd-MM-yyyy').format(fecha)} ${actividad.hini}';
      } catch (e2) {
        return '${actividad.fini} ${actividad.hini}';
      }
    }
  }
  static Color getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobada':
        return const Color(0xFF4CAF50); 
      case 'pendiente':
        return const Color(0xFFFFA726); 
      case 'rechazada':
      case 'cancelada':
        return const Color(0xFFEF5350); 
      default:
        return Colors.grey;
    }
  }
  static IconData getEstadoIcon(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobada':
        return Icons.check_circle_rounded;
      case 'pendiente':
        return Icons.schedule_rounded;
      case 'rechazada':
      case 'cancelada':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }
}