import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:proyecto_santi/models/actividad.dart';

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
    // Filtrar las actividades para el día seleccionado
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
    return Center(
      child: Container(
        height: 375.0,
        margin: EdgeInsets.all(16.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: TableCalendar<Actividad>(
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
            _showActivityDetails(_selectedEvents.value);
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
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(fontSize: 12),
            weekendStyle: TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
}
