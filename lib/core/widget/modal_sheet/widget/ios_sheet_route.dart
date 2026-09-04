import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../model/ios_sheet_options.dart';
import '../theme/ios_sheet_tokens.dart';
import 'ios_sheet_container.dart';

/// Pure Core `PopupRoute` managing modal transition and dismissal mechanics.
final class IosSheetRoute<T> extends PopupRoute<T> {
  IosSheetRoute({required this.builder, required this.options, super.settings});

  final WidgetBuilder builder;
  final IosSheetOptions options;

  @override
  Duration get transitionDuration => IosSheetTokens.animDuration;

  @override
  bool get barrierDismissible => options.isDismissible;

  @override
  Color? get barrierColor => null; // Handled directly in custom barrier builder

  @override
  String? get barrierLabel => 'Dismiss Sheet';

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: IosSheetContainer(
        animation: animation,
        options: options,
        child: builder(context),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: IosSheetTokens.entryCurve,
      reverseCurve: IosSheetTokens.exitCurve,
    );

    // Slide up transition paired with soft fade
    final offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(curvedAnimation);

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curvedAnimation);

    return SlideTransition(
      position: offsetAnimation,
      child: FadeTransition(opacity: fadeAnimation, child: child),
    );
  }

  @override
  Widget buildModalBarrier() {
    if (!barrierDismissible) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: animation!,
      builder: (context, _) {
        final opacity = animation!.value * options.barrierColor.opacity;
        return GestureDetector(
          onTap: () {
            if (options.isDismissible) Navigator.of(context).pop();
          },
          behavior: HitTestBehavior.opaque,
          child: BackdropFilter(
            filter: options.barrierBlur
                ? ui.ImageFilter.blur(
                    sigmaX: animation!.value * 8.0,
                    sigmaY: animation!.value * 8.0,
                  )
                : ui.ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
            child: Container(
              color: options.barrierColor.withValues(alpha: opacity),
            ),
          ),
        );
      },
    );
  }
}
