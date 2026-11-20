// lib/feat/shape/widget/painter/sphere_painter.dart
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class SpherePainter extends CustomPainter {
  const SpherePainter({
    required this.values,
    required this.units,
    required this.isDark,
  });

  final Map<String, double> values;
  final Map<String, String> units;
  final bool isDark;

  String _formatLabel(String key, String fallbackSymbol) {
    final val = values[key];
    final unit = units[key] ?? '';
    if (val == null || val <= 0 || val.isNaN) return fallbackSymbol;

    final formatted = val % 1 == 0
        ? val.toInt().toString()
        : val.toStringAsFixed(val < 10 ? 1 : 0);

    return formatted.length <= 4 ? '$formatted$unit' : fallbackSymbol;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final strokeColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final accentColor = const Color(0xFF007FFF);
    final guideColor = isDark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF636366);

    final shapePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final radiusPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final equatorRearPaint = Paint()
      ..color = guideColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final equatorFrontPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 24.0;
    final equatorRy = radius * 0.32;

    // 1. Outer Sphere Circle
    canvas.drawCircle(center, radius, shapePaint);

    // 2. 3D Equator Ellipse (Rear Dashed Arc, Front Solid Arc)
    final equatorRect = Rect.fromCenter(
      center: center,
      width: radius * 2,
      height: equatorRy * 2,
    );

    // Rear arc (top half, dashed)
    _drawDashedArc(canvas, equatorRect, math.pi, math.pi, equatorRearPaint);

    // Front arc (bottom half, solid)
    final frontArc = Path()..addArc(equatorRect, 0, math.pi);
    canvas.drawPath(frontArc, equatorFrontPaint);

    // 3. Center Origin Dot
    canvas.drawCircle(center, 3.0, Paint()..color = accentColor);

    // 4. Solid Radius Arrow (Center to right equator)
    canvas.drawLine(center, Offset(center.dx + radius, center.dy), radiusPaint);
    _drawText(
      canvas,
      _formatLabel('Radius', 'r'),
      Offset(center.dx + radius / 2, center.dy - 12.0),
      accentColor,
    );

    // 5. Diameter Label (Left half)
    _drawText(
      canvas,
      _formatLabel('Diameter', 'd'),
      Offset(center.dx - radius / 2, center.dy - 12.0),
      guideColor,
    );
  }

  void _drawDashedArc(
    Canvas canvas,
    Rect rect,
    double startAngle,
    double sweepAngle,
    Paint paint,
  ) {
    const dashAngle = 0.12;
    const gapAngle = 0.08;
    var currentAngle = startAngle;
    final endAngle = startAngle + sweepAngle;

    while (currentAngle < endAngle) {
      final sweep = math.min(dashAngle, endAngle - currentAngle);
      final path = Path()..addArc(rect, currentAngle, sweep);
      canvas.drawPath(path, paint);
      currentAngle += dashAngle + gapAngle;
    }
  }

  void _drawText(Canvas canvas, String text, Offset center, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'RedditSans',
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant SpherePainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.units != units ||
      oldDelegate.isDark != isDark;
}
