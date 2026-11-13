// lib/feat/shape/screen/sphere_shape_page.dart
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../screen/base_shape_page.dart';
import '../widget/painter/sphere_painter.dart';

class SphereShapePage extends StatelessWidget {
  const SphereShapePage({super.key});

  static const parameters = [
    'Radius',
    'Diameter',
    'Circumference',
    'Surface Area',
    'Volume',
  ];

  static Map<String, double> _solveSphere(Map<String, double> inputs) {
    var r = inputs['Radius'];
    var d = inputs['Diameter'];
    var c = inputs['Circumference'];
    var sa = inputs['Surface Area'];
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

      // Single degree-of-freedom cascade propagation
      if (r case double rad) {
        d = assign(d, 2 * rad);
        c = assign(c, 2 * math.pi * rad);
        sa = assign(sa, 4 * math.pi * rad * rad);
        v = assign(v, (4 / 3) * math.pi * math.pow(rad, 3).toDouble());
      } else if (d case double diam) {
        r = assign(r, diam / 2);
      } else if (c case double circ) {
        r = assign(r, circ / (2 * math.pi));
      } else if (sa case double area) {
        r = assign(r, math.sqrt(area / (4 * math.pi)));
      } else if (v case double vol) {
        r = assign(r, math.pow((3 * vol) / (4 * math.pi), 1 / 3).toDouble());
      }

      safetyPass++;
    } while (changed && safetyPass < 10);

    return {
      'Radius': ?r,
      'Diameter': ?d,
      'Circumference': ?c,
      'Surface Area': ?sa,
      'Volume': ?v,
    }..removeWhere((_, val) => val <= 0 || val.isNaN);
  }

  @override
  Widget build(BuildContext context) => BaseShapePage(
    title: 'Sphere Calculator',
    shapeType: 'Sphere',
    parameters: parameters,
    solver: _solveSphere,
    painterBuilder: (context, values, units, isDark) =>
        SpherePainter(values: values, units: units, isDark: isDark),
  );
}
