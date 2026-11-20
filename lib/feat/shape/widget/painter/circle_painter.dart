// lib/feat/shape/widget/painter/circle_painter.dart
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class CirclePainter extends CustomPainter {
  const CirclePainter({
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

    final diameterPaint = Paint()
      ..color = guideColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final dimensionPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final has3D =
        (values['Height'] != null && values['Height']! > 0) ||
        (values['Volume'] != null && values['Volume']! > 0);

    if (has3D) {
      // Cylinder 3D View
      const ellipseRx = 60.0;
      const ellipseRy = 22.0;
      const cylHeight = 75.0;

      final topCenter = Offset(
        size.width / 2 - 10.0,
        size.height / 2 - cylHeight / 2,
      );
      final bottomCenter = Offset(topCenter.dx, topCenter.dy + cylHeight);

      // Top Ellipse
      final topRect = Rect.fromCenter(
        center: topCenter,
        width: ellipseRx * 2,
        height: ellipseRy * 2,
      );
      canvas.drawOval(topRect, shapePaint);

      // Bottom Ellipse (Front solid, Rear dashed)
      final bottomRect = Rect.fromCenter(
        center: bottomCenter,
        width: ellipseRx * 2,
        height: ellipseRy * 2,
      );
      final bottomArc = Path()..addArc(bottomRect, 0, math.pi);
      canvas.drawPath(bottomArc, shapePaint);

      _drawDashedLine(
        canvas,
        Offset(bottomCenter.dx - ellipseRx, bottomCenter.dy),
        Offset(bottomCenter.dx + ellipseRx, bottomCenter.dy),
        diameterPaint,
      );

      // Vertical Silhouette Edges
      canvas.drawLine(
        Offset(topCenter.dx - ellipseRx, topCenter.dy),
        Offset(bottomCenter.dx - ellipseRx, bottomCenter.dy),
        shapePaint,
      );
      canvas.drawLine(
        Offset(topCenter.dx + ellipseRx, topCenter.dy),
        Offset(bottomCenter.dx + ellipseRx, bottomCenter.dy),
        shapePaint,
      );

      // Radius line on top ellipse
      canvas.drawCircle(topCenter, 3.0, Paint()..color = accentColor);
      canvas.drawLine(
        topCenter,
        Offset(topCenter.dx + ellipseRx, topCenter.dy),
        radiusPaint,
      );
      _drawText(
        canvas,
        _formatLabel('Radius', 'r'),
        Offset(topCenter.dx + ellipseRx / 2, topCenter.dy - 12.0),
        accentColor,
      );

      // Height Dimension Arrow (Right)
      final arrowX = topCenter.dx + ellipseRx + 20.0;
      _drawDimensionArrow(
        canvas,
        Offset(arrowX, topCenter.dy),
        Offset(arrowX, bottomCenter.dy),
        dimensionPaint,
      );
      _drawText(
        canvas,
        _formatLabel('Height', 'h'),
        Offset(arrowX + 16.0, topCenter.dy + cylHeight / 2),
        accentColor,
      );
    } else {
      // 2D Circle View
      final center = Offset(size.width / 2, size.height / 2);
      final radius = math.min(size.width, size.height) / 2 - 28.0;

      canvas.drawCircle(center, radius, shapePaint);
      _drawDashedLine(
        canvas,
        Offset(center.dx - radius, center.dy),
        Offset(center.dx + radius, center.dy),
        diameterPaint,
      );
      canvas.drawCircle(center, 3.0, Paint()..color = accentColor);
      canvas.drawLine(
        center,
        Offset(center.dx + radius, center.dy),
        radiusPaint,
      );

      _drawText(
        canvas,
        _formatLabel('Radius', 'r'),
        Offset(center.dx + radius / 2, center.dy - 12.0),
        accentColor,
      );
      _drawText(
        canvas,
        _formatLabel('Diameter', 'd'),
        Offset(center.dx - radius / 2, center.dy - 12.0),
        guideColor,
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dash = 4.0;
    const gap = 3.0;
    final dist = (p2 - p1).distance;
    final uv = (p2 - p1) / dist;

    var cur = 0.0;
    while (cur < dist) {
      final start = p1 + uv * cur;
      final next = math.min(cur + dash, dist);
      canvas.drawLine(start, p1 + uv * next, paint);
      cur += dash + gap;
    }
  }

  void _drawDimensionArrow(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    canvas.drawLine(p1, p2, paint);
    const len = 5.0;
    final dist = (p2 - p1).distance;
    if (dist == 0) return;
    final uv = (p2 - p1) / dist;
    final norm = Offset(-uv.dy, uv.dx);

    canvas.drawLine(p1 - norm * 4.0, p1 + norm * 4.0, paint);
    canvas.drawLine(p2 - norm * 4.0, p2 + norm * 4.0, paint);
    canvas.drawLine(p1, p1 + uv * len + norm * (len / 1.5), paint);
    canvas.drawLine(p1, p1 + uv * len - norm * (len / 1.5), paint);
    canvas.drawLine(p2, p2 - uv * len + norm * (len / 1.5), paint);
    canvas.drawLine(p2, p2 - uv * len - norm * (len / 1.5), paint);
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
  bool shouldRepaint(covariant CirclePainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.units != units ||
      oldDelegate.isDark != isDark;
}
