import 'dart:math';

/// Pure geometric calculation engine.
/// Accepts input parameters in base meters and returns calculated values in base meters.
final class ShapeSolver {
  const ShapeSolver._();

  static Map<String, double> solve({
    required String shapeType,
    required Map<String, double> inputs,
  }) => switch (shapeType) {
    'Rectangle' => _solveRectangle(inputs),
    'Square' => _solveSquare(inputs),
    'Circle' => _solveCircle(inputs),
    'Triangle' => _solveTriangle(inputs),
    'Trapezoid' => _solveTrapezoid(inputs),
    _ => const {},
  };

  static Map<String, double> _solveRectangle(Map<String, double> i) {
    final res = <String, double>{};
    double? l = i['Length'];
    double? w = i['Width'];
    double? h = i['Height'];
    double? a = i['Area'];
    double? p = i['Perimeter'];
    double? v = i['Volume'];

    if (l != null && w != null) {
      if (l <= 0 || w <= 0) return const {};
      a = l * w;
      p = 2 * (l + w);
      if (h != null && h > 0) v = l * w * h;
    } else if (l != null && a != null) {
      if (l <= 0 || a <= 0) return const {};
      w = a / l;
      p = 2 * (l + w);
    } else if (w != null && a != null) {
      if (w <= 0 || a <= 0) return const {};
      l = a / w;
      p = 2 * (l + w);
    } else if (l != null && p != null) {
      final halfP = p / 2;
      if (halfP <= l || l <= 0) return const {};
      w = halfP - l;
      a = l * w;
    } else if (w != null && p != null) {
      final halfP = p / 2;
      if (halfP <= w || w <= 0) return const {};
      l = halfP - w;
      a = l * w;
    } else if (a != null && v != null) {
      if (a <= 0 || v <= 0) return const {};
      h = v / a;
    } else if (a != null && p != null) {
      final sum = p / 2;
      final disc = sum * sum - 4 * a;
      if (disc < 0) return const {};
      final sqrtD = sqrt(disc);
      l = (sum + sqrtD) / 2;
      w = (sum - sqrtD) / 2;
    }

    if (l != null && l > 0) res['Length'] = l;
    if (w != null && w > 0) res['Width'] = w;
    if (h != null && h > 0) res['Height'] = h;
    if (a != null && a > 0) res['Area'] = a;
    if (p != null && p > 0) res['Perimeter'] = p;
    if (v != null && v > 0) res['Volume'] = v;
    return res;
  }

  static Map<String, double> _solveSquare(Map<String, double> i) {
    final res = <String, double>{};
    double? s = i['Side'];
    double? a = i['Area'];
    double? p = i['Perimeter'];
    double? d = i['Diagonal'];

    if (s != null && s > 0) {
      a = s * s;
      p = 4 * s;
      d = s * sqrt(2);
    } else if (a != null && a > 0) {
      s = sqrt(a);
      p = 4 * s;
      d = s * sqrt(2);
    } else if (p != null && p > 0) {
      s = p / 4;
      a = s * s;
      d = s * sqrt(2);
    } else if (d != null && d > 0) {
      s = d / sqrt(2);
      a = s * s;
      p = 4 * s;
    }

    if (s != null && s > 0) res['Side'] = s;
    if (a != null && a > 0) res['Area'] = a;
    if (p != null && p > 0) res['Perimeter'] = p;
    if (d != null && d > 0) res['Diagonal'] = d;
    return res;
  }

  static Map<String, double> _solveCircle(Map<String, double> i) {
    final res = <String, double>{};
    double? r = i['Radius'];
    double? d = i['Diameter'];
    double? a = i['Area'];
    double? c = i['Circumference'];

    if (r != null && r > 0) {
      d = 2 * r;
      a = pi * r * r;
      c = 2 * pi * r;
    } else if (d != null && d > 0) {
      r = d / 2;
      a = pi * r * r;
      c = pi * d;
    } else if (a != null && a > 0) {
      r = sqrt(a / pi);
      d = 2 * r;
      c = 2 * pi * r;
    } else if (c != null && c > 0) {
      r = c / (2 * pi);
      d = 2 * r;
      a = pi * r * r;
    }

    if (r != null && r > 0) res['Radius'] = r;
    if (d != null && d > 0) res['Diameter'] = d;
    if (a != null && a > 0) res['Area'] = a;
    if (c != null && c > 0) res['Circumference'] = c;
    return res;
  }

  static Map<String, double> _solveTriangle(Map<String, double> i) {
    final res = <String, double>{};
    double? b = i['Base'];
    double? h = i['Height'];
    double? sa = i['Side A'];
    double? sb = i['Side B'];
    double? a = i['Area'];
    double? p = i['Perimeter'];

    if (b != null && h != null && b > 0 && h > 0) {
      a = 0.5 * b * h;
    } else if (b != null && a != null && b > 0 && a > 0) {
      h = (2 * a) / b;
    }

    if (sa != null && sb != null && b != null) {
      if (sa > 0 &&
          sb > 0 &&
          b > 0 &&
          sa + sb > b &&
          sa + b > sb &&
          sb + b > sa) {
        p = sa + sb + b;
        final s = p / 2;
        final heronArea = sqrt(s * (s - sa) * (s - sb) * (s - b));
        if (!heronArea.isNaN && heronArea > 0) {
          a ??= heronArea;
          h ??= (2 * a) / b;
        }
      }
    }

    if (b != null && b > 0) res['Base'] = b;
    if (h != null && h > 0) res['Height'] = h;
    if (sa != null && sa > 0) res['Side A'] = sa;
    if (sb != null && sb > 0) res['Side B'] = sb;
    if (a != null && a > 0) res['Area'] = a;
    if (p != null && p > 0) res['Perimeter'] = p;
    return res;
  }

  static Map<String, double> _solveTrapezoid(Map<String, double> i) {
    final res = <String, double>{};
    double? bA = i['Base A'];
    double? bB = i['Base B'];
    double? h = i['Height'];
    double? sC = i['Side C'];
    double? sD = i['Side D'];
    double? a = i['Area'];
    double? p = i['Perimeter'];

    if (bA != null && bB != null && h != null && bA > 0 && bB > 0 && h > 0) {
      a = 0.5 * (bA + bB) * h;
    } else if (bA != null &&
        bB != null &&
        a != null &&
        (bA + bB) > 0 &&
        a > 0) {
      h = (2 * a) / (bA + bB);
    }

    if (bA != null &&
        bB != null &&
        sC != null &&
        sD != null &&
        sC > 0 &&
        sD > 0) {
      p = bA + bB + sC + sD;
    }

    if (bA != null && bA > 0) res['Base A'] = bA;
    if (bB != null && bB > 0) res['Base B'] = bB;
    if (h != null && h > 0) res['Height'] = h;
    if (sC != null && sC > 0) res['Side C'] = sC;
    if (sD != null && sD > 0) res['Side D'] = sD;
    if (a != null && a > 0) res['Area'] = a;
    if (p != null && p > 0) res['Perimeter'] = p;
    return res;
  }
}
