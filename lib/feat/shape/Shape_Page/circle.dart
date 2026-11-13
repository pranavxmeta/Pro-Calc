// lib/feat/shape/screen/circle_shape_page.dart
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../screen/base_shape_page.dart';
import '../widget/painter/circle_painter.dart';

class CircleShapePage extends StatelessWidget {
  const CircleShapePage({super.key});

  static const parameters = [
    'Radius',
    'Diameter',
    'Height',
    'Area',
    'Circumference',
    'Volume',
  ];

  static Map<String, double> _solveCircle(Map<String, double> inputs) {
    var r = inputs['Radius'];
    var d = inputs['Diameter'];
    var h = inputs['Height'];
    var a = inputs['Area'];
    var c = inputs['Circumference'];
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

      // 1. 2D Circle Base relations
      if (r case double rad) {
        d = assign(d, 2 * rad);
        a = assign(a, math.pi * rad * rad);
        c = assign(c, 2 * math.pi * rad);
      } else if (d case double diam) {
        r = assign(r, diam / 2);
      } else if (a case double area) {
        r = assign(r, math.sqrt(area / math.pi));
      } else if (c case double circ) {
        r = assign(r, circ / (2 * math.pi));
      }

      // 2. Extrusion Cylinder Volume: V = Base Area * Height
      if ((a, h) case (double area, double height))
        v = assign(v, area * height);
      if ((a, v) case (double area, double vol)) h = assign(h, vol / area);
      if ((h, v) case (double height, double vol)) a = assign(a, vol / height);

      safetyPass++;
    } while (changed && safetyPass < 10);

    return {
      'Radius': ?r,
      'Diameter': ?d,
      'Height': ?h,
      'Area': ?a,
      'Circumference': ?c,
      'Volume': ?v,
    }..removeWhere((_, val) => val <= 0 || val.isNaN);
  }

  @override
  Widget build(BuildContext context) => BaseShapePage(
    title: 'Circle Calculator',
    shapeType: 'Circle',
    parameters: parameters,
    solver: _solveCircle,
    painterBuilder: (context, values, units, isDark) =>
        CirclePainter(values: values, units: units, isDark: isDark),
  );
}
