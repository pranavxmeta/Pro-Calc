import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

class const CalcBottomNavNew({
  super.key,
  this.isCompact = false,
  this.onNavAction,
  this.iconBuilder,
}) extends StatelessWidget {
  final bool isCompact;
  final ValueChanged<String>? onNavAction;
  final Widget Function(String symbol, bool isPressed)? iconBuilder;

  static const _capsuleSymbols = ['hist', 'chat', 'tools'];

  ({IconData icon, VoidCallback? action}) _item(String s) => switch (s) {
    'hist' => (
      icon: FluentIcons.history_24_filled,
      action: () => onNavAction?.call('hist'),
    ),
    'chat' => (
      icon: FluentIcons.chat_sparkle_24_regular,
      action: () => onNavAction?.call('chat'),
    ),
    'tools' || 'unit' => (
      icon: FluentIcons.diversity_24_regular,
      action: () => onNavAction?.call('unit'),
    ),
    'settings' || 'Settings' => (
      icon: FluentIcons.settings_24_regular,
      action: () => onNavAction?.call('Settings'),
    ),
    _ => (icon: FluentIcons.question_circle_24_regular, action: null),
  };

  Widget _btn(String symbol, double size, Color normalColor, bool isDark) {
    final item = _item(symbol);

    // Hero centerpiece: Deep Obsidian to Radiant Sunburst Gold
    final gradient = symbol == 'chat'
        ? LinearGradient(
            begin: .bottomLeft,
            end: .topRight,
            colors: isDark
                ? const [
                    Color(0xFF27272A),
                    Color(0xFF27272A),
                    Color(0xFFFDE047),
                  ]
                : const [
                    Color(0xFF27272A),
                    Color(0xFF09090B),
                    Color(0xFF38BDF8),
                  ],
            stops: const [0.0, 0.50, 1.0],
          )
        : null;

    return _PebbleIconButton(
      symbol: symbol,
      icon: item.icon,
      iconSize: size,
      iconColor: normalColor,
      iconGradient: gradient,
      onTap: item.action,
      iconBuilder: iconBuilder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final normalColor = isDark ? Colors.white : const Color(0xFF09090B);
    final h = isCompact ? 38.0 : 50.0;
    final iconSize = isCompact ? 18.0 : 22.0;
    // final radius = .circular(h * 0.5);

    final wash = isDark
        ? const [
            Color.fromRGBO(255, 255, 255, 0.10),
            Color.fromRGBO(255, 255, 255, 0.03),
          ]
        : const [
            Color.fromRGBO(255, 255, 255, 0.92),
            Color.fromRGBO(245, 245, 250, 0.60),
          ];

    return SizedBox(
      height: h,
      child: Row(
        mainAxisAlignment: .center,
        children: [
          // 1. Tooling Capsule: hist, chat (hero center), tools
          _PebbleGlass(
            width: isCompact ? 126.0 : 168.0,
            height: h,
            borderRadius: .circular(h * 0.5),
            isDark: isDark,
            washColors: wash,
            child: Row(
              children: [
                for (final s in _capsuleSymbols)
                  Expanded(child: _btn(s, iconSize, normalColor, isDark)),
              ],
            ),
          ),

          SizedBox(width: isCompact ? 8.0 : 10.0),

          // 2. Satellite Circle: Settings
          _PebbleGlass(
            width: h,
            height: h,
            borderRadius: .circular(h * 0.5),
            isDark: isDark,
            washColors: wash,
            child: _btn('settings', iconSize, normalColor, isDark),
          ),
        ],
      ),
    );
  }
}

class const _PebbleGlass({
  required this.width,
  required this.height,
  required this.borderRadius,
  required this.isDark,
  required this.washColors,
  required this.child,
}) extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final bool isDark;
  final List<Color> washColors;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: borderRadius,
      boxShadow: [
        BoxShadow(
          color: isDark ? const Color(0x59000000) : const Color(0x0A000000),
          blurRadius: 12.0,
          offset: const Offset(0, 4.0),
        ),
      ],
      gradient: LinearGradient(
        begin: .topLeft,
        end: .bottomRight,
        colors: washColors,
      ),
    ),
    child: CustomPaint(
      painter: _RoundedGlassRimPainter(
        borderRadius: borderRadius,
        isDark: isDark,
      ),
      child: child,
    ),
  );
}

class _RoundedGlassRimPainter({
  required this.borderRadius,
  required this.isDark,
}) extends CustomPainter {
  final BorderRadius borderRadius;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect).deflate(0.75);

    final rimPaint = Paint()
      ..style = .stroke
      ..strokeWidth = 1.5
      ..shader = LinearGradient(
        begin: .topLeft,
        end: .bottomRight,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.40 : 0.80),
          Colors.white.withValues(alpha: isDark ? 0.06 : 0.20),
          Colors.white.withValues(alpha: isDark ? 0.18 : 0.38),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, rimPaint);
  }

  @override
  bool shouldRepaint(covariant _RoundedGlassRimPainter old) =>
      old.borderRadius != borderRadius || old.isDark != isDark;
}

class const _PebbleIconButton({
  required this.symbol,
  required this.icon,
  required this.iconSize,
  required this.iconColor,
  this.iconGradient,
  required this.onTap,
  this.iconBuilder,
}) extends StatefulWidget {
  final String symbol;
  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final Gradient? iconGradient;
  final VoidCallback? onTap;
  final Widget Function(String symbol, bool isPressed)? iconBuilder;

  @override
  State<_PebbleIconButton> createState() => _PebbleIconButtonState();
}

class _PebbleIconButtonState extends State<_PebbleIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: .opaque,
    onTapDown: (_) => setState(() => _isPressed = true),
    onTapUp: (_) {
      setState(() => _isPressed = false);
      widget.onTap?.call();
    },
    onTapCancel: () => setState(() => _isPressed = false),
    child: Center(
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child:
            widget.iconBuilder?.call(widget.symbol, _isPressed) ??
            (widget.iconGradient != null
                ? ShaderMask(
                    shaderCallback: (bounds) =>
                        widget.iconGradient!.createShader(bounds),
                    child: Icon(
                      widget.icon,
                      size: widget.iconSize,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    widget.icon,
                    size: widget.iconSize,
                    color: widget.iconColor,
                  )),
      ),
    ),
  );
}
