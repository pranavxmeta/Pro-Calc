import 'dart:math' as math;

import 'package:intl/intl.dart';

/// Pure utility responsible for localization, spaced typography, accounting tape formatting,
/// and bidirectional cursor tracking across localized tokens.
final class ExpressionFormatter {
  const ExpressionFormatter._();

  static final RegExp _binaryOperatorRegex = RegExp(r'[+\-*/×÷]');

  /// Formats raw mathematical input.
  /// When [isVertical] is false: produces clean, spaced horizontal infix math (`1,250 + 350 × 2`).
  /// When [isVertical] is true: produces an accounting ledger tape with Line 1 padded by
  /// a Unicode figure space `\u2007` to match operator columns pixel-for-pixel.
  static String format(
    String raw,
    NumberFormat numberFormat, {
    bool isVertical = false,
  }) {
    final clean = raw.replaceAll(',', '').replaceAll(RegExp(r'\s+'), '');
    if (clean.isEmpty) return '';

    if (!isVertical) {
      return _formatHorizontal(clean, numberFormat);
    }

    return _formatVerticalTape(clean, numberFormat);
  }

  /// Formats standard single-line expressions with spaces around binary operators
  /// (` + `, ` - `, ` × `, ` ÷ `) while keeping unary minuses tight (`-5`).
  static String _formatHorizontal(String clean, NumberFormat numberFormat) {
    final buffer = StringBuffer();
    final numberBuffer = StringBuffer();

    void flushNumber() {
      if (numberBuffer.isEmpty) return;
      buffer.write(_formatScalar(numberBuffer.toString(), numberFormat));
      numberBuffer.clear();
    }

    for (int i = 0; i < clean.length; i++) {
      final char = clean[i];

      // Distinguish unary minus from binary subtraction
      final isUnaryMinus =
          char == '-' &&
          (i == 0 ||
              _binaryOperatorRegex.hasMatch(clean[i - 1]) ||
              clean[i - 1] == '(' ||
              clean[i - 1] == 'E' ||
              clean[i - 1] == 'e');

      final isBinaryOp = !isUnaryMinus && _binaryOperatorRegex.hasMatch(char);

      final isDigitOrDot =
          (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57) || char == '.';

      if (isDigitOrDot) {
        numberBuffer.write(char);
      } else {
        flushNumber();
        if (isBinaryOp) {
          buffer.write(' $char ');
        } else {
          buffer.write(char);
        }
      }
    }

    flushNumber();
    return buffer.toString();
  }

  /// Formats expressions into an authentic vertical accounting ledger tape:
  /// - Line 1: Initial base value padded with `  \u2007` (2 spaces + 1 Unicode Figure Space)
  ///   matching the exact advance width of the operator column on subsequent lines.
  /// - Lines 2+: `<number>  <operator>` with the operator on the far right.
  /// - Unclosed parentheses (parenDepth > 0) never break to a new row.
  static String _formatVerticalTape(String clean, NumberFormat numberFormat) {
    final rows = <({String operand, String operator})>[];
    final currentOperand = StringBuffer();
    String pendingOperator = '';
    int parenDepth = 0;

    for (int i = 0; i < clean.length; i++) {
      final char = clean[i];

      if (char == '(') {
        parenDepth++;
        currentOperand.write(char);
        continue;
      }

      if (char == ')') {
        if (parenDepth > 0) parenDepth--;
        currentOperand.write(char);
        continue;
      }

      final isUnaryMinus =
          char == '-' &&
          (i == 0 ||
              _binaryOperatorRegex.hasMatch(clean[i - 1]) ||
              clean[i - 1] == '(');

      // Only top-level operators break onto the next ledger line
      final isBinaryOp =
          parenDepth == 0 &&
          !isUnaryMinus &&
          _binaryOperatorRegex.hasMatch(char);

      if (isBinaryOp) {
        rows.add((
          operand: currentOperand.toString().trim(),
          operator: pendingOperator,
        ));
        currentOperand.clear();
        pendingOperator = char;
      } else {
        currentOperand.write(char);
      }
    }

    // Add trailing active operand
    rows.add((
      operand: currentOperand.toString().trim(),
      operator: pendingOperator,
    ));

    if (rows.isEmpty) return '';

    final lines = <String>[];

    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      final formattedNumber = row.operand.isNotEmpty
          ? _formatScalarOrGroup(row.operand, numberFormat)
          : '';

      if (i == 0) {
        // Line 1: Always padded with 2 spaces + 1 Figure Space (\u2007)
        // Figure Space has the exact advance width of a tabular operator (+, -)
        lines.add('$formattedNumber  \u2007');
      } else {
        // Lines 2+: Number with operator pinned to the right margin
        if (formattedNumber.isEmpty) {
          lines.add('  ${row.operator}');
        } else {
          lines.add('$formattedNumber  ${row.operator}');
        }
      }
    }

    return lines.join('\n');
  }

  /// Formats scalars directly, or sub-expressions with parentheses recursively.
  static String _formatScalarOrGroup(String text, NumberFormat numberFormat) {
    if (text.contains('(') || text.contains(')')) {
      return _formatHorizontal(text, numberFormat);
    }
    return _formatScalar(text, numberFormat);
  }

  /// Localizes an individual numeric string with commas.
  static String _formatScalar(String numberStr, NumberFormat numberFormat) {
    if (numberStr.contains('.')) {
      final parts = numberStr.split('.');
      final integerPart = parts[0];
      final decimalPart = parts.length > 1 ? parts[1] : '';

      try {
        if (integerPart.isEmpty || integerPart == '-') {
          return '${integerPart}0.$decimalPart';
        }
        final value = double.parse(integerPart);
        return '${numberFormat.format(value)}.$decimalPart';
      } catch (_) {
        return numberStr;
      }
    }

    try {
      return numberFormat.format(double.parse(numberStr));
    } catch (_) {
      return numberStr;
    }
  }

  /// Converts a cursor offset in the formatted text back to the raw expression offset.
  static int formattedToRaw(int formattedOffset, String formattedText) {
    final clamped = formattedOffset.clamp(0, formattedText.length);
    int nonRawChars = 0;
    for (int i = 0; i < clamped; i++) {
      final c = formattedText[i];
      // Strip formatting artifacts: commas, newlines, figure spaces, and padded spaces
      if (c == ',' || c == '\n' || c == '\u2007' || c == ' ') {
        nonRawChars++;
      }
    }
    return math.max(0, clamped - nonRawChars);
  }

  /// Converts a cursor offset in the raw expression forward to the formatted display offset.
  static int rawToFormatted(int rawOffset, String formattedText) {
    if (rawOffset <= 0) return 0;
    int rawCharsSeen = 0;
    for (int i = 0; i < formattedText.length; i++) {
      final c = formattedText[i];
      final isFormattingArtifact =
          c == ',' || c == '\n' || c == '\u2007' || c == ' ';
      if (!isFormattingArtifact) {
        rawCharsSeen++;
        if (rawCharsSeen == rawOffset) return i + 1;
      }
    }
    return formattedText.length;
  }
}
