import 'package:flutter/material.dart';
import 'package:proyecto_santi/views/home/components/home_user.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  const UserInformation(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Próximas Actividades',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: const [
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
                        height: constraints.maxHeight * 0.18,
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
                            child: Row(
                              children: activities.map((actividad) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: SizedBox(
                                    width: constraints.maxHeight * 0.38,
                                    child: ActivityCardItem(
                                      actividad: actividad,
                                      isDarkTheme:
                                          Theme.of(context).brightness ==
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