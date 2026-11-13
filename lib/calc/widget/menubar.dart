import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';

typedef ToolbarAction = ({IconData icon, String tooltip, VoidCallback? onTap});

class const CalcMenubar({
  super.key,
  final bool isCompact = false,
  final bool isVerticalMode = false,
  final bool isReducedKeypad = false,
  final VoidCallback? onToggleVertical,
  final VoidCallback? onToggleReducedKeypad,
  final Future<bool> Function()? onCopy,
  final VoidCallback? onPaste,
  final VoidCallback? onToolbox,
  final List<ToolbarAction>? customButtons,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    final size = isCompact ? 34.0 : 40.0;
    final iconSize = isCompact ? 18.0 : 22.0;

    final actions =
        customButtons ??
        [
          if (onPaste != null)
            (
              icon: FluentIcons.clipboard_paste_24_regular,
              tooltip: 'Paste',
              onTap: onPaste,
            ),
          if (onToolbox != null)
            (
              icon: FluentIcons.toolbox_24_regular,
              tooltip: 'Toolbox',
              onTap: onToolbox,
            ),
        ];

    return Container(
      alignment: .centerLeft,
      padding: const .symmetric(horizontal: 4.0, vertical: 2.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: .min,
          children: [
            if (onCopy != null)
              _CopyButton(
                onCopy: onCopy!,
                color: color,
                size: size,
                iconSize: iconSize,
              ),

            // Button 1: Toggle Keypad Matrix (5x7 Scientific <-> 4x5 Basic)
            if (onToggleReducedKeypad != null) ...[
              const SizedBox(width: 4.0),
              IconButton(
                icon: Icon(
                  FluentIcons.table_simple_24_regular,
                  size: iconSize,
                  color: isReducedKeypad ? theme.colorScheme.primary : color,
                ),
                tooltip: isReducedKeypad
                    ? 'Full Scientific Matrix'
                    : 'Basic 4x5 Keypad',
                onPressed: onToggleReducedKeypad,
                style: IconButton.styleFrom(
                  backgroundColor: isReducedKeypad
                      ? theme.colorScheme.primary.withValues(alpha: 0.14)
                      : Colors.transparent,
                  minimumSize: Size(size, size),
                  padding: .zero,
                ),
              ),
            ],

            // Button 2: Toggle Tape Mode (Single-line <-> Vertical Ledger)
            if (onToggleVertical != null) ...[
              const SizedBox(width: 4.0),
              IconButton(
                icon: Icon(
                  FluentIcons.arrow_sort_down_lines_24_regular,
                  size: iconSize,
                  color: isVerticalMode ? theme.colorScheme.primary : color,
                ),
                tooltip: isVerticalMode
                    ? 'Standard Mode'
                    : 'Vertical Entry Mode',
                onPressed: onToggleVertical,
                style: IconButton.styleFrom(
                  backgroundColor: isVerticalMode
                      ? theme.colorScheme.primary.withValues(alpha: 0.14)
                      : Colors.transparent,
                  minimumSize: Size(size, size),
                  padding: .zero,
                ),
              ),
            ],

            for (final btn in actions) ...[
              const SizedBox(width: 4.0),
              IconButton(
                icon: Icon(btn.icon, size: iconSize, color: color),
                tooltip: btn.tooltip,
                onPressed: btn.onTap,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  minimumSize: Size(size, size),
                  padding: .zero,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class const _CopyButton({
  required final Future<bool> Function() onCopy,
  required final Color color,
  required final double size,
  required final double iconSize,
}) extends StatefulWidget {
  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _tap() async {
    if (await widget.onCopy() && mounted) {
      Feedback.forTap(context);
      setState(() => _copied = true);
      _timer?.cancel();
      _timer = Timer(
        const Duration(milliseconds: 1500),
        () => mounted ? setState(() => _copied = false) : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: _copied ? 'Copied!' : 'Copy',
    onPressed: _tap,
    style: IconButton.styleFrom(
      backgroundColor: Colors.transparent,
      minimumSize: Size(widget.size, widget.size),
      padding: .zero,
    ),
    icon: AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: anim,
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: Icon(
        _copied
            ? FluentIcons.checkmark_24_regular
            : FluentIcons.copy_24_regular,
        key: ValueKey(_copied),
        size: widget.iconSize,
        color: _copied ? Theme.of(context).colorScheme.primary : widget.color,
      ),
    ),
  );
}
