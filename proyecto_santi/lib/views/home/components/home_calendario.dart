import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/views/activityDetail/activity_detail_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class CalendarView extends StatefulWidget {
  final List<Actividad> activities;

  const CalendarView({super.key, required this.activities});

  @override
  CalendarViewState createState() => CalendarViewState();
}

class CalendarViewState extends State<CalendarView> {
  late final ValueNotifier<List<Actividad>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _hoveredDay;

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

  @override
  Widget build(BuildContext context) {
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
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.shortestSide < 400 ? 16.dg : 3.5.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _buildCalendar(constraints),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendar(BoxConstraints constraints) {
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    return Container(
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
      child: TableCalendar<Actividad>(
        locale: 'es_ES',
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
          leftChevronIcon: _HoverIcon(icon: Icons.chevron_left),
          rightChevronIcon: _HoverIcon(icon: Icons.chevron_right),
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
            color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
          markersAutoAligned: false,
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return _DayCell(
              day: day,
              isSelected: isSameDay(_selectedDay, day),
              isToday: isSameDay(DateTime.now(), day),
              isWeekend: day.weekday == DateTime.saturday || day.weekday == DateTime.sunday,
              hasEvent: _getEventsForDay(day).isNotEmpty,
            );
          },
        ),
      ),
    );
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
                    title: Text(actividad.titulo),
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
}

// Widget personalizado para los íconos de las flechas con hover
class _HoverIcon extends StatefulWidget {
  final IconData icon;

  const _HoverIcon({required this.icon});

  @override
  _HoverIconState createState() => _HoverIconState();
}

class _HoverIconState extends State<_HoverIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _isHovered ? Color(0xFF1976d2).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          widget.icon,
          color: _isHovered ? Color(0xFF1976d2) : null,
        ),
      ),
    );
  }
}

// Widget personalizado para las celdas de los días con hover
class _DayCell extends StatefulWidget {
  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final bool isWeekend;
  final bool hasEvent;

  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.isWeekend,
    required this.hasEvent,
  });

  @override
  _DayCellState createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.all(widget.isToday ? 2 : 4),
        decoration: BoxDecoration(
          color: _isHovered 
              ? Color(0xFF1976d2).withOpacity(0.1)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${widget.day.day}',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.shortestSide < 400 ? 10 : 14,
              color: widget.isWeekend
                  ? Color.fromARGB(255, 209, 128, 128)
                  : (_isHovered ? Color(0xFF1976d2) : null),
              fontWeight: widget.isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}