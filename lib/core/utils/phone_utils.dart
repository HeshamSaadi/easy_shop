class PhoneUtils {
  PhoneUtils._();

  static const String egyptCode = '+20';
  static const int localLength = 10;

  static final RegExp _nonDigits = RegExp(r'\D');

  static String toLocal(String? input) {
    var digits = (input ?? '').replaceAll(_nonDigits, '');
    if (digits.startsWith('20') && digits.length > localLength) {
      digits = digits.substring(2);
    }
    if (digits.startsWith('0')) digits = digits.substring(1);
    return digits;
  }

  static String toInternational(String? input) => '$egyptCode${toLocal(input)}';
}
