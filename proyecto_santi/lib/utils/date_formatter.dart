import 'package:intl/intl.dart';
class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  static String formatDateLong(DateTime date) {
    return DateFormat('dd \'de\' MMMM \'de\' yyyy', 'es_ES').format(date);
  }
  static String formatDateShort(DateTime date) {
    return DateFormat('EEE, dd MMM', 'es_ES').format(date);
  }
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
  static DateTime? parseIsoString(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    try {
      return DateTime.parse(isoString);
    } catch (e) {
      print('[DateFormatter] Error parsing date: $e');
      return null;
    }
  }
  static DateTime? parseSpanishDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateFormat('dd/MM/yyyy').parse(dateString);
    } catch (e) {
      print('[DateFormatter] Error parsing Spanish date: $e');
      return null;
    }
  }
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return to.difference(from).inDays;
  }
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }
  static String getRelativeDateText(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = targetDate.difference(today).inDays;
    if (difference == 0) return 'Hoy';
    if (difference == 1) return 'Mañana';
    if (difference == -1) return 'Ayer';
    if (difference > 1 && difference <= 7) return 'En $difference días';
    if (difference < -1 && difference >= -7) return 'Hace ${-difference} días';
    return formatDate(date);
  }
  static DateTime? parseTimeString(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return null;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      print('[DateFormatter] Error parsing time: $e');
      return null;
    }
  }
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }
}