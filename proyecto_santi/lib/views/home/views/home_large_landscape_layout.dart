import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:proyecto_santi/components/marco_desktop.dart';
import 'package:proyecto_santi/views/home/components/home_activity_cards.dart';
import 'package:proyecto_santi/views/home/components/home_calendario.dart';
import 'package:proyecto_santi/models/actividad.dart';

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
          // Tamaño mínimo donde deja de ser responsive
          final minWidth = 900.0;
          final minHeight = 600.0;
          
          // Si la ventana es más pequeña que el mínimo, usar el mínimo y agregar scroll
          final effectiveWidth = constraints.maxWidth < minWidth ? minWidth : constraints.maxWidth;
          final effectiveHeight = constraints.maxHeight < minHeight ? minHeight : constraints.maxHeight;
          
          // Si necesitamos scroll, envolver en SingleChildScrollView
          if (constraints.maxWidth < minWidth || constraints.maxHeight < minHeight) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  width: minWidth,
                  height: minHeight,
                  child: _buildContent(minWidth, minHeight),
                ),
              ),
            );
          }
          
          // Si no necesitamos scroll, usar el tamaño disponible (responsive)
          return _buildContent(effectiveWidth, effectiveHeight);
        },
      ),
    );
  }

  Widget _buildContent(double width, double height) {
    return Builder(
      builder: (context) {
        return SizedBox(
          width: width,
          height: height,
          child: Column(
            children: [
              // Sección de actividades con scroll horizontal
              SizedBox(
                height: height * 0.25, // 25% de la altura
                child: Column(
                  children: [
                    SizedBox(height: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
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
                          child: widget.activities.isEmpty
                              ? Center(
                                  child: Text(
                                    'No hay actividades próximas',
                                    style: TextStyle(fontSize: 18, color: Colors.grey),
                                  ),
                                )
                              : Listener(
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
                                    padding: EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0, right: 16.0),
                                    itemCount: widget.activities.length,
                                    itemBuilder: (context, index) {
                                      final isLast = index == widget.activities.length - 1;
                                      return Padding(
                                        padding: EdgeInsets.only(right: isLast ? 0 : 16.0),
                                        child: SizedBox(
                                          width: width * 0.35,
                                          child: ActivityCardItem(
                                            actividad: widget.activities[index],
                                            isDarkTheme: Theme.of(context).brightness == Brightness.dark,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                  ],
                ),
              ),
              
              // Título del calendario centrado
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenHeight = MediaQuery.of(context).size.height;
                    double scaleFactor = 1.0;
                    if (screenHeight >= 2160) { // 4K
                      scaleFactor = 1.6;
                    } else if (screenHeight >= 1440) { // 2K/QHD
                      scaleFactor = 1.3;
                    } else if (screenHeight >= 1080) { // Full HD
                      scaleFactor = 1.1;
                    }
                    
                    return Text(
                      'Calendario de Actividades',
                      style: TextStyle(
                        fontSize: 24 * scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
              
              // Calendario con ancho completo
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                  child: SizedBox(
                    width: width - 32, // Ancho completo menos padding
                    child: CalendarView(activities: widget.activities),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}