import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/views/activities/views/activityDetail_view.dart';
import 'package:proyecto_santi/tema/theme.dart';
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
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
              Container(
                height: isWeb ? 455 : 252,
                margin: isWeb ? EdgeInsets.symmetric(vertical: 16.0, horizontal: 220.0) : EdgeInsets.all(16.0),
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? lightTheme.primaryColor.withOpacity(0.1)
                      : darkTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: SizedBox(
                  child: isWeb ? _buildWebCalendar() : _buildMobileCalendar(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWebCalendar() {
    return TableCalendar<Actividad>(
      rowHeight: 60,
      daysOfWeekHeight: 40,
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
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        headerPadding: EdgeInsets.all(2.0),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(fontSize: 16),
        weekendStyle: TextStyle(fontSize: 16),
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle: TextStyle(fontSize: 16),
        weekendTextStyle: TextStyle(
            fontSize: 16, color: Color.fromARGB(255, 209, 128, 128)),
        selectedTextStyle: TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 210, 217, 221),
            fontWeight: FontWeight.bold),
        todayTextStyle: TextStyle(fontSize: 18),
        markersMaxCount: 1,
        markerSizeScale: 0.9,
        cellMargin: EdgeInsets.all(0.0),
        markersAlignment: Alignment.center,
        markerDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
        markersAutoAligned: false,
      ),
    );
  }

  Widget _buildMobileCalendar() {
    return TableCalendar<Actividad>(
      rowHeight: 30,
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
        titleTextStyle: TextStyle(fontSize: 14),
        headerPadding: EdgeInsets.all(4.0),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(fontSize: 12),
        weekendStyle: TextStyle(fontSize: 12),
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle: TextStyle(fontSize: 14),
        weekendTextStyle: TextStyle(
            fontSize: 14, color: Color.fromARGB(255, 209, 128, 128)),
        selectedTextStyle: TextStyle(
            fontSize: 14,
            color: Color.fromARGB(255, 210, 217, 221),
            fontWeight: FontWeight.bold),
        todayTextStyle: TextStyle(fontSize: 14),
        markersMaxCount: 1,
        markerSizeScale: 1.0,
        cellMargin: EdgeInsets.all(3.0),
        markersAlignment: Alignment.center,
        markerDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
        markersAutoAligned: false,
      ),
    );
  }
}