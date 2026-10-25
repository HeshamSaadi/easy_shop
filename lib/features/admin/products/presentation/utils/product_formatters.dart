import 'package:intl/intl.dart';

abstract final class ProductFormatters {
  static const int _priceDecimals = 2;
  static const String _datePattern = 'MMM d, y';
  static final DateFormat _dateFormat = DateFormat(_datePattern);

  /// Whole numbers without decimals (299), others with two (12.50).
  static String price(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(_priceDecimals);
  }

  /// "Jan 10, 2024" in the device time zone, because the API sends UTC.
  static String date(DateTime value) => _dateFormat.format(value.toLocal());
}
