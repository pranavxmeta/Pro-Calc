import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Minimalist iOS input bar with zero double-border clutter.
class const ConverterInputBar({
  super.key,
  required final TextEditingController controller,
  required final VoidCallback onHistoryTap,
  required final VoidCallback onPaste,
  required final VoidCallback onClear,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pillBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Container(
      padding: const .fromLTRB(14.0, 8.0, 14.0, 10.0),
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                FluentIcons.history_24_regular,
                color: Color(0xFF007FFF),
              ),
              tooltip: 'Calculation History',
              onPressed: onHistoryTap,
              style: IconButton.styleFrom(
                backgroundColor: pillBg,
                minimumSize: const Size(44.0, 44.0),
                shape: RoundedRectangleBorder(borderRadius: .circular(12.0)),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  final hasText = value.text.isNotEmpty;

                  return Container(
                    height: 44.0,
                    padding: const .symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: .circular(12.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            autofocus: false,
                            keyboardType: const .numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            style: TextStyle(
                              fontFamily: 'RedditSans',
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1C1C1E),
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Enter value',
                              hintStyle: TextStyle(
                                fontFamily: 'RedditSans',
                                fontSize: 16.0,
                                color: Color(0xFF8E8E93),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: .zero,
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: hasText ? onClear : onPaste,
                          child: Padding(
                            padding: const .only(left: 6.0),
                            child: Icon(
                              hasText
                                  ? FluentIcons.dismiss_24_regular
                                  : FluentIcons.clipboard_paste_24_regular,
                              size: 19.0,
                              color: const Color(0xFF007FFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
