import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:proyecto_santi/views/home/components/home_activity_cards.dart';
import 'package:proyecto_santi/views/home/components/calendar/syncfusion_calendar.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/components/desktop_shell.dart';
import 'package:proyecto_santi/views/home/widgets/calendar_title.dart';
import 'package:proyecto_santi/shared/widgets/state_widgets.dart';

class HomeLargeLandscapeLayout extends StatefulWidget {
  final List<Actividad> activities;
  final VoidCallback onToggleTheme;

  const HomeLargeLandscapeLayout({
    super.key, 
    required this.activities, 
    required this.onToggleTheme
  });

  @override
  State<HomeLargeLandscapeLayout> createState() =>
      _HomeLargeLandscapeLayoutState();
}

class _HomeLargeLandscapeLayoutState extends State<HomeLargeLandscapeLayout> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Actualizar el contador de actividades en el shell
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateActivitiesCountInShell(context, widget.activities.length);
    });
  }

  @override
  void didUpdateWidget(HomeLargeLandscapeLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Actualizar si cambia el número de actividades
    if (oldWidget.activities.length != widget.activities.length) {
      updateActivitiesCountInShell(context, widget.activities.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          const SizedBox(height: 16), // Espaciado superior
          // Carrusel de actividades con groove (sin header, ahora está en el top bar)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              height: 190, // Reducido de 232 a 190
              decoration: BoxDecoration(
                color: isDark 
                    ? const Color.fromRGBO(26, 35, 50, 0.4)
                    : const Color.fromRGBO(227, 242, 253, 0.6),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.08),
                    offset: Offset(0, 2),
                    blurRadius: 8,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.12),
                    offset: Offset(0, -1),
                    blurRadius: 6,
                    spreadRadius: -3,
                    blurStyle: BlurStyle.inner,
                  ),
                ],
              ),
              child: widget.activities.isEmpty
                  ? const EmptyState(
                      message: 'No hay actividades próximas',
                      icon: Icons.event_busy_rounded,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Listener(
                        onPointerSignal: (pointerSignal) {
                          if (pointerSignal is PointerScrollEvent) {
                            final offset = _scrollController.offset +
                                (pointerSignal.scrollDelta.dy);
                            _scrollController.jumpTo(
                              offset.clamp(
                                0.0,
                                _scrollController.position.maxScrollExtent,
                              ),
                            );
                          }
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(16.0),
                          itemCount: widget.activities.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index < widget.activities.length - 1 ? 16.0 : 0.0,
                              ),
                              child: SizedBox(
                                width: 350, // Ancho fijo
                                height: 158, // Altura reducida para caber en el contenedor (190 - 32 padding)
                                child: ActivityCardItem(
                                  actividad: widget.activities[index],
                                  isDarkTheme: isDark,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Título del calendario
          const CalendarTitle(),
          
          // Calendario
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 16.0),
              child: ModernSyncfusionCalendar(
                activities: widget.activities,
                countryCode: 'ES',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
