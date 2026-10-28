import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

class const CalcBottomNavNew({
  super.key,
  final ValueChanged<String>? onNavAction,
  final Widget Function(String symbol, bool isPressed)? iconBuilder,
}) extends StatelessWidget {
  static const _pillSymbols = ['hist', 'unit'];

  ({IconData icon, VoidCallback? action}) _navDescriptor(String symbol) =>
      switch (symbol) {
        'hist' => (
          icon: FluentIcons.history_24_filled,
          action: () => onNavAction?.call('hist'),
        ),
        'unit' => (
          icon: FluentIcons.diversity_24_regular,
          action: () => onNavAction?.call('unit'),
        ),
        'Settings' => (
          icon: FluentIcons.settings_24_regular,
          action: () => onNavAction?.call('Settings'),
        ),
        'chat' => (icon: FluentIcons.chat_sparkle_24_regular, action: null),
        _ => (icon: FluentIcons.question_circle_24_regular, action: null),
      };

  Widget _buildButton(BuildContext context, String symbol) {
    final item = _navDescriptor(symbol);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : const Color(0xFF09090B);

    return _GlassButton(
      symbol: symbol,
      onTap: item.action,
      child:
          iconBuilder?.call(symbol, false) ??
          Icon(item.icon, size: 22, color: iconColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const barHeight = 50.0;
    const circleSize = 50.0;
    const leftIslandGap = 11.0;

    return Padding(
      padding: const .only(left: 18.0, right: 18.0, bottom: 4.0),
      child: SizedBox(
        height: barHeight,
        child: Row(
          crossAxisAlignment: .center,
          children: [
            // =============================================================
            // 1. Warm Amber Refractive Glass Pill (hist, unit)
            // =============================================================
            _GlassContainer(
              width: 126.0,
              height: barHeight,
              borderRadius: .circular(barHeight * 0.5),
              washColors: isDark
                  ? const [
                      Color.fromRGBO(180, 110, 20, 0.35),
                      Color.fromRGBO(30, 24, 18, 0.25),
                    ]
                  : const [
                      Color.fromRGBO(255, 250, 252, 0.88),
                      Color.fromRGBO(255, 248, 255, 0.28),
                    ],
              child: Row(
                children: [
                  for (final symbol in _pillSymbols)
                    Expanded(child: _buildButton(context, symbol)),
                ],
              ),
            ),

            const SizedBox(width: leftIslandGap),

            // =============================================================
            // 2. Orchid / Magenta Refractive Glass Circle (Settings)
            // =============================================================
            _GlassContainer(
              width: circleSize,
              height: circleSize,
              borderRadius: .circular(circleSize * 0.5),
              washColors: isDark
                  ? const [
                      Color.fromRGBO(140, 40, 150, 0.35),
                      Color.fromRGBO(28, 18, 30, 0.25),
                    ]
                  : const [
                      Color.fromRGBO(255, 250, 252, 0.88),
                      Color.fromRGBO(255, 248, 255, 0.28),
                    ],
              child: _buildButton(context, 'Settings'),
            ),

            const Spacer(),

            // =============================================================
            // 3. Azure / Cyan Refractive Glass Circle (chat sparkle)
            // =============================================================
            _GlassContainer(
              width: circleSize,
              height: circleSize,
              borderRadius: .circular(circleSize * 0.5),
              washColors: isDark
                  ? const [
                      Color.fromRGBO(0, 100, 200, 0.35),
                      Color.fromRGBO(14, 22, 32, 0.25),
                    ]
                  : const [
                      Color.fromRGBO(224, 242, 254, 0.58),
                      Color.fromRGBO(250, 254, 255, 0.28),
                    ],
              child: _buildButton(context, 'chat'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassContainer({
  required final double width,
  required final double height,
  required final BorderRadius borderRadius,
  required final List<Color> washColors,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 10.0,
            offset: Offset(0, 4.0),
          ),
        ],
        border: Border.all(
          width: 1.5,
          color: isDark
              ? const Color.fromRGBO(255, 255, 255, 0.20)
              : const Color.fromRGBO(255, 255, 255, 0.90),
        ),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomRight,
          colors: washColors,
        ),
      ),
      child: child,
    );
  }
}

class _GlassButton({
  required final String symbol,
  required final VoidCallback? onTap,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(child: child),
    );
  }
}
