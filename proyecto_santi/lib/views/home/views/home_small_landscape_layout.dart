import 'package:flutter/material.dart';
import 'package:proyecto_santi/views/home/components/home_activity_cards.dart';
import 'package:proyecto_santi/views/home/components/syncfusion_calendar.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/views/home/widgets/activities_header.dart';

class HomeSmallLandscapeLayout extends StatelessWidget {
  final List<Actividad> activities;

  const HomeSmallLandscapeLayout({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            // Columna izquierda: Actividades
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // Header compacto
                  ActivitiesHeader(
                    activityCount: activities.length,
                    isCompact: true,
                    title: 'Actividades',
                  ),
                  // Lista vertical con surco
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0.5, 6.0, 0.5, 6.0),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? const Color.fromRGBO(0, 0, 0, 0.2)
                            : const Color.fromRGBO(255, 255, 255, 0.3),
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                            offset: Offset(0, 2),
                            blurRadius: 8,
                            spreadRadius: -2,
                          ),
                          // Sombra interna para efecto de surco
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.15),
                            offset: Offset(0, -2),
                            blurRadius: 6,
                            spreadRadius: -4,
                            blurStyle: BlurStyle.inner,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                          itemCount: activities.length,
                          itemBuilder: (context, index) {
                            final actividad = activities[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: SizedBox(
                                height: 170, // Altura fija para cada card
                                child: ActivityCardItem(
                                  actividad: actividad,
                                  isDarkTheme: isDark,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Columna derecha: Calendario
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ModernSyncfusionCalendar(
                  activities: activities,
                  countryCode: 'ES',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}