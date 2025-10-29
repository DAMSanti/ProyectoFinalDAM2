import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:proyecto_santi/models/actividad.dart';

/// Helpers para la lógica del calendario
/// Aplica Single Responsibility Principle
class CalendarHelpers {
  /// Obtiene el color según el estado de la actividad
  static Color getColorByEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'planificada':
        return const Color(0xFF2196F3); // Azul
      case 'en curso':
        return const Color(0xFF4CAF50); // Verde
      case 'completada':
        return const Color(0xFF9E9E9E); // Gris
      case 'cancelada':
        return const Color(0xFFF44336); // Rojo
      default:
        return const Color(0xFF1976d2); // Azul por defecto
    }
  }

  /// Parsea la hora en formato "HH:mm:ss" y la combina con la fecha
  static DateTime parseTimeWithDate(DateTime date, String time) {
    if (time.isEmpty || time == '00:00:00') {
      return date;
    }

    final parts = time.split(':');
    if (parts.length < 2) return date;

    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
      parts.length > 2 ? int.parse(parts[2]) : 0,
    );
  }

  /// Convierte una actividad en un Appointment de Syncfusion
  static Appointment? actividadToAppointment(Actividad actividad) {
    try {
      final startDate = DateTime.parse(actividad.fini);
      final endDate = DateTime.parse(actividad.ffin);

      DateTime startTime = parseTimeWithDate(startDate, actividad.hini);
      DateTime endTime = parseTimeWithDate(endDate, actividad.hfin);

      // Si la hora de inicio y fin son iguales en el mismo día, agregar 1 hora
      if (startTime.isAtSameMomentAs(endTime) && _isSameDay(startDate, endDate)) {
        endTime = endTime.add(const Duration(hours: 1));
      }

      // Determinar si es un evento de todo el día
      final isMultiDay = endDate.difference(startDate).inDays > 0;
      final hasSpecificHours = actividad.hini != '00:00:00' || actividad.hfin != '00:00:00';
      final isAllDay = isMultiDay || !hasSpecificHours;

      return Appointment(
        startTime: startTime,
        endTime: endTime,
        subject: actividad.titulo,
        color: getColorByEstado(actividad.estado),
        isAllDay: isAllDay,
        id: actividad.id,
      );
    } catch (e) {
      debugPrint('Error al parsear actividad ${actividad.id}: $e');
      return null;
    }
  }

  /// Comprueba si dos fechas son el mismo día
  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Genera una clave de caché para festivos
  static String getCacheKey(String countryCode, int year) {
    return '${countryCode}_$year';
  }
}
