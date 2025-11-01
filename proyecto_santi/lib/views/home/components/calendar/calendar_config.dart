import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../../shared/constants/app_theme_constants.dart';

/// Clase con las configuraciones del calendario
class CalendarConfig {
  /// Obtiene los settings de la vista mensual
  static MonthViewSettings getMonthViewSettings(bool isDark) {
    return MonthViewSettings(
      appointmentDisplayMode: MonthAppointmentDisplayMode.none,
      showAgenda: false,
      numberOfWeeksInView: 6,
      monthCellStyle: MonthCellStyle(
        backgroundColor: isDark 
            ? Color(0xFF1E1E1E) 
            : Color(0xFFFFFFFF),
        todayBackgroundColor: Color.fromRGBO(
          (AppThemeConstants.primaryBlue.r * 255.0).round(),
          (AppThemeConstants.primaryBlue.g * 255.0).round(),
          (AppThemeConstants.primaryBlue.b * 255.0).round(),
          1.0,
        ),
        leadingDatesBackgroundColor: isDark 
            ? Color(0xFF121212) 
            : Color(0xFFF5F5F5),
        trailingDatesBackgroundColor: isDark 
            ? Color(0xFF121212) 
            : Color(0xFFF5F5F5),
        textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? Color(0xFFE0E0E0) : Color(0xFF424242),
        ),
        todayTextStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        leadingDatesTextStyle: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.white12 : Colors.black12,
        ),
        trailingDatesTextStyle: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
    );
  }

  /// Obtiene los settings de time slot
  static TimeSlotViewSettings getTimeSlotViewSettings() {
    return TimeSlotViewSettings(
      timeIntervalHeight: 60,
      timeFormat: 'HH:mm',
      dateFormat: 'dd',
      dayFormat: 'EEE',
      timeTextStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  /// Obtiene el estilo del header del calendario
  static CalendarHeaderStyle getHeaderStyle(bool isDark) {
    return CalendarHeaderStyle(
      textAlign: TextAlign.center,
      backgroundColor: isDark ? Color(0xFF121212) : Color(0xFFFFFFFF),
      textStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isDark ? Color(0xFFE0E0E0) : Color(0xFF212121),
      ),
    );
  }

  /// Obtiene el estilo de la vista del calendario
  static ViewHeaderStyle getViewHeaderStyle(bool isDark) {
    return ViewHeaderStyle(
      backgroundColor: isDark ? Color(0xFF1E1E1E) : Color(0xFFF5F5F5),
      dayTextStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isDark ? Color(0xFFE0E0E0) : Color(0xFF616161),
      ),
      dateTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: isDark ? Color(0xFFE0E0E0) : Color(0xFF212121),
      ),
    );
  }

  /// Obtiene el color de fondo del calendario
  static Color getBackgroundColor(bool isDark) {
    return isDark ? Color(0xFF121212) : Color(0xFFFFFFFF);
  }

  /// Obtiene el color de fondo de las celdas de today
  static Color getTodayHighlightColor() {
    return Color.fromRGBO(
      (AppThemeConstants.primaryBlue.r * 255.0).round(),
      (AppThemeConstants.primaryBlue.g * 255.0).round(),
      (AppThemeConstants.primaryBlue.b * 255.0).round(),
      1.0,
    );
  }

  /// Obtiene el color de fondo de los festivos
  static Color getHolidayColor(bool isDark) {
    return isDark 
        ? const Color.fromRGBO(244, 67, 54, 0.15)
        : const Color.fromRGBO(244, 67, 54, 0.08);
  }

  /// Obtiene el color de fondo de los días con actividades
  static Color getActivityColor(bool isDark) {
    return isDark
        ? Color(0xFF1976D2).withValues(alpha: 0.2)
        : Color(0xFF1976D2).withValues(alpha: 0.1);
  }
}
