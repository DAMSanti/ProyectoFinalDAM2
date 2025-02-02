// home_large_landscape_layout.dart
import 'package:flutter/material.dart';
import 'package:proyecto_santi/views/home/components/home_user.dart';
import 'package:proyecto_santi/views/home/components/home_activityCards.dart';
import 'package:proyecto_santi/views/home/components/home_calendario.dart';
import 'package:proyecto_santi/models/actividad.dart';

class HomeLargeLandscapeLayout extends StatelessWidget {
  final List<Actividad> activities;

  const HomeLargeLandscapeLayout({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              UserInformation(),
              SizedBox(
                height: 100,
                child: ActivityList(activities: activities),
              ),
            ],
          ),
        ),
        Expanded(
          child: CalendarView(activities: activities),
        ),
      ],
    );
  }
}