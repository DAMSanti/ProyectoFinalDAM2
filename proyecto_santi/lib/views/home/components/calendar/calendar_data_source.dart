import 'package:syncfusion_flutter_calendar/calendar.dart';

/// Fuente de datos para el calendario de Syncfusion
class ActivityDataSource extends CalendarDataSource {
  ActivityDataSource(List<Appointment> source) {
    appointments = source;
  }
}
