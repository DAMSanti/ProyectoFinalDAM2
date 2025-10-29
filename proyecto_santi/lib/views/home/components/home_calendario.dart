import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/views/home/components/syncfusion_calendar.dart';

class CalendarView extends StatelessWidget {
  final List<Actividad> activities;
  final String countryCode;

  const CalendarView({
    super.key, 
    required this.activities,
    this.countryCode = 'ES',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ModernSyncfusionCalendar(
        activities: activities,
        countryCode: countryCode,
      ),
    );
  }
}