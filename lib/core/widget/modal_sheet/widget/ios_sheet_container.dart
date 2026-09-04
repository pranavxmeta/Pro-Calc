import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../model/ios_sheet_options.dart';
import '../theme/ios_sheet_tokens.dart';

/// Interactive draggable card container featuring real-time frosted glass
/// and specular border reflections.
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
  late final AnimationController _dragController;
  double _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _dragController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _dragController.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!widget.options.enableDrag) return;
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dy).clamp(
        0.0,
        double.infinity,
      );
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (!widget.options.enableDrag) return;
    final velocity = details.primaryVelocity ?? 0.0;

    // Fast fling down or dragged > 120 pixels dismisses the sheet
    if (velocity > 750.0 || _dragOffset > 120.0) {
      Navigator.of(context).pop();
    } else {
      // Spring back to base position
      final springAnimation = Tween<double>(begin: _dragOffset, end: 0.0)
          .animate(
            CurvedAnimation(
              parent: _dragController,
              curve: IosSheetTokens.entryCurve,
            ),
          );

      _dragController.forward(from: 0.0);
      springAnimation.addListener(() {
        setState(() => _dragOffset = springAnimation.value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom;
    final paddingBottom = media.padding.bottom;

    final baseRadius = Radius.circular(widget.options.cornerRadius);
    final sheetBorderRadius = BorderRadius.all(baseRadius);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Transform.translate(
        offset: Offset(0.0, _dragOffset),
        child: GestureDetector(
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              widget.options.floatingMargin,
              0.0,
              widget.options.floatingMargin,
              widget.options.floatingMargin + bottomInset,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: widget.options.maxWidth),
              child: ClipRRect(
                borderRadius: sheetBorderRadius,
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: IosSheetTokens.blurSigmaX,
                    sigmaY: IosSheetTokens.blurSigmaY,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: widget.options.surfaceColor,
                      borderRadius: sheetBorderRadius,
                      border: Border.all(
                        strokeAlign: BorderSide.strokeAlignInside,
                        width: 1.2,
                        color: IosSheetTokens.borderGlowLight,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.options.showGrabber)
                          const _IosSheetGrabber(),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: paddingBottom > 0 ? paddingBottom : 12.0,
                            ),
                            child: widget.child,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _IosSheetGrabber extends StatelessWidget {
  const _IosSheetGrabber();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24.0,
      child: Center(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: IosSheetTokens.grabberColor,
            borderRadius: BorderRadius.all(Radius.circular(999.0)),
          ),
          child: SizedBox.fromSize(size: IosSheetTokens.grabberSize),
        ),
      ),
    );
  }
}
