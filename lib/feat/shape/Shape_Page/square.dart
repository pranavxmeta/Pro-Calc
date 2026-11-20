// lib/feat/shape/screen/square_shape_page.dart
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../screen/base_shape_page.dart';
import '../widget/painter/square_painter.dart';

class SquareShapePage extends StatelessWidget {
  const SquareShapePage({super.key});

  static const parameters = [
    'Side',
    'Height',
    'Area',
    'Perimeter',
    'Diagonal',
    'Volume',
  ];

  static Map<String, double> _solveSquare(Map<String, double> inputs) {
    var s = inputs['Side'];
    var h = inputs['Height'];
    var a = inputs['Area'];
    var p = inputs['Perimeter'];
    var d = inputs['Diagonal'];
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

      // 1. 2D Base Square relations
      if (s case double side) {
        a = assign(a, side * side);
        p = assign(p, 4 * side);
        d = assign(d, side * math.sqrt2);
      } else if (a case double area) {
        s = assign(s, math.sqrt(area));
      } else if (p case double perim) {
        s = assign(s, perim / 4);
      } else if (d case double diag) {
        s = assign(s, diag / math.sqrt2);
      }

      // 2. Extrusion Volume: V = Base Area * Height
      if ((a, h) case (double area, double height)) {
        v = assign(v, area * height);
      }
      if ((a, v) case (double area, double vol)) h = assign(h, vol / area);
      if ((h, v) case (double height, double vol)) a = assign(a, vol / height);

      // Cube special deduction (if volume given without height, default cube: s = cbrt(v))
      if (v case double vol when s == null && h == null) {
        final side = math.pow(vol, 1 / 3).toDouble();
        s = assign(s, side);
        h = assign(h, side);
      }

      safetyPass++;
    } while (changed && safetyPass < 10);

    return {
      'Side': ?s,
      'Height': ?h,
      'Area': ?a,
      'Perimeter': ?p,
      'Diagonal': ?d,
      'Volume': ?v,
    }..removeWhere((_, val) => val <= 0 || val.isNaN);
  }

  @override
  Widget build(BuildContext context) => BaseShapePage(
    title: 'Square Calculator',
    shapeType: 'Square',
    parameters: parameters,
    solver: _solveSquare,
    painterBuilder: (context, values, units, isDark) =>
        SquarePainter(values: values, units: units, isDark: isDark),
  );
}
