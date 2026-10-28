import 'package:flutter/widgets.dart';

import '../../../core/widget/modal_sheet/model/ios_sheet_options.dart';
import '../../../core/widget/modal_sheet/utils/ios_sheet_extension.dart';
import '../model/calculation_history.dart';
import '../screen.dart';

/// Global presentation entry-point decoupling history from CalcPage.
/// Callable from any screen, drawer, or settings modal in the app.
Future<void> showHistorySheet(
  BuildContext context, {
  List<CalculationHistory>? history,
  required ValueChanged<String> onExpressionTap,
  VoidCallback? onClear,
  double heightFactor = 0.65,
}) {
  return context.showIosSheet<void>(
    options: const IosSheetOptions(),
    builder: (modalContext) => SizedBox(
      height: MediaQuery.sizeOf(modalContext).height * heightFactor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: HistoryPage(
            onExpressionTap: (result) {
              onExpressionTap(result);
              Navigator.of(modalContext).pop();
            },
            onClear: onClear != null
                ? () {
                    onClear();
                    Navigator.of(modalContext).pop();
                  }
                : null,
          ),
        ),
      ),
    ),
  );
}
