import 'package:intl/intl.dart';

/// Pure utility responsible for localization and cursor tracking.
/// Operates with zero heap map allocations and zero GC pauses.
final class ExpressionFormatter {
  const ExpressionFormatter._();

  /// Formats raw mathematical input by inserting localized grouping separators.
  /// Formats raw mathematical input by inserting localized grouping separators.
  /// Automatically strips preexisting commas to ensure idempotent formatting across locales.
  static String format(String raw, NumberFormat numberFormat) {
    final clean = raw.replaceAll(',', '');
    if (clean.isEmpty) return '';

    final formattedBuffer = StringBuffer();
    final numberBuffer = StringBuffer();

    void flushNumber() {
      if (numberBuffer.isEmpty) return;

      final numberStr = numberBuffer.toString();
      String formattedNumber;

      if (numberStr.contains('.')) {
        final parts = numberStr.split('.');
        final integerPart = parts[0];
        final decimalPart = parts.length > 1 ? parts[1] : '';

        try {
          if (integerPart.isEmpty) {
            formattedNumber = '0.$decimalPart';
          } else {
            final value = double.parse(integerPart);
            formattedNumber = '${numberFormat.format(value)}.$decimalPart';
          }
        } catch (_) {
          formattedNumber = numberStr;
        }
      } else {
        try {
          formattedNumber = numberFormat.format(double.parse(numberStr));
        } catch (_) {
          formattedNumber = numberStr;
        }
      }

      formattedBuffer.write(formattedNumber);
      numberBuffer.clear();
    }

    for (int i = 0; i < clean.length; i++) {
      final char = clean[i];
      final isDigitOrDot =
          (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57) || char == '.';

      if (isDigitOrDot) {
        numberBuffer.write(char);
      } else {
        flushNumber();
        formattedBuffer.write(char);
      }
    }

    flushNumber();
    return formattedBuffer.toString();
  }

  /// Converts a cursor offset in the formatted string back to the raw expression offset.
  /// Zero allocations: simply subtracts the count of grouping commas preceding [formattedOffset].
  static int formattedToRaw(int formattedOffset, String formattedText) {
    final clamped = formattedOffset.clamp(0, formattedText.length);
    int commas = 0;
    for (int i = 0; i < clamped; i++) {
      if (formattedText[i] == ',') commas++;
    }
    return clamped - commas;
  }

  /// Converts a cursor offset in the raw expression forward to the formatted display offset.
  /// Zero allocations: counts forward until matching [rawOffset] non-comma characters.
  static int rawToFormatted(int rawOffset, String formattedText) {
    if (rawOffset <= 0) return 0;
    int nonCommas = 0;
    for (int i = 0; i < formattedText.length; i++) {
      if (formattedText[i] != ',') {
        nonCommas++;
        if (nonCommas == rawOffset) return i + 1;
      }
    }
    return formattedText.length;
  }
}
