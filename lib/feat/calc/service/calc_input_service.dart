/// Pure input service managing calculator token insertion, engine syntax
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

  static const List<String> shiftedKeypadSymbols = [
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
    '±',
    'log',
    '00',
    '0',
    '.',
    '=',
  ];

  static final RegExp _leadingAnyOperatorRegex = RegExp(r'^[+\-*/×÷^]+');
  static final RegExp digitRegex = RegExp(r'[0-9]$');
  static final RegExp operatorRegex = RegExp(r'[+\-*/×÷]$');
  static final RegExp _anyOperatorTrailingRegex = RegExp(r'[+\-*/×÷^]$');
  static final RegExp _leadingBinaryOperatorRegex = RegExp(r'^[+\*/×÷^]+');
  static final RegExp numberOrParenRegex = RegExp(r'([\d.)eπXYk!%])$');
  static final RegExp operandPattern = RegExp(r'(\d*\.?\d+|\d+\.|[XYxyπek])$');
  static final RegExp wrappedNegatedOperandPattern = RegExp(
    r'\(-(\d*\.?\d+|\d+\.|[XYxyπek])\)$',
  );
  static final RegExp openNegatedOperandPattern = RegExp(
    r'\(-(\d*\.?\d+|\d+\.|[XYxyπek])$',
  );
  static final RegExp _unaryMinusPattern = RegExp(
    r'(^|[+\-*/×÷^(E])\-(\d*\.?\d+|\d+\.|[XYxyπek])$',
  );
  static final RegExp _functionPrefixRegex = RegExp(
    r'(?:sin|cos|tan|log|ln|abs|cbrt|√|⁻¹)$',
  );
  static final RegExp _trailingNumberRegex = RegExp(r'(\d*\.?\d+)$');
  static final RegExp _zerosOnlyRegex = RegExp(r'^0+$');

  /// Returns keypad symbols dynamically updated for the active shift mode.
  /// When shift is enabled, '+' transforms into '±'.
  static List<String> getKeypadSymbols({required bool isShift}) =>
      isShift ? shiftedKeypadSymbols : keypadSymbols;

  /// Resolves functions based on active shift state and engine syntax.
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
  /// injected before functions, constants, or identifiers when preceded by a number,
  /// constant, postfix operator, or closing parenthesis.
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

    final newBefore = before + insertText;
    return (expression: newBefore + after, cursor: newBefore.length);
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
    if (textBefore.isEmpty || !digitRegex.hasMatch(textBefore)) {
      return null;
    }

    // Guard: Prevent '00' on standalone leading zeros (e.g., '0' -> '000')
    final match = _trailingNumberRegex.firstMatch(textBefore);
    if (match != null && _zerosOnlyRegex.hasMatch(match.group(0)!)) {
      return null;
    }

    return insertToken(
      expression: expression,
      cursor: clampedCursor,
      token: '00',
    );
  }

  /// Handles operator entry (`+`, `-`, `×`, `÷`, `^`) and consecutive operator
  /// substitution, while preventing invalid leading or post-paren binary operators.
  static ({String expression, int cursor}) handleOperator({
    required String expression,
    required int cursor,
    required String operator,
  }) {
    final clampedCursor = cursor.clamp(0, expression.length);
    final textBefore = expression.substring(0, clampedCursor);
    final textAfter = expression.substring(clampedCursor);
    final trimmedBefore = textBefore.trimRight();
    final trimmedAfter = textAfter.trimLeft();

    // Guard: Empty prefix or open parenthesis can only start with a unary minus
    if (trimmedBefore.isEmpty || trimmedBefore.endsWith('(')) {
      if (operator == '-' && !trimmedAfter.startsWith('-')) {
        final newBefore = '$textBefore-';
        return (expression: newBefore + textAfter, cursor: newBefore.length);
      }
      return (expression: expression, cursor: clampedCursor);
    }

    // Check if preceding context ends with an operator
    if (_anyOperatorTrailingRegex.hasMatch(trimmedBefore)) {
      // Protect unary minus at expression start ('-') or after '(' ('(-')
      final isLeadingOrParenUnary =
          trimmedBefore == '-' ||
          (trimmedBefore.length >= 2 &&
              trimmedBefore.endsWith('-') &&
              trimmedBefore[trimmedBefore.length - 2] == '(');
      if (isLeadingOrParenUnary) {
        return (expression: expression, cursor: clampedCursor);
      }

      // Allow trailing '-' for unary negation after a binary operator (e.g., '5 × -')
      if (operator == '-' && !trimmedBefore.endsWith('-')) {
        if (trimmedAfter.startsWith('-')) {
          return (expression: expression, cursor: clampedCursor);
        }
        final newBefore = '$textBefore-';
        return (expression: newBefore + textAfter, cursor: newBefore.length);
      }

      // Replace existing operator(s) and any trailing whitespace cleanly
      var cutPos = trimmedBefore.length - 1;
      if (trimmedBefore.length >= 2 &&
          _anyOperatorTrailingRegex.hasMatch(
            trimmedBefore[trimmedBefore.length - 2],
          )) {
        cutPos = trimmedBefore.length - 2;
      }

      final cleanPrefix = trimmedBefore.substring(0, cutPos);
      final cleanAfter = _stripLeadingBinaryOperators(
        trimmedAfter,
        keepUnaryMinus: operator != '-',
      );
      final newBefore = cleanPrefix + operator;
      return (expression: newBefore + cleanAfter, cursor: newBefore.length);
    }

    // Mid-expression insertion right before an existing operator (e.g., '5|+3')
    if (operator == '-' && trimmedAfter.startsWith('-')) {
      return (expression: expression, cursor: clampedCursor);
    }

    final cleanAfter = _stripLeadingBinaryOperators(
      trimmedAfter,
      keepUnaryMinus: operator != '-',
    );
    final newBefore = textBefore + operator;
    return (expression: newBefore + cleanAfter, cursor: newBefore.length);
  }

  /// Toggles negation (`±`) of the current numeric token bidirectionally:
  /// `5` -> `(-5)` -> `5` without leaking parentheses or ignoring cursor offsets.
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

    // Case 1: Cursor immediately after a wrapped negative: '(-5)|' -> '5|'
    final wrappedMatch = wrappedNegatedOperandPattern.firstMatch(textBefore);
    if (wrappedMatch != null) {
      final operand = wrappedMatch.group(1)!;
      final start = wrappedMatch.start;
      final prefix = textBefore.substring(0, start);

      // Preserve function parentheses like 'sin(-5)|' -> 'sin(5)|'
      if (_functionPrefixRegex.hasMatch(prefix)) {
        final newBefore = '$prefix($operand)';
        return (expression: newBefore + textAfter, cursor: newBefore.length);
      }

      final needsMul = numberOrParenRegex.hasMatch(prefix);
      final newBefore = needsMul ? '$prefix×$operand' : '$prefix$operand';
      return (expression: newBefore + textAfter, cursor: newBefore.length);
    }

    // Case 2: Cursor inside a negative with trailing paren: '(-5|)' -> '5|'
    final openMatch = openNegatedOperandPattern.firstMatch(textBefore);
    if (openMatch != null && textAfter.startsWith(')')) {
      final operand = openMatch.group(1)!;
      final start = openMatch.start;
      final prefix = textBefore.substring(0, start);

      // Preserve function parentheses like 'sin(-5|)' -> 'sin(5|)'
      if (_functionPrefixRegex.hasMatch(prefix)) {
        final newBefore = '$prefix($operand';
        return (expression: newBefore + textAfter, cursor: newBefore.length);
      }

      final needsMul = numberOrParenRegex.hasMatch(prefix);
      final newBefore = needsMul ? '$prefix×$operand' : '$prefix$operand';
      final newAfter = textAfter.substring(1);
      return (expression: newBefore + newAfter, cursor: newBefore.length);
    }

    // Case 3: Empty context, trailing operator, or open paren -> toggle or insert '(-'
    final trimmedBefore = textBefore.trimRight();
    if (trimmedBefore.isEmpty ||
        _anyOperatorTrailingRegex.hasMatch(trimmedBefore) ||
        trimmedBefore.endsWith('(')) {
      if (trimmedBefore == '-') {
        return (expression: textAfter, cursor: 0);
      }
      if (trimmedBefore.endsWith('(-')) {
        final prefix = trimmedBefore.substring(0, trimmedBefore.length - 2);
        final newBefore = _functionPrefixRegex.hasMatch(prefix)
            ? '$prefix('
            : prefix;
        return (expression: newBefore + textAfter, cursor: newBefore.length);
      }
      if (trimmedBefore.length >= 2 &&
          trimmedBefore.endsWith('-') &&
          _anyOperatorTrailingRegex.hasMatch(
            trimmedBefore[trimmedBefore.length - 2],
          )) {
        final newBefore = trimmedBefore.substring(0, trimmedBefore.length - 1);
        return (expression: newBefore + textAfter, cursor: newBefore.length);
      }

      final newBefore = '$textBefore(-';
      return (expression: newBefore + textAfter, cursor: newBefore.length);
    }

    // Case 4: Preceded by unary minus (e.g., '-5', '5×-5', '(-5', 'sin(-5')
    final unaryMinusMatch = _unaryMinusPattern.firstMatch(textBefore);
    if (unaryMinusMatch != null) {
      final delimiter = unaryMinusMatch.group(1)!;
      final operand = unaryMinusMatch.group(2)!;
      final prefix = textBefore.substring(0, unaryMinusMatch.start);

      String newBefore;
      if (delimiter == '(' && !_functionPrefixRegex.hasMatch(prefix)) {
        // Remove orphaned '(' from an unclosed '(-5' -> '5' (or '5×5')
        final needsMul = numberOrParenRegex.hasMatch(prefix);
        newBefore = needsMul ? '$prefix×$operand' : '$prefix$operand';
      } else {
        newBefore = '$prefix$delimiter$operand';
      }
      return (expression: newBefore + textAfter, cursor: newBefore.length);
    }

    // Case 5: Standard positive operand -> wrap as '(-operand)'
    final operandMatch = operandPattern.firstMatch(textBefore);
    if (operandMatch != null) {
      final operand = operandMatch.group(0)!;
      final start = operandMatch.start;
      final newBefore = '${textBefore.substring(0, start)}(-$operand)';
      return (expression: newBefore + textAfter, cursor: newBefore.length);
    }

    // Fallback: insert multiplication negation at cursor
    final newBefore = '$textBefore×(-1)';
    return (expression: newBefore + textAfter, cursor: newBefore.length);
  }

  /// Validates decimal point insertion at the active cursor offset.
  /// Prevents duplicate decimals in the current operand, blocks decimals after
  /// non-numeric tokens or inside scientific exponents, and prepends '0.' after
  /// operators or open parentheses.
  static ({String expression, int cursor})? handleDecimal({
    required String expression,
    required int cursor,
  }) {
    final clampedCursor = cursor.clamp(0, expression.length);
    final textBefore = expression.substring(0, clampedCursor);
    final textAfter = expression.substring(clampedCursor);

    if (_hasDecimalInAdjacentNumber(textBefore, textAfter)) {
      return null;
    }

    final trimmedBefore = textBefore.trimRight();
    if (trimmedBefore.isEmpty ||
        _anyOperatorTrailingRegex.hasMatch(trimmedBefore) ||
        trimmedBefore.endsWith('(')) {
      return insertToken(
        expression: expression,
        cursor: clampedCursor,
        token: '0.',
      );
    }

    if (digitRegex.hasMatch(textBefore) &&
        !_isInScientificExponent(textBefore)) {
      return insertToken(
        expression: expression,
        cursor: clampedCursor,
        token: '.',
      );
    }

    return null;
  }

  static String _stripLeadingBinaryOperators(
    String trimmedAfter, {
    required bool keepUnaryMinus,
  }) {
    if (trimmedAfter.isEmpty) return trimmedAfter;
    if (keepUnaryMinus && trimmedAfter.startsWith('-')) {
      return trimmedAfter;
    }
    return trimmedAfter.replaceFirst(
      keepUnaryMinus ? _leadingBinaryOperatorRegex : _leadingAnyOperatorRegex,
      '',
    );
  }

  static bool _hasDecimalInAdjacentNumber(String textBefore, String textAfter) {
    for (var i = textBefore.length - 1; i >= 0; i--) {
      final code = textBefore.codeUnitAt(i);
      if (code == 0x2E /* '.' */ ) return true;
      if (code < 0x30 || code > 0x39) break;
    }
    for (var i = 0; i < textAfter.length; i++) {
      final code = textAfter.codeUnitAt(i);
      if (code == 0x2E /* '.' */ ) return true;
      if (code < 0x30 || code > 0x39) break;
    }
    return false;
  }

  static bool _isInScientificExponent(String textBefore) {
    var i = textBefore.length - 1;
    while (i >= 0) {
      final code = textBefore.codeUnitAt(i);
      if (code >= 0x30 && code <= 0x39) {
        i--;
      } else {
        break;
      }
    }
    if (i >= 0 && textBefore.codeUnitAt(i) == 0x45 /* 'E' */ ) {
      return true;
    }
    return i >= 1 &&
        textBefore.codeUnitAt(i) == 0x2D /* '-' */ &&
        textBefore.codeUnitAt(i - 1) == 0x45 /* 'E' */;
  }
}
