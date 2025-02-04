import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/views/activities/views/activityDetail_view.dart';
import 'package:proyecto_santi/tema/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class CalendarView extends StatefulWidget {
  final List<Actividad> activities;

  const CalendarView({super.key, required this.activities});

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late final ValueNotifier<List<Actividad>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  List<Actividad> _getEventsForDay(DateTime day) {
    return widget.activities.where((actividad) {
      final activityDate = DateTime.parse(actividad.fini);
      return isSameDay(activityDate, day);
    }).toList();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  void _showActivityDetails(List<Actividad> actividades) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Actividades'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: actividades.map((actividad) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(actividad.titulo ?? 'Sin título'),
                    subtitle: Text('Fecha de inicio: ${actividad.fini}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ActivityDetailView(
                                actividad: actividad,
                                isDarkTheme: Theme
                                    .of(context)
                                    .brightness == Brightness.dark,
                                onToggleTheme: () {},
                              ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    return LayoutBuilder(
      builder: (context, constraints) {
        final orientation = MediaQuery.of(context).orientation;
        return Center(
          child: Column(
            children: [
              Visibility(
                visible: orientation == Orientation.portrait,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Calendario de Actividades',
                    style: TextStyle(fontSize: MediaQuery.of(context).size.shortestSide < 400 ? 16.dg : 3.5.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Container(
                height: isWeb ? constraints.maxHeight * 0.8 : 252,
                margin: isWeb ? EdgeInsets.symmetric(vertical: 16.0, horizontal: 220.0) : EdgeInsets.all(16.0),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(4, 4),
                      blurRadius: 10.0,
                      spreadRadius: 1.0,
                      blurStyle: BlurStyle.inner,
                    ),
                  ],
                ),
                child: isWeb ? _buildWebCalendar() : _buildWebCalendar(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWebCalendar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return TableCalendar<Actividad>(
          locale: 'es_ES', // Configura el idioma a español
          shouldFillViewport: true,
          daysOfWeekHeight: MediaQuery.of(context).size.shortestSide < 400 ? 30 : 40,
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _selectedEvents.value = _getEventsForDay(selectedDay);
            });
            if (_selectedEvents.value.isNotEmpty) {
              _showActivityDetails(_selectedEvents.value);
            }
          },
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarFormat: _calendarFormat,
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          eventLoader: _getEventsForDay,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(fontSize: MediaQuery.of(context).size.shortestSide < 400 ? 13.dg : 4.sp),
            headerPadding: EdgeInsets.all(2.0),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(fontSize: MediaQuery.of(context).size.shortestSide < 400 ? 10.dg : 3.sp),
            weekendStyle: TextStyle(fontSize: MediaQuery.of(context).size.shortestSide < 400 ? 10.dg : 3.sp),
          ),
          calendarStyle: CalendarStyle(
            defaultTextStyle: TextStyle(fontSize: MediaQuery.of(context).size.shortestSide < 400 ? 10.dg : 4.sp),
            weekendTextStyle: TextStyle(fontSize: MediaQuery.of(context).size.shortestSide < 400 ? 10.dg : 4.sp, color: Color.fromARGB(255, 209, 128, 128)),
            selectedTextStyle: TextStyle(fontSize: MediaQuery.of(context).size.shortestSide < 400 ? 10.dg : 4.sp, color: Color.fromARGB(255, 210, 217, 221), fontWeight: FontWeight.bold),
            todayTextStyle: TextStyle(fontSize: MediaQuery.of(context).size.shortestSide < 400 ? 10.dg : 4.sp, fontWeight: FontWeight.bold),
            markersMaxCount: 1,
            markerSizeScale: 1,
            cellMargin: EdgeInsets.all(0.0),
            markersAlignment: Alignment.center,
            markerDecoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .primaryColor
                  .withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            markersAutoAligned: false,
          ),
        );
      },
    );
  }
}