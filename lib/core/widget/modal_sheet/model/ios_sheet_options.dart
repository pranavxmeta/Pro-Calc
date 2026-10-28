import 'package:flutter/widgets.dart';

import '../theme/ios_sheet_tokens.dart';

/// Configuration options for the frosted glass modal sheet.
/// Uses Dart 3.13 primary constructor.
final class const IosSheetOptions({
  final bool isDismissible = true,
  final bool enableDrag = true,
  final bool useRootNavigator = true,
  final double maxWidth = IosSheetTokens.maxContentWidth,
  final double floatingMargin = IosSheetTokens.defaultFloatingMargin,
  final double cornerRadius = IosSheetTokens.cornerRadius,
  final Color barrierColor = IosSheetTokens.barrierColor,
  final TraversalEdgeBehavior traversalEdgeBehavior =
      TraversalEdgeBehavior.leaveFlutterView,
});
