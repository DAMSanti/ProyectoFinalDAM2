// home_small_landscape_layout.dart
import 'package:flutter/material.dart';
import 'package:proyecto_santi/views/home/components/home_user.dart';
import 'package:proyecto_santi/views/home/components/home_activityCards.dart';
import 'package:proyecto_santi/views/home/components/home_calendario.dart';
import 'package:proyecto_santi/models/actividad.dart';

class HomeSmallLandscapeLayout extends StatelessWidget {
  final List<Actividad> activities;

  const HomeSmallLandscapeLayout({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  UserInformation(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final actividad = activities[index];
                        return ActivityCardItem(
                          actividad: actividad,
                          isDarkTheme: Theme.of(context).brightness == Brightness.dark,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: constraints.maxHeight, // Adjust the height of the calendar based on screen size
                    child: CalendarView(activities: activities),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}