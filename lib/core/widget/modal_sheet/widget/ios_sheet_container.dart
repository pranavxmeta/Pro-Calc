import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../model/ios_sheet_options.dart';
import '../theme/ios_sheet_tokens.dart';

/// Interactive draggable frosted glass container.
///
/// Features dynamic blur ramp-up driven by the entrance animation
/// (0.0ms initial GPU blur cost) and matrix-only translation dragging.
final class IosSheetContainer extends StatefulWidget {
  const IosSheetContainer({
    required this.child,
    required this.options,
    required this.animation,
    super.key,
  });

  final Widget child;
  final IosSheetOptions options;
  final Animation<double> animation;

  @override
  State<IosSheetContainer> createState() => _IosSheetContainerState();
}

final class _IosSheetContainerState extends State<IosSheetContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _springController;
  final ValueNotifier<double> _dragOffsetNotifier = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
  }

  @override
  void dispose() {
    _springController.dispose();
    _dragOffsetNotifier.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!widget.options.enableDrag) return;
    final current = _dragOffsetNotifier.value;
    final next = (current + details.delta.dy).clamp(0.0, double.infinity);
    if (current != next) {
      _dragOffsetNotifier.value = next;
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (!widget.options.enableDrag) return;
    final velocity = details.primaryVelocity ?? 0.0;
    final currentOffset = _dragOffsetNotifier.value;

    if (velocity > 700.0 || currentOffset > 100.0) {
      Navigator.of(context).pop();
    } else {
      final springAnimation = Tween<double>(begin: currentOffset, end: 0.0)
          .animate(
            CurvedAnimation(
              parent: _springController,
              curve: IosSheetTokens.entryCurve,
            ),
          );

      _springController.forward(from: 0.0);

      void listener() {
        _dragOffsetNotifier.value = springAnimation.value;
        if (springAnimation.isCompleted) {
          _springController.removeListener(listener);
        }
      }

      _springController.addListener(listener);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom;
    final paddingBottom = media.padding.bottom;

    final resolvedRadius = widget.options.cornerRadius > 0.0
        ? widget.options.cornerRadius
        : 1.0;
    final sheetBorderRadius = BorderRadius.circular(resolvedRadius);

    final glassColors = isDark
        ? IosSheetTokens.surfaceDark
        : IosSheetTokens.surfaceLight;
    final borderColor = isDark
        ? IosSheetTokens.borderDark
        : IosSheetTokens.borderLight;

    return Material(
      type: MaterialType.transparency,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ValueListenableBuilder<double>(
          valueListenable: _dragOffsetNotifier,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              widget.options.floatingMargin,
              0.0,
              widget.options.floatingMargin,
              widget.options.floatingMargin + bottomInset,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: widget.options.maxWidth),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: sheetBorderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? const Color.fromRGBO(0, 0, 0, 0.40)
                          : const Color.fromRGBO(0, 0, 0, 0.06),
                      blurRadius: 20.0,
                      offset: const Offset(0.0, 8.0),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                // AnimatedBuilder ramps blur from 0.0 to target alongside the entrance curve
                child: AnimatedBuilder(
                  animation: widget.animation,
                  builder: (context, staticContent) {
                    final ramp = widget.animation.value;
                    final sigma = (ramp * IosSheetTokens.blurSigmaX).clamp(
                      0.0,
                      32.0,
                    );

                    return BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                      child: staticContent,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: sheetBorderRadius,
                      border: Border.all(
                        width: IosSheetTokens.borderWidth,
                        color: borderColor,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: glassColors,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 16.0,
                        bottom: paddingBottom > 0 ? paddingBottom : 16.0,
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
          builder: (context, dragOffset, cachedChild) {
            return Transform.translate(
              offset: Offset(0.0, dragOffset),
              child: GestureDetector(
                onVerticalDragUpdate: _onVerticalDragUpdate,
                onVerticalDragEnd: _onVerticalDragEnd,
                behavior: HitTestBehavior.opaque,
                child: cachedChild,
              ),
            );
          },
        ),
      ),
    );
  }
}
