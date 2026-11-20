// lib/feat/shape/widget/painter/rectangle_painter.dart
import 'package:material_ui/material_ui.dart';

class RectanglePainter extends CustomPainter {
  const RectanglePainter({
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
        (values['Height'] != null && values['Height']! > 0) ||
        (values['Volume'] != null && values['Volume']! > 0);

    const padLeft = 44.0;
    const padRight = 44.0;
    const padTop = 36.0;
    const padBottom = 42.0;

    final frontRect = Rect.fromLTRB(
      padLeft,
      padTop + (has3D ? 16.0 : 0.0),
      size.width - padRight - (has3D ? 20.0 : 0.0),
      size.height - padBottom,
    );

    if (has3D) {
      const offset3D = Offset(20.0, -16.0);
      final rearRect = frontRect.shift(offset3D);

      // Draw Rear Rect & connecting 3D edges
      canvas.drawRect(rearRect, extrudedPaint);
      canvas.drawLine(frontRect.topLeft, rearRect.topLeft, extrudedPaint);
      canvas.drawLine(frontRect.topRight, rearRect.topRight, extrudedPaint);
      canvas.drawLine(
        frontRect.bottomRight,
        rearRect.bottomRight,
        extrudedPaint,
      );
      canvas.drawLine(frontRect.bottomLeft, rearRect.bottomLeft, extrudedPaint);

      // Height/Depth 3D Dimension Arrow
      _drawDimensionArrow(
        canvas,
        frontRect.topRight,
        rearRect.topRight,
        dimensionPaint,
      );
      _drawText(
        canvas,
        _formatLabel('Height', 'h'),
        Offset(
          (frontRect.topRight.dx + rearRect.topRight.dx) / 2 + 14.0,
          (frontRect.topRight.dy + rearRect.topRight.dy) / 2 - 8.0,
        ),
        accentColor,
      );
    }

    // Front Rectangle Face
    canvas.drawRect(frontRect, shapePaint);

    // Right-Angle Corner Marker
    const marker = 8.0;
    final markerPath = Path()
      ..moveTo(frontRect.left + marker, frontRect.bottom)
      ..lineTo(frontRect.left + marker, frontRect.bottom - marker)
      ..lineTo(frontRect.left, frontRect.bottom - marker);
    canvas.drawPath(markerPath, dimensionPaint);

    // Length Dimension Arrow (Bottom)
    final arrowBottomY = frontRect.bottom + 16.0;
    _drawDimensionArrow(
      canvas,
      Offset(frontRect.left, arrowBottomY),
      Offset(frontRect.right, arrowBottomY),
      dimensionPaint,
    );
    _drawText(
      canvas,
      _formatLabel('Length', 'l'),
      Offset(frontRect.center.dx, arrowBottomY + 10.0),
      accentColor,
    );

    // Width Dimension Arrow (Left)
    final arrowLeftX = frontRect.left - 16.0;
    _drawDimensionArrow(
      canvas,
      Offset(arrowLeftX, frontRect.bottom),
      Offset(arrowLeftX, frontRect.top),
      dimensionPaint,
    );
    _drawText(
      canvas,
      _formatLabel('Width', 'w'),
      Offset(arrowLeftX - 16.0, frontRect.center.dy),
      accentColor,
    );
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
  bool shouldRepaint(covariant RectanglePainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.units != units ||
      oldDelegate.isDark != isDark;
}
