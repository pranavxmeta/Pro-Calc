import 'package:flutter/widgets.dart';

import '../theme/ios_sheet_tokens.dart';

/// Configuration options for the iOS 26 modal popup presentation.
final class IosSheetOptions {
  const IosSheetOptions({
    this.isDismissible = true,
    this.enableDrag = true,
    this.showGrabber = true,
    this.useRootNavigator = true,
    this.barrierBlur = true,
    this.maxWidth = IosSheetTokens.maxContentWidth,
    this.floatingMargin = IosSheetTokens.defaultFloatingMargin,
    this.cornerRadius = IosSheetTokens.cornerRadius,
    this.surfaceColor = IosSheetTokens.surfaceColor,
    this.barrierColor = IosSheetTokens.barrierColor,
    this.traversalEdgeBehavior = TraversalEdgeBehavior.leaveFlutterView,
  });

  final bool isDismissible;
  final bool enableDrag;
  final bool showGrabber;
  final bool useRootNavigator;
  final bool barrierBlur;
  final double maxWidth;
  final double floatingMargin;
  final double cornerRadius;
  final Color surfaceColor;
  final Color barrierColor;
  final TraversalEdgeBehavior traversalEdgeBehavior;
}
