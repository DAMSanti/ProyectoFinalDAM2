import 'package:flutter/material.dart';
import 'package:proyecto_santi/views/home/components/home_activity_cards.dart';
import 'package:proyecto_santi/views/home/components/syncfusion_calendar.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:flutter/gestures.dart';
import 'package:proyecto_santi/views/home/widgets/activities_header.dart';
import 'package:proyecto_santi/views/home/widgets/calendar_title.dart';

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
            // Header compacto
            ActivitiesHeader(activityCount: activities.length),
            // Carrusel con efecto de surco
            SizedBox(
              height: 180, // Altura fija para las cards
              child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? const Color.fromRGBO(26, 35, 50, 0.4)
                            : const Color.fromRGBO(227, 242, 253, 0.6),
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.08),
                            offset: Offset(0, 2),
                            blurRadius: 8,
                            spreadRadius: -2,
                          ),
                          // Sombra interna para efecto de surco
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.12),
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
            // Título del calendario
            CalendarTitle(),
            Expanded(
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