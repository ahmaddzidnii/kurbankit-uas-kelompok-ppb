import 'package:intl/intl.dart';

class AppDateTimeFormatter {
  static const String defaultDateTimePattern = 'dd MMM yyyy, HH:mm';
  static const String defaultDatePattern = 'dd MMM yyyy';

  static DateTime _toLocal(DateTime dateTime) {
    return dateTime.isUtc ? dateTime.toLocal() : dateTime;
  }

  static String formatDateTime(
    DateTime? dateTime, {
    String pattern = defaultDateTimePattern,
    String locale = 'id',
  }) {
    if (dateTime == null) {
      return '-';
    }

    return DateFormat(pattern, locale).format(_toLocal(dateTime));
  }

  static String formatDate(
    DateTime? dateTime, {
    String pattern = defaultDatePattern,
    String locale = 'id',
  }) {
    if (dateTime == null) {
      return '-';
    }

    return DateFormat(pattern, locale).format(_toLocal(dateTime));
  }

  static String formatBackendValue(
    Object? value, {
    String pattern = defaultDateTimePattern,
    String locale = 'id',
  }) {
    if (value == null) {
      return '-';
    }

    DateTime? parsed;

    if (value is DateTime) {
      parsed = value;
    } else if (value is int) {
      parsed = DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      parsed = DateTime.tryParse(value);
    }

    if (parsed == null) {
      return value.toString();
    }

    return DateFormat(pattern, locale).format(_toLocal(parsed));
  }
}
