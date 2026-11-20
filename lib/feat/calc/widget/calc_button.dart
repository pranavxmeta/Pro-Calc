import 'dart:math' as math;

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

/// Style configuration record bundling visual attributes computed in a single pass.
typedef _ButtonVisualSpec = ({
  Gradient background,
  Gradient pressedBackground,
  Color borderColor,
  Color pressedBorderColor,
  double borderWidth,
  BorderRadius borderRadius,
  Color foregroundColor,
  double fontSize,
  FontWeight fontWeight,
});

/// Production-ready High-Fidelity Simulated Optical Glass calculator button.
/// Dead branches eliminated; equipped with text-overflow protection via FittedBox,
/// native onLongPress (del -> AC), and zero gradient-lerping lag.
class CalcButton extends StatefulWidget {
  const CalcButton({
    super.key,
    required this.symbol,
    required this.width,
    required this.height,
    required this.onPressed,
    this.onLongPress,
    this.isDeg = true,
    this.isShift = false,
  });

  final String symbol;
  final double width;
  final double height;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool isDeg;
  final bool isShift;

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton> {
  bool _isPressed = false;

  static const Set<String> _digits = {
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '00',
    '.',
  };

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      widget.onPressed?.call();
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeTextColor = Theme.of(context).colorScheme.onSurface;

    final minDimension = math.min(widget.width, widget.height);
    final standardRadius = BorderRadius.circular(minDimension * 0.4);
    final circularRadius = BorderRadius.circular(minDimension * 0.5);

    const specularBorderDark = Color.fromRGBO(255, 255, 255, 0.20);
    const specularBorderLight = Color.fromRGBO(255, 255, 255, 0.25);
    const specularBorderPressed = Color.fromRGBO(255, 255, 255, 0.45);

    final defaultBorderColor = isDark
        ? specularBorderDark
        : specularBorderLight;

    // High-transmission crystal glass wash
    final neutralBaseWash = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(34, 34, 42, 0.72),
              Color.fromRGBO(20, 20, 26, 0.45),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(255, 255, 255, 0.82),
              Color.fromRGBO(246, 248, 252, 0.22),
              Color.fromRGBO(255, 255, 255, 0.82),
            ],
            stops: [0.0, 0.50, 1.0],
          );

    final neutralPressedWash = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(55, 55, 68, 0.85),
              Color.fromRGBO(35, 35, 45, 0.65),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(255, 255, 255, 0.95),
              Color.fromRGBO(240, 244, 252, 0.62),
              Color.fromRGBO(255, 255, 255, 0.95),
            ],
            stops: [0.0, 0.50, 1.0],
          );

    // Single-pass style resolution with all dead cases eliminated
    final _ButtonVisualSpec spec = switch (widget.symbol) {
      // 1. Hero '=' Button: Electric Azure Refractive Lens Flare
      '=' => (
        background: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(255, 255, 255, 0.28),
                  Color.fromRGBO(0, 100, 200, 0.28),
                  Color.fromRGBO(16, 20, 28, 0.16),
                  Color.fromRGBO(255, 255, 255, 0.18),
                ],
                stops: [0.0, 0.38, 0.68, 1.0],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(255, 255, 255, 0.88),
                  Color.fromRGBO(224, 242, 254, 0.45),
                  Color.fromRGBO(240, 248, 255, 0.16),
                  Color.fromRGBO(255, 255, 255, 0.70),
                ],
                stops: [0.0, 0.38, 0.68, 1.0],
              ),
        pressedBackground: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(0, 140, 255, 0.55),
                  Color.fromRGBO(0, 180, 255, 0.45),
                  Color.fromRGBO(255, 255, 255, 0.35),
                ],
                stops: [0.0, 0.50, 1.0],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(255, 255, 255, 0.95),
                  Color.fromRGBO(186, 230, 253, 0.65),
                  Color.fromRGBO(255, 255, 255, 0.90),
                ],
                stops: [0.0, 0.48, 1.0],
              ),
        borderColor: isDark
            ? const Color.fromRGBO(255, 255, 255, 0.22)
            : const Color.fromRGBO(255, 255, 255, 0.45),
        pressedBorderColor: const Color.fromRGBO(255, 255, 255, 0.65),
        borderWidth: 1.2,
        borderRadius: standardRadius,
        foregroundColor: const Color.fromRGBO(0, 122, 255, 1.0),
        fontSize: 34.0,
        fontWeight: FontWeight.w700,
      ),

      // 2. Backspace ('del') - Neutral Body with Flare
      'del' => (
        background: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(254, 226, 226, 0.65),
            Color.fromRGBO(255, 250, 250, 0.28),
          ],
        ),
        pressedBackground: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(254, 202, 202, 0.88),
            Color.fromRGBO(255, 255, 255, 0.55),
          ],
        ),
        borderColor: defaultBorderColor,
        pressedBorderColor: specularBorderPressed,
        borderWidth: 1.2,
        borderRadius: circularRadius,
        foregroundColor: const Color.fromRGBO(239, 68, 68, 0.70),
        fontSize: 25.0,
        fontWeight: FontWeight.w400,
      ),

      // 3. Shift ('shft') - Royal Lilac Lens Flare
      'shft' => (
        background: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(238, 235, 254, 0.65),
            Color.fromRGBO(255, 252, 255, 0.28),
          ],
        ),
        pressedBackground: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(224, 218, 254, 0.88),
            Color.fromRGBO(245, 240, 255, 0.55),
          ],
        ),
        borderColor: defaultBorderColor,
        pressedBorderColor: specularBorderPressed,
        borderWidth: 1.2,
        borderRadius: circularRadius,
        foregroundColor: widget.isShift
            ? (isDark ? Colors.white : const Color.fromRGBO(99, 102, 241, 1.0))
            : const Color.fromRGBO(99, 102, 241, 0.92),
        fontSize: 25.0,
        fontWeight: FontWeight.w400,
      ),

      // 4. Angular Modes ('deg' / 'rad') - Mint / Amber Lens Flare
      'deg' || 'rad' => (
        background: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isDeg
              ? const [
                  Color.fromRGBO(220, 252, 231, 0.65),
                  Color.fromRGBO(250, 255, 252, 0.28),
                ]
              : const [
                  Color.fromRGBO(254, 243, 199, 0.65),
                  Color.fromRGBO(255, 251, 235, 0.28),
                ],
        ),
        pressedBackground: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isDeg
              ? const [
                  Color.fromRGBO(187, 247, 208, 0.88),
                  Color.fromRGBO(235, 254, 245, 0.55),
                ]
              : const [
                  Color.fromRGBO(253, 230, 138, 0.88),
                  Color.fromRGBO(254, 243, 199, 0.55),
                ],
        ),
        borderColor: defaultBorderColor,
        pressedBorderColor: specularBorderPressed,
        borderWidth: 1.2,
        borderRadius: circularRadius,
        foregroundColor: widget.isDeg
            ? const Color.fromRGBO(16, 185, 129, 0.95)
            : const Color.fromRGBO(245, 158, 11, 0.95),
        fontSize: 20.0,
        fontWeight: FontWeight.w400,
      ),

      // 5. Variables ('X', 'Y') - Orchid & Azure Flares
      'X' || 'Y' => (
        background: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.symbol == 'X'
              ? const [
                  Color.fromRGBO(250, 232, 255, 0.65),
                  Color.fromRGBO(255, 250, 255, 0.28),
                ]
              : const [
                  Color.fromRGBO(224, 242, 254, 0.65),
                  Color.fromRGBO(250, 254, 255, 0.28),
                ],
        ),
        pressedBackground: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.symbol == 'X'
              ? const [
                  Color.fromRGBO(245, 208, 254, 0.88),
                  Color.fromRGBO(252, 240, 255, 0.55),
                ]
              : const [
                  Color.fromRGBO(186, 230, 253, 0.88),
                  Color.fromRGBO(240, 250, 255, 0.55),
                ],
        ),
        borderColor: defaultBorderColor,
        pressedBorderColor: specularBorderPressed,
        borderWidth: 1.2,
        borderRadius: circularRadius,
        foregroundColor: widget.symbol == 'X'
            ? const Color.fromRGBO(168, 85, 247, 0.95)
            : const Color.fromRGBO(14, 165, 233, 0.95),
        fontSize: 20.0,
        fontWeight: FontWeight.w400,
      ),

      // 6. Math Operators ('+', '-', '×', '÷') - Harmonized Crystal Glass
      '+' || '-' || '×' || '÷' => (
        background: neutralBaseWash,
        pressedBackground: neutralPressedWash,
        borderColor: defaultBorderColor,
        pressedBorderColor: specularBorderPressed,
        borderWidth: 1.2,
        borderRadius: standardRadius,
        foregroundColor: const Color.fromRGBO(24, 24, 20, 0.78),
        fontSize: 30.0,
        fontWeight: FontWeight.w400,
      ),

      // 7. Numeric Keypad ('0'–'9', '.', '00') - Frosted Pure Crystal Lens Flare
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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(34, 34, 42, 0.72),
                  Color.fromRGBO(20, 20, 26, 0.45),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(255, 255, 255, 0.78),
                  Color.fromRGBO(246, 248, 252, 0.38),
                  Color.fromRGBO(255, 255, 255, 0.65),
                ],
                stops: [0.0, 0.52, 1.0],
              ),
        pressedBackground: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(60, 60, 75, 0.88),
                  Color.fromRGBO(35, 35, 45, 0.65),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(255, 255, 255, 0.95),
                  Color.fromRGBO(240, 244, 252, 0.65),
                  Color.fromRGBO(255, 255, 255, 0.88),
                ],
                stops: [0.0, 0.52, 1.0],
              ),
        borderColor: defaultBorderColor,
        pressedBorderColor: specularBorderPressed,
        borderWidth: 1.2,
        borderRadius: standardRadius,
        foregroundColor: themeTextColor,
        fontSize: widget.symbol == '00' ? 20.0 : 25.0,
        fontWeight: FontWeight.w400,
      ),

      // 8. Secondary Scientific Functions ('sin', 'cos', 'log', '√', 'π', etc.)
      _ => (
        background: neutralBaseWash,
        pressedBackground: neutralPressedWash,
        borderColor: defaultBorderColor,
        pressedBorderColor: specularBorderPressed,
        borderWidth: 1.0,
        borderRadius: standardRadius,
        foregroundColor: const Color.fromRGBO(24, 24, 20, 0.86),
        fontSize: _digits.contains(widget.symbol)
            ? 24.0
            : (widget.symbol.length > 1 ? 21.0 : 24.0),
        fontWeight: FontWeight.w400,
      ),
    };

    final content = _buildContent(spec);

    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOutCubic,
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: spec.borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? const Color.fromRGBO(0, 0, 0, 0.25)
                        : const Color.fromRGBO(0, 0, 0, 0.04),
                    blurRadius: _isPressed ? 3.0 : 7.0,
                    offset: _isPressed
                        ? const Offset(0, 1.0)
                        : const Offset(0, 2.0),
                  ),
                ],
                border: Border.all(
                  width: spec.borderWidth,
                  color: _isPressed
                      ? spec.pressedBorderColor
                      : spec.borderColor,
                ),
                gradient: _isPressed ? spec.pressedBackground : spec.background,
              ),
              child: Center(child: content),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(_ButtonVisualSpec spec) => switch (widget.symbol) {
    'shft' => Icon(
      widget.isShift
          ? FluentIcons.keyboard_shift_uppercase_24_filled
          : FluentIcons.keyboard_shift_uppercase_24_regular,
      size: 26,
      color: spec.foregroundColor,
    ),
    'del' => Icon(
      FluentIcons.backspace_24_regular,
      size: 26,
      color: spec.foregroundColor,
    ),
    _ => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          _resolvedText(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'RedditSans',
            fontWeight: spec.fontWeight,
            fontSize: spec.fontSize,
            color: spec.foregroundColor,
          ),
        ),
      ),
    ),
  };

  String _resolvedText() {
    var text = (widget.symbol == 'deg')
        ? (widget.isDeg ? 'deg' : 'rad')
        : widget.symbol;
    if (widget.isShift) {
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
