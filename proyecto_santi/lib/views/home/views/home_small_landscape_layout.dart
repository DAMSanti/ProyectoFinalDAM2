import 'package:flutter/material.dart';
import 'package:proyecto_santi/views/home/components/home_activity_cards.dart';
import 'package:proyecto_santi/views/home/components/home_calendario.dart';
import 'package:proyecto_santi/models/actividad.dart';

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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available_rounded,
                          color: Color(0xFF1976d2),
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Actividades',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Color(0xFF1976d2),
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(width: 8),
                        // Burbuja con número
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Color(0xFF1976d2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${activities.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Lista vertical con surco
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0.5, 6.0, 0.5, 6.0),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.black.withOpacity(0.2)
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(0, 2),
                            blurRadius: 8,
                            spreadRadius: -2,
                          ),
                          // Sombra interna para efecto de surco
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
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
                          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                          itemCount: activities.length,
                          itemBuilder: (context, index) {
                            final actividad = activities[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: ActivityCardItem(
                                actividad: actividad,
                                isDarkTheme: isDark,
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
              child: CalendarView(activities: activities),
            ),
          ],
        );
      },
    );
  }
}