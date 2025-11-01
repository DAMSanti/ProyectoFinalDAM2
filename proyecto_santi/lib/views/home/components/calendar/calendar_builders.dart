import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../../shared/constants/app_theme_constants.dart';
import '../../../activityDetail/activity_detail_view.dart';
import '../../../../models/actividad.dart';
import '../../../../services/holidays_service.dart';
import '../../../../components/desktop_shell.dart';
import '../../widgets/calendar_appointment_widget.dart';

/// Clase con los builders personalizados para el calendario
class CalendarBuilders {
  /// Builder para las celdas del mes
  static Widget monthCellBuilder(
    BuildContext context,
    MonthCellDetails details,
    bool isDark,
    bool isSmallScreen,
    Holiday? Function(DateTime) getHoliday,
    CalendarController calendarController,
  ) {
    final date = details.date;
    final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    final holiday = getHoliday(date);
    final isHoliday = holiday != null;
    final isCurrentMonth = date.month == calendarController.displayDate?.month;
    final today = DateTime.now();
    final isToday = date.year == today.year && 
                    date.month == today.month && 
                    date.day == today.day;
    
    // Verificar si el día tiene actividades (excluyendo festivos)
    final hasActivities = details.appointments.isNotEmpty && 
        details.appointments.any((app) {
          if (app is Appointment) {
            return app.id is int || 
                (app.id is String && !app.id.toString().startsWith('holiday_'));
          }
          return false;
        });

    return Container(
      decoration: BoxDecoration(
        // Prioridad: Hoy > Festivo > Actividades > Transparente
        color: isToday
            ? (isDark 
                ? Color.fromRGBO(
                    (AppThemeConstants.primaryBlue.r * 255.0).round(),
                    (AppThemeConstants.primaryBlue.g * 255.0).round(),
                    (AppThemeConstants.primaryBlue.b * 255.0).round(),
                    0.25,
                  )
                : Color.fromRGBO(
                    (AppThemeConstants.primaryBlue.r * 255.0).round(),
                    (AppThemeConstants.primaryBlue.g * 255.0).round(),
                    (AppThemeConstants.primaryBlue.b * 255.0).round(),
                    0.15,
                  ))
            : isHoliday
                ? (isDark 
                    ? const Color.fromRGBO(244, 67, 54, 0.15)
                    : const Color.fromRGBO(244, 67, 54, 0.08))
            : hasActivities && isCurrentMonth
                ? (isDark
                    ? Color(0xFF1976D2).withValues(alpha: 0.2)
                    : Color(0xFF1976D2).withValues(alpha: 0.1))
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        // Borde para día de hoy o días con actividades
        border: isToday
            ? Border.all(
                color: Color.fromRGBO(
                  (AppThemeConstants.primaryBlue.r * 255.0).round(),
                  (AppThemeConstants.primaryBlue.g * 255.0).round(),
                  (AppThemeConstants.primaryBlue.b * 255.0).round(),
                  0.5,
                ),
                width: 2,
              )
            : hasActivities && isCurrentMonth && !isHoliday
                ? Border.all(
                    color: Color(0xFF1976D2).withValues(alpha: 0.4),
                    width: 1.5,
                  )
                : null,
      ),
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: isSmallScreen ? 2 : 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${date.day}',
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 15,
              fontWeight: isToday || hasActivities ? FontWeight.bold : FontWeight.w600,
              color: !isCurrentMonth
                  ? (isDark ? Colors.white12 : Colors.black12)
                  : isToday
                      ? Colors.white
                      : isHoliday || isWeekend
                          ? Colors.red.shade400
                          : (isDark ? Color(0xFFE0E0E0) : Color(0xFF424242)),
            ),
          ),
          if (!isSmallScreen && isHoliday && isCurrentMonth && !isToday)
            Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.celebration,
                size: 10,
                color: Colors.red.shade400,
              ),
            ),
        ],
      ),
    );
  }

  /// Builder para los appointments (actividades)
  static Widget appointmentBuilder(
    BuildContext context,
    CalendarAppointmentDetails calendarAppointmentDetails,
    CalendarView currentView,
    bool isSmallScreen,
  ) {
    final appointment = calendarAppointmentDetails.appointments.first as Appointment;
    return CalendarAppointmentWidget(
      appointment: appointment,
      currentView: currentView,
      isSmallScreen: isSmallScreen,
    );
  }

  /// Handler para tap en appointment
  static void handleAppointmentTap(
    BuildContext context,
    CalendarTapDetails details,
    List<Actividad> activities,
  ) {
    if (details.targetElement == CalendarElement.appointment) {
      final Appointment appointment = details.appointments![0];
      
      // Solo navegar si es una actividad (no un festivo)
      if (appointment.id is int || (appointment.id is String && !appointment.id.toString().startsWith('holiday_'))) {
        try {
          final actividad = activities.firstWhere(
            (a) => a.id == appointment.id,
          );
          
          navigateToActivityDetailInShell(
            context,
            {'activity': actividad},
          );
        } catch (e) {
          debugPrint('Actividad no encontrada: ${appointment.id}');
        }
      }
    }
  }
}
