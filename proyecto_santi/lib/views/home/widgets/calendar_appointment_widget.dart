import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

/// Widget para renderizar appointments del calendario
/// Separado para mejor mantenibilidad y testabilidad
class CalendarAppointmentWidget extends StatelessWidget {
  final Appointment appointment;
  final CalendarView currentView;
  final bool isSmallScreen;

  const CalendarAppointmentWidget({
    super.key,
    required this.appointment,
    required this.currentView,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    // En pantallas pequeñas, widget ultra simple
    if (isSmallScreen) {
      return _buildSimpleAppointment();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Si el espacio es muy pequeño, widget mínimo
        if (constraints.maxHeight < 8 || constraints.maxWidth < 10) {
          return Container(color: appointment.color);
        }

        // Vista día/semana/agenda
        if (currentView != CalendarView.month) {
          return _buildTimelineAppointment(constraints);
        }

        // Vista mes
        return _buildMonthAppointment(constraints);
      },
    );
  }

  /// Widget ultra simple para pantallas pequeñas
  Widget _buildSimpleAppointment() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0.5, horizontal: 0.5),
      decoration: BoxDecoration(
        color: appointment.color,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Text(
          appointment.subject,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  /// Appointment para vista día/semana/agenda (timeline)
  Widget _buildTimelineAppointment(BoxConstraints constraints) {
    final showFullText = constraints.maxHeight > 50;
    final showTime = !appointment.isAllDay && constraints.maxHeight > 35;
    final borderRadius = _calculateBorderRadius(constraints.maxHeight);

    return Container(
      constraints: const BoxConstraints(minHeight: 16),
      margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            appointment.color,
            Color.fromRGBO(
              (appointment.color.r * 255.0).round(),
              (appointment.color.g * 255.0).round(),
              (appointment.color.b * 255.0).round(),
              0.85,
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: const Color.fromRGBO(255, 255, 255, 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(
              (appointment.color.r * 255.0).round(),
              (appointment.color.g * 255.0).round(),
              (appointment.color.b * 255.0).round(),
              0.3,
            ),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Center(
        child: Text(
          _getAppointmentText(showTime),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            height: 1.1,
            shadows: [
              Shadow(
                color: Color.fromRGBO(0, 0, 0, 0.5),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: showFullText ? 2 : 1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Appointment para vista mes (compacto)
  Widget _buildMonthAppointment(BoxConstraints constraints) {
    final showText = constraints.maxHeight > 12;
    final borderRadius = _calculateBorderRadius(constraints.maxHeight);

    return Container(
      constraints: const BoxConstraints(minHeight: 14),
      margin: const EdgeInsets.symmetric(vertical: 0.5, horizontal: 1),
      decoration: BoxDecoration(
        color: appointment.color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: const Color.fromRGBO(255, 255, 255, 0.2),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      child: showText
          ? Text(
              appointment.subject,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            )
          : const SizedBox.shrink(),
    );
  }

  /// Calcula un borderRadius seguro basado en la altura
  double _calculateBorderRadius(double height) {
    final maxRadius = height / 2;
    if (maxRadius > 6) return 6.0;
    if (maxRadius > 1) return maxRadius - 1;
    return 0.0;
  }

  /// Obtiene el texto del appointment con o sin hora
  String _getAppointmentText(bool showTime) {
    if (showTime) {
      final time = DateFormat('HH:mm').format(appointment.startTime);
      return '$time ${appointment.subject}';
    }
    return appointment.subject;
  }
}
