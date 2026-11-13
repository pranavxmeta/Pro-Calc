// lib/feat/shape/screen/rectangle_shape_page.dart
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../screen/base_shape_page.dart';
import '../widget/painter/rectangle_painter.dart';

class RectangleShapePage extends StatelessWidget {
  const RectangleShapePage({super.key});

  static const parameters = [
    'Length',
    'Width',
    'Height',
    'Area',
    'Perimeter',
    'Volume',
  ];

  static Map<String, double> _solveRectangle(Map<String, double> inputs) {
    var l = inputs['Length'];
    var w = inputs['Width'];
    var h = inputs['Height'];
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

      // 1. Length & Width <-> Base Area
      if ((l, w) case (double len, double wid)) a = assign(a, len * wid);
      if ((l, a) case (double len, double area)) w = assign(w, area / len);
      if ((w, a) case (double wid, double area)) l = assign(l, area / wid);

      // 2. Length & Width <-> Base Perimeter
      if ((l, w) case (double len, double wid)) p = assign(p, 2 * (len + wid));
      if ((l, p) case (double len, double perim) when perim / 2 > len) {
        w = assign(w, perim / 2 - len);
      }
      if ((w, p) case (double wid, double perim) when perim / 2 > wid) {
        l = assign(l, perim / 2 - wid);
      }

      // 3. Area & Perimeter Quadratic Recovery
      if ((a, p) case (double area, double perim) when l == null && w == null) {
        final halfP = perim / 2;
        final disc = halfP * halfP - 4 * area;
        if (disc >= 0) {
          final sqrtD = math.sqrt(disc);
          l = assign(l, (halfP + sqrtD) / 2);
          w = assign(w, (halfP - sqrtD) / 2);
        }
      }

      // 4. Extrusion Volume <-> Base Area * Height
      if ((a, h) case (double area, double height))
        v = assign(v, area * height);
      if ((a, v) case (double area, double vol)) h = assign(h, vol / area);
      if ((h, v) case (double height, double vol)) a = assign(a, vol / height);

      safetyPass++;
    } while (changed && safetyPass < 10);

    return {
      'Length': ?l,
      'Width': ?w,
      'Height': ?h,
      'Area': ?a,
      'Perimeter': ?p,
      'Volume': ?v,
    }..removeWhere((_, val) => val <= 0 || val.isNaN);
  }

  @override
  Widget build(BuildContext context) => BaseShapePage(
    title: 'Rectangle Calculator',
    shapeType: 'Rectangle',
    parameters: parameters,
    solver: _solveRectangle,
    painterBuilder: (context, values, units, isDark) =>
        RectanglePainter(values: values, units: units, isDark: isDark),
  );
}
