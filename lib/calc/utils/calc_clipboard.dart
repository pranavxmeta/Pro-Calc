import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:apptoast/apptoast.dart';

/// Clipboard validation and transfer helper.
final class CalcClipboard {
  const CalcClipboard._();

  static final RegExp _validChars = RegExp(
    r'^[0-9,\.\+\-*/×÷%^()\s]*(sin|cos|tan|asin|acos|atan|log|ln|sqrt|cbrt|π|e|X|Y|x|y)?$',
  );

  static final List<RegExp> _invalidPatterns = [
    RegExp(r'[+*\/×÷%^]{2,}'),
    RegExp(r'[-]{3,}'),
    RegExp(r'[\.]{2,}'),
  ];

  static Future<String?> getValidatedClipboardText(BuildContext context) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!context.mounted) return null;

    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) {
      AppToast.warning(context, 'Clipboard is empty');
      return null;
    }

    if (!_validChars.hasMatch(text)) {
      AppToast.error(context, 'Invalid characters in clipboard');
      return null;
    }

    for (final pattern in _invalidPatterns) {
      if (pattern.hasMatch(text)) {
        AppToast.error(context, 'Invalid expression format');
        return null;
      }
    }

    return text.replaceAll(' ', '');
  }

  /// Copies text to clipboard. Returns `true` on success without showing a toast,
  /// allowing caller UI widgets to display animated confirmation.
  static Future<bool> copy(BuildContext context, String text) async {
    if (text.isNotEmpty && text != 'Error' && !text.contains('Infinity')) {
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    }
    if (!context.mounted) return false;
    AppToast.error(context, 'No valid answer to copy');
    return false;
  }
}
