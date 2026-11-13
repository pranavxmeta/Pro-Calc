// lib/feat/shape/widget/painter/triangle_painter.dart
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart';

class TrianglePainter extends CustomPainter {
  const TrianglePainter({
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

    final extrudedPaint = Paint()
      ..color = guideColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final dimensionPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final has3D =
        (values['Depth'] != null && values['Depth']! > 0) ||
        (values['Volume'] != null && values['Volume']! > 0);

    const padX = 40.0;
    const padTop = 36.0;
    const padBottom = 42.0;

    // Front triangle face
    final pLeft = Offset(padX, size.height - padBottom);
    final pRight = Offset(
      size.width - padX - (has3D ? 24.0 : 0.0),
      size.height - padBottom,
    );
    final apex = Offset(size.width * 0.40, padTop + (has3D ? 16.0 : 0.0));
    final altitudeFoot = Offset(apex.dx, size.height - padBottom);

    if (has3D) {
      // Oblique extrusion offset (depth direction)
      const offset3D = Offset(24.0, -16.0);
      final bLeft = pLeft + offset3D;
      final bRight = pRight + offset3D;
      final bApex = apex + offset3D;

      // Draw rear extruded faces & connecting edges
      final backPath = Path()
        ..moveTo(bLeft.dx, bLeft.dy)
        ..lineTo(bRight.dx, bRight.dy)
        ..lineTo(bApex.dx, bApex.dy)
        ..close();
      canvas.drawPath(backPath, extrudedPaint);

      canvas.drawLine(pLeft, bLeft, extrudedPaint);
      canvas.drawLine(pRight, bRight, extrudedPaint);
      canvas.drawLine(apex, bApex, extrudedPaint);

      // Depth Dimension Arrow along top receding edge
      _drawDimensionArrow(canvas, apex, bApex, dimensionPaint);
      _drawText(
        canvas,
        _formatLabel('Depth', 'depth'),
        Offset((apex.dx + bApex.dx) / 2 - 14.0, (apex.dy + bApex.dy) / 2 - 8.0),
        accentColor,
      );
    }

    // Front Triangle
    final frontPath = Path()
      ..moveTo(pLeft.dx, pLeft.dy)
      ..lineTo(pRight.dx, pRight.dy)
      ..lineTo(apex.dx, apex.dy)
      ..close();
    canvas.drawPath(frontPath, shapePaint);

    // Dashed Altitude (Height)
    _drawDashedLine(canvas, apex, altitudeFoot, dimensionPaint);

    const marker = 8.0;
    final markerPath = Path()
      ..moveTo(altitudeFoot.dx + marker, altitudeFoot.dy)
      ..lineTo(altitudeFoot.dx + marker, altitudeFoot.dy - marker)
      ..lineTo(altitudeFoot.dx, altitudeFoot.dy - marker);
    canvas.drawPath(markerPath, dimensionPaint);

    // Dimension Arrow: Base
    final arrowY = size.height - padBottom + 16.0;
    _drawDimensionArrow(
      canvas,
      Offset(pLeft.dx, arrowY),
      Offset(pRight.dx, arrowY),
      dimensionPaint,
    );

    _drawText(
      canvas,
      _formatLabel('Base', 'b'),
      Offset((pLeft.dx + pRight.dx) / 2, arrowY + 10.0),
      accentColor,
    );

    _drawText(
      canvas,
      _formatLabel('Height', 'h'),
      Offset(apex.dx - 16.0, (apex.dy + altitudeFoot.dy) / 2),
      accentColor,
    );

    _drawText(
      canvas,
      _formatLabel('Side A', 'a'),
      Offset((pLeft.dx + apex.dx) / 2 - 14.0, (pLeft.dy + apex.dy) / 2 - 6.0),
      guideColor,
    );

    _drawText(
      canvas,
      _formatLabel('Side B', 'c'),
      Offset((pRight.dx + apex.dx) / 2 + 14.0, (pRight.dy + apex.dy) / 2 - 6.0),
      guideColor,
    );
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
    final uv = (p2 - p1) / (p2 - p1).distance;
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
  bool shouldRepaint(covariant TrianglePainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.units != units ||
      oldDelegate.isDark != isDark;
}
