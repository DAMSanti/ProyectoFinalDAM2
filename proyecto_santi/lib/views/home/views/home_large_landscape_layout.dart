import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:proyecto_santi/views/home/components/home_activity_cards.dart';
import 'package:proyecto_santi/views/home/components/home_calendario.dart';
import 'package:proyecto_santi/models/actividad.dart';

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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          // Header compacto
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available_rounded,
                  color: Color(0xFF1976d2),
                  size: 28,
                ),
                SizedBox(width: 16),
                Text(
                  'Próximas Actividades',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Color(0xFF1976d2),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(width: 12),
                // Burbuja con número
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF1976d2),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF1976d2).withOpacity(0.3),
                        offset: Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    '${widget.activities.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Carrusel de actividades con groove
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              height: 232,
              decoration: BoxDecoration(
                color: isDark 
                    ? Color(0xFF1A2332).withOpacity(0.4)
                    : Color(0xFFE3F2FD).withOpacity(0.6),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    offset: Offset(0, 2),
                    blurRadius: 8,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    offset: Offset(0, -1),
                    blurRadius: 6,
                    spreadRadius: -3,
                    blurStyle: BlurStyle.inner,
                  ),
                ],
              ),
              child: widget.activities.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy_rounded,
                            size: 48,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No hay actividades próximas',
                            style: TextStyle(
                              fontSize: 18, 
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.all(16.0),
                          itemCount: widget.activities.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index < widget.activities.length - 1 ? 16.0 : 0.0,
                              ),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: 300,
                                  maxWidth: 400,
                                ),
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
          
          SizedBox(height: 24),
          
          // Título del calendario
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFF1976d2),
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'Calendario de Actividades',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Color(0xFF1976d2),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Calendario
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 16.0),
              child: CalendarView(activities: widget.activities),
            ),
          ),
        ],
      ),
    );
  }
}