// lib/feat/shape/widget/painter/rhombus_painter.dart
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class RhombusPainter extends CustomPainter {
  const RhombusPainter({
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

    final diagonalPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final dimensionPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final has3D =
        (values['Depth'] != null && values['Depth']! > 0) ||
        (values['Volume'] != null && values['Volume']! > 0);

    final offset3D = has3D ? const Offset(20.0, -14.0) : Offset.zero;

    final center = Offset(
      size.width / 2 - offset3D.dx / 2,
      size.height / 2 + offset3D.dy.abs() / 2,
    );
    final rx = size.width * 0.36;
    final ry = size.height * 0.28;

    final top = Offset(center.dx, center.dy - ry);
    final bottom = Offset(center.dx, center.dy + ry);
    final left = Offset(center.dx - rx, center.dy);
    final right = Offset(center.dx + rx, center.dy);

    if (has3D) {
      final rTop = top + offset3D;
      final rBottom = bottom + offset3D;
      final rLeft = left + offset3D;
      final rRight = right + offset3D;

      final rearPath = Path()
        ..moveTo(rTop.dx, rTop.dy)
        ..lineTo(rRight.dx, rRight.dy)
        ..lineTo(rBottom.dx, rBottom.dy)
        ..lineTo(rLeft.dx, rLeft.dy)
        ..close();
      canvas.drawPath(rearPath, extrudedPaint);

      canvas.drawLine(top, rTop, extrudedPaint);
      canvas.drawLine(bottom, rBottom, extrudedPaint);
      canvas.drawLine(left, rLeft, extrudedPaint);
      canvas.drawLine(right, rRight, extrudedPaint);

      _drawDimensionArrow(canvas, right, rRight, dimensionPaint);
      _drawText(
        canvas,
        _formatLabel('Depth', 'depth'),
        Offset(
          (right.dx + rRight.dx) / 2 + 14.0,
          (right.dy + rRight.dy) / 2 - 8.0,
        ),
        accentColor,
      );
    }

    // Front Rhombus
    final path = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(left.dx, left.dy)
      ..close();
    canvas.drawPath(path, shapePaint);

    // Diagonals
    _drawDashedLine(canvas, left, right, diagonalPaint);
    _drawDashedLine(canvas, top, bottom, diagonalPaint);

    // Central perpendicular marker
    const marker = 7.0;
    final markerPath = Path()
      ..moveTo(center.dx + marker, center.dy)
      ..lineTo(center.dx + marker, center.dy - marker)
      ..lineTo(center.dx, center.dy - marker);
    canvas.drawPath(markerPath, diagonalPaint);

    // Labels
    _drawText(
      canvas,
      _formatLabel('Diagonal 1', 'd₁'),
      Offset(center.dx + rx / 2, center.dy - 10.0),
      accentColor,
    );
    _drawText(
      canvas,
      _formatLabel('Diagonal 2', 'd₂'),
      Offset(center.dx - 12.0, center.dy - ry / 2),
      accentColor,
    );
    _drawText(
      canvas,
      _formatLabel('Side', 's'),
      Offset((top.dx + right.dx) / 2 + 14.0, (top.dy + right.dy) / 2 - 8.0),
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
  bool shouldRepaint(covariant RhombusPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.units != units ||
      oldDelegate.isDark != isDark;
}
