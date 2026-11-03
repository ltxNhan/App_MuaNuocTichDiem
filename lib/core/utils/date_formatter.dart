import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDateTime(dynamic date) {
    if (date == null) return '';
    DateTime dt;
    if (date is DateTime) {
      dt = date;
    } else {
      dt = DateTime.tryParse(date.toString()) ?? DateTime.now();
    }
    return DateFormat('HH:mm - dd/MM/yyyy').format(dt);
  }

  static String formatDate(dynamic date) {
    if (date == null) return '';
    DateTime dt;
    if (date is DateTime) {
      dt = date;
    } else {
      dt = DateTime.tryParse(date.toString()) ?? DateTime.now();
    }
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  static String formatTime(dynamic date) {
    if (date == null) return '';
    DateTime dt;
    if (date is DateTime) {
      dt = date;
    } else {
      dt = DateTime.tryParse(date.toString()) ?? DateTime.now();
    }
    return DateFormat('HH:mm').format(dt);
  }
}
