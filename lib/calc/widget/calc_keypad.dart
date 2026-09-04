import 'package:flutter/cupertino.dart';

import 'calc_button.dart';

/// Responsive button matrix calculating layout metrics directly from parent constraints.
class CalcKeypad extends StatelessWidget {
  const CalcKeypad({
    super.key,
    required this.symbols,
    required this.onKeyPressed,
    required this.isDeg,
    required this.isShift,
  });

  final List<String> symbols;
  final ValueChanged<String> onKeyPressed;
  final bool isDeg;
  final bool isShift;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 5;
        const runSpacing = 8.0;
        final totalWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight - 15.0;
        final rows = (symbols.length / columns).ceil();

        final itemWidth = totalWidth / columns;
        final btnWidth = itemWidth * 0.9;
        final btnHeight = ((availableHeight - ((rows - 1) * runSpacing)) / rows)
            .clamp(0.0, availableHeight);

        return Padding(
          padding: const .only(bottom: 15.0),
          child: Wrap(
            runSpacing: runSpacing,
            children: symbols.map((symbol) {
              return SizedBox(
                width: itemWidth,
                child: Center(
                  child: CalcButton(
                    symbol: symbol,
                    width: btnWidth,
                    height: btnHeight,
                    isDeg: isDeg,
                    isShift: isShift,
                    onPressed: () => onKeyPressed(symbol),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
