import '../model/note_item.dart';

final class MathEvaluator {
  const MathEvaluator._();

  /// Extracts arithmetic expressions from lines like '100 = fuel', 'fuel = 100 * 2', or '150.50'
  static double? evaluateText(String rawText) {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) return null;

    String candidate = trimmed;
    if (trimmed.contains('=')) {
      final parts = trimmed.split('=');
      // If "100 = rent", take left side. If "rent = 100", take right side.
      final left = parts[0].trim();
      final right = parts.sublist(1).join('=').trim();
      candidate = _hasMathTokens(left) ? left : right;
    }

    return _evaluateSimpleExpression(candidate);
  }

  static bool _hasMathTokens(String input) {
    return RegExp(r'[0-9]').hasMatch(input);
  }

  static double? _evaluateSimpleExpression(String input) {
    // Strip non-arithmetic characters except digits, decimals, and operators
    final sanitized = input
        .replaceAll(RegExp(r'[^0-9\.\+\-\*\/\(\)\s]'), '')
        .trim();
    if (sanitized.isEmpty) return null;

    // Fast direct parse
    final directVal = double.tryParse(sanitized);
    if (directVal != null) return directVal;

    // Minimal recursive-descent parser for basic arithmetic without external packages
    try {
      final tokens = _tokenize(sanitized);
      if (tokens.isEmpty) return null;
      var parser = _Parser(tokens);
      final result = parser.parseExpression();
      return (result.isNaN || result.isInfinite) ? null : result;
    } catch (_) {
      return null;
    }
  }

  static List<String> _tokenize(String expression) {
    final List<String> tokens = [];
    final regex = RegExp(r'(\d+(\.\d+)?|[\+\-\*\/\(\)])');
    for (final match in regex.allMatches(expression)) {
      tokens.add(match.group(0)!);
    }
    return tokens;
  }

  /// Recalculates all 20 lines, resolving block subtotals and grand total
  static (List<NoteItem> calculated, double grandTotal) computeDocument(
    List<NoteItem> items,
  ) {
    final List<NoteItem> resolved = [];
    final List<double> currentBlock = [];
    double totalSum = 0.0;

    for (final item in items) {
      if (item.type.isSubtotal) {
        final blockSubtotal = currentBlock.fold(0.0, (acc, val) => acc + val);
        resolved.add(item.copyWith(computedValue: blockSubtotal));
        currentBlock.clear();
      } else {
        final val = evaluateText(item.text);
        if (val != null) {
          currentBlock.add(val);
          totalSum += val;
          resolved.add(item.copyWith(computedValue: val));
        } else {
          resolved.add(item.copyWith(computedValue: null));
        }
      }
    }

    return (resolved, totalSum);
  }
}

final class _Parser {
  final List<String> tokens;
  int _pos = 0;

  _Parser(this.tokens);

  double parseExpression() {
    double value = _parseTerm();
    while (_pos < tokens.length) {
      final op = tokens[_pos];
      if (op == '+' || op == '-') {
        _pos++;
        final nextTerm = _parseTerm();
        value = (op == '+') ? (value + nextTerm) : (value - nextTerm);
      } else {
        break;
      }
    }
    return value;
  }

  double _parseTerm() {
    double value = _parseFactor();
    while (_pos < tokens.length) {
      final op = tokens[_pos];
      if (op == '*' || op == '/') {
        _pos++;
        final nextFactor = _parseFactor();
        value = (op == '*') ? (value * nextFactor) : (value / nextFactor);
      } else {
        break;
      }
    }
    return value;
  }

  double _parseFactor() {
    if (_pos >= tokens.length) return 0.0;
    final token = tokens[_pos++];
    if (token == '(') {
      final value = parseExpression();
      if (_pos < tokens.length && tokens[_pos] == ')') _pos++;
      return value;
    }
    return double.tryParse(token) ?? 0.0;
  }
}
