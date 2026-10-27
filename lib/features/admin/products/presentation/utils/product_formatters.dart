import 'package:intl/intl.dart';
import 'package:easy_shop/core/utils/price_formatter.dart';

abstract final class ProductFormatters {
  static const String _datePattern = 'MMM d, y';
  static final DateFormat _dateFormat = DateFormat(_datePattern);

  /// Whole numbers without decimals (299), others with two (12.50).
  static String price(double value) => PriceFormatter.format(value);

  /// "Jan 10, 2024" in the device time zone, because the API sends UTC.
  static String date(DateTime value) => _dateFormat.format(value.toLocal());
}
