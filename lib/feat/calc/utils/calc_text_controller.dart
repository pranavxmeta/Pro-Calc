import 'package:material_ui/material_ui.dart';

/// Syntax-highlighting text editing controller.
/// Highlights `+` (credit green) and `-` (debit red) ONLY when [isVerticalMode] is true.
/// In horizontal mode (Basic / Scientific), all characters retain standard neutral typography.
class CalcTextEditingController extends TextEditingController {
  CalcTextEditingController({super.text, this.isVerticalMode = false});

  bool isVerticalMode;

  static const Color creditGreen = Color(0xFF22C55E);
  static const Color debitRed = Color(0xFFEF4444);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final baseStyle = (style ?? const TextStyle()).copyWith(
      fontFeatures: [if (isVerticalMode) const FontFeature.tabularFigures()],
    );

    if (text.isEmpty || !isVerticalMode) {
      return TextSpan(text: text, style: baseStyle);
    }

    final spans = <TextSpan>[];
    final buffer = StringBuffer();

    void flushBuffer() {
      if (buffer.isEmpty) return;
      spans.add(TextSpan(text: buffer.toString(), style: baseStyle));
      buffer.clear();
    }

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      if (char == '+') {
        flushBuffer();
        spans.add(
          TextSpan(
            text: char,
            style: baseStyle.copyWith(
              color: creditGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      } else if (char == '-' || char == '−') {
        flushBuffer();
        spans.add(
          TextSpan(
            text: char,
            style: baseStyle.copyWith(
              color: debitRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      } else {
        buffer.write(char);
      }
    }

    flushBuffer();
    return TextSpan(children: spans, style: baseStyle);
  }
}
