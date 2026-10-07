import 'dart:async';
import 'dart:math' as math;

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Navigation bar hosting secondary modal triggers.
/// Projects an ultra-translucent crystal cylinder with convex specular aperture and forced perspective.
class CalcBottomNav extends StatefulWidget {
  const CalcBottomNav({super.key, required this.onNavAction, this.iconBuilder});

  final ValueChanged<String> onNavAction;
  final Widget Function(String symbol, bool isPressed)? iconBuilder;

  @override
  State<CalcBottomNav> createState() => _CalcBottomNavState();
}

class _CalcBottomNavState extends State<CalcBottomNav>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  StreamSubscription<AccelerometerEvent>? _sensorSub;

  final ValueNotifier<(double x, double y)> _tiltNotifier = ValueNotifier((
    0.0,
    0.0,
  ));

  // Ergonomic baseline (~48° pitch, Gravity Y ≈ 6.5 m/s²)
  static const double _neutralPitchY = 6.5;

  double _targetX = 0.0;
  double _targetY = 0.0;
  double _currentX = 0.0;
  double _currentY = 0.0;

  int? _pressedIndex;

  static const _symbols = ['Calc', 'hist', 'unit', 'Settings'];

  @override
  void initState() {
    super.initState();
    _startSensor();

    // 120 FPS vsync-driven low-pass filter (spring damping)
    _ticker = createTicker((_) {
      _currentX += (_targetX - _currentX) * 0.15;
      _currentY += (_targetY - _currentY) * 0.15;

      if ((_currentX - _tiltNotifier.value.$1).abs() > 0.0006 ||
          (_currentY - _tiltNotifier.value.$2).abs() > 0.0006) {
        _tiltNotifier.value = (_currentX, _currentY);
      }
    })..start();
  }

  void _startSensor() {
    try {
      _sensorSub = accelerometerEventStream().listen(
        (event) {
          final roll = (-event.x / 5.2).clamp(-1.0, 1.0);
          final pitch = ((event.y - _neutralPitchY) / 4.2).clamp(-1.0, 1.0);

          _targetX = roll;
          _targetY = pitch;
        },
        onError: (_) {},
        cancelOnError: true,
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _ticker.dispose();
    _sensorSub?.cancel();
    _tiltNotifier.dispose();
    super.dispose();
  }

  Widget _defaultIcon(String symbol, bool isPressed) {
    const iconColor = Colors.white; // Handled by ShaderMask

    return switch (symbol) {
      'Calc' => const Icon(
        FluentIcons.calculator_24_filled,
        size: 26,
        color: iconColor,
      ),
      'hist' => const Icon(
        FluentIcons.history_24_filled,
        size: 26,
        color: iconColor,
      ),
      'unit' => const Icon(
        FluentIcons.diversity_24_regular,
        size: 26,
        color: iconColor,
      ),
      'Settings' => const Icon(
        FluentIcons.settings_24_regular,
        size: 26,
        color: iconColor,
      ),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final barWidth = screenWidth * 0.65;
    const barHeight = 54.0;

    return Padding(
      padding: const .only(bottom: 12.0),
      child: GestureDetector(
        // Interactive drag fallback for emulator and desktop testing
        onPanUpdate: (details) {
          _targetX = (_targetX + (details.delta.dx / 120.0)).clamp(-1.0, 1.0);
          _targetY = (_targetY - (details.delta.dy / 90.0)).clamp(-1.0, 1.0);
        },
        onPanEnd: (_) {
          _targetX = 0.0;
          _targetY = 0.0;
        },
        child: RepaintBoundary(
          child: ValueListenableBuilder<(double x, double y)>(
            valueListenable: _tiltNotifier,
            builder: (context, tilt, _) {
              // High-precision micro-play travel
              final fgDx = tilt.$1 * 3.5;
              final fgDy = tilt.$2 * 2.2;

              // Atmospheric floor shadow vector
              final shadowDx = -tilt.$1 * 26.0;
              final shadowDy = -tilt.$2 * 14.0;

              return SizedBox(
                width: screenWidth,
                height: barHeight + 64.0,
                child: Stack(
                  clipBehavior: .none,
                  alignment: .topCenter,
                  children: [
                    // =========================================================
                    // 1. Decoupled Radiant Purple Floor Shadow (Floor Plane)
                    // =========================================================
                    Positioned(
                      top: 4.0,
                      child: Container(
                        width: screenWidth * 0.72,
                        height: barHeight,
                        decoration: BoxDecoration(
                          borderRadius: .circular(barHeight * 0.5),
                          boxShadow: [
                            // Radiant atmospheric purple caustic dispersion halo
                            BoxShadow(
                              color: const Color.fromRGBO(66, 0, 255, 0.22),
                              blurRadius: 46.0,
                              offset: Offset(shadowDx, 48.0 + shadowDy),
                              spreadRadius: 1.0,
                            ),
                            // Soft contact occlusion directly underneath
                            BoxShadow(
                              color: const Color.fromRGBO(10, 6, 30, 0.06),
                              blurRadius: 14.0,
                              offset: Offset(
                                shadowDx * 0.3,
                                14.0 + shadowDy * 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // =========================================================
                    // 2. Translucent Crystal Glass Cylinder Hull
                    // =========================================================
                    Positioned(
                      top: fgDy,
                      left: (screenWidth - barWidth) * 0.5 + fgDx,
                      width: barWidth,
                      height: barHeight,
                      child: CustomPaint(
                        painter: _CrystalCylinderPainter(
                          tilt: tilt,
                          width: barWidth,
                          height: barHeight,
                        ),
                      ),
                    ),

                    // =========================================================
                    // 3. Forced-Perspective Deep Graphite Icons (Artifact-Free)
                    // =========================================================
                    Positioned(
                      top: fgDy,
                      left: (screenWidth - barWidth) * 0.5 + fgDx,
                      width: barWidth,
                      height: barHeight,
                      child: Row(
                        mainAxisAlignment: .spaceEvenly,
                        children: [
                          for (int i = 0; i < _symbols.length; i++)
                            _SpatialFlushedIcon(
                              index: i,
                              total: _symbols.length,
                              tilt: tilt,
                              isPressed: _pressedIndex == i,
                              onTapDown: () =>
                                  setState(() => _pressedIndex = i),
                              onTapUp: () {
                                setState(() => _pressedIndex = null);
                                widget.onNavAction(_symbols[i]);
                              },
                              onTapCancel: () =>
                                  setState(() => _pressedIndex = null),
                              child: widget.iconBuilder != null
                                  ? widget.iconBuilder!(
                                      _symbols[i],
                                      _pressedIndex == i,
                                    )
                                  : _defaultIcon(
                                      _symbols[i],
                                      _pressedIndex == i,
                                    ),
                            ),
                        ],
                      ),
                    ),

                    // =========================================================
                    // 4. Geodesic Tapered Specular Glaze (No 2D Sharp Cuts)
                    // =========================================================
                    Positioned(
                      top: fgDy,
                      left: (screenWidth - barWidth) * 0.5 + fgDx,
                      width: barWidth,
                      height: barHeight,
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _ConvexApertureGlazePainter(
                            tilt: tilt,
                            width: barWidth,
                            height: barHeight,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Paints the light-theme translucent crystal cylinder with chiseled double bevels.
class _CrystalCylinderPainter extends CustomPainter {
  const _CrystalCylinderPainter({
    required this.tilt,
    required this.width,
    required this.height,
  });

  final (double x, double y) tilt;
  final double width;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    final r = height * 0.5;
    final rect = Offset.zero & Size(width, height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(r));

    // 1. Crystal Translucent Glass Body (Off-white / crystal gradient)
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-tilt.$1 * 0.25, -1.0),
        end: Alignment(tilt.$1 * 0.25, 1.0),
        colors: const [
          Color.fromRGBO(255, 255, 255, 0.48), // Bright reflective crest
          Color.fromRGBO(244, 244, 250, 0.18), // High-transmission core
          Color.fromRGBO(234, 234, 244, 0.35), // Subtle optical density base
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, bodyPaint);

    // 2. Gleaming Specular Outer Bevel (Direction-aligned highlight)
    final outerBevelPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment(tilt.$1 * 1.4, tilt.$2 * 1.2 - 0.7),
        end: Alignment(-tilt.$1 * 1.4, -tilt.$2 * 1.2 + 0.7),
        colors: const [
          Color.fromRGBO(255, 255, 255, 0.95), // Direct highlight
          Color.fromRGBO(255, 255, 255, 0.40),
          Color.fromRGBO(195, 190, 215, 0.35), // Refraction side
          Color.fromRGBO(255, 255, 255, 0.20),
        ],
        stops: const [0.0, 0.35, 0.75, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, outerBevelPaint);

    // 3. Inner Chiseled Ridge (Deep cut-crystal chamfer)
    final innerRRect = RRect.fromRectAndRadius(
      rect.deflate(1.4),
      Radius.circular(r - 1.4),
    );

    final innerBevelPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = LinearGradient(
        begin: Alignment(-tilt.$1 * 1.2, -tilt.$2 * 1.2 - 0.5),
        end: Alignment(tilt.$1 * 1.2, tilt.$2 * 1.2 + 0.5),
        colors: const [
          Color.fromRGBO(255, 255, 255, 0.65),
          Color.fromRGBO(255, 255, 255, 0.10),
          Color.fromRGBO(180, 175, 205, 0.25),
        ],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(rect);

    canvas.drawRRect(innerRRect, innerBevelPaint);
  }

  @override
  bool shouldRepaint(covariant _CrystalCylinderPainter old) =>
      old.tilt.$1 != tilt.$1 || old.tilt.$2 != tilt.$2;
}

/// Paints a geodesic tapered specular glare that wraps smoothly around the hemispherical caps.
/// Eliminates 2D sharp horizontal and vertical cuts with 360° Gaussian falloff.
class _ConvexApertureGlazePainter extends CustomPainter {
  const _ConvexApertureGlazePainter({
    required this.tilt,
    required this.width,
    required this.height,
  });

  final (double x, double y) tilt;
  final double width;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    final r = height * 0.5;
    final specCenterY = (height * 0.30) - (tilt.$2 * (height * 0.20));
    const hHalf = 7.0;

    final leftCap = r * 0.7;
    final rightCap = width - (r * 0.7);

    // Geodesic Tapered Lens Path: tapers smoothly into the hemispherical domes
    final lensPath = Path()
      ..moveTo(leftCap, specCenterY)
      ..cubicTo(
        leftCap,
        specCenterY - hHalf,
        r,
        specCenterY - hHalf,
        width * 0.5,
        specCenterY - hHalf,
      )
      ..cubicTo(
        width - r,
        specCenterY - hHalf,
        rightCap,
        specCenterY - hHalf,
        rightCap,
        specCenterY,
      )
      ..cubicTo(
        rightCap,
        specCenterY + hHalf,
        width - r,
        specCenterY + hHalf,
        width * 0.5,
        specCenterY + hHalf,
      )
      ..cubicTo(
        r,
        specCenterY + hHalf,
        leftCap,
        specCenterY + hHalf,
        leftCap,
        specCenterY,
      )
      ..close();

    // Bi-Axial Gaussian Radial Gradient: 360° seamless falloff
    final glazeCenter = Offset(
      (width * 0.5) + (tilt.$1 * (width * 0.20)),
      specCenterY,
    );

    final glazeRect = Rect.fromCenter(
      center: glazeCenter,
      width: width * 0.85,
      height: hHalf * 3.0,
    );

    final glazePaint = Paint()
      ..shader = RadialGradient(
        radius: 0.90,
        colors: const [
          Color.fromRGBO(255, 255, 255, 0.70), // Crisp white crest
          Color.fromRGBO(255, 255, 255, 0.28),
          Color.fromRGBO(255, 255, 255, 0.0), // Seamless fade
        ],
        stops: const [0.0, 0.40, 1.0],
      ).createShader(glazeRect);

    canvas.drawPath(lensPath, glazePaint);
  }

  @override
  bool shouldRepaint(covariant _ConvexApertureGlazePainter old) =>
      old.tilt.$1 != tilt.$1 || old.tilt.$2 != tilt.$2;
}

/// Forced-perspective deep graphite icon with differential scaling,
/// anisotropic pitch foreshortening, and zero rectangular container box shadows.
class _SpatialFlushedIcon extends StatelessWidget {
  const _SpatialFlushedIcon({
    required this.index,
    required this.total,
    required this.tilt,
    required this.isPressed,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
    required this.child,
  });

  final int index;
  final int total;
  final (double x, double y) tilt;
  final bool isPressed;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final VoidCallback onTapCancel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double u = (index - ((total - 1) * 0.5)) / ((total - 1) * 0.5);

    // 1. Differential Sizing (Roll Parallax)
    final double rollScale = 1.0 + (u * tilt.$1 * 0.07);

    // 2. Anisotropic Pitch Foreshortening
    final double pitchScaleY = math.cos(tilt.$2 * 0.45).clamp(0.88, 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: () => onTapCancel(),
      child: AnimatedScale(
        scale: isPressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Transform(
          alignment: .center,
          transform: Matrix4.identity()
            ..scale(rollScale, rollScale * pitchScaleY, 1.0),
          // Clean, unencumbered container: ZERO square box-shadow artifacts
          child: Container(
            width: 42,
            height: 42,
            alignment: .center,
            // 3. Convex Luminance Mask: Deep graphite with physical curvature shading
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) {
                final crestY = 0.35 - (tilt.$2 * 0.25);
                return LinearGradient(
                  begin: Alignment(0.0, -1.0 + crestY),
                  end: Alignment(0.0, 1.0 + crestY),
                  colors: isPressed
                      ? const [
                          Color.fromRGBO(72, 0, 255, 1.0),
                          Color.fromRGBO(90, 20, 255, 1.0),
                          Color.fromRGBO(55, 0, 220, 1.0),
                        ]
                      : const [
                          Color.fromRGBO(38, 34, 46, 0.90), // Receding top
                          Color.fromRGBO(
                            18,
                            16,
                            24,
                            0.95,
                          ), // Convex crest (deep obsidian graphite)
                          Color.fromRGBO(
                            62,
                            58,
                            74,
                            0.85,
                          ), // Receding bottom reflection
                        ],
                  stops: const [0.0, 0.42, 1.0],
                ).createShader(bounds);
              },
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
