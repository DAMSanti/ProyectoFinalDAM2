import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:intl/intl.dart';

/// Utilidades para formatear y obtener información de Actividades
/// Aplica Single Responsibility Principle (SRP)
class ActivityFormatters {
  /// Formatea la fecha y hora de una actividad combinando fini y hini
  static String formatearFechaHora(Actividad actividad) {
    try {
      // Parsear la fecha (fini está en formato YYYY-MM-DDT00:00:00)
      final fecha = DateTime.parse(actividad.fini);
      
      // Combinar fecha con hora (hini está en formato HH:mm)
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
      // Fallback: mostrar fecha y hora como vienen
      try {
        final fecha = DateTime.parse(actividad.fini);
        return '${DateFormat('dd-MM-yyyy').format(fecha)} ${actividad.hini}';
      } catch (e2) {
        return '${actividad.fini} ${actividad.hini}';
      }
    }
  }

  /// Obtiene el color asociado al estado de la actividad
  static Color getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobada':
        return const Color(0xFF4CAF50); // Verde
      case 'pendiente':
        return const Color(0xFFFFA726); // Naranja
      case 'rechazada':
      case 'cancelada':
        return const Color(0xFFEF5350); // Rojo
      default:
        return Colors.grey;
    }
  }

  /// Obtiene el icono asociado al estado de la actividad
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
