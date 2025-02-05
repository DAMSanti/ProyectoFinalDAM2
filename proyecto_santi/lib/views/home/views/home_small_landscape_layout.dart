// home_small_landscape_layout.dart
import 'package:flutter/material.dart';
import 'package:proyecto_santi/views/home/components/home_user.dart';
import 'package:proyecto_santi/views/home/components/home_activity_cards.dart';
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(-4, -4),
                                blurRadius: 10.0,
                                spreadRadius: 1.0,
                                blurStyle: BlurStyle.inner,
                              ),
                            ],
                          ),
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