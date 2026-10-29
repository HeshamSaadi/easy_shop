import 'package:easy_shop/core/utils/date_formatter.dart';
import 'package:easy_shop/core/utils/price_formatter.dart';

abstract final class ProductFormatters {
  /// Whole numbers without decimals (299), others with two (12.50).
  static String price(double value) => PriceFormatter.format(value);

  /// "Jan 10, 2024" in the device time zone, because the API sends UTC.
  static String date(DateTime value) => AppDateFormatter.date(value);
}
