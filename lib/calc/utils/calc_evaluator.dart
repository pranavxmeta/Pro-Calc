import 'package:exath_engine/exath_engine.dart';
import 'package:intl/intl.dart';

/// Pure evaluation adapter for `exath_engine`.
final class CalcEvaluator {
  const CalcEvaluator._();

  static final RegExp _endingOperatorRegex = RegExp(r'[+\-*/×÷%^]$');
  static final RegExp _endingOpenParenRegex = RegExp(r'\($');
  static final RegExp _operatorRegex = RegExp(r'[+\-*/×÷%^E]');
  static final RegExp _functionRegex = RegExp(r'(sin|cos|tan|log|ln|√)');
  static final RegExp _endsWithERegex = RegExp(r'E[+-]?$');

  /// Determines whether the expression is syntactically incomplete for live evaluation.
  static bool shouldSkipLiveEvaluation(String expression) {
    final trimmed = expression.trim();
    if (trimmed.isEmpty) return true;

    final openCount = '('.allMatches(trimmed).length;
    final closeCount = ')'.allMatches(trimmed).length;

    return (!_operatorRegex.hasMatch(trimmed) &&
            !_functionRegex.hasMatch(trimmed)) ||
        _endingOperatorRegex.hasMatch(trimmed) ||
        _endsWithERegex.hasMatch(trimmed) ||
        _endingOpenParenRegex.hasMatch(trimmed) ||
        (openCount != closeCount);
  }

  /// Contextual and signed percentage parser supporting discount scenarios:
  /// - `100 * -6%`  -> `100 * (-0.06)` = `-6`
  /// - `100 + -6%`  -> `100 + (-6.0)`  = `94`
  /// - `100 - 6%`   -> `100 - (6.0)`   = `94`
  /// - `-6%`        -> `(-0.06)`
  static String processPercentages(String expression) {
    if (!expression.contains('%')) return expression;

    var clean = expression.replaceAll(',', '');

    // 1. Additive contextual percentages with optional sign: e.g. 100 + -6% or 100 - 15%
    clean = clean.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?)\s*([+\-])\s*([+-]?\d+(?:\.\d+)?)%'),
      (m) {
        final base = double.tryParse(m[1]!) ?? 0;
        final op = m[2]!;
        final pct = (double.tryParse(m[3]!) ?? 0) / 100;
        final delta = base * pct;
        return '$base $op ($delta)';
      },
    );

    // 2. Multiplicative / division / standalone signed percentages: e.g. 100 * -6% -> 100 * (-0.06)
    clean = clean.replaceAllMapped(RegExp(r'([+-]?\d+(?:\.\d+)?)%'), (m) {
      final val = (double.tryParse(m[1]!) ?? 0) / 100;
      return '($val)';
    });

    return clean;
  }

  /// Sanitizes and evaluates mathematical expression with exath_engine.
  static String evaluate({
    required String rawExpression,
    required bool isDeg,
    required Map<String, double> variables,
    required NumberFormat numberFormat,
  }) {
    var expr = rawExpression.trim();
    if (expr.isEmpty) return '';

    expr = processPercentages(expr);

    // Expand scientific E-notations
    var processed = expr.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?)\s*E\s*([+-]?\d+)'),
      (m) => '(${m[1]} * 10^(${m[2]}))',
    );
    processed = processed.replaceAllMapped(
      RegExp(r'(?<![\d.])E\s*([+-]?\d+)'),
      (m) => '(10^(${m[1]}))',
    );

    // Normalize display symbols to engine syntax
    final prepared = processed
        .replaceAll(',', '')
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('√', 'sqrt')
        .replaceAll('sin⁻¹', 'asin')
        .replaceAll('cos⁻¹', 'acos')
        .replaceAll('tan⁻¹', 'atan');

    final session = ExathSession(
      angleMode: isDeg ? AngleMode.deg : AngleMode.rad,
    );
    try {
      for (final entry in variables.entries) {
        session.setVar(entry.key, entry.value);
      }
      final evalResult = session.eval(prepared);

      if (evalResult.isError) throw Exception(evalResult.error);

      if (evalResult.isComplex) {
        return formatComplex(evalResult.re, evalResult.im, numberFormat);
      }

      if (!evalResult.re.isFinite) throw Exception('Result is not finite');

      return formatNumber(evalResult.re, numberFormat);
    } finally {
      session.dispose(); // Guarded against native memory leaks
    }
  }

  static String formatNumber(double number, NumberFormat numberFormat) {
    if (number.isInfinite || number.isNaN) return 'Error';
    if (number.abs() > 1e9 || (number != 0 && number.abs() < 1e-9)) {
      return number.toStringAsExponential(9);
    }
    return numberFormat.format(number);
  }

  static String formatComplex(double re, double im, NumberFormat numberFormat) {
    final imPart = '${formatNumber(im.abs(), numberFormat)}i';
    if (re.abs() < 1e-12) return im < 0 ? '-$imPart' : imPart;
    return '${formatNumber(re, numberFormat)} ${im < 0 ? '-' : '+'} $imPart';
  }
}
