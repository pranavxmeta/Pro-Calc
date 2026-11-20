// lib/feat/shape/widget/painter/trapezoid_painter.dart
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class TrapezoidPainter extends CustomPainter {
  const TrapezoidPainter({
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
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dimensionPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    const padLeft = 40.0;
    const padRight = 40.0;
    const padTop = 32.0;
    const padBottom = 42.0;

    final bLeft = Offset(padLeft, size.height - padBottom);
    final bRight = Offset(size.width - padRight, size.height - padBottom);
    final tLeft = Offset(size.width * 0.30, padTop);
    final tRight = Offset(size.width * 0.70, padTop);
    final altitudeFoot = Offset(tLeft.dx, size.height - padBottom);

    // 1. Draw Trapezoid
    final path = Path()
      ..moveTo(bLeft.dx, bLeft.dy)
      ..lineTo(bRight.dx, bRight.dy)
      ..lineTo(tRight.dx, tRight.dy)
      ..lineTo(tLeft.dx, tLeft.dy)
      ..close();
    canvas.drawPath(path, shapePaint);

    // 2. Dashed Altitude (Height)
    _drawDashedLine(canvas, tLeft, altitudeFoot, dimensionPaint);

    // Right-angle square marker
    const marker = 8.0;
    final markerPath = Path()
      ..moveTo(altitudeFoot.dx + marker, altitudeFoot.dy)
      ..lineTo(altitudeFoot.dx + marker, altitudeFoot.dy - marker)
      ..lineTo(altitudeFoot.dx, altitudeFoot.dy - marker);
    canvas.drawPath(markerPath, dimensionPaint);

    // 3. Top Base A Dimension Arrow
    final topArrowY = padTop - 14.0;
    _drawDimensionArrow(
      canvas,
      Offset(tLeft.dx, topArrowY),
      Offset(tRight.dx, topArrowY),
      dimensionPaint,
    );
    _drawText(
      canvas,
      _formatLabel('Base A', 'a'),
      Offset((tLeft.dx + tRight.dx) / 2, topArrowY - 9.0),
      accentColor,
    );

    // 4. Bottom Base B Dimension Arrow
    final bottomArrowY = size.height - padBottom + 16.0;
    _drawDimensionArrow(
      canvas,
      Offset(bLeft.dx, bottomArrowY),
      Offset(bRight.dx, bottomArrowY),
      dimensionPaint,
    );
    _drawText(
      canvas,
      _formatLabel('Base B', 'b'),
      Offset((bLeft.dx + bRight.dx) / 2, bottomArrowY + 10.0),
      accentColor,
    );

    // 5. Height Label
    _drawText(
      canvas,
      _formatLabel('Height', 'h'),
      Offset(tLeft.dx - 14.0, (tLeft.dy + altitudeFoot.dy) / 2),
      accentColor,
    );

    // 6. Side C and Side D
    _drawText(
      canvas,
      _formatLabel('Side C', 'c'),
      Offset((bLeft.dx + tLeft.dx) / 2 - 14.0, (bLeft.dy + tLeft.dy) / 2),
      guideColor,
    );
    _drawText(
      canvas,
      _formatLabel('Side D', 'd'),
      Offset((bRight.dx + tRight.dx) / 2 + 14.0, (bRight.dy + tRight.dy) / 2),
      guideColor,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashLength = 4.0;
    const gapLength = 3.0;
    final totalDist = (p2 - p1).distance;
    final unitVector = (p2 - p1) / totalDist;

    var currentDist = 0.0;
    while (currentDist < totalDist) {
      final start = p1 + unitVector * currentDist;
      final nextDist = math.min(currentDist + dashLength, totalDist);
      final end = p1 + unitVector * nextDist;
      canvas.drawLine(start, end, paint);
      currentDist += dashLength + gapLength;
    }
  }

  void _drawDimensionArrow(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    canvas.drawLine(p1, p2, paint);
    const arrowLen = 5.0;
    canvas.drawLine(
      Offset(p1.dx, p1.dy - 4.0),
      Offset(p1.dx, p1.dy + 4.0),
      paint,
    );
    canvas.drawLine(
      Offset(p2.dx, p2.dy - 4.0),
      Offset(p2.dx, p2.dy + 4.0),
      paint,
    );
    canvas.drawLine(
      p1,
      Offset(p1.dx + arrowLen, p1.dy - arrowLen / 1.5),
      paint,
    );
    canvas.drawLine(
      p1,
      Offset(p1.dx + arrowLen, p1.dy + arrowLen / 1.5),
      paint,
    );
    canvas.drawLine(
      p2,
      Offset(p2.dx - arrowLen, p2.dy - arrowLen / 1.5),
      paint,
    );
    canvas.drawLine(
      p2,
      Offset(p2.dx - arrowLen, p2.dy + arrowLen / 1.5),
      paint,
    );
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
  bool shouldRepaint(covariant TrapezoidPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.units != units ||
      oldDelegate.isDark != isDark;
}
