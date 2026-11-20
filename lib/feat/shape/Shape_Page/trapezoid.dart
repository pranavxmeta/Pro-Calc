// lib/feat/shape/screen/trapezoid_shape_page.dart
import 'package:material_ui/material_ui.dart';

import '../screen/base_shape_page.dart';
import '../widget/painter/trapezoid_painter.dart';

class TrapezoidShapePage extends StatelessWidget {
  const TrapezoidShapePage({super.key});

  static const parameters = [
    'Base A',
    'Base B',
    'Height',
    'Side C',
    'Side D',
    'Depth',
    'Area',
    'Perimeter',
    'Volume',
  ];

  static Map<String, double> _solveTrapezoid(Map<String, double> inputs) {
    var bA = inputs['Base A'];
    var bB = inputs['Base B'];
    var h = inputs['Height'];
    var sC = inputs['Side C'];
    var sD = inputs['Side D'];
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

      // 1. Bases & Height <-> Area: A = 0.5 * (bA + bB) * h
      if ((bA, bB, h) case (double ba, double bb, double height)) {
        a = assign(a, 0.5 * (ba + bb) * height);
      }
      if ((bA, bB, a) case (double ba, double bb, double area)
          when ba + bb > 0) {
        h = assign(h, (2 * area) / (ba + bb));
      }
      if ((bA, h, a) case (double ba, double height, double area)) {
        bB = assign(bB, (2 * area) / height - ba);
      }
      if ((bB, h, a) case (double bb, double height, double area)) {
        bA = assign(bA, (2 * area) / height - bb);
      }

      // 2. Perimeter = bA + bB + sC + sD
      if ((bA, bB, sC, sD) case (double ba, double bb, double sc, double sd)) {
        p = assign(p, ba + bb + sc + sd);
      }
      if ((p, bA, bB, sC) case (
        double perim,
        double ba,
        double bb,
        double sc,
      )) {
        sD = assign(sD, perim - ba - bb - sc);
      }
      if ((p, bA, bB, sD) case (
        double perim,
        double ba,
        double bb,
        double sd,
      )) {
        sC = assign(sC, perim - ba - bb - sd);
      }
      if ((p, bA, sC, sD) case (
        double perim,
        double ba,
        double sc,
        double sd,
      )) {
        bB = assign(bB, perim - ba - sc - sd);
      }
      if ((p, bB, sC, sD) case (
        double perim,
        double bb,
        double sc,
        double sd,
      )) {
        bA = assign(bA, perim - bb - sc - sd);
      }

      // 3. Extrusion: Volume = Base Area * Depth
      if ((a, depth) case (double area, double d)) v = assign(v, area * d);
      if ((a, v) case (double area, double vol)) {
        depth = assign(depth, vol / area);
      }
      if ((depth, v) case (double d, double vol)) a = assign(a, vol / d);

      safetyPass++;
    } while (changed && safetyPass < 10);

    return {
      'Base A': ?bA,
      'Base B': ?bB,
      'Height': ?h,
      'Side C': ?sC,
      'Side D': ?sD,
      'Depth': ?depth,
      'Area': ?a,
      'Perimeter': ?p,
      'Volume': ?v,
    }..removeWhere((_, val) => val <= 0 || val.isNaN);
  }

  @override
  Widget build(BuildContext context) => BaseShapePage(
    title: 'Trapezoid Calculator',
    shapeType: 'Trapezoid',
    parameters: parameters,
    solver: _solveTrapezoid,
    painterBuilder: (context, values, units, isDark) =>
        TrapezoidPainter(values: values, units: units, isDark: isDark),
  );
}
