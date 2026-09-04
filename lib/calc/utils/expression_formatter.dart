import 'package:intl/intl.dart';

/// Bundle containing formatted string and bidirectional position maps.
typedef FormattedExpressionResult = ({
  String formattedText,
  Map<int, int> rawToFormatted,
  Map<int, int> formattedToRaw,
});

/// Pure utility responsible for localization and cursor tracking.
final class ExpressionFormatter {
  const ExpressionFormatter._();

  static FormattedExpressionResult format(
    String raw,
    NumberFormat numberFormat,
  ) {
    if (raw.isEmpty) {
      return (
        formattedText: '',
        rawToFormatted: {0: 0},
        formattedToRaw: {0: 0},
      );
    }

    final rawToFormatted = <int, int>{};
    final formattedToRaw = <int, int>{};
    final formattedBuffer = StringBuffer();
    final currentNumberBuffer = StringBuffer();

    int rawPos = 0;
    int formattedPos = 0;

    void flushNumber() {
      if (currentNumberBuffer.isEmpty) return;

      final numberStr = currentNumberBuffer.toString();
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

      final originalLength = numberStr.length;
      final formattedLength = formattedNumber.length;

      for (int i = 0; i < originalLength; i++) {
        int adjustedFormattedPos = formattedPos + i;
        for (int j = 0; j < formattedLength; j++) {
          if (formattedNumber[j] == ',' && j <= adjustedFormattedPos) {
            adjustedFormattedPos++;
          }
        }
        final currentRawPos = rawPos - originalLength + i;
        rawToFormatted[currentRawPos] = adjustedFormattedPos;
        formattedToRaw[adjustedFormattedPos] = currentRawPos;
      }

      formattedBuffer.write(formattedNumber);
      formattedPos += formattedLength;
      currentNumberBuffer.clear();
    }

    for (int i = 0; i < raw.length; i++) {
      final char = raw[i];
      if (RegExp(r'[0-9.]').hasMatch(char)) {
        currentNumberBuffer.write(char);
      } else {
        flushNumber();
        formattedBuffer.write(char);
        rawToFormatted[i] = formattedPos;
        formattedToRaw[formattedPos] = i;
        formattedPos++;
      }
      rawPos++;
    }

    flushNumber();
    rawToFormatted.putIfAbsent(raw.length, () => formattedPos);
    formattedToRaw.putIfAbsent(formattedPos, () => raw.length);

    return (
      formattedText: formattedBuffer.toString(),
      rawToFormatted: rawToFormatted,
      formattedToRaw: formattedToRaw,
    );
  }
}
