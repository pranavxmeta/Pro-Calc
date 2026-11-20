// lib/feat/shape/widget/painter/parallelogram_painter.dart
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class ParallelogramPainter extends CustomPainter {
  const ParallelogramPainter({
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

    const padLeft = 40.0;
    const padRight = 44.0;
    const padTop = 36.0;
    const padBottom = 42.0;

    final offset3D = has3D ? const Offset(20.0, -14.0) : Offset.zero;
    const slant = 36.0;

    final bLeft = Offset(padLeft, size.height - padBottom);
    final bRight = Offset(
      size.width - padRight - offset3D.dx - slant,
      size.height - padBottom,
    );
    final tLeft = Offset(padLeft + slant, padTop + offset3D.dy.abs());
    final tRight = Offset(
      size.width - padRight - offset3D.dx,
      padTop + offset3D.dy.abs(),
    );
    final altitudeFoot = Offset(tLeft.dx, size.height - padBottom);

    if (has3D) {
      final rbLeft = bLeft + offset3D;
      final rbRight = bRight + offset3D;
      final rtLeft = tLeft + offset3D;
      final rtRight = tRight + offset3D;

      final rearPath = Path()
        ..moveTo(rbLeft.dx, rbLeft.dy)
        ..lineTo(rbRight.dx, rbRight.dy)
        ..lineTo(rtRight.dx, rtRight.dy)
        ..lineTo(rtLeft.dx, rtLeft.dy)
        ..close();
      canvas.drawPath(rearPath, extrudedPaint);

      canvas.drawLine(bLeft, rbLeft, extrudedPaint);
      canvas.drawLine(bRight, rbRight, extrudedPaint);
      canvas.drawLine(tLeft, rtLeft, extrudedPaint);
      canvas.drawLine(tRight, rtRight, extrudedPaint);

      _drawDimensionArrow(canvas, tRight, rtRight, dimensionPaint);
      _drawText(
        canvas,
        _formatLabel('Depth', 'depth'),
        Offset(
          (tRight.dx + rtRight.dx) / 2 + 14.0,
          (tRight.dy + rtRight.dy) / 2 - 8.0,
        ),
        accentColor,
      );
    }

    // Front Parallelogram
    final path = Path()
      ..moveTo(bLeft.dx, bLeft.dy)
      ..lineTo(bRight.dx, bRight.dy)
      ..lineTo(tRight.dx, tRight.dy)
      ..lineTo(tLeft.dx, tLeft.dy)
      ..close();
    canvas.drawPath(path, shapePaint);

    // Dashed Altitude Height
    _drawDashedLine(canvas, tLeft, altitudeFoot, dimensionPaint);

    const marker = 8.0;
    final markerPath = Path()
      ..moveTo(altitudeFoot.dx + marker, altitudeFoot.dy)
      ..lineTo(altitudeFoot.dx + marker, altitudeFoot.dy - marker)
      ..lineTo(altitudeFoot.dx, altitudeFoot.dy - marker);
    canvas.drawPath(markerPath, dimensionPaint);

    // Base Arrow (Bottom)
    final arrowY = size.height - padBottom + 16.0;
    _drawDimensionArrow(
      canvas,
      Offset(bLeft.dx, arrowY),
      Offset(bRight.dx, arrowY),
      dimensionPaint,
    );
    _drawText(
      canvas,
      _formatLabel('Base', 'b'),
      Offset((bLeft.dx + bRight.dx) / 2, arrowY + 10.0),
      accentColor,
    );

    // Height Label
    _drawText(
      canvas,
      _formatLabel('Height', 'h'),
      Offset(tLeft.dx - 14.0, (tLeft.dy + altitudeFoot.dy) / 2),
      accentColor,
    );

    // Slanted Side Label
    _drawText(
      canvas,
      _formatLabel('Side', 's'),
      Offset((bLeft.dx + tLeft.dx) / 2 - 14.0, (bLeft.dy + tLeft.dy) / 2),
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
  bool shouldRepaint(covariant ParallelogramPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.units != units ||
      oldDelegate.isDark != isDark;
}
