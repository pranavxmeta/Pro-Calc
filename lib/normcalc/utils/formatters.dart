// lib/normcalc/utils/formatters.dart

final class CalcFormatter {
  const CalcFormatter._();

  /// Formats double outputs cleanly (e.g., strips trailing `.0`, handles NaN/Infinity).
  static String formatResult(double value) {
    if (value.isNaN) return 'Cannot divide by 0';
    if (value.isInfinite) return value.isNegative ? '-Infinity' : 'Infinity';

    // Check if the number is an exact integer
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    // Limit precision to 8 decimal places and strip trailing zeros
    final str = value.toStringAsFixed(8);
    return str.contains('.')
        ? str.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '')
        : str;
  }
}
