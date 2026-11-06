import 'package:intl/intl.dart';

/// Formats dates the same way everywhere. The API sends UTC, so values are
/// converted to the device time zone before they are shown.
abstract final class AppDateFormatter {
  static final DateFormat _dateFormat = DateFormat('MMM d, y');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');

  /// "Jan 10, 2024"
  static String date(DateTime value) => _dateFormat.format(value.toLocal());

  /// "02:32 PM"
  static String time(DateTime value) => _timeFormat.format(value.toLocal());
}
