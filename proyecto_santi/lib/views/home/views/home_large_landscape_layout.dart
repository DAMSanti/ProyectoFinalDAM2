import 'package:flutter/material.dart';
import 'package:proyecto_santi/views/home/components/home_user.dart';
import 'package:proyecto_santi/views/home/components/home_activityCards.dart';
import 'package:proyecto_santi/views/home/components/home_calendario.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/components/menu.dart';
import 'package:flutter/gestures.dart';

class HomeLargeLandscapeLayout extends StatefulWidget {
  final List<Actividad> activities;

  const HomeLargeLandscapeLayout({super.key, required this.activities});

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
    return Row(
      children: [
        Container(
          width: 250,
          child: Menu(),
        ),
        Expanded(
          child: Column(
            children: [
              UserInformation(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Próximas Actividades',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Container(
                height: 130,
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
                        duration: Duration(milliseconds: 100),
                        curve: Curves.ease,
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
                            width: 300,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                child: Text(
                  'Calendario de Actividades',
                  style: Theme.of(context).textTheme.headlineSmall,
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
  }
}