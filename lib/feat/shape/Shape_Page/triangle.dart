// lib/feat/shape/screen/triangle_shape_page.dart
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../widget/painter/triangle_painter.dart';
import '../screen/base_shape_page.dart';

class TriangleShapePage extends StatelessWidget {
  const TriangleShapePage({super.key});

  static const parameters = [
    'Base',
    'Height',
    'Side A',
    'Side B',
    'Depth',
    'Area',
    'Perimeter',
    'Volume',
  ];

  static Map<String, double> _solveTriangle(Map<String, double> inputs) {
    var base = inputs['Base'];
    var height = inputs['Height'];
    var sideA = inputs['Side A'];
    var sideB = inputs['Side B'];
    var depth = inputs['Depth'];
    var area = inputs['Area'];
    var perimeter = inputs['Perimeter'];
    var volume = inputs['Volume'];

    bool changed;
    var safetyPass = 0;

    double? assign(double? current, double next) {
      if (current == null && next > 0 && !next.isNaN) {
        changed = true;
        return next;
      }
      return current;
    }

    do {
      changed = false;

      // 1. Perimeter <-> 3 sides (Perimeter = a + b + c)
      if ((sideA, sideB) case (double sa, double sb)) {
        if (base case double b) perimeter = assign(perimeter, sa + sb + b);
        if (perimeter case double p) base = assign(base, p - sa - sb);
      }

      // 2. Heron's Formula (3 sides -> Area)
      if ((sideA, sideB, base) case (double sa, double sb, double b)
          when area == null) {
        if (sa + sb > b && sa + b > sb && sb + b > sa) {
          final s = (sa + sb + b) / 2;
          final radicand = s * (s - sa) * (s - sb) * (s - b);
          if (radicand > 0) area = assign(area, math.sqrt(radicand));
        }
      }

      // 3. Triangle Base/Height/Area trio (Area = 0.5 * Base * Height)
      if ((base, height) case (double b, double h))
        area = assign(area, 0.5 * b * h);
      if ((base, area) case (double b, double a))
        height = assign(height, (2 * a) / b);
      if ((height, area) case (double h, double a))
        base = assign(base, (2 * a) / h);

      // 4. Extrusion: Volume = Base Area * Depth
      if ((area, depth) case (double a, double d))
        volume = assign(volume, a * d);
      if ((area, volume) case (double a, double v))
        depth = assign(depth, v / a);
      if ((depth, volume) case (double d, double v)) area = assign(area, v / d);

      safetyPass++;
    } while (changed && safetyPass < 10);

    return {
      'Base': ?base,
      'Height': ?height,
      'Side A': ?sideA,
      'Side B': ?sideB,
      'Depth': ?depth,
      'Area': ?area,
      'Perimeter': ?perimeter,
      'Volume': ?volume,
    }..removeWhere((_, val) => val <= 0 || val.isNaN);
  }

  @override
  Widget build(BuildContext context) => BaseShapePage(
    title: 'Triangle Calculator',
    shapeType: 'Triangle',
    parameters: parameters,
    solver: _solveTriangle,
    painterBuilder: (context, values, units, isDark) =>
        TrianglePainter(values: values, units: units, isDark: isDark),
  );
}
