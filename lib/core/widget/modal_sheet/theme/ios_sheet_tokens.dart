import 'package:flutter/widgets.dart';

/// Design tokens defining the futuristic iOS 26 frosted glass aesthetic.
abstract final class IosSheetTokens {
  // Frosted Glass Blur Sigmas
  static const double blurSigmaX = 32.0;
  static const double blurSigmaY = 32.0;

  // Modern Translucent Background Layers
  static const Color surfaceColor = Color(0xCC18191E);
  static const Color barrierColor = Color(0x66000000);

  // Specular Ambient Border Gradients
  static const Color borderGlowLight = Color(0x33FFFFFF);
  static const Color borderGlowDark = Color(0x0AFFFFFF);

  // Grabber / Pull Indicator
  static const Color grabberColor = Color(0x4DFFFFFF);
  static const Size grabberSize = Size(36.0, 4.5);

  // Geometry
  static const double cornerRadius = 32.0;
  static const double defaultFloatingMargin = 12.0;
  static const double maxContentWidth = 580.0;

  // Spring & Easing
  static const Curve entryCurve = Cubic(0.18, 0.89, 0.32, 1.02);
  static const Curve exitCurve = Cubic(0.4, 0.0, 1.0, 1.0);
  static const Duration animDuration = Duration(milliseconds: 380);
}
