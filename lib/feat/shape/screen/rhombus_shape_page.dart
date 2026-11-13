// lib/feat/shape/screen/rhombus_shape_page.dart
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../screen/base_shape_page.dart';
import '../widget/painter/rhombus_painter.dart';

class RhombusShapePage extends StatelessWidget {
  const RhombusShapePage({super.key});

  static const parameters = [
    'Side',
    'Diagonal 1',
    'Diagonal 2',
    'Depth',
    'Area',
    'Perimeter',
    'Volume',
  ];

  static Map<String, double> _solveRhombus(Map<String, double> inputs) {
    var s = inputs['Side'];
    var d1 = inputs['Diagonal 1'];
    var d2 = inputs['Diagonal 2'];
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

      // 1. Perimeter = 4 * Side
      if (s case double side) p = assign(p, 4 * side);
      if (p case double perim) s = assign(s, perim / 4);

      // 2. Area = (d1 * d2) / 2
      if ((d1, d2) case (double diag1, double diag2))
        a = assign(a, (diag1 * diag2) / 2);
      if ((a, d1) case (double area, double diag1))
        d2 = assign(d2, (2 * area) / diag1);
      if ((a, d2) case (double area, double diag2))
        d1 = assign(d1, (2 * area) / diag2);

      // 3. Side and Diagonals Pythagorean: s^2 = (d1/2)^2 + (d2/2)^2
      if ((d1, d2) case (double diag1, double diag2)) {
        s = assign(
          s,
          math.sqrt(math.pow(diag1 / 2, 2) + math.pow(diag2 / 2, 2)),
        );
      }
      if ((s, d1) case (double side, double diag1) when side > diag1 / 2) {
        d2 = assign(
          d2,
          2 * math.sqrt(math.pow(side, 2) - math.pow(diag1 / 2, 2)),
        );
      }
      if ((s, d2) case (double side, double diag2) when side > diag2 / 2) {
        d1 = assign(
          d1,
          2 * math.sqrt(math.pow(side, 2) - math.pow(diag2 / 2, 2)),
        );
      }

      // 4. Extrusion Volume = Base Area * Depth
      if ((a, depth) case (double area, double d)) v = assign(v, area * d);
      if ((a, v) case (double area, double vol))
        depth = assign(depth, vol / area);
      if ((depth, v) case (double d, double vol)) a = assign(a, vol / d);

      safetyPass++;
    } while (changed && safetyPass < 10);

    return {
      'Side': ?s,
      'Diagonal 1': ?d1,
      'Diagonal 2': ?d2,
      'Depth': ?depth,
      'Area': ?a,
      'Perimeter': ?p,
      'Volume': ?v,
    }..removeWhere((_, val) => val <= 0 || val.isNaN);
  }

  @override
  Widget build(BuildContext context) => BaseShapePage(
    title: 'Rhombus Calculator',
    shapeType: 'Rhombus',
    parameters: parameters,
    solver: _solveRhombus,
    painterBuilder: (context, values, units, isDark) =>
        RhombusPainter(values: values, units: units, isDark: isDark),
  );
}
