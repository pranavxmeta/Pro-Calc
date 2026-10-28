import 'package:flutter/widgets.dart';

import '../../core/widget/modal_sheet/model/ios_sheet_options.dart';
import '../../core/widget/modal_sheet/utils/ios_sheet_extension.dart';
import '../screen/tools_screen.dart';

/// Global presentation entry-point decoupling Tools from any parent page.
///
/// Presents the tools hub as a modal sheet with liquid frosted glass styling.
Future<void> showToolsSheet(
  BuildContext context, {
  double heightFactor = 0.55,
}) {
  return context.showIosSheet<void>(
    options: const IosSheetOptions(),
    builder: (modalContext) => SizedBox(
      height: MediaQuery.sizeOf(modalContext).height * heightFactor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: ToolsScreen(isModal: true),
        ),
      ),
    ),
  );
}
