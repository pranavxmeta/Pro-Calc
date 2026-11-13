// lib/feat/shape/widget/shape_display.dart
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart';

/// Container housing the textbook-style CustomPainter diagram
class ShapeDisplay extends StatelessWidget {
  const ShapeDisplay({super.key, required this.painter, this.height = 200.0});

  final CustomPainter painter;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161618) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFE5E5EA);

    return Container(
      height: height,
      margin: const .fromLTRB(16.0, 0, 16.0, 16.0),
      padding: const .all(16.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: .circular(20.0),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: .circular(12.0),
        child: CustomPaint(size: Size.infinite, painter: painter),
      ),
    );
  }
}
