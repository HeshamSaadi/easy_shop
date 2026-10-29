/// Formats prices the same way everywhere: whole numbers have no decimals.
abstract final class PriceFormatter {
  static const int _decimals = 2;

  static String format(double value) {
    final isWhole = value == value.roundToDouble();
    return isWhole
        ? value.toInt().toString()
        : value.toStringAsFixed(_decimals);
  }
}
