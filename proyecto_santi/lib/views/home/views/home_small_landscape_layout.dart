import 'package:flutter/material.dart';
import 'package:proyecto_santi/views/home/components/home_activity_cards.dart';
import 'package:proyecto_santi/views/home/components/calendar/syncfusion_calendar.dart';
import 'package:proyecto_santi/models/actividad.dart';

class HomeSmallLandscapeLayout extends StatelessWidget {
  final List<Actividad> activities;

  const HomeSmallLandscapeLayout({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // En landscape móvil, priorizamos el calendario
        return Row(
          children: [
            // Columna izquierda: Actividades (40%)
            Expanded(
              flex: 40,
              child: Column(
                children: [
                  // Header compacto
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6.0, 6.0, 4.0, 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.event_note_rounded,
                          color: Color(0xFF1976d2),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Actividades',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1976d2),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976d2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${activities.length}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Lista vertical compacta
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(6.0, 0, 3.0, 6.0),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? const Color.fromRGBO(0, 0, 0, 0.2)
                            : const Color.fromRGBO(255, 255, 255, 0.3),
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                            offset: Offset(0, 2),
                            blurRadius: 6,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: activities.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.event_busy_rounded,
                                      size: 32,
                                      color: isDark ? Colors.white24 : Colors.black26,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Sin\nactividades',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? Colors.white54 : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(6.0),
                                itemCount: activities.length,
                                itemBuilder: (context, index) {
                                  final actividad = activities[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6.0),
                                    child: SizedBox(
                                      height: 120, // Altura muy reducida para landscape móvil
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
            // Columna derecha: Calendario (60%)
            Expanded(
              flex: 60,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(3.0, 6.0, 6.0, 6.0),
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