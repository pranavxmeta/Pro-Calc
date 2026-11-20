import 'package:material_ui/material_ui.dart';

import 'calc_button.dart';

/// Matrix mathematical keypad. Dynamically computes button geometry
/// for standard (5x7) or vertical entry mode (4x5) via internal LayoutBuilder.
class const CalcKeypad({
  super.key,
  required this.symbols,
  required this.isDeg,
  required this.isShift,
  required this.onKeyPressed,
  this.onKeyLongPressed,
  this.columns = 5,
  this.rows = 7,
}) extends StatelessWidget {
  final List<String> symbols;
  final bool isDeg;
  final bool isShift;
  final ValueChanged<String> onKeyPressed;
  final ValueChanged<String>? onKeyLongPressed;
  final int columns;
  final int rows;

  static const double _spacing = 6.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final btnWidth =
          ((constraints.maxWidth - (_spacing * (columns - 1))) / columns).clamp(
            0.0,
            double.infinity,
          );
      final btnHeight =
          ((constraints.maxHeight - (_spacing * (rows - 1))) / rows).clamp(
            0.0,
            double.infinity,
          );

      return Column(
        mainAxisAlignment: .spaceBetween,
        children: [
          for (int r = 0; r < rows; r++)
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                for (int c = 0; c < columns; c++)
                  _buildButton(r * columns + c, btnWidth, btnHeight),
              ],
            ),
        ],
      );
    },
  );

  Widget _buildButton(int index, double width, double height) {
    if (index >= symbols.length) return SizedBox(width: width, height: height);
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
