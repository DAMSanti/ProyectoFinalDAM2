import 'package:flutter/material.dart';
import 'package:proyecto_santi/components/marco_desktop.dart';
import 'package:proyecto_santi/views/home/components/home_activity_cards.dart';
import 'package:proyecto_santi/views/home/components/home_calendario.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeLargeLandscapeLayout extends StatefulWidget {
  final List<Actividad> activities;
  final VoidCallback onToggleTheme;

  const HomeLargeLandscapeLayout({super.key, required this.activities, required this.onToggleTheme});

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
    return MarcoDesktop(
      onToggleTheme: widget.onToggleTheme,
      content: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Próximas Actividades',
                        style: TextStyle(fontSize: 5.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                        child: SizedBox(
                          height: constraints.maxHeight * 0.20,
                          child: Listener(
                            onPointerSignal: (pointerSignal) {
                              if (pointerSignal is PointerScrollEvent) {
                                final offset = _scrollController.offset +
                                    (pointerSignal.scrollDelta.dy * -5.0);
                                _scrollController.animateTo(
                                  offset.clamp(
                                    0.0,
                                    _scrollController.position.maxScrollExtent,
                                  ),
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              physics: BouncingScrollPhysics(),
                              child: Row(
                                children: widget.activities.map((actividad) {
                                  return Padding(
                                    padding: EdgeInsets.only(right: 16.0),
                                    child: SizedBox(
                                      width: constraints.maxHeight * 0.53,
                                      child: ActivityCardItem(
                                        actividad: actividad,
                                        isDarkTheme: Theme.of(context).brightness ==
                                            Brightness.dark,
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
                    SizedBox(
                      height: constraints.maxHeight * 0.05, // Fixed height for Calendario de Actividades
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                      child: Text(
                        'Calendario de Actividades',
                        style: TextStyle(fontSize: 5.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: CalendarView(activities: widget.activities),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}