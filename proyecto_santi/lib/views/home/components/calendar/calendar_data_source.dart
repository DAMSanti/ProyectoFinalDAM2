import 'package:syncfusion_flutter_calendar/calendar.dart';
class ActivityDataSource extends CalendarDataSource {
  ActivityDataSource(List<Appointment> source) {
    appointments = source;
  }
}