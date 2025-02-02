import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/tema/theme.dart';

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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: actividades.map((actividad) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Título: ${actividad.titulo}'),
                  Text('Fecha de inicio: ${actividad.fini}'),
                  Text('Descripción: ${actividad.descripcion}'),
                  SizedBox(height: 8),
                ],
              );
            }).toList(),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Container(
            height: 260,
            margin: EdgeInsets.all(16.0),
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? lightTheme.primaryColor.withOpacity(0.1)
                  : darkTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: SizedBox(
              child: TableCalendar<Actividad>(
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
                  titleTextStyle: TextStyle(fontSize: 12),
                  headerPadding: EdgeInsets.all(2.0),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(fontSize: 10),
                  weekendStyle: TextStyle(fontSize: 10),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(fontSize: 12),
                  weekendTextStyle: TextStyle(fontSize: 12),
                  selectedTextStyle: TextStyle(fontSize: 12),
                  todayTextStyle: TextStyle(fontSize: 12),
                  markersMaxCount: 1,
                  markerSizeScale: 0.5,
                  cellMargin: EdgeInsets.all(0.0),
                  cellPadding: EdgeInsets.all(3.0),
                  markerDecoration: BoxDecoration(
                    color: Colors.blue, // Change marker color
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}