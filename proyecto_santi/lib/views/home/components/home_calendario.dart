import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/views/home/components/home_calendar.dart';

class CalendarView extends StatelessWidget {
  final List<Actividad> activities;

  const CalendarView({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ModernCalendar(activities: activities),
    );
  }
}
