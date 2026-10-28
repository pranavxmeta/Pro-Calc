import 'package:flutter/widgets.dart';

import '../model/ios_sheet_options.dart';
import '../theme/ios_sheet_tokens.dart';
import 'ios_sheet_container.dart';

/// Pure Core `PopupRoute` managing modal transition mechanics.
///
/// Uses pure hardware-accelerated slide translation without redundant
/// FadeTransition alpha blending.
final class IosSheetRoute<T> extends PopupRoute<T> {
  IosSheetRoute({required this.builder, required this.options, super.settings});

  final WidgetBuilder builder;
  final IosSheetOptions options;

  @override
  Duration get transitionDuration => IosSheetTokens.animDuration;

  @override
  bool get barrierDismissible => options.isDismissible;

  @override
  Color? get barrierColor => null;

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
    // Pure iOS ease-out deceleration curve
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: const Cubic(0.22, 1.0, 0.36, 1.0),
      reverseCurve: IosSheetTokens.exitCurve,
    );

    final offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(curvedAnimation);

    // Stripped of FadeTransition to prevent double GPU alpha compositing
    return SlideTransition(position: offsetAnimation, child: child);
  }

  @override
  Widget buildModalBarrier() {
    if (!barrierDismissible) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: animation!,
      builder: (context, _) {
        final opacity = animation!.value * options.barrierColor.a;
        return GestureDetector(
          onTap: () {
            if (options.isDismissible) Navigator.of(context).pop();
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: options.barrierColor.withValues(alpha: opacity),
          ),
        );
      },
    );
  }
}
