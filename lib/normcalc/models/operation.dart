// lib/normcalc/models/operation.dart

/// Enhanced Enum representing arithmetic operations with custom symbols and computations.
enum Operation {
  add(symbol: '+', precedence: 1),
  subtract(symbol: '−', precedence: 1),
  multiply(symbol: '×', precedence: 2),
  divide(symbol: '÷', precedence: 2);

  const Operation({required this.symbol, required this.precedence});

  final String symbol;
  final int precedence;

  double compute(double a, double b) => switch (this) {
    Operation.add => a + b,
    Operation.subtract => a - b,
    Operation.multiply => a * b,
    Operation.divide => b == 0 ? double.nan : a / b,
  };

  static Operation? fromSymbol(String char) => switch (char) {
    '+' => Operation.add,
    '-' || '−' => Operation.subtract,
    '*' || '×' => Operation.multiply,
    '/' || '÷' => Operation.divide,
    _ => null,
  };
}

/// Strongly-typed named record for each step in the vertical equation stream.
typedef EquationStep = ({double value, Operation? op});
