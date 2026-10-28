import 'package:flutter/widgets.dart';

/// Design tokens defining the liquid frosted-glass modal sheet aesthetic.
abstract final class IosSheetTokens {
  // Frosted Glass Blur Sigma (Single-pass GPU-efficient)
  static const double blurSigmaX = 10.0;
  static const double blurSigmaY = 10.0;

  // Barrier Scrim (Zero-overhead clean fade)
  static const Color barrierColor = Color(0x00000000);

  // Surface Glass Gradients matching CalcButton & CalcBottomNavNew
  static const List<Color> surfaceLight = [
    Color.fromARGB(10, 255, 255, 255), // 81% white crest
    Color.fromARGB(6, 255, 255, 255),
  ];

  static const List<Color> surfaceDark = [
    Color.fromRGBO(30, 30, 38, 0.80),
    Color.fromRGBO(18, 18, 24, 0.52),
  ];

  // Specular Perimeter Borders
  static const Color borderLight = Color.fromRGBO(255, 255, 255, 0.90);
  static const Color borderDark = Color.fromRGBO(255, 255, 255, 0.20);
  static const double borderWidth = 1.2;

  // Geometry
  static const double cornerRadius = 26.0;
  static const double defaultFloatingMargin = 12.0;
  static const double maxContentWidth = 540.0;

  // Motion Curves
  static const Curve entryCurve = Cubic(0.18, 0.89, 0.32, 1.02);
  static const Curve exitCurve = Cubic(0.4, 0.0, 1.0, 1.0);
  static const Duration animDuration = Duration(milliseconds: 320);
}
