// lib/feat/shape/screen/parallelogram_shape_page.dart
import 'package:material_ui/material_ui.dart';

import '../screen/base_shape_page.dart';
import '../widget/painter/parallelogram_painter.dart';

class ParallelogramShapePage extends StatelessWidget {
  const ParallelogramShapePage({super.key});

  static const parameters = [
    'Base',
    'Side',
    'Height',
    'Depth',
    'Area',
    'Perimeter',
    'Volume',
  ];

  static Map<String, double> _solveParallelogram(Map<String, double> inputs) {
    var b = inputs['Base'];
    var s = inputs['Side'];
    var h = inputs['Height'];
    var depth = inputs['Depth'];
    var a = inputs['Area'];
    var p = inputs['Perimeter'];
    var v = inputs['Volume'];

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

      // 1. Area = Base * Height
      if ((b, h) case (double base, double height)) {
        a = assign(a, base * height);
      }
      if ((b, a) case (double base, double area)) h = assign(h, area / base);
      if ((h, a) case (double height, double area)) {
        b = assign(b, area / height);
      }

      // 2. Perimeter = 2 * (Base + Side)
      if ((b, s) case (double base, double side)) {
        p = assign(p, 2 * (base + side));
      }
      if ((p, b) case (double perim, double base) when perim / 2 > base) {
        s = assign(s, perim / 2 - base);
      }
      if ((p, s) case (double perim, double side) when perim / 2 > side) {
        b = assign(b, perim / 2 - side);
      }

      // 3. Extrusion Volume = Base Area * Depth
      if ((a, depth) case (double area, double d)) v = assign(v, area * d);
      if ((a, v) case (double area, double vol)) {
        depth = assign(depth, vol / area);
      }
      if ((depth, v) case (double d, double vol)) a = assign(a, vol / d);

      safetyPass++;
    } while (changed && safetyPass < 10);

    return {
      'Base': ?b,
      'Side': ?s,
      'Height': ?h,
      'Depth': ?depth,
      'Area': ?a,
      'Perimeter': ?p,
      'Volume': ?v,
    }..removeWhere((_, val) => val <= 0 || val.isNaN);
  }

  @override
  Widget build(BuildContext context) => BaseShapePage(
    title: 'Parallelogram Calculator',
    shapeType: 'Parallelogram',
    parameters: parameters,
    solver: _solveParallelogram,
    painterBuilder: (context, values, units, isDark) =>
        ParallelogramPainter(values: values, units: units, isDark: isDark),
  );
}
