import 'package:material_ui/material_ui.dart';

import 'calc_button.dart';

/// 5x7 Mathematical Keypad Matrix.
/// Uses LayoutBuilder to compute pixel-exact button dimensions in a single pass,
/// eliminating GridView scrolling overhead and subpixel jitter.
class CalcKeypad extends StatelessWidget {
  const CalcKeypad({
    super.key,
    required this.symbols,
    required this.isDeg,
    required this.isShift,
    required this.onKeyPressed,
    this.onKeyLongPressed,
  });

  final List<String> symbols;
  final bool isDeg;
  final bool isShift;
  final ValueChanged<String> onKeyPressed;
  final ValueChanged<String>? onKeyLongPressed;

  static const int _columns = 5;
  static const int _rows = 7;
  static const double _crossAxisSpacing = 6.0;
  static const double _mainAxisSpacing = 6.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        final buttonWidth =
            ((availableWidth - (_crossAxisSpacing * (_columns - 1))) / _columns)
                .clamp(0.0, double.infinity);

        final buttonHeight =
            ((availableHeight - (_mainAxisSpacing * (_rows - 1))) / _rows)
                .clamp(0.0, double.infinity);

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (int r = 0; r < _rows; r++)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int c = 0; c < _columns; c++) ...[
                    _buildButton(
                      index: r * _columns + c,
                      width: buttonWidth,
                      height: buttonHeight,
                    ),
                  ],
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildButton({
    required int index,
    required double width,
    required double height,
  }) {
    if (index >= symbols.length) {
      return SizedBox(width: width, height: height);
    }

    final symbol = symbols[index];

    return CalcButton(
      symbol: symbol,
      width: width,
      height: height,
      isDeg: isDeg,
      isShift: isShift,
      onPressed: () => onKeyPressed(symbol),
      onLongPress: symbol == 'del'
          ? () => (onKeyLongPressed ?? onKeyPressed).call('AC')
          : null,
    );
  }
}
