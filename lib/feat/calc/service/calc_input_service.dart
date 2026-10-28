/// Pure input service managing calculator token insertion, exath_engine syntax
/// mapping, cursor offset translation, and operator mechanics.
class CalcInputService {
  const CalcInputService._();

  static const List<String> keypadSymbols = [
    'shft',
    'X',
    'Y',
    'deg',
    'del',
    'sin',
    'cos',
    'tan',
    'π',
    'k',
    '|x|',
    '(',
    ')',
    '%',
    '÷',
    '!',
    '7',
    '8',
    '9',
    '×',
    '^',
    '4',
    '5',
    '6',
    '-',
    '√',
    '1',
    '2',
    '3',
    '+',
    'log',
    '00',
    '0',
    '.',
    '=',
  ];

  static final RegExp digitRegex = RegExp(r'[0-9]$');
  static final RegExp operatorRegex = RegExp(r'[+\-*/×÷]$');
  static final RegExp numberOrParenRegex = RegExp(r'([\d.)eπXY])$');

  /// Returns keypad symbols dynamically updated for the active shift mode.
  /// When shift is enabled, '+' transforms into '±'.
  static List<String> getKeypadSymbols({required bool isShift}) {
    if (!isShift) return keypadSymbols;
    return keypadSymbols.map((key) => key == '+' ? '±' : key).toList();
  }

  /// Resolves functions based on active shift state and exath_engine syntax.
  static String resolveFunctionToken(String key, {required bool isShift}) =>
      switch (key) {
        '√' => isShift ? 'cbrt(' : '√(',
        '∛' || 'cbrt' => 'cbrt(',
        '|x|' || 'abs' => 'abs(',
        'log' => isShift ? 'ln(' : 'log(',
        '^' => isShift ? 'E' : '^',
        'sin' || 'cos' || 'tan' => isShift ? '$key⁻¹(' : '$key(',
        _ => key,
      };

  /// Inserts a token at the current cursor offset with implicit multiplication
  /// injected before functions, parentheses, or variable identifiers.
  static ({String expression, int cursor}) insertToken({
    required String expression,
    required int cursor,
    required String token,
    bool isSuffixFunctionOrConstant = false,
  }) {
    final clampedCursor = cursor.clamp(0, expression.length);
    var insertText = token;
    final before = expression.substring(0, clampedCursor);
    final after = expression.substring(clampedCursor);

    if (isSuffixFunctionOrConstant && numberOrParenRegex.hasMatch(before)) {
      insertText = '×$insertText';
    }

    final newExpression = before + insertText + after;
    final newCursor = clampedCursor + insertText.length;
    return (expression: newExpression, cursor: newCursor);
  }

  /// Inserts '00' only when immediately preceded by a valid digit, preventing
  /// invalid tokens like '+00' or redundant leading zeros like '000'.
  static ({String expression, int cursor})? handleDoubleZero({
    required String expression,
    required int cursor,
  }) {
    final clampedCursor = cursor.clamp(0, expression.length);
    final textBefore = expression.substring(0, clampedCursor);

    // Guard: Must be preceded by a digit
    if (textBefore.isEmpty || !RegExp(r'\d$').hasMatch(textBefore)) {
      return null;
    }

    // Guard: Prevent '00' on a standalone leading zero (e.g., '0' -> '000')
    final match = RegExp(r'(\d*\.?\d+)$').firstMatch(textBefore);
    if (match != null && match.group(0) == '0') {
      return null;
    }

    return insertToken(
      expression: expression,
      cursor: clampedCursor,
      token: '00',
    );
  }

  /// Handles operator entry (`+`, `-`, `×`, `÷`) and consecutive operator substitution.
  static ({String expression, int cursor}) handleOperator({
    required String expression,
    required int cursor,
    required String operator,
  }) {
    final clampedCursor = cursor.clamp(0, expression.length);
    final textBefore = expression.substring(0, clampedCursor);
    final textAfter = expression.substring(clampedCursor);
    final trimmedBefore = textBefore.trim();

    if (operatorRegex.hasMatch(trimmedBefore)) {
      if (operator == '-' && !trimmedBefore.endsWith('-')) {
        return (
          expression: textBefore + operator + textAfter,
          cursor: clampedCursor + 1,
        );
      } else {
        var cutPos = textBefore.length - 1;
        if (trimmedBefore.length >= 2 &&
            operatorRegex.hasMatch(trimmedBefore[trimmedBefore.length - 2])) {
          cutPos = textBefore.length - 2;
        }
        return (
          expression: textBefore.substring(0, cutPos) + operator + textAfter,
          cursor: cutPos + operator.length,
        );
      }
    }

    return (
      expression: textBefore + operator + textAfter,
      cursor: clampedCursor + operator.length,
    );
  }

  /// Toggles negation (`±`) of the current numeric token or evaluated answer.
  static ({String expression, int cursor}) toggleNegate({
    required String expression,
    required int cursor,
  }) {
    if (expression.isEmpty) {
      return (expression: '(-', cursor: 2);
    }

    final clampedCursor = cursor.clamp(0, expression.length);
    final textBefore = expression.substring(0, clampedCursor);
    final textAfter = expression.substring(clampedCursor);

    if (textBefore.isEmpty ||
        operatorRegex.hasMatch(textBefore.trim()) ||
        textBefore.endsWith('(')) {
      return (expression: '$textBefore(-$textAfter', cursor: clampedCursor + 2);
    }

    final match = RegExp(r'(\d*\.?\d+|[XYxyπe])$').firstMatch(textBefore);
    if (match != null) {
      final operand = match.group(0)!;
      final start = match.start;

      if (start >= 2 && textBefore.substring(start - 2, start) == '(-') {
        final newBefore = textBefore.substring(0, start - 2) + operand;
        return (expression: newBefore + textAfter, cursor: clampedCursor - 2);
      } else if (start >= 1 && textBefore[start - 1] == '-') {
        final newBefore = textBefore.substring(0, start - 1) + operand;
        return (expression: newBefore + textAfter, cursor: clampedCursor - 1);
      } else {
        final newBefore = '${textBefore.substring(0, start)}(-$operand)';
        return (expression: newBefore + textAfter, cursor: clampedCursor + 3);
      }
    }

    return (expression: '$expression×(-1)', cursor: expression.length + 5);
  }

  /// Validates decimal point insertion to avoid consecutive or duplicate decimals in a single operand.
  static ({String expression, int cursor})? handleDecimal({
    required String expression,
    required int cursor,
  }) {
    final parts = expression.split(RegExp(r'[+\-*/×÷(]'));
    if (parts.isEmpty || !parts.last.contains('.')) {
      final clampedCursor = cursor.clamp(0, expression.length);
      final textBefore = expression.substring(0, clampedCursor);
      final toInsert =
          (textBefore.isEmpty ||
              operatorRegex.hasMatch(textBefore) ||
              textBefore.endsWith('('))
          ? '0.'
          : '.';
      return insertToken(
        expression: expression,
        cursor: clampedCursor,
        token: toInsert,
      );
    }
    return null;
  }
}
