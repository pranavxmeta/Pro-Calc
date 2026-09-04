import 'package:flutter/widgets.dart';

import '../model/ios_sheet_options.dart';
import '../widget/ios_sheet_route.dart';

/// Global invocation extension and helper for presenting the iOS 26 Modal Sheet.
extension IosSheetContextExtension on BuildContext {
  /// Presents an iOS 26 modal popup bottom sheet wrapping any page/widget.
  Future<T?> showIosSheet<T>({
    required WidgetBuilder builder,
    IosSheetOptions options = const IosSheetOptions(),
    RouteSettings? settings,
  }) {
    return Navigator.of(this, rootNavigator: options.useRootNavigator).push<T>(
      IosSheetRoute<T>(builder: builder, options: options, settings: settings),
    );
  }
}

/// Static invocation facade for imperative call-sites.
abstract final class IosModalSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    IosSheetOptions options = const IosSheetOptions(),
    RouteSettings? settings,
  }) {
    return context.showIosSheet<T>(
      builder: builder,
      options: options,
      settings: settings,
    );
  }
}
