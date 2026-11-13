// lib/feat/shape/screen/hexagon_shape_page.dart
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../screen/base_shape_page.dart';
import '../widget/painter/hexagon_painter.dart';

class HexagonShapePage extends StatelessWidget {
  const HexagonShapePage({super.key});

  static const parameters = [
    'Side',
    'Short Diagonal',
    'Long Diagonal',
    'Depth',
    'Area',
    'Perimeter',
    'Volume',
  ];

  static Map<String, double> _solveHexagon(Map<String, double> inputs) {
    var s = inputs['Side'];
    var ds = inputs['Short Diagonal'];
    var dl = inputs['Long Diagonal'];
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

    final sqrt3 = math.sqrt(3);

    do {
      changed = false;

      // 1. Regular Hexagon 2D Base relations
      if (s case double side) {
        p = assign(p, 6 * side);
        dl = assign(dl, 2 * side);
        ds = assign(ds, side * sqrt3);
        a = assign(a, (3 * sqrt3 / 2) * side * side);
      } else if (p case double perim) {
        s = assign(s, perim / 6);
      } else if (dl case double longDiag) {
        s = assign(s, longDiag / 2);
      } else if (ds case double shortDiag) {
        s = assign(s, shortDiag / sqrt3);
      } else if (a case double area) {
        s = assign(s, math.sqrt((2 * area) / (3 * sqrt3)));
      }

      // 2. Extrusion Volume = Base Area * Depth
      if ((a, depth) case (double area, double d)) v = assign(v, area * d);
      if ((a, v) case (double area, double vol))
        depth = assign(depth, vol / area);
      if ((depth, v) case (double d, double vol)) a = assign(a, vol / d);

      safetyPass++;
    } while (changed && safetyPass < 10);

    return {
      'Side': ?s,
      'Short Diagonal': ?ds,
      'Long Diagonal': ?dl,
      'Depth': ?depth,
      'Area': ?a,
      'Perimeter': ?p,
      'Volume': ?v,
    }..removeWhere((_, val) => val <= 0 || val.isNaN);
  }

  @override
  Widget build(BuildContext context) => BaseShapePage(
    title: 'Regular Hexagon Calculator',
    shapeType: 'Hexagon',
    parameters: parameters,
    solver: _solveHexagon,
    painterBuilder: (context, values, units, isDark) =>
        HexagonPainter(values: values, units: units, isDark: isDark),
  );
}
