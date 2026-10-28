import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../feat/tool/Shape_Page/shape_page.dart';

/// Screen hosting geometric shape calculation tools.
///
/// Shares the frosted glassmorphism visual language, 4-column squircle grid,
/// and typography with [ToolsScreen].
class const ShapesPage({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const ShapesGridContent();
  }
}

/// Compact 4-Column Grid for Shape Calculators.
class const ShapesGridContent({super.key}) extends StatelessWidget {
  static const _shapes = [
    (
      'Rectangle',
      FluentIcons.rectangle_landscape_24_regular,
      Color(0xFF007AFF),
    ),
    ('Square', FluentIcons.square_24_regular, Color(0xFF34C759)),
    ('Circle', FluentIcons.circle_24_regular, Color(0xFFFF9500)),
    ('Triangle', FluentIcons.triangle_24_regular, Color(0xFFFF3B30)),
    ('Trapezoid', FluentIcons.triangle_24_regular, Color(0xFF5856D6)),
  ];

  void _navigateToShape(BuildContext context, String name) {
    final Widget? page = switch (name) {
      'Rectangle' => const RectangleShapePage(),
      'Square' => const SquareShapePage(),
      'Circle' => const CircleShapePage(),
      'Triangle' => const TriangleShapePage(),
      'Trapezoid' => const TrapezoidShapePage(),
      _ => null,
    };

    if (page == null) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => page,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = isDark ? Colors.white : Colors.black;
    final cardBorderColor = isDark
        ? const Color.fromRGBO(255, 255, 255, 0.10)
        : const Color.fromRGBO(0, 0, 0, 0.08);

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const .fromLTRB(4.0, 2.0, 4.0, 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.10,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: _shapes.length,
      itemBuilder: (context, index) {
        final (name, icon, accentColor) = _shapes[index];

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _navigateToShape(context, name),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color.fromRGBO(255, 255, 255, 0.035)
                  : const Color.fromRGBO(255, 255, 255, 0.62),
              borderRadius: .circular(14.0),
              border: Border.all(width: 1.0, color: cardBorderColor),
            ),
            padding: const .symmetric(vertical: 4.0, horizontal: 4.0),
            child: Column(
              mainAxisAlignment: .center,
              children: [
                Icon(icon, size: 24.0, color: accentColor),
                const SizedBox(height: 4.0),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'RedditSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: primaryTextColor,
                    letterSpacing: 1,
                  ),
                  textAlign: .center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
