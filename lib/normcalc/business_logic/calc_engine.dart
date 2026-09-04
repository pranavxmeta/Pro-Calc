// lib/normcalc/business_logic/calc_engine.dart

import '../models/operation.dart';

final class CalcEngine {
  const CalcEngine();

  /// Evaluates an ordered list of equation steps in real time.
  double evaluate(List<EquationStep> stream, String currentBuffer) {
    if (stream.isEmpty && currentBuffer.isEmpty) return 0.0;

    final parsedCurrent = double.tryParse(currentBuffer);

    // Build token lists using named fields
    final numbers = <double>[
      for (final step in stream) step.value,
      ?parsedCurrent,
    ];

    final operators = <Operation>[for (final step in stream) ?step.op];

    if (numbers.isEmpty) return 0.0;
    if (operators.isEmpty) return numbers.first;

    // First pass: Multiply & Divide (Precedence 2)
    final intermediateNumbers = <double>[numbers.first];
    final intermediateOps = <Operation>[];

    for (var i = 0; i < operators.length; i++) {
      final nextNum = (i + 1 < numbers.length) ? numbers[i + 1] : numbers[i];
      final op = operators[i];

      if (op.precedence == 2) {
        final prev = intermediateNumbers.removeLast();
        final res = op.compute(prev, nextNum);
        intermediateNumbers.add(res);
      } else {
        intermediateOps.add(op);
        if (i + 1 < numbers.length) {
          intermediateNumbers.add(nextNum);
        }
      }
    }

    // Second pass: Add & Subtract (Precedence 1)
    var result = intermediateNumbers.first;
    for (var i = 0; i < intermediateOps.length; i++) {
      if (i + 1 < intermediateNumbers.length) {
        result = intermediateOps[i].compute(result, intermediateNumbers[i + 1]);
      }
    }

    return result;
  }
}
