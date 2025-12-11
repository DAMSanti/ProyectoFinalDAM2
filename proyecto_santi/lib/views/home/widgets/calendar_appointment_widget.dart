import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
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
    if (isSmallScreen) {
      return _buildSimpleAppointment();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight < 8 || constraints.maxWidth < 10) {
          return Container(color: appointment.color);
        }
        if (currentView != CalendarView.month) {
          return _buildTimelineAppointment(constraints);
        }
        return _buildMonthAppointment(constraints);
      },
    );
  }
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
  double _calculateBorderRadius(double height) {
    final maxRadius = height / 2;
    if (maxRadius > 6) return 6.0;
    if (maxRadius > 1) return maxRadius - 1;
    return 0.0;
  }
  String _getAppointmentText(bool showTime) {
    if (showTime) {
      final time = DateFormat('HH:mm').format(appointment.startTime);
      return '$time ${appointment.subject}';
    }
    return appointment.subject;
  }
}