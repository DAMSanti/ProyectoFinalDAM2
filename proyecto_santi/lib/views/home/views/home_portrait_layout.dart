import 'package:flutter/material.dart';
import 'package:proyecto_santi/views/home/components/home_activity_cards.dart';
import 'package:proyecto_santi/views/home/components/home_calendario.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:flutter/gestures.dart';

class HomePortraitLayout extends StatelessWidget {
  final List<Actividad> activities;
  final ScrollController _scrollController = ScrollController();

  HomePortraitLayout({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  // Header compacto
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available_rounded,
                          color: Color(0xFF1976d2),
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Próximas Actividades',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Color(0xFF1976d2),
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(width: 8),
                        // Burbuja con número
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFF1976d2),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF1976d2).withOpacity(0.3),
                                offset: Offset(0, 2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Text(
                            '${activities.length}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Carrusel con efecto de surco
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Color(0xFF1A2332).withOpacity(0.4)
                            : Color(0xFFE3F2FD).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            offset: Offset(0, 2),
                            blurRadius: 8,
                            spreadRadius: -2,
                          ),
                          // Sombra interna para efecto de surco
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            offset: Offset(0, -1),
                            blurRadius: 6,
                            spreadRadius: -3,
                            blurStyle: BlurStyle.inner,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Listener(
                          onPointerSignal: (pointerSignal) {
                            if (pointerSignal is PointerScrollEvent) {
                              final offset = _scrollController.offset +
                                  (pointerSignal.scrollDelta.dy * -2.5);
                              _scrollController.animateTo(
                                offset.clamp(
                                  0.0,
                                  _scrollController.position.maxScrollExtent,
                                ),
                                duration: const Duration(milliseconds: 100),
                                curve: Curves.ease,
                              );
                            }
                          },
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                            child: Row(
                              children: activities.map((actividad) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: SizedBox(
                                    width: constraints.maxWidth * 0.70 + 30,
                                    child: ActivityCardItem(
                                      actividad: actividad,
                                      isDarkTheme: isDark,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: CalendarView(activities: activities),
            ),
          ],
        );
      },
    );
  }
}