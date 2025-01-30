import 'package:flutter/material.dart';
import 'package:proyecto_santi/components/AppBar.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeView extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomeView({Key? key, required this.onToggleTheme}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Future<List<Actividad>> _futureActivities;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _futureActivities = _apiService.fetchActivities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onToggleTheme: widget.onToggleTheme,
        title: 'Home',
      ),
      body: FutureBuilder<List<Actividad>>(
        future: _futureActivities,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text(snapshot.error.toString(),
                    style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No activities available"));
          } else {
            final activities = snapshot.data!;
            return Column(
              children: [
                UserInformation(),
                Expanded(
                  child: CalendarView(activities: activities),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final actividad = activities[index];
                      return ActivityCardItem(
                        activityName: actividad.titulo,
                        activityDate: actividad.fini,
                        activityStatus: actividad.estado,
                        index: actividad.id,
                        navController: Navigator.of(context),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class UserInformation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Text("User Information"),
    );
  }
}

class CalendarView extends StatefulWidget {
  final List<Actividad> activities;

  const CalendarView({Key? key, required this.activities}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<Actividad>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _selectedEvents.value = _getEventsForDay(selectedDay);
          },
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          eventLoader: _getEventsForDay,
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ValueListenableBuilder<List<Actividad>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(value[index].titulo),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class ActivityCardItem extends StatelessWidget {
  final String activityName;
  final String activityDate;
  final String activityStatus;
  final int index;
  final NavigatorState navController;

  const ActivityCardItem({
    Key? key,
    required this.activityName,
    required this.activityDate,
    required this.activityStatus,
    required this.index,
    required this.navController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(activityName),
        subtitle: Text(activityDate),
        trailing: Text(activityStatus),
        onTap: () {
          // Navegar a la vista de detalles de la actividad
          navController.pushNamed('/activityDetail', arguments: index);
        },
      ),
    );
  }
}
