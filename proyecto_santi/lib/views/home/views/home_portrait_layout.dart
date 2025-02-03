// home_portrait_layout.dart
import 'package:flutter/material.dart';
import 'package:proyecto_santi/views/home/components/home_user.dart';
import 'package:proyecto_santi/views/home/components/home_activityCards.dart';
import 'package:proyecto_santi/views/home/components/home_calendario.dart';
import 'package:proyecto_santi/models/actividad.dart';

class HomePortraitLayout extends StatelessWidget {
  final List<Actividad> activities;

  const HomePortraitLayout({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserInformation(),
        SizedBox(
          height: 175,
          child: ActivityList(activities: activities),
        ),
        Expanded(
          child: CalendarView(activities: activities),
        ),
      ],
    );
  }
}
