// lib/feat/shape/widget/painter/hexagon_painter.dart
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class HexagonPainter extends CustomPainter {
  const HexagonPainter({
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
      ..color = accentColor.withValues(alpha: 0.65)
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
    final r = math.min(size.width, size.height) / 2 - 28.0;

    // 6 Vertices of regular hexagon (flat-top orientation)
    List<Offset> getVertices(Offset c) => List.generate(6, (i) {
      final angle = (i * 60.0 - 30.0) * math.pi / 180.0;
      return Offset(c.dx + r * math.cos(angle), c.dy + r * math.sin(angle));
    });

    final frontVertices = getVertices(center);

    if (has3D) {
      final rearVertices = getVertices(center + offset3D);

      final rearPath = Path()..addPolygon(rearVertices, true);
      canvas.drawPath(rearPath, extrudedPaint);

      for (var i = 0; i < 6; i++) {
        canvas.drawLine(frontVertices[i], rearVertices[i], extrudedPaint);
      }

      _drawDimensionArrow(
        canvas,
        frontVertices[1],
        rearVertices[1],
        dimensionPaint,
      );
      _drawText(
        canvas,
        _formatLabel('Depth', 'depth'),
        Offset(
          (frontVertices[1].dx + rearVertices[1].dx) / 2 + 14.0,
          (frontVertices[1].dy + rearVertices[1].dy) / 2 - 8.0,
        ),
        accentColor,
      );
    }

    // Front Hexagon
    final frontPath = Path()..addPolygon(frontVertices, true);
    canvas.drawPath(frontPath, shapePaint);

    // Long Diagonal (vertex 4 to vertex 1)
    _drawDashedLine(canvas, frontVertices[4], frontVertices[1], diagonalPaint);
    _drawText(
      canvas,
      _formatLabel('Long Diagonal', 'd_L'),
      center + const Offset(0, -10.0),
      accentColor,
    );

    // Side Label (bottom-right edge)
    final pA = frontVertices[2];
    final pB = frontVertices[3];
    _drawText(
      canvas,
      _formatLabel('Side', 's'),
      Offset((pA.dx + pB.dx) / 2, (pA.dy + pB.dy) / 2 + 12.0),
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
  bool shouldRepaint(covariant HexagonPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.units != units ||
      oldDelegate.isDark != isDark;
}
