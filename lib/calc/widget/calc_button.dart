import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';

/// Style configuration record bundling all visual attributes computed in a single pass.
typedef _ButtonVisualSpec = ({
  Gradient background,
  Color borderColor,
  double borderWidth,
  Color foregroundColor,
  double fontSize,
});

/// Smart unified button component handling visuals, labels, icons, and events in one place.
class const CalcButton({
  super.key,
  required final String symbol,
  required final double width,
  required final double height,
  required final VoidCallback? onPressed,
  final bool isDeg = true,
  final bool isShift = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final themeTextColor =
        CupertinoTheme.of(context).textTheme.textStyle.color ??
        CupertinoColors.label;
    final barBgColor = CupertinoTheme.of(context).barBackgroundColor;

    // Single-pass style resolution via Dart 3 pattern matching
    final _ButtonVisualSpec spec = switch (symbol) {
      '=' => (
        background: const LinearGradient(
          begin: .centerLeft,
          end: .bottomRight,
          colors: [
            Color.fromRGBO(0, 122, 255, 0.75),
            Color.fromRGBO(0, 198, 255, 0.45),
          ],
        ),
        borderColor: const Color.fromRGBO(0, 122, 255, 0.35),
        borderWidth: 1.4,
        foregroundColor: CupertinoColors.white,
        fontSize: 32.0,
      ),
      'del' => (
        background: const LinearGradient(
          colors: [CupertinoColors.transparent, CupertinoColors.transparent],
        ),
        borderColor: isDark
            ? const Color.fromRGBO(30, 30, 30, 1)
            : const Color.fromRGBO(220, 220, 220, 0.9),
        borderWidth: 0.8,
        foregroundColor: const Color.fromRGBO(255, 59, 48, 0.75),
        fontSize: 25.0,
      ),
      '0' ||
      '1' ||
      '2' ||
      '3' ||
      '4' ||
      '5' ||
      '6' ||
      '7' ||
      '8' ||
      '9' ||
      '00' ||
      '.' => (
        background: isDark
            ? const LinearGradient(
                colors: [CupertinoColors.black, CupertinoColors.black],
              )
            : const LinearGradient(
                colors: [CupertinoColors.white, CupertinoColors.white],
              ),
        borderColor: isDark
            ? const Color.fromRGBO(16, 16, 16, 1)
            : const Color.fromRGBO(240, 240, 240, 1),
        borderWidth: 0.8,
        foregroundColor: themeTextColor,
        fontSize: symbol == '00' ? 20.0 : 25.0,
      ),
      'DEG' || 'RAD' => (
        background: const LinearGradient(
          colors: [CupertinoColors.transparent, CupertinoColors.transparent],
        ),
        borderColor: isDeg
            ? const Color.fromRGBO(52, 199, 89, 0.36)
            : const Color.fromRGBO(255, 149, 0, 0.3),
        borderWidth: 2.0,
        foregroundColor: themeTextColor,
        fontSize: isDeg ? height * 0.29 : 20.0,
      ),
      'X' || 'Y' => (
        background: const LinearGradient(
          colors: [CupertinoColors.transparent, CupertinoColors.transparent],
        ),
        borderColor:
            (symbol == 'X'
                    ? const Color.fromRGBO(175, 82, 222, 1)
                    : const Color.fromRGBO(90, 200, 250, 1))
                .withValues(alpha: isDark ? 0.6 : 0.3),
        borderWidth: 2.0,
        foregroundColor: themeTextColor,
        fontSize: 20.0,
      ),
      'shft' => (
        background: const LinearGradient(
          colors: [CupertinoColors.transparent, CupertinoColors.transparent],
        ),
        borderColor: CupertinoColors.systemIndigo.withValues(
          alpha: isShift ? 0.4 : 0.3,
        ),
        borderWidth: 2.0,
        foregroundColor: themeTextColor,
        fontSize: 25.0,
      ),
      'AC' => (
        background: const LinearGradient(
          colors: [CupertinoColors.transparent, CupertinoColors.transparent],
        ),
        borderColor: const Color.fromRGBO(255, 0, 0, 0.4),
        borderWidth: 2.0,
        foregroundColor: themeTextColor,
        fontSize: height * 0.29,
      ),
      'hist' || 'unit' || 'Settings' || 'Calc' => (
        background: const LinearGradient(
          colors: [CupertinoColors.transparent, CupertinoColors.transparent],
        ),
        borderColor: barBgColor,
        borderWidth: 0.8,
        foregroundColor: themeTextColor,
        fontSize: 25.0,
      ),
      'Copy' || 'Paste' => (
        background: const LinearGradient(
          colors: [CupertinoColors.transparent, CupertinoColors.transparent],
        ),
        borderColor: const Color.fromRGBO(254, 254, 254, 1),
        borderWidth: 0.8,
        foregroundColor: themeTextColor,
        fontSize: 25.0,
      ),
      '+' || '-' || '×' || '÷' => (
        background: const LinearGradient(
          colors: [CupertinoColors.transparent, CupertinoColors.transparent],
        ),
        borderColor: isDark
            ? const Color.fromRGBO(30, 30, 30, 1)
            : const Color.fromRGBO(220, 220, 220, 0.9),
        borderWidth: 0.8,
        foregroundColor: themeTextColor,
        fontSize: 32.0,
      ),
      _ => (
        background: const LinearGradient(
          colors: [CupertinoColors.transparent, CupertinoColors.transparent],
        ),
        borderColor: isDark
            ? const Color.fromRGBO(30, 30, 30, 1)
            : const Color.fromRGBO(220, 220, 220, 0.9),
        borderWidth: 0.8,
        foregroundColor: themeTextColor,
        fontSize: symbol == 'empty'
            ? 10.0
            : (symbol.length > 1 && !RegExp(r'^\d+$').hasMatch(symbol)
                  ? 24.0
                  : 25.0),
      ),
    };

    final content = _buildContent(spec);
    final isEnabled = symbol != 'Calc' && onPressed != null;

    return CupertinoButton(
      minimumSize: .zero,
      padding: .zero,
      borderRadius: .circular(25),
      onPressed: isEnabled ? onPressed : null,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: .circular(15),
          border: Border.all(width: spec.borderWidth, color: spec.borderColor),
          gradient: spec.background,
        ),
        child: Center(child: content),
      ),
    );
  }

  Widget _buildContent(_ButtonVisualSpec spec) => switch (symbol) {
    'shft' => Icon(
      isShift
          ? FluentIcons.keyboard_shift_uppercase_24_filled
          : FluentIcons.keyboard_shift_uppercase_24_regular,
      size: 28,
      color: spec.foregroundColor,
    ),
    'unit' => const Icon(
      FluentIcons.diversity_24_regular,
      size: 28,
      color: Color.fromRGBO(20, 20, 20, 0.85),
    ),
    'Calc' => const Icon(
      FluentIcons.calculator_24_filled,
      size: 28,
      color: Color.fromRGBO(20, 20, 20, 0.85),
    ),
    'hist' => const Icon(
      FluentIcons.history_24_regular,
      size: 28,
      color: Color.fromRGBO(20, 20, 20, 0.85),
    ),
    'Settings' => const Icon(
      FluentIcons.settings_24_regular,
      size: 28,
      color: Color.fromRGBO(20, 20, 20, 0.85),
    ),
    'Copy' => const Icon(
      FluentIcons.copy_24_regular,
      size: 28,
      color: Color.fromRGBO(142, 142, 147, 0.76),
    ),
    'Paste' => const Icon(
      FluentIcons.clipboard_paste_24_regular,
      size: 28,
      color: Color.fromRGBO(142, 142, 147, 0.76),
    ),
    'del' => Icon(
      FluentIcons.backspace_24_filled,
      size: 28,
      color: spec.foregroundColor,
    ),
    _ => Text(
      _resolvedText(),
      textAlign: .center,
      style: TextStyle(
        fontFamily: 'RedditSans',
        fontWeight: FontWeight.w400,
        fontSize: spec.fontSize,
        color: spec.foregroundColor,
      ),
    ),
  };

  String _resolvedText() {
    var text = (symbol == 'DEG') ? (isDeg ? 'DEG' : 'RAD') : symbol;
    if (isShift) {
      text = switch (text) {
        'sin' => 'sin⁻¹',
        'cos' => 'cos⁻¹',
        'tan' => 'tan⁻¹',
        'log' => 'ln',
        '^' => 'E',
        _ => text,
      };
    }
    return text;
  }
}
