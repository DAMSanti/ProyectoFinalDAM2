import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:proyecto_santi/models/actividad.dart';
class CalendarHelpers {
  static Color getColorByEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'planificada':
        return const Color(0xFF2196F3); 
      case 'en curso':
        return const Color(0xFF4CAF50); 
      case 'completada':
        return const Color(0xFF9E9E9E); 
      case 'cancelada':
        return const Color(0xFFF44336); 
      default:
        return const Color(0xFF1976d2); 
    }
  }
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
  static Appointment? actividadToAppointment(Actividad actividad) {
    try {
      final startDate = DateTime.parse(actividad.fini);
      final endDate = DateTime.parse(actividad.ffin);
      DateTime startTime = parseTimeWithDate(startDate, actividad.hini);
      DateTime endTime = parseTimeWithDate(endDate, actividad.hfin);
      if (startTime.isAtSameMomentAs(endTime) && _isSameDay(startDate, endDate)) {
        endTime = endTime.add(const Duration(hours: 1));
      }
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
  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  static String getCacheKey(String countryCode, int year) {
    return '${countryCode}_$year';
  }
}