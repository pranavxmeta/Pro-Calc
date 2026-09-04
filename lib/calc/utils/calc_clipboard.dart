import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../core/widget/apptoast/apptoast.dart';

/// Clipboard validation and transfer helper.
final class CalcClipboard {
  const CalcClipboard._();

  static final RegExp _validChars = RegExp(
    r'^[0-9,\.\+\-*/×÷%^()\s]*(sin|cos|tan|log|ln|sqrt|π|e|X|Y)?$',
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
      context.appToast('Clipboard is empty', type: ToastType.warning);
      return null;
    }

    if (!_validChars.hasMatch(text)) {
      context.appToast(
        'Invalid characters in clipboard',
        type: ToastType.error,
      );
      return null;
    }

    for (final pattern in _invalidPatterns) {
      if (pattern.hasMatch(text)) {
        context.appToast('Invalid expression format', type: ToastType.error);
        return null;
      }
    }

    return text.replaceAll(' ', '');
  }

  static Future<void> copy(BuildContext context, String text) async {
    if (text.isNotEmpty && text != 'Error' && !text.contains('Infinity')) {
      await Clipboard.setData(ClipboardData(text: text));
      if (!context.mounted) return;
      context.appToast('Answer copied to clipboard', type: ToastType.info);
    } else {
      context.appToast('No valid answer to copy', type: ToastType.error);
    }
  }
}
